--[[
	BuildingItemsData
	Daftar item yang bisa di-build. Data ini yang ditampilkan di AddBuildingFrame.

	PENTING:
	- ModelName HARUS sama dengan nama Model fisik di:
	  ReplicatedStorage > BuildingItems (nama folder diambil dari BuildConfig.ITEMS_FOLDER_NAME)
	- Untuk sekarang ini masih data DUMMY. Nanti tinggal masukkan Model fisiknya
	  ke ReplicatedStorage dengan nama yang sama dengan ModelName di bawah.
	- Urutan tampil di ScrollingFrame mengikuti urutan array ini.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BuildConfig = require(script.Parent.Parent.BuildingSystem.BuildConfig)

export type BuildingItem = {
	ModelName: string, -- nama Model di ReplicatedStorage > BuildingItems
	DisplayName: string, -- nama yang ditampilkan di GUI
	Image: string, -- gambar item untuk GUI
	Price: number, -- harga item
	Description: string, -- deskripsi yang ditampilkan di InfoFrame
}

local BuildingItemsData = {}

BuildingItemsData.Items = {

	{
		ModelName = "Kotak_1x1",
		DisplayName = "Kotak Kecil",
		Image = "rbxassetid://201",
		Price = 25,
		Description = "Kotak kecil 1x1 untuk dasar bangunan.",
	},

	{
		ModelName = "Kotak_2x2",
		DisplayName = "Kotak Sedang",
		Image = "rbxassetid://202",
		Price = 75,
		Description = "Kotak sedang 2x2, cocok untuk lantai yang lebih luas.",
	},

	{
		ModelName = "Dinding_2x1",
		DisplayName = "Dinding",
		Image = "rbxassetid://203",
		Price = 50,
		Description = "Dinding 2x1 untuk membatasi area bangunan.",
	},

	{
		ModelName = "Meja_Charger",
		DisplayName = "Meja Charger",
		Image = "rbxassetid://204",
		Price = 150,
		Description = "Meja tempat menaruh charger untuk pelanggan.",
	},

	{
		ModelName = "Rak_Powerbank",
		DisplayName = "Rak Powerbank",
		Image = "rbxassetid://205",
		Price = 300,
		Description = "Rak untuk memajang powerbank yang dijual.",
	},

} :: { BuildingItem }

-- Ambil Model fisik dari ReplicatedStorage > BuildingItems sesuai data item.
-- Return nil kalau modelnya belum dimasukkan ke ReplicatedStorage.
function BuildingItemsData.GetModel(item: BuildingItem): Model?
	local itemsFolder = ReplicatedStorage:FindFirstChild(BuildConfig.ITEMS_FOLDER_NAME)
	if not itemsFolder then
		return nil
	end

	local model = itemsFolder:FindFirstChild(item.ModelName)
	if model and model:IsA("Model") then
		return model
	end
	return nil
end

return BuildingItemsData
