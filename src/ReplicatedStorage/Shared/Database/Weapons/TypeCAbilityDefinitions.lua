local TypeCAbilityDefinitions = {}

TypeCAbilityDefinitions.Abilities = {
	Strong = {
		Id = "Strong",
		DisplayName = "Strong",
		Description = "Attack weapon meningkat.",
		Effects = {
			{ Type = "AttackPercent", Value = 0.05 },
		},
	},

	Fine = {
		Id = "Fine",
		DisplayName = "Fine",
		Description = "Accuracy meningkat.",
		Effects = {
			{ Type = "AccuracyFlat", Value = 5 },
		},
	},

	Solid = {
		Id = "Solid",
		DisplayName = "Solid",
		Description = "Defense meningkat.",
		Effects = {
			{ Type = "DefensePercent", Value = 0.10 },
		},
	},

	Strength = {
		Id = "Strength",
		DisplayName = "Strength",
		Description = "Max HP meningkat.",
		Effects = {
			{ Type = "MaxHPPercent", Value = 0.06 },
		},
	},

	AdvancedStrength = {
		Id = "AdvancedStrength",
		DisplayName = "Advanced Strength",
		Description = "Max HP dan Max FP meningkat.",
		Effects = {
			{ Type = "MaxHPPercent", Value = 0.06 },
			{ Type = "MaxFPPercent", Value = 0.06 },
		},
	},

	Vampire = {
		Id = "Vampire",
		DisplayName = "Vampire",
		Description = "Sebagian damage berubah menjadi heal HP.",
		Effects = {
			{ Type = "LifeStealPercent", Value = 0.04 },
		},
	},

	Guardian = {
		Id = "Guardian",
		DisplayName = "Guardian",
		Description = "Durasi debuff/curse berkurang.",
		Effects = {
			{ Type = "DebuffDurationReduction", Value = 0.10 },
		},
	},

	Sharp = {
		Id = "Sharp",
		DisplayName = "Sharp",
		Description = "Critical chance meningkat.",
		Effects = {
			{ Type = "CriticalChanceFlat", Value = 0.08 },
		},
	},

	Protection = {
		Id = "Protection",
		DisplayName = "Protection",
		Description = "Block chance meningkat.",
		Effects = {
			{ Type = "BlockChanceFlat", Value = 0.05 },
		},
	},

	Grand = {
		Id = "Grand",
		DisplayName = "Grand",
		Description = "Range serangan meningkat.",
		Effects = {
			{ Type = "RangePercent", Value = 0.10 },
		},
	},

	AntiSharp = {
		Id = "AntiSharp",
		DisplayName = "Anti-Sharp",
		Description = "Mengurangi peluang terkena critical.",
		Effects = {
			{ Type = "CriticalResistanceFlat", Value = 0.08 },
		},
	},

	Saving = {
		Id = "Saving",
		DisplayName = "Saving",
		Description = "Konsumsi FP skill/force berkurang.",
		Effects = {
			{ Type = "FPCostReduction", Value = 0.10 },
		},
	},

	Endurance = {
		Id = "Endurance",
		DisplayName = "Endurance",
		Description = "Elemental resistance meningkat.",
		Effects = {
			{ Type = "ElementalResistanceFlat", Value = 4 },
		},
	},

	LevelDown = {
		Id = "LevelDown",
		DisplayName = "Level Down",
		Description = "Requirement level weapon turun.",
		Effects = {
			{ Type = "RequiredLevelReduction", Value = 5 },
		},
	},
}

function TypeCAbilityDefinitions.GetAbility(abilityId)
	return TypeCAbilityDefinitions.Abilities[abilityId]
end

function TypeCAbilityDefinitions.GetEffects(abilityId)
	local ability = TypeCAbilityDefinitions.GetAbility(abilityId)

	if not ability then
		return {}
	end

	return ability.Effects or {}
end

return TypeCAbilityDefinitions