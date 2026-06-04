-- PlayerDataFactory.lua
-- Fix: Currencies di-init hanya Gold (global). Faction currency diisi
-- saat SelectRaceAndClass, bukan saat Create. Player tidak punya
-- currency faction lain yang tidak relevan.

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

local PlayerDataFactory = {}

local function defaultPT()
	return {
		Melee   = { Level = 1, Exp = 0 },
		Ranged  = { Level = 1, Exp = 0 },
		Launcher= { Level = 1, Exp = 0 },
		Shield  = { Level = 1, Exp = 0 },
		Defense = { Level = 1, Exp = 0 },
		Magic   = { Level = 1, Exp = 0 },
		Unit    = { Level = 1, Exp = 0 },
	}
end

function PlayerDataFactory.Create(player)
	return {
		SchemaVersion = 3,

		UserId  = player.UserId,
		Name    = player.Name,

		Level   = 1,
		Exp     = 0,
		MaxLevel = GameConfig.MaxLevel,

		FactionId        = nil,
		StartingClassId  = nil,
		ClassLevel30Id   = nil,
		ClassLevel40Id   = nil,

		NeedsRaceSelection          = true,
		NeedsStartingClassSelection = true,
		NeedsLevel30ClassSelection  = false,
		NeedsLevel40ClassSelection  = false,

		-- Fix: hanya Gold yang ada dari awal.
		-- Faction currency (MechaCredits / CyborgCredits / ElyndraSignil)
		-- akan ditambahkan oleh CharacterCreationService.SelectRaceAndClass.
		Currencies = {
			Gold = 0,
		},

		Stats = {
			MaxHP = 150,
			HP    = 150,
			MaxFP = 100,
			FP    = 100,
			MaxSP = 100,
			SP    = 100,
		},

		PT = defaultPT(),

		Inventory = {},

		Equipment = {
			Weapon     = nil,
			Armor      = nil,
			Shield     = nil,
			Cloak      = nil,
			Accessory1 = nil,
			Accessory2 = nil,
			Accessory3 = nil,
			Accessory4 = nil,
		},

		ContributionPoints = 0,
		ChaosUntil         = 0,
	}
end

return PlayerDataFactory
