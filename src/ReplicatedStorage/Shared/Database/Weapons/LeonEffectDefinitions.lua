local LeonEffectDefinitions = {}

LeonEffectDefinitions.Grades = {
	Low = "Low",
	Med = "Med",
	High = "High",
}

LeonEffectDefinitions.GradeProfiles = {
	Low = {
		HPMultiplier = 0.08,
		DefenseMultiplier = 0.20,
		BlockChance = 0.03,
		MoveSpeedPenalty = -3.00,

		AllAttackMultiplier = 0.10,
		IgnoreBlockChance = 0.15,
		ForceDelayReduction = 0.30,
		FPCostIncrease = 1.50,

		LauncherDelayReduction = 0.03,
		RangeMultiplier = 0.03,
		AccuracyBonus = 3,
		CriticalChanceBonus = 0.03,
	},

	Med = {
		HPMultiplier = 0.10,
		DefenseMultiplier = 0.25,
		BlockChance = 0.05,
		MoveSpeedPenalty = -2.50,

		AllAttackMultiplier = 0.15,
		IgnoreBlockChance = 0.20,
		ForceDelayReduction = 0.50,
		FPCostIncrease = 1.90,

		LauncherDelayReduction = 0.05,
		RangeMultiplier = 0.05,
		AccuracyBonus = 5,
		CriticalChanceBonus = 0.05,
	},

	High = {
		HPMultiplier = 0.13,
		DefenseMultiplier = 0.30,
		BlockChance = 0.08,
		MoveSpeedPenalty = -2.00,

		AllAttackMultiplier = 0.20,
		IgnoreBlockChance = 0.25,
		ForceDelayReduction = 0.70,
		FPCostIncrease = 2.30,

		LauncherDelayReduction = 0.07,
		RangeMultiplier = 0.08,
		AccuracyBonus = 8,
		CriticalChanceBonus = 0.08,
	},
}

local function getGradeFromName(name)
	local lowerName = string.lower(name)

	if string.find(lowerName, "low") then
		return LeonEffectDefinitions.Grades.Low
	end

	if string.find(lowerName, "med") or string.find(lowerName, "medium") then
		return LeonEffectDefinitions.Grades.Med
	end

	if string.find(lowerName, "high") then
		return LeonEffectDefinitions.Grades.High
	end

	return nil
end

local function isMagicWeapon(weaponType)
	return weaponType == "Staff" or weaponType == "Wand"
end

local function isLauncherWeapon(weaponType)
	return weaponType == "Launcher" or weaponType == "GrenadeLauncher"
end

local function isRangedWeapon(weaponType)
	return weaponType == "Bow"
		or weaponType == "Rifle"
		or weaponType == "Gun"
		or weaponType == "Gatling"
end

function LeonEffectDefinitions.GetGradeFromName(name)
	return getGradeFromName(name)
end

function LeonEffectDefinitions.GetEffects(name, weaponType)
	local grade = getGradeFromName(name)

	if not grade then
		return {}, nil
	end

	local profile = LeonEffectDefinitions.GradeProfiles[grade]
	local effects = {}

	if isMagicWeapon(weaponType) then
		table.insert(effects, {
			Type = "AllAttackPercent",
			Value = profile.AllAttackMultiplier,
		})

		table.insert(effects, {
			Type = "IgnoreBlockChance",
			Value = profile.IgnoreBlockChance,
		})

		table.insert(effects, {
			Type = "ForceDelayReductionFlat",
			Value = profile.ForceDelayReduction,
		})

		table.insert(effects, {
			Type = "FPCostIncreasePercent",
			Value = profile.FPCostIncrease,
			IsNegative = true,
		})

		return effects, grade
	end

	table.insert(effects, {
		Type = "MaxHPPercent",
		Value = profile.HPMultiplier,
	})

	table.insert(effects, {
		Type = "DefensePercent",
		Value = profile.DefenseMultiplier,
	})

	table.insert(effects, {
		Type = "BlockChanceFlat",
		Value = profile.BlockChance,
	})

	table.insert(effects, {
		Type = "MoveSpeedFlat",
		Value = profile.MoveSpeedPenalty,
		IsNegative = true,
	})

	if isLauncherWeapon(weaponType) then
		table.insert(effects, {
			Type = "LauncherAttackDelayReduction",
			Value = profile.LauncherDelayReduction,
		})
	end

	if isRangedWeapon(weaponType) then
		table.insert(effects, {
			Type = "RangePercent",
			Value = profile.RangeMultiplier,
		})

		table.insert(effects, {
			Type = "AccuracyFlat",
			Value = profile.AccuracyBonus,
		})
	end

	return effects, grade
end

return LeonEffectDefinitions