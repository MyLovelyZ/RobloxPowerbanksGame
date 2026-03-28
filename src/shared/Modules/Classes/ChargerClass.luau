local Charger = {}
Charger.__index = Charger

function Charger.new(config)
	local self = setmetatable({}, Charger)

	self.Name = config.Name
	self.Image = config.Image
	self.BuyPrice = config.BuyPrice

	self.BaseChargingRate = config.ChargingRate

	return self
end

function Charger:GetChargingRate()
	return self.BaseChargingRate
end

return Charger