--[[
	ShopGuiController (client)
	Mengisi ShopGui dengan stok yang diterbitkan server.

	ALUR DATANYA:
	  ShopStockServer (server)
	      -> ReplicatedStorage > ShopStock   (folder, otomatis ter-replikasi)
	          -> script ini membacanya       (TIDAK perlu RemoteEvent)
	              -> ScrollingShopItems
	  Klik beli -> Remotes.BuyPowerbankEvent -> BuyPowerbankHandler (server yang memutuskan)

	Script ini cuma MENAMPILKAN. Semua angka yang penting (stok, jatah, duit)
	divalidasi ulang di server, jadi kalau ada yang menipu tampilannya di sini
	pun pembeliannya tetap ditolak server.

	NAMA CHILD YANG DICARI DI DALAM ItemShopTemplate (semuanya opsional —
	yang tidak ada tinggal dilewati, jadi aman kalau template-mu belum lengkap):
		ItemImage  : ImageLabel / ImageButton  -> gambar powerbank
		ItemName   : TextLabel                 -> nama powerbank
		ItemPrice  : TextLabel                 -> harga beli
		ItemStock  : TextLabel                 -> sisa jatah, contoh "3 / 5"
		BuyButton  : TextButton / ImageButton  -> tombol beli
	Kalau BuyButton tidak ada, script pakai GuiButton pertama yang ditemukan di
	dalam template. Kalau tidak ada juga, dibuatkan tombol transparan.

	Opsional di dalam MainFrame:
		RestockLabel : TextLabel -> hitung mundur ke restock berikutnya
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local ShopSystem = Modules:WaitForChild("ShopSystem")

local ShopConfig = require(ShopSystem:WaitForChild("ShopConfig"))
local ShopStock = require(ShopSystem:WaitForChild("ShopStock"))
local Powerbanks = require(Modules:WaitForChild("Data"):WaitForChild("PowerbankData"))

local Player = Players.LocalPlayer

--------------------------------------------------------------------
-- Referensi GUI (struktur awalnya diurus ShopGuiInit.client.luau)
--------------------------------------------------------------------

local PlayerGui = Player:WaitForChild("PlayerGui")
local ShopGui = PlayerGui:WaitForChild("ShopGui")
local MainFrame = ShopGui:WaitForChild("MainFrame")

local ScrollingShopItems = MainFrame:WaitForChild("ScrollingShopItems")
local ItemTemplate = ScrollingShopItems:WaitForChild("ItemShopTemplate")

local RestockLabel = MainFrame:FindFirstChild("RestockLabel", true)

--------------------------------------------------------------------
-- Sumber data
--------------------------------------------------------------------

local StockFolder = ReplicatedStorage:WaitForChild(ShopConfig.STOCK_FOLDER_NAME)

local RemotesFolder = ReplicatedStorage:WaitForChild(ShopConfig.REMOTES_FOLDER_NAME)
local BuyEvent = RemotesFolder:WaitForChild(ShopConfig.BUY_REMOTE_NAME) :: RemoteEvent

--------------------------------------------------------------------
-- Helper
--------------------------------------------------------------------

-- Cari tombol yang bisa diklik di dalam sebuah entry.
-- (pola yang sama dipakai BuildingGuiController)
local function getBuyButton(entry: GuiObject): GuiButton
	local named = entry:FindFirstChild("BuyButton", true)
	if named and named:IsA("GuiButton") then
		return named
	end

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

local function setText(parent: Instance, childName: string, text: string)
	local label = parent:FindFirstChild(childName, true)
	if label and (label:IsA("TextLabel") or label:IsA("TextButton")) then
		label.Text = text
	end
end

local function setImage(parent: Instance, childName: string, image: string)
	local target = parent:FindFirstChild(childName, true)
	if target and (target:IsA("ImageLabel") or target:IsA("ImageButton")) then
		target.Image = image
	end
end

--------------------------------------------------------------------
-- Render
--------------------------------------------------------------------

-- entry yang sedang tampil: [powerbankId] = GuiObject
local entries: { [string]: GuiObject } = {}

-- nilai asli template, dipakai supaya efek "habis" tidak merusak desain
local TEMPLATE_TRANSPARENCY = ItemTemplate.BackgroundTransparency

-- Update bagian yang berubah-ubah (sisa jatah + tombol habis) tanpa
-- menggambar ulang seluruh daftar
local function refreshEntry(itemId: string)
	local entry = entries[itemId]
	if not entry then
		return
	end

	local stock = ShopStock.getStockAmount(StockFolder, itemId)
	local remaining = ShopStock.getRemaining(Player, StockFolder, itemId)

	setText(entry, "ItemStock", remaining .. " / " .. stock)

	local button = getBuyButton(entry)
	local habis = remaining <= 0

	button.Active = not habis
	button.AutoButtonColor = not habis

	-- diredupkan sedikit kalau habis, tapi tetap berangkat dari nilai asli
	-- template supaya desainmu tidak ketimpa
	entry.BackgroundTransparency = habis
		and math.clamp(TEMPLATE_TRANSPARENCY + 0.4, 0, 1)
		or TEMPLATE_TRANSPARENCY

	if habis then
		setText(entry, "ItemPrice", "HABIS")
	else
		local powerbank = Powerbanks[itemId]
		if powerbank then
			setText(entry, "ItemPrice", tostring(powerbank.BuyPrice))
		end
	end
end

local function refreshAll()
	for itemId in entries do
		refreshEntry(itemId)
	end
end

local function render()
	-- bersihkan entry lama (template jangan ikut dihapus)
	for _, child in ScrollingShopItems:GetChildren() do
		if child:IsA("GuiObject") and child ~= ItemTemplate then
			child:Destroy()
		end
	end
	table.clear(entries)

	for index, stockEntry in ShopStock.getStockList(StockFolder) do
		local powerbank = Powerbanks[stockEntry.Id]
		if not powerbank then
			-- Id di stok tidak ada di PowerbankData (biasanya salah ketik di ShopConfig.POOL)
			warn("[ShopGuiController] Powerbank '" .. stockEntry.Id .. "' tidak ada di PowerbankData.")
			continue
		end

		local entry = ItemTemplate:Clone()
		entry.Name = stockEntry.Id
		entry.LayoutOrder = index
		entry.Visible = true

		setImage(entry, "ItemImage", powerbank.Image)
		setText(entry, "ItemName", powerbank.Name)
		setText(entry, "ItemPrice", tostring(powerbank.BuyPrice))

		-- kalau template-nya sendiri berupa ImageButton/ImageLabel
		if entry:IsA("ImageButton") or entry:IsA("ImageLabel") then
			entry.Image = powerbank.Image
		end

		getBuyButton(entry).Activated:Connect(function()
			-- Server yang menentukan boleh/tidak. Di sini cuma cegah spam
			-- kalau tampilannya memang sudah habis.
			if ShopStock.getRemaining(Player, StockFolder, stockEntry.Id) <= 0 then
				return
			end
			BuyEvent:FireServer(stockEntry.Id)
		end)

		entry.Parent = ScrollingShopItems
		entries[stockEntry.Id] = entry

		refreshEntry(stockEntry.Id)
	end
end

--------------------------------------------------------------------
-- Ikuti perubahan data
--------------------------------------------------------------------

-- Saat restock, server menghapus + menambah beberapa IntValue lalu menulis
-- atribut. Kalau tiap perubahan langsung menggambar ulang, GUI bisa kedip dan
-- sempat menampilkan stok setengah jadi. Jadi semua sinyal dikumpulkan dulu,
-- gambar ulangnya cukup sekali di akhir frame.
local renderQueued = false

local function scheduleRender()
	if renderQueued then
		return
	end
	renderQueued = true

	task.defer(function()
		renderQueued = false
		render()
	end)
end

StockFolder:GetAttributeChangedSignal("Period"):Connect(scheduleRender)
StockFolder.ChildAdded:Connect(scheduleRender)
StockFolder.ChildRemoved:Connect(scheduleRender)

-- Kalau player membeli, PlayerData > Shop > Bought ikut berubah -> update sisa jatah.
-- Ditunggu terpisah karena PlayerData baru muncul setelah selesai di-load dari DataStore.
task.spawn(function()
	local playerData = Player:WaitForChild("PlayerData", 30)
	if not playerData then
		warn("[ShopGuiController] PlayerData tidak muncul, sisa jatah tidak bisa ditampilkan.")
		return
	end

	local shop = playerData:WaitForChild("Shop", 10)
	if not shop then
		return
	end

	local bought = shop:WaitForChild("Bought", 10)
	if not bought then
		return
	end

	local periodValue = shop:FindFirstChild("Period")
	if periodValue then
		periodValue.Changed:Connect(refreshAll)
	end

	bought.ChildAdded:Connect(function(child)
		child.Changed:Connect(function()
			refreshEntry(child.Name)
		end)
		refreshEntry(child.Name)
	end)

	bought.ChildRemoved:Connect(refreshAll)

	for _, child in bought:GetChildren() do
		child.Changed:Connect(function()
			refreshEntry(child.Name)
		end)
	end

	refreshAll()
end)

--------------------------------------------------------------------
-- Hitung mundur restock (opsional, cuma kalau ada RestockLabel)
--------------------------------------------------------------------

if RestockLabel and RestockLabel:IsA("TextLabel") then
	task.spawn(function()
		while true do
			task.wait(0.5)

			if MainFrame.Visible then
				local nextRestock = ShopStock.getNextRestock(StockFolder)
				if nextRestock then
					-- os.time() client dipakai HANYA untuk angka hitung mundur.
					-- Isi stoknya tetap datang dari server, jadi jam client yang
					-- meleset paling banter bikin countdown-nya kurang akurat.
					local sisa = math.max(0, nextRestock - os.time())
					RestockLabel.Text = string.format("Restock: %02d:%02d", sisa // 60, sisa % 60)
				end
			end
		end
	end)
end

--------------------------------------------------------------------

render()
