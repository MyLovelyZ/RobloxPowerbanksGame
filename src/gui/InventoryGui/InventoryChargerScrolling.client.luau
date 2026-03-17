local MainGui = script.Parent.Parent.Parent.MainGui
local InventoryFrame = MainGui.FrameFolder.InventoryFrame

local ChargerScrollingFrame = InventoryFrame.MainInventoryFrame.InventoryChargerFrame.ChargerScrollingFrame

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PowerbankData = require(ReplicatedStorage.Shared.Modules:WaitForChild("PowerbankData"))

local Template = ChargerScrollingFrame.ChargerTemplate

local UNSELECTED = Color3.fromRGB(0, 221, 255)
local SELECTED = Color3.fromRGB(0, 255, 170)

local SelectedItem = nil

for name, data in pairs(PowerbankData) do

	local Item = Template:Clone()
	Item.Parent = ChargerScrollingFrame
	Item.Visible = true
	Item.Name = name

	Item.Stocks.Text = data.ChargeTime.."x"

	local Button = Item.ImageButton
	local Stroke = Item.UIStroke

	Button.MouseButton1Click:Connect(function()

		if SelectedItem == Item then
			Stroke.Color = UNSELECTED
			SelectedItem = nil
			return
		end

		if SelectedItem then
			SelectedItem.UIStroke.Color = UNSELECTED
		end

		Stroke.Color = SELECTED
		SelectedItem = Item

	end)

end