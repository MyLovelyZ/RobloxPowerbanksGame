local Charger = {}
Charger.__index = Charger

function Charger.new(config)

	local self = setmetatable({}, Charger)

	self.Name = config.Name
	self.Image = config.Image
	self.BuyPrice = config.BuyPrice
	self.ChargingSpeed = config.ChargingSpeed

	return self

end 

return Charger