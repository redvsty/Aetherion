-- WeaponUpgradeDefinitions.lua
-- Definisi lengkap sistem upgrade talic sesuai RF Online asli.
-- AppliesTo menggunakan key dari GameConfig.TalicTargetGroups.

local WeaponUpgradeDefinitions = {}

WeaponUpgradeDefinitions.Slot = {
	Min = 0,
	Max = 7,
}

-- Definisi canonical tiap talic: AppliesTo, Effect, dan referensi ke ItemDefinitions Id
-- Ini dipakai WeaponEffectService dan EquipmentService saat hitung total stats.
WeaponUpgradeDefinitions.Talic = {

	-- 1. Ignorance / Keen — Weapon — Attack Power
	Ignorant = {
		Id           = "ignorant_talic",
		DisplayName  = "Ignorance Talic",
		AppliesTo    = "Weapon",
		Effect       = { Type = "WeaponAttackUpgrade" },
	},

	Keen = {
		Id           = "keen_talic",
		DisplayName  = "Keen Talic",
		AppliesTo    = "Weapon",
		Effect       = { Type = "WeaponAttackUpgrade" },
	},

	-- 2. Destruction — Weapon — Life Steal
	Destruction = {
		Id           = "destruction_talic",
		DisplayName  = "Destruction Talic",
		AppliesTo    = "Weapon",
		Effect       = { Type = "LifeStealPercent", ValuePerTalic = 0.03 },
	},

	-- 3. Darkness — Weapon — Ignore Block
	Darkness = {
		Id           = "darkness_talic",
		DisplayName  = "Darkness Talic",
		AppliesTo    = "Weapon",
		Effect       = { Type = "IgnoreBlockChance", ValuePerTalic = 0.03 },
	},

	-- 4. Chaos — Weapon + Jetpack — Stun Chance
	Chaos = {
		Id           = "chaos_talic",
		DisplayName  = "Chaos Talic",
		AppliesTo    = "WeaponOrCloak",   -- Weapon dan Jetpack (Cloak)
		Effect       = { Type = "StunChance", ValuePerTalic = 0.03 },
	},

	-- 5. Hatred — Ranged Weapon only — Attack Range
	Hatred = {
		Id           = "hatred_talic",
		DisplayName  = "Hatred Talic",
		AppliesTo    = "RangedWeapon",    -- Ranged dan Launcher saja
		Effect       = { Type = "RangeMultiplier", ValuePerTalic = 0.05 },
	},

	-- 6. Favor — All Armor — Defense
	Favor = {
		Id           = "favor_talic",
		DisplayName  = "Favor Talic",
		AppliesTo    = "AllArmor",        -- Helmet/Upper/Lower/Gloves/Boots/Shield/Cloak
		Effect       = { Type = "DefenseFlat", ValuePerTalic = 2 },
	},

	-- 7. Wisdom — Helmet only — Debuff Duration Reduction
	Wisdom = {
		Id           = "wisdom_talic",
		DisplayName  = "Wisdom Talic",
		AppliesTo    = "Helmet",
		Effect       = { Type = "DebuffDurationReduction", ValuePerTalic = 0.05 },
	},

	-- 8. Sacredfire — Upper/Lower/Shield/Jetpack/Melee — Fire Resistance
	SacredFire = {
		Id           = "sacred_fire_talic",
		DisplayName  = "Sacredfire Talic",
		AppliesTo    = "UpperLowerShieldJetpackMelee",
		Effect       = { Type = "FireResistanceFlat", ValuePerTalic = 1 },
	},

	-- 9. Belief — Upper/Lower/Shield/Jetpack/Melee — Water Resistance
	Belief = {
		Id           = "belief_talic",
		DisplayName  = "Belief Talic",
		AppliesTo    = "UpperLowerShieldJetpackMelee",
		Effect       = { Type = "AquaResistanceFlat", ValuePerTalic = 1 },
	},

	-- 10. Guard — Upper/Lower/Shield/Jetpack/Melee — Terra Resistance
	Guard = {
		Id           = "guard_talic",
		DisplayName  = "Guard Talic",
		AppliesTo    = "UpperLowerShieldJetpackMelee",
		Effect       = { Type = "TerraResistanceFlat", ValuePerTalic = 1 },
	},

	-- 11. Glory — Upper/Lower/Shield/Jetpack/Melee — Wind Resistance
	Glory = {
		Id           = "glory_talic",
		DisplayName  = "Glory Talic",
		AppliesTo    = "UpperLowerShieldJetpackMelee",
		Effect       = { Type = "WindResistanceFlat", ValuePerTalic = 1 },
	},

	-- 12. Grace — Gloves only — Accuracy
	Grace = {
		Id           = "grace_talic",
		DisplayName  = "Grace Talic",
		AppliesTo    = "Gloves",
		Effect       = { Type = "AccuracyFlat", ValuePerTalic = 2 },
	},

	-- 13. Mercy — Boots only — Dodge / Avoidance
	Mercy = {
		Id           = "mercy_talic",
		DisplayName  = "Mercy Talic",
		AppliesTo    = "Boots",
		Effect       = { Type = "DodgeFlat", ValuePerTalic = 2 },
	},

	-- 14. Restoration — All — Remove Last Talic (tidak ada Effect stat)
	Restoration = {
		Id           = "restoration_talic",
		DisplayName  = "Restoration Talic",
		AppliesTo    = "All",
		Effect       = { Type = "RemoveLastTalic" },
	},
}

-- Reverse lookup: ItemDefinitions Id → WeaponUpgradeDefinitions.Talic entry
WeaponUpgradeDefinitions.TalicById = {}
for _, entry in pairs(WeaponUpgradeDefinitions.Talic) do
	WeaponUpgradeDefinitions.TalicById[entry.Id] = entry
end

-- Chance table (sama untuk semua item, mirip RF)
WeaponUpgradeDefinitions.UpgradeChance = {
	[1] = { Success = 1.00, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[2] = { Success = 1.00, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[3] = { Success = 0.70, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[4] = { Success = 0.50, Destroy = 0.00, Downgrade = 0.10, Lock = 0.00 },
	[5] = { Success = 0.30, Destroy = 0.00, Downgrade = 0.60, Lock = 0.70 },
	[6] = { Success = 0.15, Destroy = 0.35, Downgrade = 0.40, Lock = 0.50 },
	[7] = { Success = 0.07, Destroy = 0.55, Downgrade = 0.30, Lock = 0.60 },
}

return WeaponUpgradeDefinitions
