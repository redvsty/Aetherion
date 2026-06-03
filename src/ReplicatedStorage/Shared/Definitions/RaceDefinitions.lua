local GameConfig = require(script.Parent.Parent.GameConfig)
local CurrencyDefinitions = require(script.Parent.CurrencyDefinitions)

local RaceDefinitions = {
	[GameConfig.Factions.MECHA] = {
		Id = GameConfig.Factions.MECHA,
		DisplayName = "Asterion Mechanica",
		CurrencyId = CurrencyDefinitions.GetFactionCurrencyId(GameConfig.Factions.MECHA),

		AllowedStartingClasses = {
			GameConfig.StartingClasses.Warrior,
			GameConfig.StartingClasses.Ranger,
			GameConfig.StartingClasses.Spiritualist,
			GameConfig.StartingClasses.Specialist,
		},

		CanUseMagic = true,
		MagicSchool = "Holy",
		CanUseLauncher = false,
		CanUseUnit = true,
		SpawnLocationId = "mecha_hq_spawn",
	},

	[GameConfig.Factions.CYBORG] = {
		Id = GameConfig.Factions.CYBORG,
		DisplayName = "Iron Dominion",
		CurrencyId = CurrencyDefinitions.GetFactionCurrencyId(GameConfig.Factions.CYBORG),

		AllowedStartingClasses = {
			GameConfig.StartingClasses.Warrior,
			GameConfig.StartingClasses.Ranger,
			GameConfig.StartingClasses.Specialist,
		},

		CanUseMagic = false,
		MagicSchool = nil,
		CanUseLauncher = true,
		CanUseUnit = false,
		SpawnLocationId = "cyborg_hq_spawn",
	},

	[GameConfig.Factions.MYSTIC] = {
		Id = GameConfig.Factions.MYSTIC,
		DisplayName = "Elyndra Covenant",
		CurrencyId = CurrencyDefinitions.GetFactionCurrencyId(GameConfig.Factions.MYSTIC),

		AllowedStartingClasses = {
			GameConfig.StartingClasses.Warrior,
			GameConfig.StartingClasses.Ranger,
			GameConfig.StartingClasses.Spiritualist,
			GameConfig.StartingClasses.Specialist,
		},

		CanUseMagic = true,
		MagicSchool = "Dark",
		CanUseLauncher = false,
		CanUseUnit = false,
		SpawnLocationId = "mystic_hq_spawn",
	},
}

function RaceDefinitions.IsValidRace(factionId)
	return RaceDefinitions[factionId] ~= nil
end

function RaceDefinitions.IsClassAllowed(factionId, classId)
	local race = RaceDefinitions[factionId]

	if not race then
		return false
	end

	for _, allowedClassId in ipairs(race.AllowedStartingClasses) do
		if allowedClassId == classId then
			return true
		end
	end

	return false
end

return RaceDefinitions
