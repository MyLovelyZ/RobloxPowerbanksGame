--[[
	ShelfVisual
	Menampilkan body fisik powerbank di atas Part slot rak.

	PRINSIPNYA: visual = cermin dari state, bukan hasil perintah.
	Modul ini TIDAK dipanggil dari AddItem/RemoveItem. Dia mendengarkan atribut
	"Item" di setiap Part slot lewat GetAttributeChangedSignal, lalu membangun
	ulang modelnya. Jadi body di rak selalu cocok dengan isi slot, dari mana pun
	atribut itu diubah — lewat AddItem, load dari DataStore nanti, atau diubah
	manual di Explorer saat testing. Tidak ada jalan untuk jadi tidak sinkron,
	dan tidak ada yang perlu ingat "jangan lupa update visualnya".

	Model hasil clone diparent ke Part slotnya dan dinamai BODY_NAME supaya
	gampang dicari & dihapus. Karena parent-nya slot, model ikut terhapus sendiri
	kalau raknya di-Destroy, dan koneksi atributnya ikut terputus otomatis.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")
local DataFolder = Modules:WaitForChild("Data")

local PowerbankModels = require(DataFolder:WaitForChild("PowerbankModels"))
local GridUtil = require(Modules:WaitForChild("BuildingSystem"):WaitForChild("GridUtil"))

local ShelfVisual = {}

-- Nama Model body yang ditaruh di dalam Part slot
local BODY_NAME = "PowerbankBody"

local ITEM_ATTRIBUTE = "Item"

--[[
	Part slot cuma penanda posisi, bukan sesuatu yang harus dilihat player.
	Set false kalau sedang debug dan mau melihat kotak slotnya di dalam game
	(di Studio > Explorer slotnya tetap kelihatan walaupun ini true).
]]
local HIDE_PLACEHOLDER = true

local function clearBody(slot: Instance)
	local existing = slot:FindFirstChild(BODY_NAME)

	if existing then
		existing:Destroy()
	end
end

-- Taruh model powerbank duduk di atas permukaan slot
local function placeBody(slot: BasePart, powerbankId: string)
	local template = PowerbankModels.Get(powerbankId)

	if not template then
		warn(string.format(
			"[ShelfVisual] Model untuk '%s' tidak ketemu di %s, slot dibiarkan kosong",
			powerbankId,
			PowerbankModels.FOLDER_PATH_TEXT
		))
		return
	end

	local clone = template:Clone()
	clone.Name = BODY_NAME

	--[[
		Naikkan setengah tinggi slot + setengah tinggi model supaya model duduk
		DI ATAS permukaan slot, bukan tenggelam di tengahnya.

		pivotToBB dipakai karena pivot sebuah Model belum tentu di tengah
		bounding box-nya (tergantung PrimaryPart / cara modelnya dibuat). Tanpa
		koreksi ini, model dengan pivot miring akan melayang atau nyelip.
		Helper-nya dipinjam dari GridUtil supaya matematika pivot cuma ada di
		satu tempat.
	]]
	local size, pivotToBB = GridUtil.getModelBounds(clone)
	local target = slot.CFrame * CFrame.new(0, slot.Size.Y / 2 + size.Y / 2, 0)

	clone:PivotTo(target * pivotToBB:Inverse())

	-- Dipajang, bukan barang fisik: jangan sampai jatuh atau kesenggol player
	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.CanCollide = false
		end
	end

	clone.Parent = slot
end

--[[
	Sembunyikan Part placeholder-nya. Transparency, bukan Parent = nil atau
	Destroy: slotnya tetap harus ada di Workspace karena CFrame-nya yang dipakai
	untuk menghitung posisi body, dan atribut "Item" juga menempel di situ.

	CanCollide dimatikan supaya player tidak menabrak kotak yang tidak kelihatan.
]]
local function hidePlaceholder(slot: BasePart)
	slot.Transparency = 1
	slot.CanCollide = false
	slot.CastShadow = false
end

-- Samakan body di slot dengan atribut "Item"-nya sekarang
local function syncSlot(slot: BasePart)
	clearBody(slot)

	local powerbankId = slot:GetAttribute(ITEM_ATTRIBUTE)

	if powerbankId == nil or powerbankId == "" then
		return -- slot kosong, cukup dibersihkan
	end

	placeBody(slot, powerbankId)
end

--[[
	Sambungkan visual ke sebuah Shelf: pasang body untuk slot yang sudah terisi,
	lalu ikut berubah setiap kali atribut "Item" slot berubah.

	Jangan panggil dua kali untuk rak yang sama — koneksinya akan dobel.
	Pemanggilnya ShelfManager:Register, dan Register sendiri sudah idempoten.
]]
function ShelfVisual.Bind(shelf)
	for _, slotNumber in shelf:GetSlotNumbers() do
		local slot = shelf:GetSlot(slotNumber)

		-- Butuh CFrame & Size untuk menghitung posisi, jadi slot harus BasePart
		if not slot:IsA("BasePart") then
			warn(string.format(
				"[ShelfVisual] slot%d di %s bukan BasePart (%s), body powerbank dilewati",
				slotNumber,
				shelf.Rack:GetFullName(),
				slot.ClassName
			))
			continue
		end

		if HIDE_PLACEHOLDER then
			hidePlaceholder(slot)
		end

		syncSlot(slot)

		slot:GetAttributeChangedSignal(ITEM_ATTRIBUTE):Connect(function()
			syncSlot(slot)
		end)
	end
end

return ShelfVisual
