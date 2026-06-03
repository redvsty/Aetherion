local WeaponEnums = require(script.Parent.WeaponEnums)

local WeaponAbilityDefinitions = {}

WeaponAbilityDefinitions.Abilities = {
	[WeaponEnums.AbilityId.Wind] = {
		Id = WeaponEnums.AbilityId.Wind,
		DisplayName = "Wind",
		Description = "Movement speed meningkat.",
		Effects = {
			{ Type = "MoveSpeedFlat", Value = 1 },
		},
	},

	[WeaponEnums.AbilityId.Strong] = {
		Id = WeaponEnums.AbilityId.Strong,
		DisplayName = "Strong",
		Description = "Attack weapon meningkat.",
		Effects = {
			{ Type = "AttackPercent", Value = 0.05 },
		},
	},

	[WeaponEnums.AbilityId.Fine] = {
		Id = WeaponEnums.AbilityId.Fine,
		DisplayName = "Fine",
		Description = "Accuracy meningkat.",
		Effects = {
			{ Type = "AccuracyFlat", Value = 5 },
		},
	},

	[WeaponEnums.AbilityId.Smart] = {
		Id = WeaponEnums.AbilityId.Smart,
		DisplayName = "Smart",
		Description = "Konsumsi FP berkurang.",
		Effects = {
			{ Type = "FPCostReduction", Value = 0.10 },
		},
	},

	[WeaponEnums.AbilityId.Solid] = {
		Id = WeaponEnums.AbilityId.Solid,
		DisplayName = "Solid",
		Description = "Defense meningkat saat weapon dipakai.",
		Effects = {
			{ Type = "DefensePercent", Value = 0.10 },
		},
	},

	[WeaponEnums.AbilityId.Strength] = {
		Id = WeaponEnums.AbilityId.Strength,
		DisplayName = "Strength",
		Description = "Max HP meningkat.",
		Effects = {
			{ Type = "MaxHPPercent", Value = 0.06 },
		},
	},

	[WeaponEnums.AbilityId.AdvancedStrength] = {
		Id = WeaponEnums.AbilityId.AdvancedStrength,
		DisplayName = "Advanced Strength",
		Description = "Max HP dan Max FP meningkat.",
		Effects = {
			{ Type = "MaxHPPercent", Value = 0.06 },
			{ Type = "MaxFPPercent", Value = 0.06 },
		},
	},

	[WeaponEnums.AbilityId.Vampire] = {
		Id = WeaponEnums.AbilityId.Vampire,
		DisplayName = "Vampire",
		Description = "Sebagian damage menjadi heal.",
		Effects = {
			{ Type = "LifeStealPercent", Value = 0.04 },
		},
	},

	[WeaponEnums.AbilityId.Guardian] = {
		Id = WeaponEnums.AbilityId.Guardian,
		DisplayName = "Guardian",
		Description = "Durasi debuff berkurang.",
		Effects = {
			{ Type = "DebuffDurationReduction", Value = 0.10 },
		},
	},

	[WeaponEnums.AbilityId.Sharp] = {
		Id = WeaponEnums.AbilityId.Sharp,
		DisplayName = "Sharp",
		Description = "Critical chance meningkat.",
		Effects = {
			{ Type = "CriticalChanceFlat", Value = 0.08 },
		},
	},

	[WeaponEnums.AbilityId.Protection] = {
		Id = WeaponEnums.AbilityId.Protection,
		DisplayName = "Protection",
		Description = "Block chance meningkat.",
		Effects = {
			{ Type = "BlockChanceFlat", Value = 0.05 },
		},
	},

	[WeaponEnums.AbilityId.Grand] = {
		Id = WeaponEnums.AbilityId.Grand,
		DisplayName = "Grand",
		Description = "Range serangan meningkat.",
		Effects = {
			{ Type = "RangePercent", Value = 0.10 },
		},
	},

	[WeaponEnums.AbilityId.AntiSharp] = {
		Id = WeaponEnums.AbilityId.AntiSharp,
		DisplayName = "Anti-Sharp",
		Description = "Mengurangi peluang terkena critical.",
		Effects = {
			{ Type = "CriticalResistanceFlat", Value = 0.08 },
		},
	},

	[WeaponEnums.AbilityId.Saving] = {
		Id = WeaponEnums.AbilityId.Saving,
		DisplayName = "Saving",
		Description = "Mengurangi konsumsi FP.",
		Effects = {
			{ Type = "FPCostReduction", Value = 0.10 },
		},
	},

	[WeaponEnums.AbilityId.Endurance] = {
		Id = WeaponEnums.AbilityId.Endurance,
		DisplayName = "Endurance",
		Description = "Elemental resistance meningkat.",
		Effects = {
			{ Type = "ElementalResistanceFlat", Value = 4 },
		},
	},

	[WeaponEnums.AbilityId.LevelDown] = {
		Id = WeaponEnums.AbilityId.LevelDown,
		DisplayName = "Level Down",
		Description = "Requirement level turun.",
		Effects = {
			{ Type = "RequiredLevelReduction", Value = 5 },
		},
	},
}

function WeaponAbilityDefinitions.GetAbility(abilityId)
	return WeaponAbilityDefinitions.Abilities[abilityId]
end

function WeaponAbilityDefinitions.GetEffects(abilityId)
	local ability = WeaponAbilityDefinitions.GetAbility(abilityId)
	return ability and ability.Effects or {}
end

return WeaponAbilityDefinitions
