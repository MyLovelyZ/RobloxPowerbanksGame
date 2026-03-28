local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuyEvent = ReplicatedStorage.Remotes:WaitForChild("BuyPowerbankEvent")

local PowerBanks = require(ReplicatedStorage.Shared.Modules.Data.PowerbankData)

BuyEvent.OnServerEvent:Connect(function(player, powerbankId)
	local powerbank = PowerBanks[powerbankId]
	if not powerbank then return end
	local Duit = player.PlayerData.Duit
	local Inventory = player.PlayerData.Inventory
	
	if Duit.Value >= powerbank.BuyPrice then
		Duit.Value -= powerbank.BuyPrice
		local ExistingItem = Inventory.FindFirstChild(powerbankId)
		
		if ExistingItem then
			ExistingItem.Value += 1
		else
			local item = Instance.new("IntValue")
			item.Name = powerbankId
			item.Value = 1
			item.Parent = Inventory
		end
	else
		print("duit ngk cukup woi kerja dulu sono")
	end
end)