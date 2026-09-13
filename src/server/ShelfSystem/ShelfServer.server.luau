local Workspace = game:GetService("Workspace")

local ShelfManager = require(script.Parent.ShelfManager)

local rack = Workspace:WaitForChild("ChargingRack")
local shelf = ShelfManager:Register(rack)

-- TESTING: isi satu slot supaya isinya kelihatan di atribut Item slot itu
print(string.format("[ShelfServer] %s: %d slot terbaca", rack.Name, #shelf:GetSlotNumbers()))

-- Yang disimpan ID powerbank (key di PowerbankData), BUKAN display name-nya,
-- supaya konsisten dengan Inventory & ShopStock yang juga pakai id.
local TEST_ITEM_ID = "Basic"
local TestLagi = "Standard"

shelf:AddItem(TestLagi)

local slotNumber = shelf:AddItem(TEST_ITEM_ID)
print(string.format("[ShelfServer] %s -> slot %s", TEST_ITEM_ID, tostring(slotNumber)))
