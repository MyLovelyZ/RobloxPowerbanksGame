local Players = game:GetService("Players")

local PlotsFolder = workspace.Maps.Plots

Players.PlayerAdded:Connect(function(Player)

	local PlotNumber = Instance.new("IntValue")
	PlotNumber.Name = "PlotNumber"
	PlotNumber.Parent = Player

	for _, Plot in pairs(PlotsFolder:GetChildren()) do
		local Owner = Plot:FindFirstChild("Owner")

		if Owner and Owner.Value == nil then
			Owner.Value = Player
			PlotNumber.Value = tonumber(Plot.Name)
			break
		end
	end

	if PlotNumber.Value == 0 then
		Player:Kick("Server Penuh")
	end

	local PlotFolder = PlotsFolder:FindFirstChild(tostring(PlotNumber.Value))

	Player.CharacterAdded:Connect(function(character)
		local TeleportPart = PlotFolder.Teleport
		character:PivotTo(TeleportPart.CFrame)
	end)

	local Sign = PlotFolder.Sign
	Sign.PlayerDisplay.SurfaceGui.PlayerName.Text = Player.Name .. "'s Plot"

	local ThumbnailType = Enum.ThumbnailType.HeadShot
	local ThumbnailSize = Enum.ThumbnailSize.Size420x420

	local PlayerIcon = Players:GetUserThumbnailAsync(Player.UserId, ThumbnailType, ThumbnailSize)

	Sign.PlayerDisplay.SurfaceGui.PlayerIcon.Image = PlayerIcon
	Sign.PlayerDisplay.SurfaceGui.Enabled = true

end)