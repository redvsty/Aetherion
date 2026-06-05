local GameConfig = require(script.Parent.Parent.GameConfig)

local function starterArmorDefinition(id, name, slot, factionId, defense)
	return {
		Id = id,
		Name = name,
		Category = GameConfig.ItemCategories.Armor,
		Slot = slot,
		FactionId = factionId,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Defense, Level = 1 },
		AttackMin = 0,
		AttackMax = 0,
		Defense = defense,
		MaxUpgrade = 7,
	}
end

local ItemDefinitions = {
	mecha_training_blade_001 = {
		Id = "mecha_training_blade_001",
		Name = "Mechanica Training Blade",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Melee,
		FactionId = GameConfig.Factions.MECHA,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Melee, Level = 1 },
		AttackMin = 8,
		AttackMax = 13,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mecha_training_rifle_001 = {
		Id = "mecha_training_rifle_001",
		Name = "Mechanica Training Rifle",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Ranged,
		FactionId = GameConfig.Factions.MECHA,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Ranged, Level = 1 },
		AttackMin = 7,
		AttackMax = 15,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mecha_training_reaver_001 = {
		Id = "mecha_training_reaver_001",
		Name = "Mechanica Light Reaver",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Magic,
		FactionId = GameConfig.Factions.MECHA,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Magic, Level = 1 },
		AttackMin = 5,
		AttackMax = 10,
		ForceAttackMin = 8,
		ForceAttackMax = 15,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mecha_training_tool_001 = {
		Id = "mecha_training_tool_001",
		Name = "Mechanica Service Tool",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Melee,
		FactionId = GameConfig.Factions.MECHA,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Melee, Level = 1 },
		AttackMin = 5,
		AttackMax = 9,
		Defense = 0,
		MaxUpgrade = 7,
	},
	cyborg_training_blade_001 = {
		Id = "cyborg_training_blade_001",
		Name = "Dominion Training Blade",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Melee,
		FactionId = GameConfig.Factions.CYBORG,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Melee, Level = 1 },
		AttackMin = 9,
		AttackMax = 14,
		Defense = 0,
		MaxUpgrade = 7,
	},
	cyborg_training_launcher_001 = {
		Id = "cyborg_training_launcher_001",
		Name = "Dominion Training Launcher",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Launcher,
		FactionId = GameConfig.Factions.CYBORG,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Launcher, Level = 1 },
		AttackMin = 12,
		AttackMax = 22,
		Defense = 0,
		MaxUpgrade = 7,
	},
	cyborg_training_tool_001 = {
		Id = "cyborg_training_tool_001",
		Name = "Dominion Utility Tool",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Melee,
		FactionId = GameConfig.Factions.CYBORG,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Melee, Level = 1 },
		AttackMin = 6,
		AttackMax = 10,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mystic_training_blade_001 = {
		Id = "mystic_training_blade_001",
		Name = "Elyndra Training Blade",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Melee,
		FactionId = GameConfig.Factions.MYSTIC,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Melee, Level = 1 },
		AttackMin = 7,
		AttackMax = 12,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mystic_training_bow_001 = {
		Id = "mystic_training_bow_001",
		Name = "Elyndra Training Bow",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Ranged,
		FactionId = GameConfig.Factions.MYSTIC,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Ranged, Level = 1 },
		AttackMin = 7,
		AttackMax = 14,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mystic_training_staff_001 = {
		Id = "mystic_training_staff_001",
		Name = "Elyndra Training Staff",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Magic,
		FactionId = GameConfig.Factions.MYSTIC,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Magic, Level = 1 },
		AttackMin = 4,
		AttackMax = 9,
		ForceAttackMin = 10,
		ForceAttackMax = 18,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mystic_training_tool_001 = {
		Id = "mystic_training_tool_001",
		Name = "Elyndra Rune Tool",
		Category = GameConfig.ItemCategories.Weapon,
		Slot = GameConfig.EquipmentSlots.Weapon,
		WeaponType = GameConfig.PTTypes.Melee,
		FactionId = GameConfig.Factions.MYSTIC,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Melee, Level = 1 },
		AttackMin = 5,
		AttackMax = 9,
		Defense = 0,
		MaxUpgrade = 7,
	},
	mecha_training_helmet_001 = starterArmorDefinition(
		"mecha_training_helmet_001",
		"Mechanica Recruit Helmet",
		GameConfig.EquipmentSlots.Helmet,
		GameConfig.Factions.MECHA,
		4
	),
	mecha_training_armor_001 = starterArmorDefinition(
		"mecha_training_armor_001",
		"Mechanica Recruit Armor",
		GameConfig.EquipmentSlots.Upper,
		GameConfig.Factions.MECHA,
		15
	),
	mecha_training_lower_001 = starterArmorDefinition(
		"mecha_training_lower_001",
		"Mechanica Recruit Greaves",
		GameConfig.EquipmentSlots.Lower,
		GameConfig.Factions.MECHA,
		8
	),
	mecha_training_gloves_001 = starterArmorDefinition(
		"mecha_training_gloves_001",
		"Mechanica Recruit Gloves",
		GameConfig.EquipmentSlots.Gloves,
		GameConfig.Factions.MECHA,
		3
	),
	mecha_training_boots_001 = starterArmorDefinition(
		"mecha_training_boots_001",
		"Mechanica Recruit Boots",
		GameConfig.EquipmentSlots.Boots,
		GameConfig.Factions.MECHA,
		3
	),
	cyborg_training_helmet_001 = starterArmorDefinition(
		"cyborg_training_helmet_001",
		"Dominion Recruit Helm",
		GameConfig.EquipmentSlots.Helmet,
		GameConfig.Factions.CYBORG,
		5
	),
	cyborg_training_armor_001 = starterArmorDefinition(
		"cyborg_training_armor_001",
		"Dominion Recruit Frame",
		GameConfig.EquipmentSlots.Upper,
		GameConfig.Factions.CYBORG,
		18
	),
	cyborg_training_lower_001 = starterArmorDefinition(
		"cyborg_training_lower_001",
		"Dominion Recruit Leg Frame",
		GameConfig.EquipmentSlots.Lower,
		GameConfig.Factions.CYBORG,
		9
	),
	cyborg_training_gloves_001 = starterArmorDefinition(
		"cyborg_training_gloves_001",
		"Dominion Recruit Gauntlets",
		GameConfig.EquipmentSlots.Gloves,
		GameConfig.Factions.CYBORG,
		4
	),
	cyborg_training_boots_001 = starterArmorDefinition(
		"cyborg_training_boots_001",
		"Dominion Recruit Treads",
		GameConfig.EquipmentSlots.Boots,
		GameConfig.Factions.CYBORG,
		4
	),
	mystic_training_hood_001 = starterArmorDefinition(
		"mystic_training_hood_001",
		"Elyndra Recruit Hood",
		GameConfig.EquipmentSlots.Helmet,
		GameConfig.Factions.MYSTIC,
		3
	),
	mystic_training_robe_001 = starterArmorDefinition(
		"mystic_training_robe_001",
		"Elyndra Recruit Robe",
		GameConfig.EquipmentSlots.Upper,
		GameConfig.Factions.MYSTIC,
		11
	),
	mystic_training_lower_001 = starterArmorDefinition(
		"mystic_training_lower_001",
		"Elyndra Recruit Legwraps",
		GameConfig.EquipmentSlots.Lower,
		GameConfig.Factions.MYSTIC,
		6
	),
	mystic_training_gloves_001 = starterArmorDefinition(
		"mystic_training_gloves_001",
		"Elyndra Recruit Handwraps",
		GameConfig.EquipmentSlots.Gloves,
		GameConfig.Factions.MYSTIC,
		2
	),
	mystic_training_boots_001 = starterArmorDefinition(
		"mystic_training_boots_001",
		"Elyndra Recruit Boots",
		GameConfig.EquipmentSlots.Boots,
		GameConfig.Factions.MYSTIC,
		2
	),
	upgrader = {
		Id = "upgrader",
		Name = "Aetherion Upgrader",
		Category = GameConfig.ItemCategories.Material,
		Type = "Utility",
		SpecialAction = "OpenUpgradeUI",
		IsPermanent = true,
		Locked = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
		Stackable = false,
		Slots = 0,
		Durability = 0,
		MaxDurability = 0,
	},

	-- ============================================================
	-- RING & AMULET — Elemental Accessories (RF Online Classic)
	--
	-- Normal Elementals:
	--   Bellato → Wristlets, Cora → Armlets  (EquipSlot = "Ring")
	-- Rare Elementals (PitBoss drops):
	--   Ring  → EquipSlot = "Ring"
	--   Leash → EquipSlot = "Amulet"
	--
	-- Element variants: Fire / Aqua / Terra / Wind
	-- Stats: Attack, ForceAttack, Accuracy, ElementalAttack per element
	-- ============================================================

	-- helper lokal untuk buat elemental item
	-- (tidak di-export, hanya dipakai sekali saat build table)

	-- ---- BELLATO WRISTLETS (MECHA) ----
	-- Parsal Wristlets — Tier 1
	parsal_wristlets_fire  = { Id="parsal_wristlets_fire",  Name="Parsal Fire Wristlets",  Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=8,  Accuracy=5,  ElementalAttackFire=15 } },
	parsal_wristlets_aqua  = { Id="parsal_wristlets_aqua",  Name="Parsal Aqua Wristlets",  Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=8,  Accuracy=5,  ElementalAttackAqua=15 } },
	parsal_wristlets_terra = { Id="parsal_wristlets_terra", Name="Parsal Terra Wristlets", Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=8,  Accuracy=5,  ElementalAttackTerra=15 } },
	parsal_wristlets_wind  = { Id="parsal_wristlets_wind",  Name="Parsal Wind Wristlets",  Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=8,  Accuracy=5,  ElementalAttackWind=15 } },

	-- Spirit Wristlets — Tier 2
	spirit_wristlets_fire  = { Id="spirit_wristlets_fire",  Name="Spirit Fire Wristlets",  Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=14, Accuracy=8,  ElementalAttackFire=25 } },
	spirit_wristlets_aqua  = { Id="spirit_wristlets_aqua",  Name="Spirit Aqua Wristlets",  Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=14, Accuracy=8,  ElementalAttackAqua=25 } },
	spirit_wristlets_terra = { Id="spirit_wristlets_terra", Name="Spirit Terra Wristlets", Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=14, Accuracy=8,  ElementalAttackTerra=25 } },
	spirit_wristlets_wind  = { Id="spirit_wristlets_wind",  Name="Spirit Wind Wristlets",  Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ Attack=14, Accuracy=8,  ElementalAttackWind=25 } },

	-- Mind Wristlets — Tier 3
	mind_wristlets_fire    = { Id="mind_wristlets_fire",    Name="Mind Fire Wristlets",    Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=20, ForceAttack=10, Accuracy=12, ElementalAttackFire=35 } },
	mind_wristlets_aqua    = { Id="mind_wristlets_aqua",    Name="Mind Aqua Wristlets",    Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=20, ForceAttack=10, Accuracy=12, ElementalAttackAqua=35 } },
	mind_wristlets_terra   = { Id="mind_wristlets_terra",   Name="Mind Terra Wristlets",   Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=20, ForceAttack=10, Accuracy=12, ElementalAttackTerra=35 } },
	mind_wristlets_wind    = { Id="mind_wristlets_wind",    Name="Mind Wind Wristlets",    Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=20, ForceAttack=10, Accuracy=12, ElementalAttackWind=35 } },

	-- Ell Wristlets — Tier 4
	ell_wristlets_fire     = { Id="ell_wristlets_fire",     Name="Ell Fire Wristlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=28, ForceAttack=16, Accuracy=16, ElementalAttackFire=45 } },
	ell_wristlets_aqua     = { Id="ell_wristlets_aqua",     Name="Ell Aqua Wristlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=28, ForceAttack=16, Accuracy=16, ElementalAttackAqua=45 } },
	ell_wristlets_terra    = { Id="ell_wristlets_terra",    Name="Ell Terra Wristlets",    Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=28, ForceAttack=16, Accuracy=16, ElementalAttackTerra=45 } },
	ell_wristlets_wind     = { Id="ell_wristlets_wind",     Name="Ell Wind Wristlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MECHA, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=28, ForceAttack=16, Accuracy=16, ElementalAttackWind=45 } },

	-- ---- CORA ARMLETS (MYSTIC) ----
	-- Stuff Armlets — Tier 1
	stuff_armlets_fire     = { Id="stuff_armlets_fire",     Name="Stuff Fire Armlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=10, Accuracy=5,  ElementalAttackFire=15 } },
	stuff_armlets_aqua     = { Id="stuff_armlets_aqua",     Name="Stuff Aqua Armlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=10, Accuracy=5,  ElementalAttackAqua=15 } },
	stuff_armlets_terra    = { Id="stuff_armlets_terra",    Name="Stuff Terra Armlets",    Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=10, Accuracy=5,  ElementalAttackTerra=15 } },
	stuff_armlets_wind     = { Id="stuff_armlets_wind",     Name="Stuff Wind Armlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=10, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=10, Accuracy=5,  ElementalAttackWind=15 } },

	-- Mild Armlets — Tier 2
	mild_armlets_fire      = { Id="mild_armlets_fire",      Name="Mild Fire Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=18, Accuracy=8,  ElementalAttackFire=25 } },
	mild_armlets_aqua      = { Id="mild_armlets_aqua",      Name="Mild Aqua Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=18, Accuracy=8,  ElementalAttackAqua=25 } },
	mild_armlets_terra     = { Id="mild_armlets_terra",     Name="Mild Terra Armlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=18, Accuracy=8,  ElementalAttackTerra=25 } },
	mild_armlets_wind      = { Id="mild_armlets_wind",      Name="Mild Wind Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=20, Slots=1, Durability=100, MaxDurability=100, Stats={ ForceAttack=18, Accuracy=8,  ElementalAttackWind=25 } },

	-- Cus Armlets — Tier 3
	cus_armlets_fire       = { Id="cus_armlets_fire",       Name="Cus Fire Armlets",       Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=10, ForceAttack=24, Accuracy=12, ElementalAttackFire=35 } },
	cus_armlets_aqua       = { Id="cus_armlets_aqua",       Name="Cus Aqua Armlets",       Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=10, ForceAttack=24, Accuracy=12, ElementalAttackAqua=35 } },
	cus_armlets_terra      = { Id="cus_armlets_terra",      Name="Cus Terra Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=10, ForceAttack=24, Accuracy=12, ElementalAttackTerra=35 } },
	cus_armlets_wind       = { Id="cus_armlets_wind",       Name="Cus Wind Armlets",       Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=30, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=10, ForceAttack=24, Accuracy=12, ElementalAttackWind=35 } },

	-- Glow Armlets — Tier 4
	glow_armlets_fire      = { Id="glow_armlets_fire",      Name="Glow Fire Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=14, ForceAttack=32, Accuracy=16, ElementalAttackFire=45 } },
	glow_armlets_aqua      = { Id="glow_armlets_aqua",      Name="Glow Aqua Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=14, ForceAttack=32, Accuracy=16, ElementalAttackAqua=45 } },
	glow_armlets_terra     = { Id="glow_armlets_terra",     Name="Glow Terra Armlets",     Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=14, ForceAttack=32, Accuracy=16, ElementalAttackTerra=45 } },
	glow_armlets_wind      = { Id="glow_armlets_wind",      Name="Glow Wind Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=40, Slots=2, Durability=100, MaxDurability=100, Stats={ Attack=14, ForceAttack=32, Accuracy=16, ElementalAttackWind=45 } },

	-- Dan Armlets — Tier 5
	dan_armlets_fire       = { Id="dan_armlets_fire",       Name="Dan Fire Armlets",       Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=50, Slots=3, Durability=100, MaxDurability=100, Stats={ Attack=18, ForceAttack=42, Accuracy=20, ElementalAttackFire=55 } },
	dan_armlets_aqua       = { Id="dan_armlets_aqua",       Name="Dan Aqua Armlets",       Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=50, Slots=3, Durability=100, MaxDurability=100, Stats={ Attack=18, ForceAttack=42, Accuracy=20, ElementalAttackAqua=55 } },
	dan_armlets_terra      = { Id="dan_armlets_terra",      Name="Dan Terra Armlets",      Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=50, Slots=3, Durability=100, MaxDurability=100, Stats={ Attack=18, ForceAttack=42, Accuracy=20, ElementalAttackTerra=55 } },
	dan_armlets_wind       = { Id="dan_armlets_wind",       Name="Dan Wind Armlets",       Category=GameConfig.ItemCategories.Ring, EquipSlot="Ring", Faction=GameConfig.Factions.MYSTIC, Level=50, Slots=3, Durability=100, MaxDurability=100, Stats={ Attack=18, ForceAttack=42, Accuracy=20, ElementalAttackWind=55 } },

	-- ---- RARE ELEMENTALS — PitBoss Drops (all factions) ----
	-- Dagnu's Ring
	dagnus_ring = {
		Id = "dagnus_ring", Name = "Dagnu's Ring",
		Category = GameConfig.ItemCategories.Ring, EquipSlot = "Ring",
		Level = 40, Slots = 3, Durability = 100, MaxDurability = 100,
		Stats = { Attack = 35, ForceAttack = 35, Accuracy = 20, Dodge = 15, CritChance = 0.05 },
	},

	-- Dagan's Ring
	dagans_ring = {
		Id = "dagans_ring", Name = "Dagan's Ring",
		Category = GameConfig.ItemCategories.Ring, EquipSlot = "Ring",
		Level = 45, Slots = 3, Durability = 100, MaxDurability = 100,
		Stats = { Attack = 42, ForceAttack = 42, Accuracy = 24, Dodge = 18, CritChance = 0.06 },
	},

	-- Dagon's Leash
	dagons_leash = {
		Id = "dagons_leash", Name = "Dagon's Leash",
		Category = GameConfig.ItemCategories.Amulet, EquipSlot = "Amulet",
		Level = 40, Slots = 3, Durability = 100, MaxDurability = 100,
		Stats = { Defense = 30, MaxHP = 200, Accuracy = 18, ElementalResistanceFlat = 20 },
	},

	-- Blackblood Brother's Leash
	blackblood_leash = {
		Id = "blackblood_leash", Name = "Blackblood Brother's Leash",
		Category = GameConfig.ItemCategories.Amulet, EquipSlot = "Amulet",
		Level = 45, Slots = 3, Durability = 100, MaxDurability = 100,
		Stats = { Defense = 38, MaxHP = 280, Accuracy = 22, ElementalResistanceFlat = 28 },
	},

	-- ============================================================
	-- TALIC — sesuai RF Online asli
	--
	-- AppliesTo   : key dari GameConfig.TalicTargetGroups
	--               UpgradeService membaca ini untuk validasi slot compatibility.
	-- UpgradePower: bonus success rate (ditambah ke base chance upgrade)
	-- UpgradeEffect: efek yang diberikan ke item setelah talic berhasil dipasang
	--               (diproses EquipmentService saat hitung total stats)
	-- ============================================================

	-- 1. Ignorance Talic — Weapon — Increase Attack Power
	ignorant_talic = {
		Id = "ignorant_talic",
		Name = "Ignorance Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Weapon",
		UpgradePower = 0.01,
		UpgradeEffect = { Type = "WeaponAttackUpgrade" },
		Description = "Increases weapon Attack Power.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 1b. Keen Talic — Weapon — Increase Attack Power (stronger)
	keen_talic = {
		Id = "keen_talic",
		Name = "Keen Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Weapon",
		UpgradePower = 0.015,
		UpgradeEffect = { Type = "WeaponAttackUpgrade" },
		Description = "Increases weapon Attack Power.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 2. Destruction Talic — Weapon — Absorbs some of target's HP
	destruction_talic = {
		Id = "destruction_talic",
		Name = "Destruction Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Weapon",
		UpgradePower = 0.04,
		UpgradeEffect = { Type = "LifeStealPercent", ValuePerTalic = 0.03 },
		Description = "Absorbs some of the target's HP on each hit.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 3. Darkness Talic — Weapon — Lowers target's Block Rate
	darkness_talic = {
		Id = "darkness_talic",
		Name = "Darkness Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Weapon",
		UpgradePower = 0.02,
		UpgradeEffect = { Type = "IgnoreBlockChance", ValuePerTalic = 0.03 },
		Description = "Lowers the target's Block Rate.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 4. Chaos Talic — Weapon + Jetpack (Cloak) — Temporarily Stuns target
	chaos_talic = {
		Id = "chaos_talic",
		Name = "Chaos Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "WeaponOrCloak",
		UpgradePower = 0.05,
		UpgradeEffect = { Type = "StunChance", ValuePerTalic = 0.03 },
		Description = "Adds a chance to temporarily stun the target.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 5. Hatred Talic — Ranged Weapons only — Increases Attack Range
	hatred_talic = {
		Id = "hatred_talic",
		Name = "Hatred Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "RangedWeapon",
		UpgradePower = 0.02,
		UpgradeEffect = { Type = "RangeMultiplier", ValuePerTalic = 0.05 },
		Description = "Increases Attack Range. Ranged weapons only.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 6. Favor Talic — All Armor (Helmet/Upper/Lower/Gloves/Boots/Shield/Cloak) — Increases Defense
	favor_talic = {
		Id = "favor_talic",
		Name = "Favor Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "AllArmor",
		UpgradePower = 0.02,
		UpgradeEffect = { Type = "DefenseFlat", ValuePerTalic = 2 },
		Description = "Increases Defense. Can be used on any armor piece.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 7. Wisdom Talic — Helmet only — Reduces Debuff Duration
	wisdom_talic = {
		Id = "wisdom_talic",
		Name = "Wisdom Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Helmet",
		UpgradePower = 0.025,
		UpgradeEffect = { Type = "DebuffDurationReduction", ValuePerTalic = 0.05 },
		Description = "Reduces the duration of debuffs on the wearer. Helmet only.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 8. Sacredfire Talic — Upper/Lower/Shield/Jetpack/Melee Weapon — Fire Resistance
	sacred_fire_talic = {
		Id = "sacred_fire_talic",
		Name = "Sacredfire Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "UpperLowerShieldJetpackMelee",
		UpgradePower = 0.03,
		UpgradeEffect = { Type = "FireResistanceFlat", ValuePerTalic = 1 },
		Description = "Increases Fire Resistance.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 9. Belief Talic — Upper/Lower/Shield/Jetpack/Melee Weapon — Water Resistance
	belief_talic = {
		Id = "belief_talic",
		Name = "Belief Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "UpperLowerShieldJetpackMelee",
		UpgradePower = 0.035,
		UpgradeEffect = { Type = "AquaResistanceFlat", ValuePerTalic = 1 },
		Description = "Increases Water Resistance.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 10. Guard Talic — Upper/Lower/Shield/Jetpack/Melee Weapon — Terra Resistance
	guard_talic = {
		Id = "guard_talic",
		Name = "Guard Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "UpperLowerShieldJetpackMelee",
		UpgradePower = 0.015,
		UpgradeEffect = { Type = "TerraResistanceFlat", ValuePerTalic = 1 },
		Description = "Increases Terra Resistance.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 11. Glory Talic — Upper/Lower/Shield/Jetpack/Melee Weapon — Wind Resistance
	glory_talic = {
		Id = "glory_talic",
		Name = "Glory Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "UpperLowerShieldJetpackMelee",
		UpgradePower = 0.02,
		UpgradeEffect = { Type = "WindResistanceFlat", ValuePerTalic = 1 },
		Description = "Increases Wind Resistance.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 12. Grace Talic — Gloves only — Increases Accuracy
	grace_talic = {
		Id = "grace_talic",
		Name = "Grace Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Gloves",
		UpgradePower = 0.02,
		UpgradeEffect = { Type = "AccuracyFlat", ValuePerTalic = 2 },
		Description = "Increases Accuracy. Gloves only.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 13. Mercy Talic — Boots only — Increases Avoidance Rate
	mercy_talic = {
		Id = "mercy_talic",
		Name = "Mercy Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Talic",
		AppliesTo = "Boots",
		UpgradePower = 0.02,
		UpgradeEffect = { Type = "DodgeFlat", ValuePerTalic = 2 },
		Description = "Increases Avoidance Rate. Boots only.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- 14. Restoration Talic — All equipment — Removes the last added Talic
	-- UpgradeRole = "Restoration" → UpgradeService handle ini sebagai kasus khusus
	restoration_talic = {
		Id = "restoration_talic",
		Name = "Restoration Talic",
		Category = GameConfig.ItemCategories.Material,
		Type = "Talic",
		UpgradeRole = "Restoration",
		AppliesTo = "All",
		UpgradePower = 0,
		UpgradeEffect = { Type = "RemoveLastTalic" },
		Description = "Removes the last added Talic from any equipment.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	-- ============================================================
	-- CATALYST — meningkatkan success rate, tidak memberi efek pada item
	-- ============================================================

	upgrade_catalyst_low = {
		Id = "upgrade_catalyst_low",
		Name = "Low Upgrade Catalyst",
		Category = GameConfig.ItemCategories.Material,
		Type = "UpgradeCatalyst",
		UpgradeRole = "Catalyst",
		AppliesTo = "All",
		UpgradePower = 0.02,
		Description = "Slightly increases upgrade success rate.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	upgrade_catalyst_medium = {
		Id = "upgrade_catalyst_medium",
		Name = "Medium Upgrade Catalyst",
		Category = GameConfig.ItemCategories.Material,
		Type = "UpgradeCatalyst",
		UpgradeRole = "Catalyst",
		AppliesTo = "All",
		UpgradePower = 0.04,
		Description = "Moderately increases upgrade success rate.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},

	upgrade_catalyst_high = {
		Id = "upgrade_catalyst_high",
		Name = "High Upgrade Catalyst",
		Category = GameConfig.ItemCategories.Material,
		Type = "UpgradeCatalyst",
		UpgradeRole = "Catalyst",
		AppliesTo = "All",
		UpgradePower = 0.06,
		Description = "Greatly increases upgrade success rate.",
		Stackable = true,
		CanSell = false,
		CanDrop = false,
		CanTrade = false,
	},
}

return ItemDefinitions
