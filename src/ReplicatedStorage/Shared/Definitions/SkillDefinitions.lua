-- SkillDefinitions.lua
-- Batch 2.5: Definisi semua Skill (Melee & Ranged) yang tersedia untuk semua race.
-- CYBORG tidak bisa Force, tapi bisa semua Skill normal.
-- Tier: Basic → Expert (butuh 30 PT di Basic) → Elite (butuh 50 PT di Expert)
--
-- Field per skill:
--   Id          = string identifier unik
--   Name        = display name
--   Category    = "Melee" | "Ranged"
--   Tier        = "Basic" | "Expert" | "Elite"
--   FPCost      = FP yang dikonsumsi saat cast
--   CastDelay   = detik cooldown setelah cast (di RF disebut "Cast Delay")
--   Target      = "Enemy" | "Self"
--   TargetType  = "Single" | "Area"
--   Effect      = deskripsi efek (untuk tooltip)
--   BuffType    = "Attack" | "Buff" | "Debuff" | nil (untuk buffs)
--   WeaponReq   = daftar WeaponType yang diperbolehkan, nil = semua
--   PTTierReq   = PT tier yang harus dipunyai (Basic → Expert → Elite)
--   PTReqAmount = jumlah PT yang diperlukan dari tier sebelumnya
--   ExpLevelMax = max exp level skill (default 99)

local SkillDefinitions = {}

-- ============================================================
-- MELEE SKILLS
-- ============================================================

-- === BASIC TIER ===

SkillDefinitions["slash"] = {
	Id = "slash",
	Name = "Slash",
	Category = "Melee",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal melee damage to a single target.",
	WeaponReq = { "Melee" }, -- Knife, Sword, Axe, Spear
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["bash"] = {
	Id = "bash",
	Name = "Bash",
	Category = "Melee",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal blunt melee damage to a single target.",
	WeaponReq = { "Melee" }, -- Knife, Axe, Mace
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["blitz"] = {
	Id = "blitz",
	Name = "Blitz",
	Category = "Melee",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal swift melee damage to a single target.",
	WeaponReq = { "Melee" }, -- Sword, Spear
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["wild_rage"] = {
	Id = "wild_rage",
	Name = "Wild Rage",
	Category = "Melee",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily increase ATK.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["accuracy_skill"] = {
	Id = "accuracy_skill",
	Name = "Accuracy",
	Category = "Melee",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily increase hit rate.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["extend_range"] = {
	Id = "extend_range",
	Name = "Extend Range",
	Category = "Melee",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily increase melee attack radius.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

-- === EXPERT TIER === (butuh 30 PT di Basic)

SkillDefinitions["death_blow"] = {
	Id = "death_blow",
	Name = "Death Blow",
	Category = "Melee",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal heavy melee damage to a single target.",
	WeaponReq = { "Melee" },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["power_cleave"] = {
	Id = "power_cleave",
	Name = "Power Cleave",
	Category = "Melee",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Deal melee damage to nearby enemies in a cone.",
	WeaponReq = { "Melee" },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["death_hack"] = {
	Id = "death_hack",
	Name = "Death Hack",
	Category = "Melee",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Deal moderate melee damage with a chance to reduce target defense.",
	WeaponReq = { "Melee" },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["skill_stretch"] = {
	Id = "skill_stretch",
	Name = "Skill Stretch",
	Category = "Melee",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Extend duration of active skill buffs.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["counter_attack"] = {
	Id = "counter_attack",
	Name = "Counter Attack",
	Category = "Melee",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Increase counter-attack damage when hit.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["shield_rupture"] = {
	Id = "shield_rupture",
	Name = "Shield Rupture",
	Category = "Melee",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Next attack ignores a portion of target's shield defense.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

-- === ELITE TIER === (butuh 50 PT di Expert)

SkillDefinitions["spin_slice"] = {
	Id = "spin_slice",
	Name = "Spin Slice",
	Category = "Melee",
	Tier = "Elite",
	FPCost = 135,
	CastDelay = 18,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Spin and deal melee damage to all nearby enemies.",
	WeaponReq = { "Melee" },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

SkillDefinitions["pressure_bomb"] = {
	Id = "pressure_bomb",
	Name = "Pressure Bomb",
	Category = "Melee",
	Tier = "Elite",
	FPCost = 135,
	CastDelay = 18,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Release a pressure wave dealing heavy area melee damage.",
	WeaponReq = { "Melee" },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

SkillDefinitions["hysteria"] = {
	Id = "hysteria",
	Name = "Hysteria",
	Category = "Melee",
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 18,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Overwhelm target with frenzied strikes.",
	WeaponReq = { "Melee" },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

SkillDefinitions["bulls_eye"] = {
	Id = "bulls_eye",
	Name = "Bull's Eye",
	Category = "Melee",
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Next melee attack is guaranteed to critically hit.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

SkillDefinitions["cleanse"] = {
	Id = "cleanse",
	Name = "Cleanse",
	Category = "Melee",
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 24,
	Target = "Self",
	TargetType = "Single",
	Effect = "Remove all debuffs from self.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- ============================================================
-- RANGED SKILLS
-- ============================================================

-- === BASIC TIER ===

SkillDefinitions["fast_shot"] = {
	Id = "fast_shot",
	Name = "Fast Shot",
	Category = "Ranged",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 6,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Fire a quick shot at a single target.",
	WeaponReq = { "Ranged" }, -- Bow, Firearm, Throwing
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["speed_load"] = {
	Id = "speed_load",
	Name = "Speed Load",
	Category = "Ranged",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily reduce ranged attack reload time.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

SkillDefinitions["precision"] = {
	Id = "precision",
	Name = "Precision",
	Category = "Ranged",
	Tier = "Basic",
	FPCost = 30,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily increase ranged accuracy.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = nil,
	PTReqAmount = 0,
	ExpLevelMax = 99,
}

-- === EXPERT TIER ===

SkillDefinitions["multi_shot"] = {
	Id = "multi_shot",
	Name = "Multi Shot",
	Category = "Ranged",
	Tier = "Expert",
	FPCost = 90,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Fire multiple shots hitting up to 3 nearby targets.",
	WeaponReq = { "Ranged" },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["aiming_shot"] = {
	Id = "aiming_shot",
	Name = "Aiming Shot",
	Category = "Ranged",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 12,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Fire a high-accuracy shot dealing bonus damage.",
	WeaponReq = { "Ranged" },
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["wide_range"] = {
	Id = "wide_range",
	Name = "Wide Range",
	Category = "Ranged",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily increase ranged attack distance.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

SkillDefinitions["evasion"] = {
	Id = "evasion",
	Name = "Evasion",
	Category = "Ranged",
	Tier = "Expert",
	FPCost = 60,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Temporarily increase dodge rate.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Basic",
	PTReqAmount = 30,
	ExpLevelMax = 99,
}

-- === ELITE TIER ===

SkillDefinitions["destructive_shot"] = {
	Id = "destructive_shot",
	Name = "Destructive Shot",
	Category = "Ranged",
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 18,
	Target = "Enemy",
	TargetType = "Single",
	Effect = "Fire a devastating shot dealing heavy ranged damage.",
	WeaponReq = { "Ranged" },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

SkillDefinitions["wild_shot"] = {
	Id = "wild_shot",
	Name = "Wild Shot",
	Category = "Ranged",
	Tier = "Elite",
	FPCost = 180,
	CastDelay = 18,
	Target = "Enemy",
	TargetType = "Area",
	Effect = "Unload a barrage of shots hitting all enemies in range.",
	WeaponReq = { "Ranged" },
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

SkillDefinitions["crossfire"] = {
	Id = "crossfire",
	Name = "Crossfire",
	Category = "Ranged",
	Tier = "Elite",
	FPCost = 90,
	CastDelay = 1,
	Target = "Self",
	TargetType = "Single",
	Effect = "Buff: Next ranged attack fires from two angles simultaneously.",
	BuffType = "Buff",
	WeaponReq = nil,
	PTTierReq = "Expert",
	PTReqAmount = 50,
	ExpLevelMax = 99,
}

-- ============================================================
-- Helper Functions
-- ============================================================

-- Ambil semua skill berdasarkan category
function SkillDefinitions.GetByCategory(category)
	local result = {}
	for _, skill in pairs(SkillDefinitions) do
		if type(skill) == "table" and skill.Category == category then
			table.insert(result, skill)
		end
	end
	return result
end

-- Ambil semua skill berdasarkan tier
function SkillDefinitions.GetByTier(tier)
	local result = {}
	for _, skill in pairs(SkillDefinitions) do
		if type(skill) == "table" and skill.Tier == tier then
			table.insert(result, skill)
		end
	end
	return result
end

-- Cek apakah player memenuhi syarat untuk membuka skill (PT requirement)
-- skillPTData = { Basic = { PT = 0 }, Expert = { PT = 0 }, Elite = { PT = 0 } }
-- ini diperoleh dari AggregateSkillPT di SkillService
function SkillDefinitions.MeetsUnlockRequirement(skillDef, aggregatePT)
	if not skillDef.PTTierReq then
		return true -- Basic tier, always unlocked
	end

	local ptInTier = aggregatePT and aggregatePT[skillDef.PTTierReq] or 0
	return ptInTier >= skillDef.PTReqAmount
end

return SkillDefinitions
