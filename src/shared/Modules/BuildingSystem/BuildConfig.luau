--[[
	BuildConfig
	Semua pengaturan building system ada di sini.

	LOKASI PENTING:
	- Template item yang bisa di-place : ReplicatedStorage > BuildingItems (Folder berisi Model)
	  Setiap item harus berupa Model. Ukuran item sebaiknya kelipatan GRID_SIZE
	  (contoh: grid 4 -> item 4x4, 8x4, dst) supaya pas dengan kotak grid.
	- Area build                       : Part di Workspace bernama "BuildArea"
	  Di luar Part ini player TIDAK bisa build. Ukuran X/Z part sebaiknya
	  kelipatan GRID_SIZE supaya kotak grid pas sampai pinggir.
	- Hasil build                      : Workspace > PlacedItems (Folder)
]]

local BuildConfig = {
	-- Ukuran 1 kotak grid dalam stud. Item akan snap ke kotak-kotak ini.
	GRID_SIZE = 4,

	-- Derajat rotasi setiap kali tombol rotasi ditekan
	ROTATION_STEP = 90,

	-- Nama Part area build di Workspace
	BUILD_AREA_NAME = "BuildArea",

	-- Nama Folder template item di ReplicatedStorage
	ITEMS_FOLDER_NAME = "BuildingItems",

	-- Nama Folder hasil build di Workspace
	PLACED_FOLDER_NAME = "PlacedItems",

	-- Nama Folder RemoteEvent di ReplicatedStorage (dibuat otomatis oleh server)
	REMOTES_FOLDER_NAME = "BuildingRemotes",

	-- Nama BindableEvent (client-side) untuk komunikasi GUI -> BuildingController
	-- GUI kamu cukup memanggil: signal:Fire("NamaItem") untuk mulai, signal:Fire(nil) untuk batal
	SELECT_SIGNAL_NAME = "BuildSelectItem",

	-- Jarak maksimal player boleh menaruh item (stud)
	MAX_PLACE_DISTANCE = 100,

	-- Kontrol
	KEY_ROTATE = Enum.KeyCode.R,
	KEY_CANCEL = Enum.KeyCode.X,
}

return BuildConfig
