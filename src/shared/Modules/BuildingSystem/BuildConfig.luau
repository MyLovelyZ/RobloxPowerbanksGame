--[[
	BuildConfig
	Semua pengaturan building system ada di sini.

	LOKASI PENTING:
	- Template item yang bisa di-place : ReplicatedStorage > BuildingItems (Folder berisi Model)
	  Setiap item harus berupa Model. Ukuran item sebaiknya kelipatan GRID_SIZE
	  (contoh: grid 4 -> item 4x4, 8x4, dst) supaya pas dengan kotak grid.
	- Plot player                      : workspace > Maps > Plots > "1", "2", ...
	- Area build                       : plot > Building > "Bawah<level>" (Part atau Model),
	  sama dengan spawn point yang dipakai BuildingLoader. Level diambil dari
	  PlayerData.PlotLevel, jadi area build ikut naik saat plot di-upgrade.
	  Player hanya bisa build di area milik plot-nya sendiri. Ukuran X/Z area
	  sebaiknya kelipatan GRID_SIZE supaya kotak grid pas sampai pinggir.
	- Hasil build                      : Folder "PlacedItems" DI DALAM SETIAP PLOT
	  (dibuat otomatis oleh BuildingServer).
]]

local BuildConfig = {
	-- Ukuran 1 kotak grid dalam stud. Item akan snap ke kotak-kotak ini.
	GRID_SIZE = 4,

	-- Derajat rotasi setiap kali tombol rotasi ditekan
	ROTATION_STEP = 90,

	-- Lokasi folder plot di Workspace (workspace > Maps > Plots)
	MAPS_FOLDER_NAME = "Maps",
	PLOTS_FOLDER_NAME = "Plots",

	-- Nama Folder di dalam plot yang berisi spawn point bangunan
	BUILDING_FOLDER_NAME = "Building",

	-- Prefix nama area build di dalam folder Building.
	-- Area build = "Bawah" .. PlotLevel (contoh: Bawah1, Bawah2), boleh Part atau Model.
	BUILD_AREA_PREFIX = "Bawah",

	-- Nama Folder template item di ReplicatedStorage
	ITEMS_FOLDER_NAME = "BuildingItems",

	-- Nama Folder hasil build DI DALAM setiap plot (dibuat otomatis oleh server)
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
