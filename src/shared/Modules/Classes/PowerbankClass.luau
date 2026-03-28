local Powerbank = {}
Powerbank.__index = Powerbank

function Powerbank.new(config)
	local self = setmetatable({}, Powerbank)

	self.Name = config.Name
	self.Image = config.Image
	self.BuyPrice = config.BuyPrice
	self.SellPrice = config.SellPrice

	self.BaseMaxCharge = config.MaxCharge
	self.CurrentCharge = config.CurrentCharge or 0

	return self
end

function Powerbank:GetMaxCharge()
	return self.BaseMaxCharge
end

function Powerbank:IsFull()
	return self.CurrentCharge >= self:GetMaxCharge()
end

function Powerbank:AddCharge(amount)
	local max = self:GetMaxCharge()

	self.CurrentCharge += amount

	if self.CurrentCharge > max then
		self.CurrentCharge = max
	end
end

return Powerbank