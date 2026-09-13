--[[
	ShelfManager
	Registry rak yang aktif di server.

	Modul ini TIDAK menyimpan isi slot. Isi slot tetap satu-satunya di atribut
	"Item" pada Part slot masing-masing (lihat Shelf.luau), dan diakses lewat
	objek Shelf.

	Versi sebelumnya punya tabel Shelves sendiri, jadi ada dua sumber kebenaran
	yang pasti tidak sinkron begitu salah satu diubah — plus tabelnya diisi
	`[1] = nil, [2] = nil, ...` yang di Lua sama dengan tabel kosong, sehingga
	GetEmptySlot() selalu nil dan AddItemToShelf() selalu gagal.

	Kuncinya Instance rak itu sendiri: satu rack = satu Shelf, dan rack yang
	dihancurkan otomatis keluar dari registry.
]]

local Shelf = require(script.Parent.Shelf)
local ShelfVisual = require(script.Parent.ShelfVisual)

local ShelfManager = {}

ShelfManager.Shelves = {} -- array Shelf, urut sesuai urutan register (iterasi stabil)
ShelfManager.ByRack = {} -- map: Instance rak -> Shelf, untuk lookup cepat

-- Daftarkan rack. Aman dipanggil dua kali: pemanggilan berikutnya mengembalikan
-- objek Shelf yang sama, bukan bikin baru.
function ShelfManager:Register(rack: Instance)
	local existing = self.ByRack[rack]

	if existing then
		return existing
	end

	local shelf = Shelf.new(rack)

	self.ByRack[rack] = shelf
	table.insert(self.Shelves, shelf)

	-- Visual disambung di sini, bukan di pemanggil, supaya rak yang didaftarkan
	-- dari mana pun (termasuk rak hasil build player nanti) otomatis menampilkan
	-- body powerbank tanpa perlu ada yang ingat memanggilnya.
	ShelfVisual.Bind(shelf)

	-- rack yang dihancurkan (mis. bangunannya dibongkar) jangan nyangkut di registry
	rack.Destroying:Once(function()
		self:Unregister(rack)
	end)

	return shelf
end

function ShelfManager:Unregister(rack: Instance): boolean
	local shelf = self.ByRack[rack]

	if not shelf then
		return false
	end

	self.ByRack[rack] = nil

	local index = table.find(self.Shelves, shelf)
	if index then
		table.remove(self.Shelves, index)
	end

	return true
end

function ShelfManager:Get(rack: Instance)
	return self.ByRack[rack]
end

-- Salinan daftar rak aktif, jadi tetap aman diiterasi walau ada rack yang
-- ke-unregister di tengah jalan.
function ShelfManager:GetAll()
	return table.clone(self.Shelves)
end

-- Cari slot kosong di rak manapun yang terdaftar. Read-only.
-- Return shelf + nomor slot, atau nil kalau semua rak penuh.
function ShelfManager:FindEmptySlot()
	for _, shelf in self.Shelves do
		local slotNumber = shelf:FindEmptySlot()

		if slotNumber then
			return shelf, slotNumber
		end
	end

	return nil
end

-- Taruh item di rak pertama yang masih ada tempat.
-- Return shelf + nomor slot, atau nil kalau semua rak penuh.
function ShelfManager:AddItem(itemName: string)
	for _, shelf in self.Shelves do
		local slotNumber = shelf:AddItem(itemName)

		if slotNumber then
			return shelf, slotNumber
		end
	end

	return nil
end

return ShelfManager
