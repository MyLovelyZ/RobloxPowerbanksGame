--[[
	PlotUtil
	Penghubung antara PlotSystem dan BuildingSystem.
	Dipakai bersama oleh client (preview) dan server (validasi) supaya
	keduanya selalu menunjuk ke plot & area build yang sama.

	STRUKTUR PLOT YANG DIHARAPKAN (workspace > Maps > Plots > "1", "2", ...):
	- Owner              : ObjectValue berisi Player pemilik plot (diisi PlotLoader)
	- Building > Bawah<n>: area build sekaligus spawn point bangunan (Part atau Model),
	                       dipilih sesuai PlayerData.PlotLevel
	- PlacedItems        : Folder hasil build (dibuat otomatis oleh BuildingServer)
	- Bangunan<n>        : Model rumah yang di-spawn BuildingLoader
]]

local BuildConfig = require(script.Parent.BuildConfig)

local PlotUtil = {}

function PlotUtil.getPlotsFolder(): Instance
	local maps = workspace:WaitForChild(BuildConfig.MAPS_FOLDER_NAME)
	return maps:WaitForChild(BuildConfig.PLOTS_FOLDER_NAME)
end

-- Cari plot milik player lewat Owner value (diisi oleh PlotLoader)
function PlotUtil.getPlayerPlot(player: Player): Instance?
	for _, plot in PlotUtil.getPlotsFolder():GetChildren() do
		local owner = plot:FindFirstChild("Owner")
		if owner and owner:IsA("ObjectValue") and owner.Value == player then
			return plot
		end
	end
	return nil
end

-- Cari plot lewat PlotNumber (IntValue di player, diisi oleh PlotLoader).
-- Lebih aman dipakai saat PlayerRemoving karena Owner mungkin sudah dikosongkan.
function PlotUtil.getPlotByNumber(plotNumber: number): Instance?
	if plotNumber == 0 then
		return nil
	end
	return PlotUtil.getPlotsFolder():FindFirstChild(tostring(plotNumber))
end

-- Ambil level plot player dari PlayerData.PlotLevel (default 1 kalau belum ada)
function PlotUtil.getPlotLevel(player: Player): number
	local playerData = player:FindFirstChild("PlayerData")
	local plotLevel = playerData and playerData:FindFirstChild("PlotLevel")
	if plotLevel and plotLevel:IsA("IntValue") then
		return plotLevel.Value
	end
	return 1
end

-- Ambil area build di dalam plot: plot > Building > Bawah<level>.
-- Boleh berupa Part atau Model (GridUtil.getAreaBounds yang mengurus bedanya).
function PlotUtil.getBuildArea(plot: Instance, level: number): Instance?
	local buildingFolder = plot:FindFirstChild(BuildConfig.BUILDING_FOLDER_NAME)
	if not buildingFolder then
		return nil
	end

	local area = buildingFolder:FindFirstChild(BuildConfig.BUILD_AREA_PREFIX .. level)
	if area and (area:IsA("BasePart") or area:IsA("Model")) then
		return area
	end
	return nil
end

-- Ambil Folder hasil build di dalam plot (dibuat oleh BuildingServer)
function PlotUtil.getPlacedFolder(plot: Instance): Folder?
	local folder = plot:FindFirstChild(BuildConfig.PLACED_FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end
	return nil
end

-- Semua instance di plot yang dianggap "sudah terpasang" untuk cek tabrakan:
-- item hasil build + rumah (Bangunan1, Bangunan2, dst) dari BuildingLoader.
function PlotUtil.getCollisionInstances(plot: Instance): { Instance }
	local list: { Instance } = {}

	local placed = PlotUtil.getPlacedFolder(plot)
	if placed then
		table.insert(list, placed)
	end

	for _, child in plot:GetChildren() do
		if string.find(child.Name, "Bangunan") then
			table.insert(list, child)
		end
	end

	return list
end

return PlotUtil
