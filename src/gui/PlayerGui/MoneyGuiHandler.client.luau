local Player = game.Players.LocalPlayer
local GuiPlayer = Player:WaitForChild("PlayerGui")
local PlayerGui = GuiPlayer:WaitForChild("PlayerGui")

local MoneyFrame = PlayerGui:WaitForChild("MoneyFrame")
local TextDuit = MoneyFrame:WaitForChild("TextDuit")

-- soon adding functionality to AddMoneyButton to open the shop or premium store when it clicked

local Duit = Player:WaitForChild("PlayerData"):WaitForChild("Duit")

local function updateMoneyDisplay()
    TextDuit.Text = tostring(Duit.Value)
end

updateMoneyDisplay()

Duit.Changed:Connect(updateMoneyDisplay)