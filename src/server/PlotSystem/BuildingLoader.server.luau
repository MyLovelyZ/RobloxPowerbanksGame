local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlotsFolder = workspace:WaitForChild("Maps"):WaitForChild("Plots")
local AssetsFolder = ReplicatedStorage:WaitForChild("Assets")

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

	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then return end

	local plotLevel = playerData:FindFirstChild("PlotLevel")
	if not plotLevel then return end

	local level = plotLevel.Value

	-- hapus bangunan lama (biar keupdate)
	for _, v in pairs(plot:GetChildren()) do
		if string.find(v.Name, "Bangunan") then
			v:Destroy()
		end
	end

	-- ambil model sesuai level
	local houseModel = AssetsFolder:FindFirstChild("Bangunan"..level)
	if not houseModel then
		warn("Model Bangunan"..level.." tidak ditemukan!")
		return
	end

	local spawnPoint = plot:FindFirstChild("Building"):FindFirstChild("Bawah"..level)
	if not spawnPoint then 
		warn("SpawnPoint Bawah"..level.." tidak ada di plot", plot.Name)
		return 
	end

	local house = houseModel:Clone()
	house.Name = "Bangunan"..level

	if house.PrimaryPart then
		local plotNumber = tonumber(plot.Name)

		if plotNumber and plotNumber > 4 then
			house:SetPrimaryPartCFrame(spawnPoint.CFrame * CFrame.Angles(0, math.rad(180), 0))
		else
			house:SetPrimaryPartCFrame(spawnPoint.CFrame)
		end
	else
		warn("PrimaryPart belum diset di", house.Name)
	end

	house.Parent = plot
end

-- saat player masuk
Players.PlayerAdded:Connect(function(player)
	task.wait(1)

	spawnHouse(player)

	local playerData = player:WaitForChild("PlayerData")
	local plotLevel = playerData:WaitForChild("PlotLevel")

	plotLevel.Changed:Connect(function()
		spawnHouse(player)
	end)
end)

-- saat player keluar
Players.PlayerRemoving:Connect(function(player)
	local plot = getPlayerPlot(player)
	if not plot then return end

	for _, v in pairs(plot:GetChildren()) do
		if string.find(v.Name, "Bangunan") then
			v:Destroy()
		end
	end
end)