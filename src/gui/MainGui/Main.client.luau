--Manggil semua button
local ButtonFolder = script.Parent.Parent.Parent.MainGui.ButtonFolder.Frame

local StoreOverviewButton = ButtonFolder:WaitForChild("StoreOverviewButton")
local InventoryButton = ButtonFolder:WaitForChild("InventoryButton")
local SettingsButton = ButtonFolder:WaitForChild("SettingsButton")
local BuildButton = ButtonFolder:WaitForChild("BuildButton")
local PremiumStoreButton = ButtonFolder:WaitForChild("PremiumStoreButton")

--manggil semua framenya beb
local frameFolder = script.Parent.Parent.Parent.MainGui.FrameFolder

local StoreOverviewFrame = frameFolder:WaitForChild("StoreOverviewFrame")
local InventoryFrame = frameFolder:WaitForChild("InventoryFrame")
local SettingsFrame = frameFolder:WaitForChild("SettingsFrame")
local BuildFrame = frameFolder:WaitForChild("BuildFrame")
local PremiumStoreFrame = frameFolder:WaitForChild("PremiumStoreFrame")

--idk mau namain apa maybe manggil logic ya ngk logic juga sih ini cuma properties aja beb

local SELECTED_COLOR = Color3.fromRGB(0, 255, 170)
local UNSELECTED_COLOR = Color3.fromRGB(0, 221, 255)

--logicnya ah felix gay

--yang ini logic buat reset semua gui ya beb
local function ResetUi()
	StoreOverviewFrame.Visible = false
	InventoryFrame.Visible = false
	SettingsFrame.Visible = false
	BuildFrame.Visible = false
	PremiumStoreFrame.Visible = false
	
	StoreOverviewButton.UIStroke.Color = UNSELECTED_COLOR
	InventoryButton.UIStroke.Color = UNSELECTED_COLOR
	SettingsButton.UIStroke.Color = UNSELECTED_COLOR
	BuildButton.UIStroke.Color = UNSELECTED_COLOR
	PremiumStoreButton.UIStroke.Color = UNSELECTED_COLOR
end

--ini buat ngasih tau gui aktif
local function GuiAktif(button, frame)
	ResetUi()
	
	frame.Visible = true
	button.UIStroke.Color = SELECTED_COLOR
end

--nah yang ini buat ngasih tau siapa yang dipencet
StoreOverviewButton.MouseButton1Click:Connect(function()
	if StoreOverviewFrame.Visible then
		ResetUi()
	else
		GuiAktif(StoreOverviewButton, StoreOverviewFrame)
	end
end)

--Bagian Inventory

InventoryButton.MouseButton1Click:Connect(function()
	if InventoryFrame.Visible then
		ResetUi()
	else
		GuiAktif(InventoryButton, InventoryFrame)
	end
end)

local CloseInventoryButton = InventoryFrame.MainInventoryFrame:WaitForChild("CloseButton")

CloseInventoryButton.MouseButton1Click:Connect(function()
	ResetUi()
end)

--Bagian Settings

SettingsButton.MouseButton1Click:Connect(function()
	if SettingsFrame.Visible then
		ResetUi()
	else
		GuiAktif(SettingsButton, SettingsFrame)
	end
end)

BuildButton.MouseButton1Click:Connect(function()
	if BuildFrame.Visible then
		ResetUi()
	else
		GuiAktif(BuildButton, BuildFrame)
	end	
end)

PremiumStoreButton.MouseButton1Click:Connect(function()
	if PremiumStoreFrame.Visible then
		ResetUi()
	else
		GuiAktif(PremiumStoreButton, PremiumStoreFrame)
	end
end)

ResetUi()

--InventoryButton.MouseButton1Click:Connect(function()
--	Inventory.Visible = not Inventory.Visible
--	IsSelected = not IsSelected
--	if IsSelected then
--		Stroke.Color = SelectedColor
--	else
--		Stroke.Color = UnselectedColor
--	end
--end)