local InventoryFrame = script.Parent.Parent.Parent.MainGui.FrameFolder.InventoryFrame
local InventoryPbFrame = InventoryFrame.MainInventoryFrame.InventoryPbFrame

local AllButton = InventoryPbFrame.AllButton
local EmptyButton = InventoryPbFrame.EmptyButton
local FullButton = InventoryPbFrame.FullButton

--warna

local SELECTED_COLOR = Color3.fromRGB(0, 255, 170)
local UNSELECTED_COLOR = Color3.fromRGB(0, 221, 255)

-- INI STATE AWAL

AllButton.BackgroundColor3 = SELECTED_COLOR
EmptyButton.BackgroundColor3 = UNSELECTED_COLOR
FullButton.BackgroundColor3 = UNSELECTED_COLOR