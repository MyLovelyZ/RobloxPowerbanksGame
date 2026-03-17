local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local PlayerData = Instance.new("Folder")
	PlayerData.Name = "PlayerData"
	PlayerData.Parent = player
	
	local Duit = Instance.new("IntValue")
	Duit.Name = "Duit"
	Duit.Value = 1000
	Duit.Parent = PlayerData
	
	local Inventory = Instance.new("Folder")
	Inventory.Name = "Inventory"
	Inventory.Parent = PlayerData
end)