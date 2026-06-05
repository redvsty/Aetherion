-- PlayerDataFactory.lua
-- Batch 2.5: Tambah Skills dan SkillPT ke schema.
-- Skills: { [skillId] = { Level = 1, Exp = 0 } } — level naik dari pemakaian.
-- SkillPT: { [category] = { Basic = N, Expert = N, Elite = N } } — untuk tier unlock.
-- Fix awal: Currencies di-init hanya Gold (global). Faction currency diisi
-- saat SelectRaceAndClass, bukan saat Create.

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local SkillDefinitions = require(game.ReplicatedStorage.Shared.Definitions.SkillDefinitions)
local ForceDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ForceDefinitions)

local PlayerDataFactory = {}

local function defaultPT()
	return {
		Melee = { Level = 1, Exp = 0 },
		Ranged = { Level = 1, Exp = 0 },
		Launcher = { Level = 1, Exp = 0 },
		Shield = { Level = 1, Exp = 0 },
		Defense = { Level = 1, Exp = 0 },
		Magic = { Level = 1, Exp = 0 },
		Unit = { Level = 1, Exp = 0 },
	}
end

-- Buat default Skills: semua skill dan force basic yang terbuka dari awal
-- Player mulai dengan Level 1, Exp 0 untuk setiap Basic-tier skill.
-- Expert dan Elite tidak di-init sampai tier-nya terbuka.
local function defaultSkills()
	local skills = {}

	-- Semua Basic Melee & Ranged skills
	for skillId, def in pairs(SkillDefinitions) do
		if type(def) == "table" and def.Tier == "Basic" then
			skills[skillId] = { Level = 1, Exp = 0 }
		end
	end

	-- Semua Basic Force (Holy, Dark, Elemental) — filter per race nanti di SkillService
	for forceId, def in pairs(ForceDefinitions) do
		if type(def) == "table" and def.Tier == "Basic" then
			skills[forceId] = { Level = 1, Exp = 0 }
		end
	end

	return skills
end

-- Default SkillPT: semua kategori mulai dari 0
local function defaultSkillPT()
	return {
		Melee = { Basic = 0, Expert = 0, Elite = 0 },
		Ranged = { Basic = 0, Expert = 0, Elite = 0 },
		Holy = { Basic = 0, Expert = 0, Elite = 0 },
		Dark = { Basic = 0, Expert = 0, Elite = 0 },
		Elemental = { Basic = 0, Expert = 0, Elite = 0 },
	}
end

function PlayerDataFactory.Create(player)
	return {
		SchemaVersion = 5,

		UserId = player.UserId,
		Name = player.Name,

		Level = 1,
		Exp = 0,
		MaxLevel = GameConfig.MaxLevel,

		FactionId = nil,
		StartingClassId = nil,
		ClassLevel30Id = nil,
		ClassLevel40Id = nil,

		NeedsRaceSelection = true,
		NeedsStartingClassSelection = true,
		NeedsLevel30ClassSelection = false,
		NeedsLevel40ClassSelection = false,

		-- Fix: hanya Gold yang ada dari awal.
		-- Faction currency (MechaCredits / CyborgCredits / ElyndraSignil)
		-- akan ditambahkan oleh CharacterCreationService.SelectRaceAndClass.
		Currencies = {
			Gold = 0,
		},

		Stats = {
			MaxHP = 150,
			HP = 150,
			MaxFP = 100,
			FP = 100,
			MaxSP = 100,
			SP = 100,
		},

		PT = defaultPT(),

		-- Batch 2.5: Skill & Force system
		-- Skills: level naik dari pemakaian (bukan dari level karakter)
		Skills = defaultSkills(),
		-- SkillPT: aggregate level per tier, digunakan untuk unlock Expert/Elite
		SkillPT = defaultSkillPT(),
		-- ActiveBuffs: buff yang sedang aktif { [skillId] = { ExpiresAt, ... } }
		ActiveBuffs = {},

		Inventory = {},

		Equipment = {
			Weapon = nil,
			Helmet = nil,
			Upper = nil,
			Lower = nil,
			Gloves = nil,
			Boots = nil,
			Shield = nil,
			Cloak = nil,
			Ring1   = nil,
			Ring2   = nil,
			Amulet1 = nil,
			Amulet2 = nil,
		},

		ContributionPoints = 0,
		ChaosUntil = 0,
	}
end

return PlayerDataFactory
