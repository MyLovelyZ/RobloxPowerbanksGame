local Player = game:GetService("Players").LocalPlayer

local PlayerGui = Player:WaitForChild("PlayerGui")
local MainGui = PlayerGui:WaitForChild("MainGui")
local MoneyFrame = MainGui:WaitForChild("MoneyFrame")
local TextDuit = MoneyFrame:WaitForChild("TextDuit")

local DuitValue = Player:WaitForChild("PlayerData"):WaitForChild("Duit")

local function formatNumber(num)
	return tostring(num):reverse():gsub("(%d%d%d)", "%1."):reverse():gsub("^%.", "")
end

TextDuit.Text = formatNumber(DuitValue.Value)

DuitValue:GetPropertyChangedSignal("Value"):Connect(function()
	TextDuit.Text = formatNumber(DuitValue.Value)
end)