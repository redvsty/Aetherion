local GameConfig = require(script.Parent.Parent.GameConfig)

local ClassDefinitions = {}

ClassDefinitions.Starting = {
	Warrior = {
		Id = "Warrior",
		DisplayName = "Warrior",
		Role = "Melee",
		PreferredPT = GameConfig.PTTypes.Melee,

		StarterWeaponByFaction = {
			MECHA = "mecha_training_blade_001",
			CYBORG = "cyborg_training_blade_001",
			MYSTIC = "mystic_training_blade_001",
		},
	},

	Ranger = {
		Id = "Ranger",
		DisplayName = "Ranger",
		Role = "Ranged",
		PreferredPT = GameConfig.PTTypes.Ranged,

		StarterWeaponByFaction = {
			MECHA = "mecha_training_rifle_001",
			CYBORG = "cyborg_training_launcher_001",
			MYSTIC = "mystic_training_bow_001",
		},
	},

	Spiritualist = {
		Id = "Spiritualist",
		DisplayName = "Spiritualist",
		Role = "Magic",
		PreferredPT = GameConfig.PTTypes.Magic,

		StarterWeaponByFaction = {
			MECHA = "mecha_training_reaver_001",
			MYSTIC = "mystic_training_staff_001",
		},
	},

	Specialist = {
		Id = "Specialist",
		DisplayName = "Specialist",
		Role = "SupportCraft",
		PreferredPT = GameConfig.PTTypes.Defense,

		StarterWeaponByFaction = {
			MECHA = "mecha_training_tool_001",
			CYBORG = "cyborg_training_tool_001",
			MYSTIC = "mystic_training_tool_001",
		},
	},
}

ClassDefinitions.Advancement30 = {
	MECHA = {
		Warrior = { "MechaGuardian", "MechaBruiser" },
		Ranger = { "PulseSniper", "ReconRunner" },
		Spiritualist = { "LightWeaver", "BioMender" },
		Specialist = { "ArmorDriver", "FieldEngineer" },
	},

	CYBORG = {
		Warrior = { "SteelDestroyer", "ShieldBreaker" },
		Ranger = { "SiegeGunner", "StealthScout" },
		Specialist = { "MechanicEngineer" },
	},

	MYSTIC = {
		Warrior = { "RuneKnight", "SpiritGuard" },
		Ranger = { "ShadowArcher", "WindStalker" },
		Spiritualist = { "DarkInvoker", "AnimusCaller" },
		Specialist = { "SoulArtisan", "RuneEngineer" },
	},
}

ClassDefinitions.Advancement40 = {
	MECHA = {
		MechaGuardian = { "AegisCommander", "TitanVanguard" },
		MechaBruiser = { "ShockBerserker", "IronWarden" },
		PulseSniper = { "RailgunMarksman", "Overwatch" },
		ReconRunner = { "GhostRunner", "MineLayer" },
		LightWeaver = { "SanctuaryPriest", "SolarInvoker" },
		BioMender = { "LifeTechnician", "DefenseMedic" },
		ArmorDriver = { "GoliathPilot", "CatapultPilot" },
		FieldEngineer = { "TowerArchitect", "WarMechanic" },
	},

	CYBORG = {
		SteelDestroyer = { "Punisher", "Assaulter" },
		ShieldBreaker = { "Mercenary", "Assaulter" },
		SiegeGunner = { "Striker", "Dementer" },
		StealthScout = { "PhantomShadow", "Dementer" },
		MechanicEngineer = { "Scientist", "BattleLeader" },
	},

	MYSTIC = {
		RuneKnight = { "TemplarShade", "BloodChampion" },
		SpiritGuard = { "SoulDefender", "DarkTemplar" },
		ShadowArcher = { "NightSeeker", "StormArcher" },
		WindStalker = { "PhantomWind", "BeastHunter" },
		DarkInvoker = { "Warlock", "DarkPriest" },
		AnimusCaller = { "SummonMaster", "SoulBinder" },
		SoulArtisan = { "ArcaneSmith", "SpiritMechanic" },
		RuneEngineer = { "RuneArchitect", "SupportOracle" },
	},
}

function ClassDefinitions.IsValidStartingClass(classId)
	return ClassDefinitions.Starting[classId] ~= nil
end

-- Kembalikan Role dari starting class player ("Melee", "Ranged", "Magic", "SupportCraft").
-- Digunakan CombatService untuk gate Force Attack ke Magic class saja.
-- Jika player belum punya StartingClassId, return nil.
function ClassDefinitions.GetStartingClassRole(playerData)
	if not playerData or not playerData.StartingClassId then
		return nil
	end

	local classDef = ClassDefinitions.Starting[playerData.StartingClassId]
	return classDef and classDef.Role or nil
end

function ClassDefinitions.GetLevel30Options(factionId, startingClassId)
	local raceTable = ClassDefinitions.Advancement30[factionId]
	return raceTable and raceTable[startingClassId] or nil
end

function ClassDefinitions.GetLevel40Options(factionId, level30ClassId)
	local raceTable = ClassDefinitions.Advancement40[factionId]
	return raceTable and raceTable[level30ClassId] or nil
end

function ClassDefinitions.ContainsOption(options, value)
	if not options then
		return false
	end

	for _, option in ipairs(options) do
		if option == value then
			return true
		end
	end

	return false
end

return ClassDefinitions
