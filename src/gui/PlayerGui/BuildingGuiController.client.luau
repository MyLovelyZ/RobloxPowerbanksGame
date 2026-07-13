--[[
	BuildingGuiController (client)
	Menghubungkan GUI building dengan BuildingController.

	ALUR:
	1. BuildButton (di ButtonFrame)  -> buka/tutup BuildFrame
	2. BuildButton (di BuildFrame)   -> buka/tutup AddBuildingFrame
	3. AddBuildingFrame menampilkan item dari BuildingItemsData (ModuleScript di Shared > Modules > Data)
	4. Klik item di ScrollingFrame   -> InfoFrame muncul menampilkan detail item
	5. Klik PriceButton di InfoFrame -> mulai mode build (fire signal BuildSelectItem ke BuildingController)
	6. CloseButton                   -> tutup AddBuildingFrame

	CATATAN: Inisialisasi struktur GUI ada di PlayerGuiInit.client.luau, script ini
	hanya mengurus interaksi tombol + isi data.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local BuildConfig = require(Modules:WaitForChild("BuildingSystem"):WaitForChild("BuildConfig"))
local BuildingItemsData = require(Modules:WaitForChild("Data"):WaitForChild("BuildingItemsData"))

local Player = Players.LocalPlayer
local GuiPlayer = Player:WaitForChild("PlayerGui")
local PlayerGui = GuiPlayer:WaitForChild("PlayerGui") -- this is the main GUI that contains all the other GUIs

--------------------------------------------------------------------
-- Referensi GUI (struktur sama dengan PlayerGuiInit.client.luau)
--------------------------------------------------------------------

local ButtonFrame = PlayerGui:WaitForChild("ButtonFrame")
local GuiFolder = PlayerGui:WaitForChild("GuiFolder")

local MainBuildButton = ButtonFrame:WaitForChild("BuildButton")

local BuildFrame = GuiFolder:WaitForChild("BuildFrame")
local BuildButton = BuildFrame:WaitForChild("BuildButton")

local AddBuildingFrame = BuildFrame:WaitForChild("AddBuildingFrame")
local CloseButton = AddBuildingFrame:WaitForChild("CloseButton"):WaitForChild("CloseButton")
local InfoFrame = AddBuildingFrame:WaitForChild("InfoFrame")
local ScrollingFrame = AddBuildingFrame:WaitForChild("ScrollingFrame")
local ItemTemplate = ScrollingFrame:WaitForChild("BuildingItemsTemplate")

local PriceButton = InfoFrame:WaitForChild("PriceFrame"):WaitForChild("PriceButton")
local ItemImage = InfoFrame:WaitForChild("ItemImage")
local ItemName = InfoFrame:WaitForChild("ItemName")
local ItemDesc = InfoFrame:WaitForChild("ItemDesc")

-- Signal ke BuildingController (dibuat oleh BuildingController.client.luau)
local selectSignal = ReplicatedStorage:WaitForChild(BuildConfig.SELECT_SIGNAL_NAME) :: BindableEvent

--------------------------------------------------------------------
-- State
--------------------------------------------------------------------

local selectedItem: BuildingItemsData.BuildingItem? = nil

-- Kondisi awal: semua frame building tertutup
BuildFrame.Visible = false
AddBuildingFrame.Visible = false
InfoFrame.Visible = false

--------------------------------------------------------------------
-- Helper
--------------------------------------------------------------------

-- Cari GuiButton yang bisa diklik dari sebuah entry item.
-- Kalau template-nya sendiri sudah button, pakai itu. Kalau bukan,
-- cari button di dalamnya. Kalau tidak ada juga, buat button transparan.
local function getClickButton(entry: GuiObject): GuiButton
	if entry:IsA("GuiButton") then
		return entry
	end

	for _, child in entry:GetDescendants() do
		if child:IsA("GuiButton") then
			return child
		end
	end

	local overlay = Instance.new("TextButton")
	overlay.Name = "ClickOverlay"
	overlay.BackgroundTransparency = 1
	overlay.Text = ""
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.ZIndex = entry.ZIndex + 1
	overlay.Parent = entry
	return overlay
end

-- Isi teks/gambar pada entry item kalau child-nya memang ada di template
local function fillItemEntry(entry: GuiObject, item: BuildingItemsData.BuildingItem)
	if entry:IsA("ImageButton") or entry:IsA("ImageLabel") then
		entry.Image = item.Image
	end

	local image = entry:FindFirstChild("ItemImage", true)
	if image and (image:IsA("ImageLabel") or image:IsA("ImageButton")) then
		image.Image = item.Image
	end

	local nameLabel = entry:FindFirstChild("ItemName", true)
	if nameLabel and nameLabel:IsA("TextLabel") then
		nameLabel.Text = item.DisplayName
	end
end

local function showItemInfo(item: BuildingItemsData.BuildingItem)
	selectedItem = item

	ItemImage.Image = item.Image
	ItemName.Text = item.DisplayName
	ItemDesc.Text = item.Description
	if PriceButton:IsA("TextButton") then
		PriceButton.Text = tostring(item.Price)
	end

	InfoFrame.Visible = true
end

--------------------------------------------------------------------
-- Isi ScrollingFrame dari BuildingItemsData
--------------------------------------------------------------------

local function populateScrollingFrame()
	-- Bersihkan entry lama (selain template) supaya tidak dobel kalau di-refresh
	for _, child in ScrollingFrame:GetChildren() do
		if child:IsA("GuiObject") and child ~= ItemTemplate then
			child:Destroy()
		end
	end

	for index, item in BuildingItemsData.Items do
		local entry = ItemTemplate:Clone()
		entry.Name = item.ModelName
		entry.LayoutOrder = index
		entry.Visible = true

		fillItemEntry(entry, item)

		getClickButton(entry).Activated:Connect(function()
			showItemInfo(item)
		end)

		entry.Parent = ScrollingFrame
	end
end

--------------------------------------------------------------------
-- Interaksi tombol
--------------------------------------------------------------------

-- BuildButton di ButtonFrame: buka/tutup BuildFrame
MainBuildButton.Activated:Connect(function()
	BuildFrame.Visible = not BuildFrame.Visible

	if not BuildFrame.Visible then
		-- Tutup semua & batalkan mode build kalau frame-nya ditutup
		AddBuildingFrame.Visible = false
		selectSignal:Fire(nil)
	end
end)

-- BuildButton di BuildFrame: buka/tutup AddBuildingFrame
BuildButton.Activated:Connect(function()
	AddBuildingFrame.Visible = not AddBuildingFrame.Visible

	if AddBuildingFrame.Visible then
		populateScrollingFrame()
		InfoFrame.Visible = false
		selectedItem = nil
	end
end)

-- CloseButton: tutup AddBuildingFrame
CloseButton.Activated:Connect(function()
	AddBuildingFrame.Visible = false
end)

-- PriceButton: mulai mode build dengan item yang dipilih
PriceButton.Activated:Connect(function()
	if not selectedItem then
		return
	end

	if not BuildingItemsData.GetModel(selectedItem) then
		warn("[BuildingGuiController] Model fisik belum ada di ReplicatedStorage > "
			.. BuildConfig.ITEMS_FOLDER_NAME .. ": " .. selectedItem.ModelName)
	end

	-- Tutup frame supaya tidak menghalangi, lalu mulai mode build.
	-- BuildingController yang mengurus ghost preview + penempatan.
	AddBuildingFrame.Visible = false
	selectSignal:Fire(selectedItem.ModelName)
end)
