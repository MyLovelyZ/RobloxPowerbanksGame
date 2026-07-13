--[[
	BuildingServer
	- Membuat RemoteEvent + folder yang dibutuhkan (jika belum ada)
	- Menerima permintaan place dari client, lalu MEMVALIDASI ULANG semuanya
	  di server (posisi snap, di dalam area, tidak tabrakan, jarak player)
	  supaya tidak bisa di-exploit.

	CATATAN: Blok "setup contoh" di bawah membuat BuildArea + 2 item contoh
	otomatis kalau belum ada, supaya sistem langsung bisa dites.
	Kalau kamu sudah punya area/item sendiri di Studio, blok itu tidak
	melakukan apa-apa (atau boleh kamu hapus).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuildingSystem = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("BuildingSystem")
local BuildConfig = require(BuildingSystem:WaitForChild("BuildConfig"))
local GridUtil = require(BuildingSystem:WaitForChild("GridUtil"))

--------------------------------------------------------------------
-- Setup folder & remote
--------------------------------------------------------------------

local function getOrCreate(parent: Instance, name: string, className: string): Instance
	local found = parent:FindFirstChild(name)
	if found then
		return found
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	return inst
end

local remotesFolder = getOrCreate(ReplicatedStorage, BuildConfig.REMOTES_FOLDER_NAME, "Folder")
local placeRemote = getOrCreate(remotesFolder, "PlaceItem", "RemoteEvent") :: RemoteEvent

local itemsFolder = getOrCreate(ReplicatedStorage, BuildConfig.ITEMS_FOLDER_NAME, "Folder")
local placedFolder = getOrCreate(workspace, BuildConfig.PLACED_FOLDER_NAME, "Folder")

--------------------------------------------------------------------
-- Setup contoh (BuildArea + item contoh) — hanya jika belum ada
--------------------------------------------------------------------

if not workspace:FindFirstChild(BuildConfig.BUILD_AREA_NAME) then
	local area = Instance.new("Part")
	area.Name = BuildConfig.BUILD_AREA_NAME
	area.Size = Vector3.new(64, 1, 64) -- kelipatan GRID_SIZE supaya kotak pas
	area.Position = Vector3.new(0, 0.5, 0)
	area.Anchored = true
	area.Color = Color3.fromRGB(90, 140, 90)
	area.Material = Enum.Material.Plastic
	area.TopSurface = Enum.SurfaceType.Studs -- visual kotak-kotak sederhana
	area.Parent = workspace
end

local function makeSampleItem(name: string, size: Vector3, color: Color3)
	if itemsFolder:FindFirstChild(name) then
		return
	end
	local model = Instance.new("Model")
	model.Name = name
	local part = Instance.new("Part")
	part.Name = "Body"
	part.Size = size
	part.Anchored = true
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = model
	model.PrimaryPart = part
	model.Parent = itemsFolder
end

-- Item contoh: 1 kotak (4x4) dan 2 kotak (8x4, untuk tes rotasi)
if #itemsFolder:GetChildren() == 0 then
	makeSampleItem("Kotak_1x1", Vector3.new(4, 4, 4), Color3.fromRGB(230, 180, 80))
	makeSampleItem("Balok_2x1", Vector3.new(8, 4, 4), Color3.fromRGB(120, 160, 230))
end

--------------------------------------------------------------------
-- Validasi & penempatan
--------------------------------------------------------------------

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = { placedFolder }

placeRemote.OnServerEvent:Connect(function(player, itemName, targetPos, rotationY)
	-- Validasi tipe data dari client
	if typeof(itemName) ~= "string" or typeof(targetPos) ~= "Vector3" or typeof(rotationY) ~= "number" then
		return
	end

	local template = itemsFolder:FindFirstChild(itemName)
	if not template or not template:IsA("Model") then
		return
	end

	local area = workspace:FindFirstChild(BuildConfig.BUILD_AREA_NAME)
	if not area or not area:IsA("BasePart") then
		return
	end

	-- Rapikan rotasi ke kelipatan ROTATION_STEP
	rotationY = (math.round(rotationY / BuildConfig.ROTATION_STEP) * BuildConfig.ROTATION_STEP) % 360

	-- Cek jarak player ke titik build
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if (root.Position - targetPos).Magnitude > BuildConfig.MAX_PLACE_DISTANCE + 10 then
		return
	end

	-- Hitung ulang posisi snap di server (jangan percaya CFrame dari client)
	local bbSize, pivotToBB = GridUtil.getModelBounds(template)
	local snapped = GridUtil.snapToGrid(area, targetPos, bbSize, rotationY)

	-- Harus di dalam area build
	if not GridUtil.isInsideArea(area, snapped, bbSize, rotationY) then
		return
	end

	-- Tidak boleh tabrakan dengan item lain yang sudah dipasang
	local overlapping = workspace:GetPartBoundsInBox(snapped, bbSize * 0.98, overlapParams)
	if #overlapping > 0 then
		return
	end

	-- Semua valid -> pasang item
	local clone = template:Clone()
	clone:PivotTo(snapped * pivotToBB:Inverse())
	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	clone:SetAttribute("Owner", player.UserId)
	clone.Parent = placedFolder
end)
