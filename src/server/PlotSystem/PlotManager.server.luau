local Players = game:GetService("Players")
local PlotsFolder = workspace:WaitForChild("PlayersPlots")

local function getFreePlot()
    local LowestPlot = nil
    local LowestNumber = math.huge

    for _, Plot in pairs(PlotsFolder:GetChildren()) do
        local Owner = Plot:FindFirstChild("Owner")

        if Owner and Owner.value == nil then
            local Number = tonumber(Plot.Name:match("%d+"))

            if Number and Number < LowestNumber then
                LowestNumber = Number
                LowestPlot = Plot
            end
        end
    end

    return LowestPlot
end

local function assignPlot(Player)
    local Plot = getFreePlot()

    if Plot then
        Plot.Owner.Value = Player
        print(Player.name.." Mendapatkan"..Plot.Name)
    end
end

local function releasePlot(Player)
    for _, Plot in pairs(PlotsFolder:GetChildren()) do
        local Owner = Plot:FindFirstChild("Owner")

        if Owner and Owner.Value == Player then
            Owner.Value = nil
            print(Player.name.." Melepaskan"..Plot.Name)
        end
    end
end

Players.PlayerAdded:Connect(assignPlot)
Players.PlayerRemoving:Connect(releasePlot)