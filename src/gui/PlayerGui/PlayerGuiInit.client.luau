local Player = game:GetService("Players").LocalPlayer

local GuiPlayer = Player:WaitForChild("PlayerGui")
local PlayerGui = GuiPlayer:WaitForChild("PlayerGui") -- this is the main GUI that contains all the other GUIs
PlayerGui.Enabled = true -- enable the PlayerGui so that the player can see the GUI

local ButtonFrame = PlayerGui:WaitForChild("ButtonFrame")
local MoneyFrame = PlayerGui:WaitForChild("MoneyFrame")
local GuiFolder = PlayerGui:WaitForChild("GuiFolder")

-- Initialize inside the ButtonFrame

local INACTIVE_BUTTON_COLOR = Color3.fromRGB(147, 248, 255)
local ACTIVE_BUTTON_COLOR = Color3.fromRGB(0, 255, 170)

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
local InventoryFrame = GuiFolder:WaitForChild("InventoryFrame")
local PremiumStoreFrame = GuiFolder:WaitForChild("PremiumStoreFrame")
local SettingsFrame = GuiFolder:WaitForChild("SettingsFrame")
local StoreOverviewFrame = GuiFolder:WaitForChild("StoreOverviewFrame")

local function InitializeGuiFolder()
    BuildFrame.Visible = false
    InventoryFrame.Visible = false
    PremiumStoreFrame.Visible = false
    SettingsFrame.Visible = false
    StoreOverviewFrame.Visible = false
end

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

        -- other

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

local function initializeInventoryFrame()
    local function InitializeMainInventoryFrame()
        -- ini bagian main inventory frame
        local MainInventoryFrame = InventoryFrame:WaitForChild("MainInventoryFrame")

        -- Buat bagian close buttonnya
        local CloseButton = MainInventoryFrame:WaitForChild("CloseButton"):WaitForChild("CloseButton")
        CloseButton.MouseButton1Click:Connect(function()
            InventoryFrame.Visible = false
        end)

        -- Bagian Button bawah
        local AllButton = MainInventoryFrame:WaitForChild("AllFrame"):WaitForChild("AllButton")
        local EmptyButton = MainInventoryFrame:WaitForChild("EmptyFrame"):WaitForChild("EmptyButton")
        local FullButton = MainInventoryFrame:WaitForChild("FullFrame"):WaitForChild("FullButton")

        -- Bagian ScrollingFrame
        local ScrollingItems = MainInventoryFrame:WaitForChild("ScrollingItems")
        local ItemTemplate = ScrollingItems:WaitForChild("ImageButtonFrame1")
    end

    local function InitializeCheckItemsFrame()
        -- nah ini bagian CheckItems
        local CheckItems = InventoryFrame:WaitForChild("CheckItems")
        local ItemName = CheckItems:WaitForChild("Name")
        local ItemImage = CheckItems:WaitForChild("Picture")

    end

    local function InitializeButtonInventoryFrame()
        local ChargerButton = InventoryFrame:WaitForChild("ChargerButton")
        local PowerBankButton = InventoryFrame:WaitForChild("PowerBankButton")
    end

    InitializeMainInventoryFrame()
    InitializeCheckItemsFrame()
    InitializeButtonInventoryFrame()
end

-- The Function for all the button frame

local function initializeButtonFrame()
    BuildButton.Visible = true --partnernya BuildFrame
    InventoryButton.Visible = true
    PremiumStoreButton.Visible = true
    SettingsButton.Visible = true
    StoreOverviewButton.Visible = true

    -- fungsinya

    BuildButton.MouseButton1Click:Connect(function()
        local WasVisible = BuildFrame.Visible

        InitializeGuiFolder()
        BuildFrame.Visible = not WasVisible

        if BuildFrame.Visible then
            BuildButton.BackgroundColor3 = ACTIVE_BUTTON_COLOR
        else
            BuildButton.BackgroundColor3 = INACTIVE_BUTTON_COLOR
        end
    end)

    InventoryButton.MouseButton1Click:Connect(function()
        local WasVisible = InventoryFrame.Visible

        InitializeGuiFolder()
        InventoryFrame.Visible = not WasVisible

        if InventoryFrame.Visible then
            InventoryButton.BackgroundColor3 = ACTIVE_BUTTON_COLOR
        else
            InventoryButton.BackgroundColor3 = INACTIVE_BUTTON_COLOR
        end
    end)

    PremiumStoreButton.MouseButton1Click:Connect(function()
        local WasVisible = PremiumStoreFrame.Visible

        InitializeGuiFolder()
        PremiumStoreFrame.Visible = not WasVisible

        if PremiumStoreFrame.Visible then
            PremiumStoreButton.BackgroundColor3 = ACTIVE_BUTTON_COLOR
        else
            PremiumStoreButton.BackgroundColor3 = INACTIVE_BUTTON_COLOR
        end
    end)

    SettingsButton.MouseButton1Click:Connect(function()
        local WasVisible = SettingsFrame.Visible

        InitializeGuiFolder()
        SettingsFrame.Visible = not WasVisible

        if SettingsFrame.Visible then
            SettingsButton.BackgroundColor3 = ACTIVE_BUTTON_COLOR
        else
            SettingsButton.BackgroundColor3 = INACTIVE_BUTTON_COLOR
        end
    end)

    StoreOverviewButton.MouseButton1Click:Connect(function()
        local WasVisible = StoreOverviewFrame.Visible

        InitializeGuiFolder()
        StoreOverviewFrame.Visible = not WasVisible

        if StoreOverviewFrame.Visible then
            StoreOverviewButton.BackgroundColor3 = ACTIVE_BUTTON_COLOR
        else
            StoreOverviewButton.BackgroundColor3 = INACTIVE_BUTTON_COLOR
        end
    end)
end

-- Initialize the Functions
    
InitializeGuiFolder()
initializeButtonFrame()
initializeBuildFrame()
initializeInventoryFrame()