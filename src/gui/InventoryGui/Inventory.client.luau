local InventoryFrame = script.Parent.Parent.Parent.MainGui.FrameFolder.InventoryFrame
local MainInventoryFrame = InventoryFrame:WaitForChild("MainInventoryFrame")

local InventoryText = MainInventoryFrame:WaitForChild("InventoryText")

--ini bagian button
local InventoryChargerButton = InventoryFrame:WaitForChild("InventoryChargerButton")
local InventoryPBButton = InventoryFrame:WaitForChild("InventoryPbButton")

--ini bagian frame
local InventoryChargerFrame = MainInventoryFrame:WaitForChild("InventoryChargerFrame")
local InventoryPBFrame = MainInventoryFrame:WaitForChild("InventoryPbFrame")

--warna
local SELECTED_COLOR = Color3.fromRGB(0, 255, 170)
local UNSELECTED_COLOR = Color3.fromRGB(147, 248, 255)

-- INITIAL STATE (ketika GUI dibuka pertama kali)
InventoryChargerFrame.Visible = true
InventoryPBFrame.Visible = false

InventoryChargerButton.BackgroundColor3 = SELECTED_COLOR
InventoryPBButton.BackgroundColor3 = UNSELECTED_COLOR

InventoryText.Text = "Chargers"


InventoryChargerButton.MouseButton1Click:Connect(function()
	if not InventoryChargerFrame.Visible then

		InventoryChargerFrame.Visible = true
		InventoryPBFrame.Visible = false

		InventoryChargerButton.BackgroundColor3 = SELECTED_COLOR
		InventoryPBButton.BackgroundColor3 = UNSELECTED_COLOR
		
		InventoryText.Text = "Chargers"

	end
end)


InventoryPBButton.MouseButton1Click:Connect(function()
	if not InventoryPBFrame.Visible then

		InventoryPBFrame.Visible = true
		InventoryChargerFrame.Visible = false

		InventoryPBButton.BackgroundColor3 = SELECTED_COLOR
		InventoryChargerButton.BackgroundColor3 = UNSELECTED_COLOR
		
		InventoryText.Text = "Powerbanks"

	end
end)