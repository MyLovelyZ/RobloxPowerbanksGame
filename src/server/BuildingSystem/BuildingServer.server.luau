--[[
	BuildingServer
	- Membuat RemoteEvent + folder yang dibutuhkan (jika belum ada)
	- Menerima permintaan place dari client, lalu MEMVALIDASI ULANG semuanya
	  di server supaya tidak bisa di-exploit:
	  1. Player hanya boleh build di PLOT MILIKNYA sendiri (cek Owner dari PlotSystem)
	  2. Posisi di-snap ulang ke grid BuildArea milik plot itu
	  3. Harus di dalam BuildArea
	  4. Tidak boleh tabrakan dengan item yang sudah dipasang / rumah (Bangunan)
	  5. Player tidak boleh terlalu jauh dari titik build

	AREA BUILD:
	- Memakai plot > Building > Bawah<level> (sama dengan spawn point bangunan
	  yang dipakai BuildingLoader). Level diambil dari PlayerData.PlotLevel.
	- Folder "PlacedItems" di dalam plot dibuat otomatis oleh script ini.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuildingSystem = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("BuildingSystem")
local BuildConfig = require(BuildingSystem:WaitForChild("BuildConfig"))
local GridUtil = require(BuildingSystem:WaitForChild("GridUtil"))
local PlotUtil = require(BuildingSystem:WaitForChild("PlotUtil"))

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

-- Siapkan folder PlacedItems di setiap plot + peringatan kalau BuildArea belum ada
local plotsFolder = PlotUtil.getPlotsFolder()

local function setupPlot(plot: Instance)
	getOrCreate(plot, BuildConfig.PLACED_FOLDER_NAME, "Folder")

	if not PlotUtil.getBuildArea(plot, 1) then
		warn("[BuildingServer] Plot '" .. plot.Name .. "' belum punya '"
			.. BuildConfig.BUILDING_FOLDER_NAME .. " > " .. BuildConfig.BUILD_AREA_PREFIX
			.. "1'. Player di plot ini tidak bisa build.")
	end
end

for _, plot in plotsFolder:GetChildren() do
	setupPlot(plot)
end
plotsFolder.ChildAdded:Connect(setupPlot)

--------------------------------------------------------------------
-- Setup item contoh — hanya jika folder item masih kosong
--------------------------------------------------------------------

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

if #itemsFolder:GetChildren() == 0 then
	makeSampleItem("Kotak_1x1", Vector3.new(4, 4, 4), Color3.fromRGB(230, 180, 80))
	makeSampleItem("Balok_2x1", Vector3.new(8, 4, 4), Color3.fromRGB(120, 160, 230))
end

--------------------------------------------------------------------
-- Validasi & penempatan
--------------------------------------------------------------------

placeRemote.OnServerEvent:Connect(function(player, itemName, targetPos, rotationY)
	-- Validasi tipe data dari client
	if typeof(itemName) ~= "string" or typeof(targetPos) ~= "Vector3" or typeof(rotationY) ~= "number" then
		return
	end

	local template = itemsFolder:FindFirstChild(itemName)
	if not template or not template:IsA("Model") then
		return
	end

	-- Player hanya boleh build di plot miliknya sendiri
	local plot = PlotUtil.getPlayerPlot(player)
	if not plot then
		return
	end

	local area = PlotUtil.getBuildArea(plot, PlotUtil.getPlotLevel(player))
	if not area then
		return
	end

	local placedFolder = getOrCreate(plot, BuildConfig.PLACED_FOLDER_NAME, "Folder")

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

	-- Harus di dalam BuildArea milik plot ini
	if not GridUtil.isInsideArea(area, snapped, bbSize, rotationY) then
		return
	end

	-- Tidak boleh tabrakan dengan item yang sudah dipasang / rumah di plot ini
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = PlotUtil.getCollisionInstances(plot)

	local overlapping = workspace:GetPartBoundsInBox(snapped, bbSize * 0.98, overlapParams)
	if #overlapping > 0 then
		return
	end

	-- Semua valid -> pasang item ke plot player
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

--------------------------------------------------------------------
-- Bersihkan hasil build saat player keluar
-- (pakai PlotNumber karena Owner mungkin sudah dikosongkan PlotLoader)
--------------------------------------------------------------------

Players.PlayerRemoving:Connect(function(player)
	local plotNumber = player:FindFirstChild("PlotNumber")
	if not plotNumber then
		return
	end

	local plot = PlotUtil.getPlotByNumber(plotNumber.Value)
	if not plot then
		return
	end

	local placedFolder = PlotUtil.getPlacedFolder(plot)
	if placedFolder then
		placedFolder:ClearAllChildren()
	end
end)
