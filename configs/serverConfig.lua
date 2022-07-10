Auth = exports.plouffe_lib:Get("Auth")
Callback = exports.plouffe_lib:Get("Callback")

Server = {
	Init = false,
	ActiveLoans = {},
	MinPlaytime = 604800
}

Bank = {}
BankFnc = {} 

Bank.Player = {}

Bank.Utils = {
	ped = 0,
	pedCoords = vector3(0,0,0),
	inCar = false,
    carId = 0,
	isCuffed = false,
	currentPropList = {},
	currentProp = 0,
	nuiActive = false,
	coolDown = false
}

Bank.Zones = {
	banking_pacifique_0 = {
		name = "banking_pacifique_0",
		coords = vector3(268.1848449707, 217.5004119873, 106.28217315674),
		maxDst = 1.5,
		protectEvents = true,
		isKey = true,
		isZone = true,
		isPed = true,
		nuiLabel = "Parler avec le banquier",
		aditionalParams = {fnc = "InteractionMenu"},
		keyMap = {
			checkCoordsBeforeTrigger = true,
			onRelease = true,
			releaseEvent = "plouffe_banking:zone_action",
			key = "E"
		},
		pedInfo = {
			coords = vector3(269.4323425293, 217.25547790527, 106.28217315674),
			heading = 70.756019592285,
			model = 'ig_marnie', 
			scenario = 'WORLD_HUMAN_COP_IDLES',
			pedId = 0,
		}
	}
}

Bank.LoanList = {
	{
		amount = 25000,
		interest = 10000,
		bankMin = -15000,
		payment = 2500
	},

	{
		amount = 50000,
		interest = 15000,
		bankMin = 10000,
		payment = 5000
	},

	{
		amount = 75000,
		interest = 25000,
		bankMin = 20000,
		payment = 7500
	},

	{
		amount = 100000,
		interest = 35000,
		bankMin = 30000,
		payment = 10000
	},

	{
		amount = 150000,
		interest = 40000,
		bankMin = 40000,
		payment = 15000
	},

	{
		amount = 200000,
		interest = 50000,
		bankMin = 50000,
		payment = 20000
	},

	{
		amount = 250000,
		interest = 55000,
		bankMin = 50000,
		payment = 25000
	}
}

Bank.Menu = {
	interaction = {
		{
			id = 1,
			header = "Prêts personnel",
			txt = "Voir vos prêts personnel",
			params = {
				event = "",
				args = {
					fnc = "ShowPersonnalLoans"
				}
			}
		},
		{
			id = 2,
			header = "Demander un prêt",
			txt = "Voir la liste des prêts possible a demander",
			params = {
				event = "",
				args = {
					fnc = "SeeLoansList"
				}
			}
		}
	},
}