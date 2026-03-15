local MainGui = script.Parent.Parent.Parent.MainGui
local InventoryFrame = MainGui.FrameFolder.InventoryFrame

local ChargerScrollingFrame = InventoryFrame.MainInventoryFrame.InventoryChargerFrame.ChargerScrollingFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerbankData = require(ReplicatedStorage.Shared.Modules:WaitForChild("PowerbankData"))

local Template = ChargerScrollingFrame.ChargerTemplate

for name, data in pairs(PowerbankData) do

	local Item = Template:Clone()
	Item.Parent = ChargerScrollingFrame
	Item.Visible = true
	
	Item.Stocks.Text = data.ChargeTime.."x"

end