local GameConfig = require(script.Parent.Parent.GameConfig)

local ClassDefinitions = {}

-- ============================================================
-- RF Classic stat scaling per class:
--   BaseHP/FP/SP = nilai saat level 1 (sebelum race modifier)
--   HPPerLevel/FPPerLevel/SPPerLevel = gain per level naik
--
-- Warrior  : HP tinggi, FP rendah, SP medium
-- Ranger   : HP medium, FP rendah, SP tinggi (banyak gerak)
-- Spiritualist: HP rendah, FP tinggi, SP rendah
-- Specialist: HP medium, FP medium, SP tinggi (banyak tools)
-- ============================================================

ClassDefinitions.Starting = {
	Warrior = {
		Id = "Warrior",
		DisplayName = "Warrior",
		Description = "Front-line melee fighter. Highest HP, built for sustained combat.",
		Role = "Melee",
		PreferredPT = GameConfig.PTTypes.Melee,

		-- Stat base + scaling per level
		StatScaling = {
			BaseHP = 200,  HPPerLevel = 25,
			BaseFP = 80,   FPPerLevel = 4,
			BaseSP = 200,  SPPerLevel = 8,
		},

		StarterWeaponByFaction = {
			MECHA  = "mecha_training_blade_001",
			CYBORG = "cyborg_training_blade_001",
			MYSTIC = "mystic_training_blade_001",
		},
	},

	Ranger = {
		Id = "Ranger",
		DisplayName = "Ranger",
		Description = "Ranged attacker and scout. High stamina for long pursuit.",
		Role = "Ranged",
		PreferredPT = GameConfig.PTTypes.Ranged,

		StatScaling = {
			BaseHP = 160,  HPPerLevel = 18,
			BaseFP = 80,   FPPerLevel = 4,
			BaseSP = 220,  SPPerLevel = 10,
		},

		StarterWeaponByFaction = {
			MECHA  = "mecha_training_rifle_001",
			CYBORG = "cyborg_training_launcher_001",
			MYSTIC = "mystic_training_bow_001",
		},
	},

	Spiritualist = {
		Id = "Spiritualist",
		DisplayName = "Spiritualist",
		Description = "Force caster and healer. Highest FP, fragile in direct combat.",
		Role = "Magic",
		PreferredPT = GameConfig.PTTypes.Magic,

		StatScaling = {
			BaseHP = 130,  HPPerLevel = 12,
			BaseFP = 160,  FPPerLevel = 20,
			BaseSP = 180,  SPPerLevel = 5,
		},

		StarterWeaponByFaction = {
			MECHA  = "mecha_training_reaver_001",
			CYBORG = "cyborg_training_reaver_001",
			MYSTIC = "mystic_training_staff_001",
		},
	},

	Specialist = {
		Id = "Specialist",
		DisplayName = "Specialist",
		Description = "Engineer and support. Blood Ammo heal (CYBORG), crafting, and traps.",
		Role = "SupportCraft",
		PreferredPT = GameConfig.PTTypes.Defense,

		StatScaling = {
			BaseHP = 150,  HPPerLevel = 15,
			BaseFP = 100,  FPPerLevel = 8,
			BaseSP = 220,  SPPerLevel = 10,
		},

		StarterWeaponByFaction = {
			MECHA  = "mecha_training_tool_001",
			CYBORG = "cyborg_training_tool_001",
			MYSTIC = "mystic_training_tool_001",
		},
	},
}

-- ============================================================
-- Level 30 Advancement — 2 pilihan per starting class per ras
-- Semua ras memiliki Spiritualist di L30 (RF Classic accurate)
-- ============================================================

ClassDefinitions.Advancement30 = {
	MECHA = {
		Warrior      = { "MechaGuardian",  "MechaBruiser"   },
		Ranger       = { "PulseSniper",    "ReconRunner"    },
		Spiritualist = { "LightWeaver",    "BioMender"      },
		Specialist   = { "ArmorDriver",    "FieldEngineer"  },
	},

	-- CYBORG tidak punya Spiritualist — Accretia tidak bisa magic sama sekali di RF Classic
	-- Heal Accretia = Blood Ammo dari Specialist, bukan Force skill
	CYBORG = {
		Warrior    = { "SteelDestroyer", "ShieldBreaker"    },
		Ranger     = { "SiegeGunner",    "StealthScout"     },
		Specialist = { "MechanicEngineer", "BloodMedic"     }, -- BloodMedic = Blood Ammo healer
	},

	MYSTIC = {
		Warrior      = { "RuneKnight",     "SpiritGuard"    },
		Ranger       = { "ShadowArcher",   "WindStalker"    },
		Spiritualist = { "DarkInvoker",    "AnimusCaller"   },
		Specialist   = { "SoulArtisan",    "RuneEngineer"   },
	},
}

-- ============================================================
-- Level 40 Advancement — 2 pilihan per L30 class
-- ============================================================

ClassDefinitions.Advancement40 = {
	MECHA = {
		MechaGuardian  = { "AegisCommander",   "TitanVanguard"    },
		MechaBruiser   = { "ShockBerserker",   "IronWarden"       },
		PulseSniper    = { "RailgunMarksman",  "Overwatch"        },
		ReconRunner    = { "GhostRunner",      "MineLayer"        },
		LightWeaver    = { "SanctuaryPriest",  "SolarInvoker"     },
		BioMender      = { "LifeTechnician",   "DefenseMedic"     },
		ArmorDriver    = { "GoliathPilot",     "CatapultPilot"    },
		FieldEngineer  = { "TowerArchitect",   "WarMechanic"      },
	},

	CYBORG = {
		SteelDestroyer   = { "Punisher",      "Assaulter"    },
		ShieldBreaker    = { "Mercenary",      "Bulwark"      },
		SiegeGunner      = { "Striker",        "Dementer"     },
		StealthScout     = { "PhantomShadow",  "Infiltrator"  },
		MechanicEngineer = { "Scientist",      "BattleLeader" },
		BloodMedic       = { "FieldSurgeon",   "BloodArsenal" },
	},

	MYSTIC = {
		RuneKnight     = { "TemplarShade",     "BloodChampion"    },
		SpiritGuard    = { "SoulDefender",     "DarkTemplar"      },
		ShadowArcher   = { "NightSeeker",      "StormArcher"      },
		WindStalker    = { "PhantomWind",      "BeastHunter"      },
		DarkInvoker    = { "Warlock",          "DarkPriest"       },
		AnimusCaller   = { "SummonMaster",     "SoulBinder"       },
		SoulArtisan    = { "ArcaneSmith",      "SpiritMechanic"   },
		RuneEngineer   = { "RuneArchitect",    "SupportOracle"    },
	},
}

-- ============================================================
-- Metadata advancement class (nama tampil + deskripsi singkat)
-- ============================================================

ClassDefinitions.AdvancementMeta = {
	-- MECHA L30
	MechaGuardian    = { DisplayName = "Mecha Guardian",   Role = "Tank"    },
	MechaBruiser     = { DisplayName = "Mecha Bruiser",    Role = "Melee"   },
	PulseSniper      = { DisplayName = "Pulse Sniper",     Role = "Ranged"  },
	ReconRunner      = { DisplayName = "Recon Runner",     Role = "Ranged"  },
	LightWeaver      = { DisplayName = "Light Weaver",     Role = "Magic"   },
	BioMender        = { DisplayName = "Bio Mender",       Role = "Heal"    },
	ArmorDriver      = { DisplayName = "Armor Driver",     Role = "MAU"     },
	FieldEngineer    = { DisplayName = "Field Engineer",   Role = "Support" },
	-- MECHA L40
	AegisCommander   = { DisplayName = "Aegis Commander",  Role = "Tank"    },
	TitanVanguard    = { DisplayName = "Titan Vanguard",   Role = "Tank"    },
	ShockBerserker   = { DisplayName = "Shock Berserker",  Role = "Melee"   },
	IronWarden       = { DisplayName = "Iron Warden",      Role = "Tank"    },
	RailgunMarksman  = { DisplayName = "Railgun Marksman", Role = "Ranged"  },
	Overwatch        = { DisplayName = "Overwatch",        Role = "Ranged"  },
	GhostRunner      = { DisplayName = "Ghost Runner",     Role = "Ranged"  },
	MineLayer        = { DisplayName = "Mine Layer",       Role = "Support" },
	SanctuaryPriest  = { DisplayName = "Sanctuary Priest", Role = "Heal"   },
	SolarInvoker     = { DisplayName = "Solar Invoker",    Role = "Magic"   },
	LifeTechnician   = { DisplayName = "Life Technician",  Role = "Heal"    },
	DefenseMedic     = { DisplayName = "Defense Medic",    Role = "Support" },
	GoliathPilot     = { DisplayName = "Goliath Pilot",    Role = "MAU"     },
	CatapultPilot    = { DisplayName = "Catapult Pilot",   Role = "MAU"     },
	TowerArchitect   = { DisplayName = "Tower Architect",  Role = "Support" },
	WarMechanic      = { DisplayName = "War Mechanic",     Role = "Support" },
	-- CYBORG L30 (tidak ada Magic — Accretia tidak punya Spiritualist)
	SteelDestroyer   = { DisplayName = "Steel Destroyer",  Role = "Melee"   },
	ShieldBreaker    = { DisplayName = "Shield Breaker",   Role = "Melee"   },
	SiegeGunner      = { DisplayName = "Siege Gunner",     Role = "Ranged"  },
	StealthScout     = { DisplayName = "Stealth Scout",    Role = "Ranged"  },
	MechanicEngineer = { DisplayName = "Mechanic Engineer",Role = "Support" },
	BloodMedic       = { DisplayName = "Blood Medic",      Role = "Heal"    }, -- heal via Blood Ammo
	-- CYBORG L40
	Punisher         = { DisplayName = "Punisher",         Role = "Melee"   },
	Assaulter        = { DisplayName = "Assaulter",        Role = "Melee"   },
	Mercenary        = { DisplayName = "Mercenary",        Role = "Melee"   },
	Bulwark          = { DisplayName = "Bulwark",          Role = "Tank"    },
	Striker          = { DisplayName = "Striker",          Role = "Ranged"  },
	Dementer         = { DisplayName = "Dementer",         Role = "Ranged"  },
	PhantomShadow    = { DisplayName = "Phantom Shadow",   Role = "Ranged"  },
	Infiltrator      = { DisplayName = "Infiltrator",      Role = "Ranged"  },
	Scientist        = { DisplayName = "Scientist",        Role = "Support" },
	BattleLeader     = { DisplayName = "Battle Leader",    Role = "Support" },
	FieldSurgeon     = { DisplayName = "Field Surgeon",    Role = "Heal"    },
	BloodArsenal     = { DisplayName = "Blood Arsenal",    Role = "Heal"    },
	-- MYSTIC L30
	RuneKnight       = { DisplayName = "Rune Knight",      Role = "Tank"    },
	SpiritGuard      = { DisplayName = "Spirit Guard",     Role = "Tank"    },
	ShadowArcher     = { DisplayName = "Shadow Archer",    Role = "Ranged"  },
	WindStalker      = { DisplayName = "Wind Stalker",     Role = "Ranged"  },
	DarkInvoker      = { DisplayName = "Dark Invoker",     Role = "Magic"   },
	AnimusCaller     = { DisplayName = "Animus Caller",    Role = "Magic"   },
	SoulArtisan      = { DisplayName = "Soul Artisan",     Role = "Support" },
	RuneEngineer     = { DisplayName = "Rune Engineer",    Role = "Support" },
	-- MYSTIC L40
	TemplarShade     = { DisplayName = "Templar Shade",    Role = "Tank"    },
	BloodChampion    = { DisplayName = "Blood Champion",   Role = "Melee"   },
	SoulDefender     = { DisplayName = "Soul Defender",    Role = "Tank"    },
	DarkTemplar      = { DisplayName = "Dark Templar",     Role = "Tank"    },
	NightSeeker      = { DisplayName = "Night Seeker",     Role = "Ranged"  },
	StormArcher      = { DisplayName = "Storm Archer",     Role = "Ranged"  },
	PhantomWind      = { DisplayName = "Phantom Wind",     Role = "Ranged"  },
	BeastHunter      = { DisplayName = "Beast Hunter",     Role = "Ranged"  },
	Warlock          = { DisplayName = "Warlock",          Role = "Magic"   },
	DarkPriest       = { DisplayName = "Dark Priest",      Role = "Heal"    },
	SummonMaster     = { DisplayName = "Summon Master",    Role = "Magic"   },
	SoulBinder       = { DisplayName = "Soul Binder",      Role = "Support" },
	ArcaneSmith      = { DisplayName = "Arcane Smith",     Role = "Support" },
	SpiritMechanic   = { DisplayName = "Spirit Mechanic",  Role = "Support" },
	RuneArchitect    = { DisplayName = "Rune Architect",   Role = "Support" },
	SupportOracle    = { DisplayName = "Support Oracle",   Role = "Support" },
}

-- ============================================================
-- Helper Functions
-- ============================================================

function ClassDefinitions.IsValidStartingClass(classId)
	return ClassDefinitions.Starting[classId] ~= nil
end

-- Kembalikan stat scaling untuk starting class player
function ClassDefinitions.GetStatScaling(startingClassId)
	local def = ClassDefinitions.Starting[startingClassId]
	return def and def.StatScaling or nil
end

-- Hitung stats pada level tertentu untuk class tertentu
-- Mengembalikan: { MaxHP, MaxFP, MaxSP }
function ClassDefinitions.CalcStatsAtLevel(startingClassId, level)
	local scaling = ClassDefinitions.GetStatScaling(startingClassId)
	if not scaling then
		return { MaxHP = 150, MaxFP = 100, MaxSP = 200 }
	end

	local lvl = math.max(1, level or 1)
	return {
		MaxHP = scaling.BaseHP + (lvl - 1) * scaling.HPPerLevel,
		MaxFP = scaling.BaseFP + (lvl - 1) * scaling.FPPerLevel,
		MaxSP = scaling.BaseSP + (lvl - 1) * scaling.SPPerLevel,
	}
end

-- Kembalikan Role dari starting class player ("Melee", "Ranged", "Magic", "SupportCraft")
function ClassDefinitions.GetStartingClassRole(playerData)
	if not playerData or not playerData.StartingClassId then return nil end
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
	if not options then return false end
	for _, option in ipairs(options) do
		if option == value then return true end
	end
	return false
end

-- Kembalikan display name class apapun (starting atau advancement)
function ClassDefinitions.GetDisplayName(classId)
	if ClassDefinitions.Starting[classId] then
		return ClassDefinitions.Starting[classId].DisplayName
	end
	local meta = ClassDefinitions.AdvancementMeta[classId]
	return meta and meta.DisplayName or classId
end

return ClassDefinitions
