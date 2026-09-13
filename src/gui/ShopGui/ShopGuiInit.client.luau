-- Initialize the Shop GUI
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local shopGui = playerGui:WaitForChild("ShopGui")
local mainframe = shopGui:WaitForChild("MainFrame")

local scrollingShopItem = mainframe:WaitForChild("ScrollingShopItems")
local itemTemplate = scrollingShopItem:WaitForChild("ItemShopTemplate")



-- Close button doang
local closeButton = mainframe:WaitForChild("CloseButton")
closeButton.MouseButton1Click:Connect(function()
    mainframe.Visible = false
end)

local function initializeShopGui()
    shopGui.Enabled = true
    mainframe.Visible = false
    itemTemplate.Visible = false
end

initializeShopGui()

