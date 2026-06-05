-- ForceDefinitions.lua
-- Batch 2.5: Definisi semua Force (Holy, Dark, Elemental) dengan biaya FP per-cast.
-- CYBORG tidak bisa Force sama sekali.
-- MECHA → Holy + Elemental
-- MYSTIC → Dark + Elemental
--
-- Field per force:
--   Id          = string identifier unik
--   Name        = display name
--   School      = "Holy" | "Dark" | "Elemental"
--   Element     = "Fire" | "Aqua" | "Terra" | "Wind" | nil (jika bukan elemental)
--   Tier        = "Basic" | "Expert" | "Elite"
--   FPCost      = FP yang dikonsumsi saat cast
--   CastDelay   = detik cooldown
--   Target      = "Enemy" | "Self" | "Area"
--   TargetType  = "Single" | "Area"
--   Effect      = deskripsi efek
--   BuffType    = "Buff" | "Debuff" | "Damage" | nil
--   AllowedRaces = daftar FactionId yang diizinkan (nil = semua yang punya magic)
--   PTTierReq   = "Basic" | "Expert" | nil
--   PTReqAmount = jumlah PT dari tier sebelumnya
--   ExpLevelMax = max exp level (default 99)

local GameConfig = require(script.Parent.Parent.GameConfig)

local ForceDefinitions = {}

-- ============================================================
-- HOLY FORCE (MECHA only)
-- ============================================================

-- === BASIC TIER ===

ForceDefinitions["focus"] = {
	Id = "focus",
	Name = "Focus",
	School = "Holy",
	Element = nil,
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase duration of active force buffs.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["energize"] = {
	Id = "energize",
	Name = "Energize",
	School = "Holy",
	Element = nil,
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Restore a portion of SP.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["soul_vitality"] = {
	Id = "soul_vitality",
	Name = "Soul Vitality",
	School = "Holy",
	Element = nil,
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase HP and FP regeneration rate.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

-- === EXPERT TIER ===

ForceDefinitions["resistance"] = {
	Id = "resistance",
	Name = "Resistance",
	School = "Holy",
	Element = nil,
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase elemental resistance.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["healing"] = {
	Id = "healing",
	Name = "Healing",
	School = "Holy",
	Element = nil,
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 2,
	Target = "Self",
	TargetType = "Single",
	Effect = "Restore a significant amount of HP.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["velocity"] = {
	Id = "velocity",
	Name = "Velocity",
	School = "Holy",
	Element = nil,
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase movement speed.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

-- === ELITE TIER ===

ForceDefinitions["agility"] = {
	Id = "agility",
	Name = "Agility",
	School = "Holy",
	Element = nil,
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase dodge rate.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

ForceDefinitions["aegis"] = {
	Id = "aegis",
	Name = "Aegis",
	School = "Holy",
	Element = nil,
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase defense.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

ForceDefinitions["conservation"] = {
	Id = "conservation",
	Name = "Conservation",
	School = "Holy",
	Element = nil,
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Reduce FP cost of all forces.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MECHA },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- ============================================================
-- DARK FORCE (MYSTIC only)
-- ============================================================

-- === BASIC TIER ===

ForceDefinitions["exertion"] = {
	Id = "exertion",
	Name = "Exertion",
	School = "Dark",
	Element = nil,
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase melee attack speed.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["sacrifice"] = {
	Id = "sacrifice",
	Name = "Sacrifice",
	School = "Dark",
	Element = nil,
	Tier = "Basic",
	FPCost = 0, -- cost khusus: HP bukan FP (60 HP)
	HPCost = 60,
	CastDelay = 2,
	Target = "Self",
	TargetType = "Single",
	Effect = "Convert 60 HP into FP.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["rush"] = {
	Id = "rush",
	Name = "Rush",
	School = "Dark",
	Element = nil,
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Reduce force cooldown duration.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

-- === EXPERT TIER ===

ForceDefinitions["might"] = {
	Id = "might",
	Name = "Might",
	School = "Dark",
	Element = nil,
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase force attack power.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["broad_outlook"] = {
	Id = "broad_outlook",
	Name = "Broad Outlook",
	School = "Dark",
	Element = nil,
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase force attack area radius.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

-- === ELITE TIER ===

ForceDefinitions["acute_sight"] = {
	Id = "acute_sight",
	Name = "Acute Sight",
	School = "Dark",
	Element = nil,
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase force aiming accuracy.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

ForceDefinitions["hell_bless"] = {
	Id = "hell_bless",
	Name = "Hell Bless",
	School = "Dark",
	Element = nil,
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Debuff: Remove HP regen from target.",
	BuffType = "Debuff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

ForceDefinitions["efficiency"] = {
	Id = "efficiency",
	Name = "Efficiency",
	School = "Dark",
	Element = nil,
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Reduce FP cost of all forces.",
	BuffType = "Buff",
	AllowedRaces = { GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- ============================================================
-- ELEMENTAL FORCES (MECHA + MYSTIC, bukan CYBORG)
-- ============================================================

-- === FIRE — BASIC ===

ForceDefinitions["fire_arrow"] = {
	Id = "fire_arrow",
	Name = "Fire Arrow",
	School = "Elemental",
	Element = "Fire",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal fire damage to a single target.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["flame_wave"] = {
	Id = "flame_wave",
	Name = "Flame Wave",
	School = "Elemental",
	Element = "Fire",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Launch a wave of fire damaging all enemies in range.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["meteor_swarm"] = {
	Id = "meteor_swarm",
	Name = "Meteor Swarm",
	School = "Elemental",
	Element = "Fire",
	Tier = "Elite",
	FPCost = 270,
	CastDelay = 24,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Call down a barrage of meteors dealing massive fire damage.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- === AQUA — BASIC ===

ForceDefinitions["aqua_arrow"] = {
	Id = "aqua_arrow",
	Name = "Aqua Arrow",
	School = "Elemental",
	Element = "Aqua",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal water damage to a single target.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["tidal_wave"] = {
	Id = "tidal_wave",
	Name = "Tidal Wave",
	School = "Elemental",
	Element = "Aqua",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Summon a tidal wave that damages and slows enemies.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["blizzard"] = {
	Id = "blizzard",
	Name = "Blizzard",
	School = "Elemental",
	Element = "Aqua",
	Tier = "Elite",
	FPCost = 270,
	CastDelay = 24,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Conjure a blizzard dealing heavy ice damage over an area.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- === TERRA — BASIC ===

ForceDefinitions["terra_arrow"] = {
	Id = "terra_arrow",
	Name = "Terra Arrow",
	School = "Elemental",
	Element = "Terra",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal earth damage to a single target.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["earth_quake"] = {
	Id = "earth_quake",
	Name = "Earth Quake",
	School = "Elemental",
	Element = "Terra",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Cause a tremor dealing earth damage to all nearby enemies.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["terra_destruction"] = {
	Id = "terra_destruction",
	Name = "Terra Destruction",
	School = "Elemental",
	Element = "Terra",
	Tier = "Elite",
	FPCost = 270,
	CastDelay = 24,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Rend the earth dealing devastating area damage.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- === WIND — BASIC ===

ForceDefinitions["wind_arrow"] = {
	Id = "wind_arrow",
	Name = "Wind Arrow",
	School = "Elemental",
	Element = "Wind",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal wind damage to a single target.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

ForceDefinitions["tornado"] = {
	Id = "tornado",
	Name = "Tornado",
	School = "Elemental",
	Element = "Wind",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Summon a tornado to damage all enemies in range.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

ForceDefinitions["chain_lightning"] = {
	Id = "chain_lightning",
	Name = "Chain Lightning",
	School = "Elemental",
	Element = "Wind",
	Tier = "Elite",
	FPCost = 270,
	CastDelay = 24,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Call down lightning that chains between enemies dealing massive wind damage.",
	BuffType = "Damage",
	AllowedRaces = { GameConfig.Factions.MECHA, GameConfig.Factions.MYSTIC },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- ============================================================
-- Helper Functions
-- ============================================================

-- Cek apakah race diizinkan memakai force ini
function ForceDefinitions.IsAllowedForRace(forceDef, factionId)
	if not forceDef.AllowedRaces then
		return true
	end

	for _, allowed in ipairs(forceDef.AllowedRaces) do
		if allowed == factionId then
			return true
		end
	end

	return false
end

-- Ambil semua force yang boleh dipakai oleh race tertentu
function ForceDefinitions.GetForRace(factionId)
	local result = {}

	for _, force in pairs(ForceDefinitions) do
		if type(force) == "table" and ForceDefinitions.IsAllowedForRace(force, factionId) then
			table.insert(result, force)
		end
	end

	return result
end

-- Ambil force berdasarkan school
function ForceDefinitions.GetBySchool(school)
	local result = {}

	for _, force in pairs(ForceDefinitions) do
		if type(force) == "table" and force.School == school then
			table.insert(result, force)
		end
	end

	return result
end

-- Cek apakah player memenuhi syarat untuk unlock force
function ForceDefinitions.MeetsUnlockRequirement(forceDef, aggregatePT)
	if not forceDef.PTTierReq then
		return true
	end

	local ptInTier = aggregatePT and aggregatePT[forceDef.PTTierReq] or 0
	return ptInTier >= forceDef.PTReqAmount
end

return ForceDefinitions
