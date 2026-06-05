local GameConfig = {}

GameConfig.GameName = "Aetherion"
GameConfig.MaxLevel = 50

GameConfig.AdvancementLevels = {
	First = 30,
	Second = 40,
}

GameConfig.Factions = {
	MECHA = "MECHA",
	CYBORG = "CYBORG",
	MYSTIC = "MYSTIC",
}

GameConfig.StartingClasses = {
	Warrior = "Warrior",
	Ranger = "Ranger",
	Spiritualist = "Spiritualist",
	Specialist = "Specialist",
}

GameConfig.PTTypes = {
	Melee = "Melee",
	Ranged = "Ranged",
	Launcher = "Launcher",
	Shield = "Shield",
	Defense = "Defense",
	Magic = "Magic",
	Unit = "Unit",
}

GameConfig.ItemCategories = {
	Weapon = "Weapon",
	Armor = "Armor",
	Cloak = "Cloak",
	Booster = "Booster",
	Accessory = "Accessory",
	Shield = "Shield",
	Ammo = "Ammo",
	Unit = "Unit",
	Box = "Box",
	Material = "Material",
}

GameConfig.EquipmentSlots = {
	Weapon     = "Weapon",
	-- Armor dipecah per slot seperti RF asli
	Helmet     = "Helmet",   -- kepala
	Upper      = "Upper",    -- body / baju
	Lower      = "Lower",    -- celana / pants
	Gloves     = "Gloves",   -- sarung tangan
	Boots      = "Boots",    -- sepatu
	-- Alias legacy agar item lama tidak langsung error
	Armor      = "Upper",    -- alias → Upper
	Shield     = "Shield",
	Cloak      = "Cloak",    -- jetpack / booster
	Accessory1 = "Accessory1",
	Accessory2 = "Accessory2",
	Accessory3 = "Accessory3",
	Accessory4 = "Accessory4",
}

-- Slot yang bisa di-upgrade (digunakan UpgradeService untuk validasi server-side)
GameConfig.UpgradeableSlots = {
	Weapon  = true,
	Helmet  = true,
	Upper   = true,
	Lower   = true,
	Gloves  = true,
	Boots   = true,
	Shield  = true,
	Cloak   = true,
	Accessory1 = true,
	Accessory2 = true,
	Accessory3 = true,
	Accessory4 = true,
}

-- Grup slot target untuk validasi AppliesTo talic.
-- Key ini dipakai di field `AppliesTo` pada ItemDefinitions.
-- UpgradeService membaca ini untuk validasi talic → item compatibility.
GameConfig.TalicTargetGroups = {
	-- Single slot
	Weapon       = { Weapon = true },
	Helmet       = { Helmet = true },
	Upper        = { Upper = true },
	Lower        = { Lower = true },
	Gloves       = { Gloves = true },
	Boots        = { Boots = true },
	Shield       = { Shield = true },
	Cloak        = { Cloak = true },

	-- Subset weapon by type (dicek kombinasi dengan WeaponType di item def)
	RangedWeapon = { Weapon = true },  -- validasi WeaponType = Ranged/Launcher di UpgradeService
	MeleeWeapon  = { Weapon = true },  -- validasi WeaponType = Melee

	-- Multi-slot: Weapon+Jetpack (RF: Chaos Talic)
	WeaponOrCloak = { Weapon = true, Cloak = true },

	-- Multi-slot: Upper + Lower + Shield + Jetpack + Melee Weapon (RF: Sacredfire/Belief/Guard/Glory)
	UpperLowerShieldJetpackMelee = {
		Upper = true, Lower = true, Shield = true, Cloak = true, Weapon = true,
	},

	-- Semua armor (tidak termasuk weapon & accessory) — RF: Favor Talic
	AllArmor = {
		Helmet = true, Upper = true, Lower = true,
		Gloves = true, Boots = true, Shield = true, Cloak = true,
	},

	-- Semua equipment — RF: Restoration Talic
	All = {
		Weapon = true, Helmet = true, Upper = true, Lower = true,
		Gloves = true, Boots = true, Shield = true, Cloak = true,
		Accessory1 = true, Accessory2 = true, Accessory3 = true, Accessory4 = true,
	},
}

GameConfig.Combat = {
	BaseDamageVarianceMin = 0.90,
	BaseDamageVarianceMax = 1.10,
	CritMultiplier = 1.5,
	DefenseScale = 100,
	MaxAttackDistance = 18,
}

return GameConfig
