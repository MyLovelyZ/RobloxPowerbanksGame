local ReplicatedStorege = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlotHolders = Instance.new("Folder")
PlotHolders.Parent = ReplicatedStorege
PlotHolders.Name = "PlotHolders"

Players.PlayerAdded:Connect(function(Player)

	local PlotNumber = Instance.new("IntValue")
	PlotNumber.Name = "PlotNumber"
	PlotNumber.Parent = Player

	for i = 1, 8  do
		if PlotHolders:FindFirstChild(i) then
			continue
		end
		local ClaimPlot = Instance.new("ObjectValue")
		ClaimPlot.Parent = PlotHolders
		ClaimPlot.Name = i
		ClaimPlot.Value = Player

		PlotNumber.Value = i

		break
	end

	if PlotNumber.Value == 0 then
		Player:Kick("Server Penuh")
	end

	local PlotFolder = workspace.Maps.Plots:FindFirstChild(PlotNumber.Value)
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