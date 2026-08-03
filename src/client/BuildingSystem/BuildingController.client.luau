--[[
	BuildingController (client)
	- Menampilkan preview "hantu" (ghost) item yang mengikuti mouse
	- Snap ke kotak grid di atas area build milik PLOT PLAYER SENDIRI
	  (plot > Building > Bawah<level>, mengikuti PlayerData.PlotLevel)
	- Hijau = boleh dipasang, Merah = tidak boleh
	  (di luar area / tabrakan dengan item terpasang atau rumah / kejauhan)
	- Kontrol: Klik Kiri = pasang, R = rotasi, X = batal

	CARA PAKAI DARI GUI KAMU:
	local signal = ReplicatedStorage:WaitForChild("BuildSelectItem")
	signal:Fire("Kotak_1x1") -- mulai mode build dengan item ini
	signal:Fire(nil)         -- keluar dari mode build
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local BuildingSystem = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("BuildingSystem")
local BuildConfig = require(BuildingSystem:WaitForChild("BuildConfig"))
local GridUtil = require(BuildingSystem:WaitForChild("GridUtil"))
local PlotUtil = require(BuildingSystem:WaitForChild("PlotUtil"))

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local placeRemote = ReplicatedStorage:WaitForChild(BuildConfig.REMOTES_FOLDER_NAME):WaitForChild("PlaceItem") :: RemoteEvent
local itemsFolder = ReplicatedStorage:WaitForChild(BuildConfig.ITEMS_FOLDER_NAME)

-- Signal untuk GUI (GUI kamu tinggal Fire signal ini, lihat komentar di atas)
local selectSignal = Instance.new("BindableEvent")
selectSignal.Name = BuildConfig.SELECT_SIGNAL_NAME
selectSignal.Parent = ReplicatedStorage

--------------------------------------------------------------------
-- Cari plot milik player (diklaim oleh PlotLoader di server)
--------------------------------------------------------------------

local plot: Instance? = nil

task.spawn(function()
	-- Tunggu PlotLoader selesai membagikan plot (PlotNumber dibuat & diisi di server)
	local plotNumber = player:WaitForChild("PlotNumber") :: IntValue
	while plotNumber.Value == 0 do
		plotNumber.Changed:Wait()
	end

	plot = PlotUtil.getPlotsFolder():WaitForChild(tostring(plotNumber.Value))
end)

-- Area build mengikuti level plot (Bawah1, Bawah2, ...), jadi dicari ulang
-- setiap kali dibutuhkan supaya otomatis pindah saat PlotLevel naik.
local function getMyBuildArea(): Instance?
	if not plot then
		return nil
	end
	return PlotUtil.getBuildArea(plot, PlotUtil.getPlotLevel(player))
end

--------------------------------------------------------------------
-- State mode build
--------------------------------------------------------------------

local currentItemName: string? = nil
local ghost: Model? = nil
local ghostHighlight: Highlight? = nil
local ghostSize = Vector3.zero
local ghostPivotToBB = CFrame.identity
local rotationY = 0
local lastTargetPos: Vector3? = nil
local lastValid = false
local renderConn: RBXScriptConnection? = nil

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

local function stopBuilding()
	currentItemName = nil
	lastTargetPos = nil
	lastValid = false
	if renderConn then
		renderConn:Disconnect()
		renderConn = nil
	end
	if ghost then
		ghost:Destroy()
		ghost = nil
	end
	ghostHighlight = nil
end

local function updateGhost()
	local area = getMyBuildArea()
	if not ghost or not plot or not area then
		lastValid = false
		return
	end

	-- Item terpasang + rumah (Bangunan) di plot ini dianggap penghalang
	local collisionInstances = PlotUtil.getCollisionInstances(plot)

	-- Raycast dari kamera ke arah mouse
	local mousePos = UserInputService:GetMouseLocation()
	local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	local exclude: { Instance } = { ghost }
	for _, inst in collisionInstances do
		table.insert(exclude, inst)
	end
	if player.Character then
		table.insert(exclude, player.Character)
	end
	rayParams.FilterDescendantsInstances = exclude

	local result = workspace:Raycast(ray.Origin, ray.Direction * 500, rayParams)
	if not result then
		-- Mouse tidak mengarah ke apa pun -> sembunyikan ghost
		ghost:PivotTo(CFrame.new(0, -10000, 0))
		lastValid = false
		return
	end

	lastTargetPos = result.Position
	local snapped = GridUtil.snapToGrid(area, result.Position, ghostSize, rotationY)
	ghost:PivotTo(snapped * ghostPivotToBB:Inverse())

	-- Cek valid: di dalam area plot sendiri, tidak tabrakan, dan tidak terlalu jauh
	local insideArea = GridUtil.isInsideArea(area, snapped, ghostSize, rotationY)

	overlapParams.FilterDescendantsInstances = collisionInstances
	local overlapping = #workspace:GetPartBoundsInBox(snapped, ghostSize * 0.98, overlapParams) > 0

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local inRange = root ~= nil and (root.Position - snapped.Position).Magnitude <= BuildConfig.MAX_PLACE_DISTANCE

	lastValid = insideArea and not overlapping and inRange

	if ghostHighlight then
		ghostHighlight.FillColor = lastValid and Color3.fromRGB(80, 220, 100) or Color3.fromRGB(230, 70, 70)
		ghostHighlight.OutlineColor = ghostHighlight.FillColor
	end
end

local function startBuilding(itemName: string)
	stopBuilding()

	if not getMyBuildArea() then
		warn("[BuildingController] Belum bisa build: plot atau area '"
			.. BuildConfig.BUILD_AREA_PREFIX .. "<level>' belum siap.")
		return
	end

	local template = itemsFolder:FindFirstChild(itemName)
	if not template or not template:IsA("Model") then
		warn("[BuildingController] Item tidak ditemukan di " .. BuildConfig.ITEMS_FOLDER_NAME .. ": " .. tostring(itemName))
		return
	end

	currentItemName = itemName
	rotationY = 0

	-- Buat ghost (ukuran diambil SEBELUM dirotasi)
	local newGhost = template:Clone()
	ghostSize, ghostPivotToBB = GridUtil.getModelBounds(newGhost)
	for _, part in newGhost:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = math.clamp(part.Transparency + 0.5, 0, 1)
		end
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.6
	highlight.OutlineTransparency = 0
	highlight.Parent = newGhost

	newGhost:PivotTo(CFrame.new(0, -10000, 0))
	newGhost.Parent = workspace

	ghost = newGhost
	ghostHighlight = highlight

	renderConn = RunService.RenderStepped:Connect(updateGhost)
end

--------------------------------------------------------------------
-- Input
--------------------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not currentItemName then
		return
	end

	if input.KeyCode == BuildConfig.KEY_ROTATE then
		rotationY = (rotationY + BuildConfig.ROTATION_STEP) % 360
	elseif input.KeyCode == BuildConfig.KEY_CANCEL then
		stopBuilding()
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
		if lastValid and lastTargetPos then
			-- Kirim posisi mentah; server yang menghitung ulang snap + validasi plot
			placeRemote:FireServer(currentItemName, lastTargetPos, rotationY)
			-- Mode build tetap aktif supaya bisa memasang banyak item sekaligus.
			-- Kalau mau sekali pasang langsung berhenti, panggil stopBuilding() di sini.
		end
	end
end)

-- GUI -> controller
selectSignal.Event:Connect(function(itemName)
	if typeof(itemName) == "string" then
		startBuilding(itemName)
	else
		stopBuilding()
	end
end)
