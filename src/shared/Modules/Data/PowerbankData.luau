local PowerbankClass = require(script.Parent.Parent.Classes.PowerbankClass)

local Powerbanks = {

	Basic = PowerbankClass.new({
		Name = "Basic Powerbank",
		Image = "rbxassetid://201",
		BuyPrice = 100,
		SellPrice = 50,
		MaxCharge = 100,
		CurrentCharge = 0
	}),

	Standard = PowerbankClass.new({
		Name = "Standard Powerbank",
		Image = "rbxassetid://202",
		BuyPrice = 250,
		SellPrice = 125,
		MaxCharge = 250,
		CurrentCharge = 0
	}),

	Advanced = PowerbankClass.new({
		Name = "Advanced Powerbank",
		Image = "rbxassetid://203",
		BuyPrice = 500,
		SellPrice = 250,
		MaxCharge = 500,
		CurrentCharge = 0
	}),

	Pro = PowerbankClass.new({
		Name = "Pro Powerbank",
		Image = "rbxassetid://204",
		BuyPrice = 900,
		SellPrice = 450,
		MaxCharge = 900,
		CurrentCharge = 0
	}),

	Ultra = PowerbankClass.new({
		Name = "Ultra Powerbank",
		Image = "rbxassetid://205",
		BuyPrice = 1500,
		SellPrice = 750,
		MaxCharge = 1500,
		CurrentCharge = 0
	})

}

return Powerbanks