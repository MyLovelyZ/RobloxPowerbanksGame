local ChargerClass = require(script.Parent.Parent.Classes.ChargerClass)

local Chargers = {

	Basic = ChargerClass.new({
		Name = "Basic Charger",
		Image = "rbxassetid://101",
		BuyPrice = 50,
		ChargingRate = 5
	}),

	Fast = ChargerClass.new({
		Name = "Fast Charger",
		Image = "rbxassetid://102",
		BuyPrice = 120,
		ChargingRate = 10
	}),

	Turbo = ChargerClass.new({
		Name = "Turbo Charger",
		Image = "rbxassetid://103",
		BuyPrice = 250,
		ChargingRate = 20
	}),

	Ultra = ChargerClass.new({
		Name = "Ultra Charger",
		Image = "rbxassetid://104",
		BuyPrice = 500,
		ChargingRate = 35
	}),

	Quantum = ChargerClass.new({
		Name = "Quantum Charger",
		Image = "rbxassetid://105",
		BuyPrice = 1000,
		ChargingRate = 60
	})

}

return Chargers