local GameConfig = require(script.Parent.Parent.GameConfig)

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
		AttackMin = 8, AttackMax = 13, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 7, AttackMax = 15, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 5, AttackMax = 10, ForceAttackMin = 8, ForceAttackMax = 15,
		Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 5, AttackMax = 9, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 9, AttackMax = 14, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 12, AttackMax = 22, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 6, AttackMax = 10, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 7, AttackMax = 12, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 7, AttackMax = 14, Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 4, AttackMax = 9, ForceAttackMin = 10, ForceAttackMax = 18,
		Defense = 0, MaxUpgrade = 7,
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
		AttackMin = 5, AttackMax = 9, Defense = 0, MaxUpgrade = 7,
	},
	mecha_training_armor_001 = {
		Id = "mecha_training_armor_001",
		Name = "Mechanica Recruit Armor",
		Category = GameConfig.ItemCategories.Armor,
		Slot = GameConfig.EquipmentSlots.Armor,
		FactionId = GameConfig.Factions.MECHA,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Defense, Level = 1 },
		AttackMin = 0, AttackMax = 0, Defense = 15, MaxUpgrade = 7,
	},
	cyborg_training_armor_001 = {
		Id = "cyborg_training_armor_001",
		Name = "Dominion Recruit Frame",
		Category = GameConfig.ItemCategories.Armor,
		Slot = GameConfig.EquipmentSlots.Armor,
		FactionId = GameConfig.Factions.CYBORG,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Defense, Level = 1 },
		AttackMin = 0, AttackMax = 0, Defense = 18, MaxUpgrade = 7,
	},
	mystic_training_robe_001 = {
		Id = "mystic_training_robe_001",
		Name = "Elyndra Recruit Robe",
		Category = GameConfig.ItemCategories.Armor,
		Slot = GameConfig.EquipmentSlots.Armor,
		FactionId = GameConfig.Factions.MYSTIC,
		RequiredLevel = 1,
		RequiredPT = { Type = GameConfig.PTTypes.Defense, Level = 1 },
		AttackMin = 0, AttackMax = 0, Defense = 11, MaxUpgrade = 7,
	},
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
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
		Stackable = true, CanSell = false, CanDrop = false, CanTrade = false,
	},
}

return ItemDefinitions
