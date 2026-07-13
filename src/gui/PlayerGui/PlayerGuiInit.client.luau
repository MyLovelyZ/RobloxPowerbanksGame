local Player = game:GetService("Players").LocalPlayer

local GuiPlayer = Player:WaitForChild("PlayerGui")
local PlayerGui = GuiPlayer:WaitForChild("PlayerGui") -- this is the main GUI that contains all the other GUIs
PlayerGui.Enabled = true -- enable the PlayerGui so that the player can see the GUI

local ButtonFrame = PlayerGui:WaitForChild("ButtonFrame")
local MoneyFrame = PlayerGui:WaitForChild("MoneyFrame")
local GuiFolder = PlayerGui:WaitForChild("GuiFolder")

-- Initialize inside the ButtonFrame

local BuildButton = ButtonFrame:WaitForChild("BuildButton")
local InventoryButton = ButtonFrame:WaitForChild("InventoryButton")
local PremiumStoreButton = ButtonFrame:WaitForChild("PremiumStoreButton")
local SettingsButton = ButtonFrame:WaitForChild("SettingsButton")
local StoreOverviewButton = ButtonFrame:WaitForChild("StoreOverviewButton")

-- Initialize inside the MoneyFrame

local ImageLabelZP = MoneyFrame:WaitForChild("ImageLabelZP") -- this is the image of the money icon
local TextDuit = MoneyFrame:WaitForChild("TextDuit") -- this is the text that shows the amount of money the player has
local AddMoneyButton = MoneyFrame:WaitForChild("AddMoneyButton") -- this is the button that the player can click to add money (will lead to shop or premium store)

-- Initialize inside the GuiFolder

local BuildFrame = GuiFolder:WaitForChild("BuildFrame")
--still a lot of things to initialize inside the GuiFolder, but for now we will just initialize the BuildFrame and its children because its the most important feature to add right now in the game

-- Initialize inside the BuildFrame
local function initializeBuildFrame()
    local BuildButton = BuildFrame:WaitForChild("BuildButton") -- this is the button that the player can click to start building it will open the AddBuildingFrame and show the items that the player can add to their build area
    local MoveButton = BuildFrame:WaitForChild("MoveButton") -- this is the button that the player can click to move an item
    local CopyButton = BuildFrame:WaitForChild("CopyButton") -- this is the button that the player can click to copy an item
    local DeleteButton = BuildFrame:WaitForChild("DeleteButton") -- this is the button that the player can click to delete an item

    local AddBuildingFrame = BuildFrame:WaitForChild("AddBuildingFrame") -- this is the frame that contains the items that the player can add to their build area

    -- inside the AddBuildingFrame

    local CloseButton = AddBuildingFrame:WaitForChild("CloseButton"):WaitForChild("CloseButton") -- this is the button that the player can click to close the AddBuildingFrame
    local InfoFrame = AddBuildingFrame:WaitForChild("InfoFrame") -- this is the frame that contains the information about the selected item
    local ScrollingFrame = AddBuildingFrame:WaitForChild("ScrollingFrame") -- this is the frame that contains the items that the player can add to their build area

    local function InitializeScrollingFrame()
        local BuildingItems = ScrollingFrame:WaitForChild("BuildingItemsTemplate") -- this is the frame that contains the items that the player can add to their build area
        BuildingItems.Visible = false -- this is to hide the template so that it doesn't show up in the scrolling frame
    end

    local function InitializeInfoFrame()
        local PriceButton = InfoFrame:WaitForChild("PriceFrame"):WaitForChild("PriceButton")
        local ItemImage = InfoFrame:WaitForChild("ItemImage")
        local ItemName = InfoFrame:WaitForChild("ItemName")
        local ItemDesc = InfoFrame:WaitForChild("ItemDesc")

        -- otehr

        PriceButton.Visible = true
        ItemImage.Visible = true
        ItemName.Visible = true
        ItemDesc.Visible = true
    end

    BuildButton.Visible = true
    MoveButton.Visible = true
    CopyButton.Visible = true
    DeleteButton.Visible = true
    CloseButton.Visible = true
    InfoFrame.Visible = false
    ScrollingFrame.Visible = true

    InitializeScrollingFrame()
    InitializeInfoFrame()
end

-- Initialize the Functions

initializeBuildFrame()