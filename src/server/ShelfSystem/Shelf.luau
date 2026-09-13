--[[
	Shelf
	Satu rak charging beserta slot-slotnya.

	STRUKTUR RAK (workspace > ChargingRack):
	- Model              : geometri raknya, diabaikan modul ini
	- slot1 .. slot14    : Part tempat powerbank nanti diletakkan
	  Tiap slot punya atribut "Item" (string) berisi nama powerbank yang
	  sedang ada di slot itu. String kosong = slot kosong.

	Nomornya tidak harus rapat — slot1, slot2, slot5 tetap sah.

	SUMBER KEBENARAN ISI SLOT:
	Atribut "Item" di slot part itu sendiri. Barangnya nempel di object tempat
	dia berdiri, jadi tidak ada mapping yang bisa bergeser, client bisa baca
	tanpa RemoteEvent, dan isinya kelihatan di Explorer saat debug.

	Konsekuensinya: JANGAN menyimpan salinan isi slot di tabel lain. Kalau butuh
	daftar rak yang aktif, pakai ShelfManager — dia cuma registry, bukan
	penyimpan state.

	KOSONG ITU "" , BUKAN nil.
	Atribut "Item" sudah dibuat di Studio sebagai string, jadi nilai awalnya
	string kosong. Makanya slot kosong dicek lewat isEmpty(), dan RemoveItem
	mengosongkannya dengan "" (bukan nil) supaya atributnya tidak ikut terhapus
	dari slot.
]]

local Shelf = {}
Shelf.__index = Shelf

local ITEM_ATTRIBUTE = "Item"

local function isEmpty(itemName): boolean
	return itemName == nil or itemName == ""
end

-- Kumpulkan slot dari sekumpulan Instance. Return map nomor -> Instance.
local function collectSlots(rack: Instance, candidates: { Instance })
	local slots = {}

	for _, object in candidates do
		local slotNumber = tonumber(object.Name:match("^slot(%d+)$"))

		if slotNumber then
			if slots[slotNumber] then
				-- dua object jatuh ke nomor yang sama (mis. "slot2" dan "slot02")
				warn(string.format(
					"[Shelf] %s punya slot nomor %d lebih dari satu, %s diabaikan",
					rack:GetFullName(),
					slotNumber,
					object:GetFullName()
				))
			else
				slots[slotNumber] = object
			end
		end
	end

	return slots
end

function Shelf.new(rack: Instance)
	local self = setmetatable({}, Shelf)

	self.Rack = rack
	self.Slots = {} -- map: nomor slot -> Instance slot
	self.SlotNumbers = {} -- array nomor slot, urut naik, supaya iterasi stabil

	-- slot biasanya anak langsung ChargingRack; kalau ternyata dibungkus lagi
	-- di dalam model, baru telusuri lebih dalam
	self.Slots = collectSlots(rack, rack:GetChildren())

	if next(self.Slots) == nil then
		self.Slots = collectSlots(rack, rack:GetDescendants())
	end

	for slotNumber in self.Slots do
		table.insert(self.SlotNumbers, slotNumber)
	end

	table.sort(self.SlotNumbers)

	if #self.SlotNumbers == 0 then
		warn(string.format(
			"[Shelf] %s tidak punya slot sama sekali — pastikan part-nya bernama slot1, slot2, dst",
			rack:GetFullName()
		))
	end

	return self
end

-- Instance slot fisiknya, buat menaruh/mencabut model powerbank.
-- nil kalau nomor slotnya tidak ada di rak ini.
function Shelf:GetSlot(slotNumber: number): Instance?
	return self.Slots[slotNumber]
end

-- Nomor slot yang benar-benar ada, urut naik. Salinan, jadi aman dimutasi caller.
function Shelf:GetSlotNumbers(): { number }
	return table.clone(self.SlotNumbers)
end

-- Isi slot. nil berarti slot kosong ATAU slotnya tidak ada
-- (pakai GetSlot kalau perlu membedakan keduanya).
function Shelf:GetItem(slotNumber: number): string?
	local slot = self.Slots[slotNumber]

	if slot == nil then
		return nil
	end

	local itemName = slot:GetAttribute(ITEM_ATTRIBUTE)

	if isEmpty(itemName) then
		return nil
	end

	return itemName
end

-- Nomor slot kosong pertama, nil kalau rak penuh. Read-only.
function Shelf:FindEmptySlot(): number?
	for _, slotNumber in self.SlotNumbers do
		if isEmpty(self.Slots[slotNumber]:GetAttribute(ITEM_ATTRIBUTE)) then
			return slotNumber
		end
	end

	return nil
end

function Shelf:IsFull(): boolean
	return self:FindEmptySlot() == nil
end

-- Taruh item di slot kosong pertama. Return nomor slotnya, nil kalau rak penuh.
function Shelf:AddItem(itemName: string): number?
	local slotNumber = self:FindEmptySlot()

	if slotNumber == nil then
		return nil
	end

	self.Slots[slotNumber]:SetAttribute(ITEM_ATTRIBUTE, itemName)

	return slotNumber
end

--[[
	Taruh item di slot TERTENTU. Return true kalau berhasil.
	Dipakai kalau slot tujuannya sudah ditentukan — misalnya player mengklik
	slot5 langsung, atau saat memuat ulang isi rak dari data simpanan.

	Gagal (false) kalau nomor slotnya tidak ada di rak ini, atau slotnya sudah
	terisi. Slot yang sudah terisi sengaja TIDAK ditimpa supaya item lama tidak
	hilang tanpa jejak — cabut dulu pakai RemoveItem kalau memang mau ditukar.
]]
function Shelf:SetItem(slotNumber: number, itemName: string): boolean
	local slot = self.Slots[slotNumber]

	if slot == nil then
		return false
	end

	if not isEmpty(slot:GetAttribute(ITEM_ATTRIBUTE)) then
		return false
	end

	slot:SetAttribute(ITEM_ATTRIBUTE, itemName)

	return true
end

-- Cabut item dari slot. Return nama item yang diambil supaya caller bisa
-- memindahkannya (mis. ke inventory), atau nil kalau slotnya kosong/tidak ada.
function Shelf:RemoveItem(slotNumber: number): string?
	local itemName = self:GetItem(slotNumber)

	if itemName == nil then
		return nil
	end

	-- dikosongkan dengan "", bukan nil, supaya atribut "Item" tetap ada di slot
	self.Slots[slotNumber]:SetAttribute(ITEM_ATTRIBUTE, "")

	return itemName
end

return Shelf
