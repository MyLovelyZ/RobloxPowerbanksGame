--[[
	BuyPowerbankHandler
	Menerima permintaan beli powerbank dari client, lalu MEMVALIDASI ULANG
	semuanya di server (client tidak dipercaya sama sekali):
	  1. powerbankId harus ada di PowerbankData
	  2. PlayerData player sudah selesai di-load dari DataStore
	  3. Item itu memang sedang dijual di period ini (ada di ReplicatedStorage > ShopStock)
	  4. Jatah player untuk item itu belum habis
	  5. Duitnya cukup

	Folder Remotes + RemoteEvent dibuat otomatis di sini kalau belum ada.

	CATATAN: seluruh handler ini TIDAK ada yield (task.wait / :WaitForChild /
	pemanggilan Async). Jadi dua permintaan beli tidak mungkin saling menyalip
	di tengah-tengah pengecekan. Jangan tambahkan yield di dalam sini.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local ShopSystem = Modules:WaitForChild("ShopSystem")

local ShopConfig = require(ShopSystem:WaitForChild("ShopConfig"))
local ShopStock = require(ShopSystem:WaitForChild("ShopStock"))
local PowerBanks = require(Modules:WaitForChild("Data"):WaitForChild("PowerbankData"))

--------------------------------------------------------------------
-- Remote (dibuat kalau belum ada)
--------------------------------------------------------------------

local function getOrCreate(parent: Instance, name: string, className: string): Instance
	local found = parent:FindFirstChild(name)
	if found then
		return found
	end
	local inst = Instance.new(className)
	inst.Name = name
	inst.Parent = parent
	return inst
end

local remotesFolder = getOrCreate(ReplicatedStorage, ShopConfig.REMOTES_FOLDER_NAME, "Folder")
local BuyEvent = getOrCreate(remotesFolder, ShopConfig.BUY_REMOTE_NAME, "RemoteEvent") :: RemoteEvent

--------------------------------------------------------------------
-- Helper
--------------------------------------------------------------------

-- Catat pembelian di PlayerData > Shop.
-- Kalau period-nya sudah ganti (shop restock), catatan lama dihapus dulu
-- supaya jatah player ikut ter-reset.
local function catatPembelian(shop: Instance, period: number, powerbankId: string)
	local periodValue = shop:FindFirstChild("Period")
	local bought = shop:FindFirstChild("Bought")
	if not periodValue or not periodValue:IsA("IntValue") or not bought then
		return
	end

	if periodValue.Value ~= period then
		bought:ClearAllChildren()
		periodValue.Value = period
	end

	local existing = bought:FindFirstChild(powerbankId)
	if existing and existing:IsA("IntValue") then
		existing.Value += 1
	else
		local value = Instance.new("IntValue")
		value.Name = powerbankId
		value.Value = 1
		value.Parent = bought
	end
end

local function tambahKeInventory(inventory: Instance, powerbankId: string)
	local existing = inventory:FindFirstChild(powerbankId)
	if existing and existing:IsA("IntValue") then
		existing.Value += 1
	else
		local item = Instance.new("IntValue")
		item.Name = powerbankId
		item.Value = 1
		item.Parent = inventory
	end
end

--------------------------------------------------------------------
-- Pembelian
--------------------------------------------------------------------

BuyEvent.OnServerEvent:Connect(function(player, powerbankId)
	-- 1. Item valid?
	if type(powerbankId) ~= "string" then
		return
	end

	local powerbank = PowerBanks[powerbankId]
	if not powerbank then
		return
	end

	-- 2. Data player sudah siap? (bisa saja masih di-load dari DataStore)
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return
	end

	local duit = playerData:FindFirstChild("Duit")
	local inventory = playerData:FindFirstChild("Inventory")
	local shop = playerData:FindFirstChild("Shop")
	if not duit or not duit:IsA("IntValue") or not inventory or not shop then
		return
	end

	-- 3. Item ini memang lagi dijual?
	local stockFolder = ReplicatedStorage:FindFirstChild(ShopConfig.STOCK_FOLDER_NAME)
	local period = ShopStock.getPublishedPeriod(stockFolder)
	if not period then
		return -- stok belum diterbitkan server
	end

	local stockAmount = ShopStock.getStockAmount(stockFolder, powerbankId)
	if stockAmount <= 0 then
		return -- tidak masuk stok period ini
	end

	-- 4. Jatah player masih ada?
	local sudahBeli = ShopStock.getBought(player, period, powerbankId)
	if sudahBeli >= stockAmount then
		return -- jatah habis, tunggu restock berikutnya
	end

	-- 5. Duit cukup?
	if duit.Value < powerbank.BuyPrice then
		print("duit ngk cukup woi kerja dulu sono")
		return
	end

	-- Semua valid -> proses
	duit.Value -= powerbank.BuyPrice
	catatPembelian(shop, period, powerbankId)
	tambahKeInventory(inventory, powerbankId)
end)
