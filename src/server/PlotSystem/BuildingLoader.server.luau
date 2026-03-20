local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlotsFolder = workspace:WaitForChild("PlayersPlots")
local HouseModel = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Bangunan1")

local function getPlayerPlot(player)
	for _, plot in pairs(PlotsFolder:GetChildren()) do
		local owner = plot:FindFirstChild("Owner")

		if owner and owner.Value == player then
			return plot
		end
	end

	return nil
end

local function spawnHouse(player)
	local plot = getPlayerPlot(player)
	if not plot then 
		warn("Plot tidak ditemukan untuk", player.Name)
		return 
	end

	local spawnPoint = plot:FindFirstChild("SpawnPoint")
	if not spawnPoint then 
		warn("SpawnPoint tidak ada di plot", plot.Name)
		return 
	end

	if plot:FindFirstChild("Bangunan1") then return end

	local house = HouseModel:Clone()
	house.Name = "Bangunan1"

	if house.PrimaryPart then
		house:SetPrimaryPartCFrame(spawnPoint.CFrame)
	else
		warn("PrimaryPart belum diset di Bangunan1!")
	end

	house.Parent = plot
end

Players.PlayerAdded:Connect(function(player)
	task.wait(1)

	spawnHouse(player)
end)

Players.PlayerRemoving:Connect(function(player)
	local plot = getPlayerPlot(player)
	if not plot then return end
	
	local house = plot:FindFirstChild("Bangunan1")
	if house then
		house:Destroy()
	end
end)