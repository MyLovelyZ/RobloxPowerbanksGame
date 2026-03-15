local Powerbank = {}
Powerbank.__index = Powerbank

function Powerbank.new(config)

	local self = setmetatable({}, Powerbank)

	self.Name = config.Name
	self.Image = config.Image
	self.BuyPrice = config.BuyPrice
	self.SellPrice = config.SellPrice
	self.ChargeTime = config.ChargeTime
	self.MaxCharge = config.MaxCharge

	return self

end 

function Powerbank:IsFull(currentCharge)

	return currentCharge >= self.MaxCharge

end

function Powerbank:GetChargePerSecond()

	return self.MaxCharge / self.ChargeTime

end

return Powerbank