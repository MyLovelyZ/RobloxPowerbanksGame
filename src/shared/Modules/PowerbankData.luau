local PowerbankClass = require(script.Parent.PowerbankClass)

local Powerbanks = {

	Basic = PowerbankClass.new({

		Name = "Basic Powerbank",
		Image = "rbxassetid://123",
		BuyPrice = 100,
		SellPrice = 200,
		ChargeTime = 60,
		MaxCharge = 100

	}),

	Pro = PowerbankClass.new({

		Name = "Pro Powerbank",
		Image = "rbxassetid://456",
		BuyPrice = 500,
		SellPrice = 900,
		ChargeTime = 40,
		MaxCharge = 200

	}),

	Ultra = PowerbankClass.new({

		Name = "Ultra Powerbank",
		Image = "rbxassetid://789",
		BuyPrice = 2000,
		SellPrice = 4000,
		ChargeTime = 20,
		MaxCharge = 500

	})

}

return Powerbanks