local WeaponEffectService = {}

function WeaponEffectService.ApplyEffectsToStats(baseStats, effects)
	local stats = table.clone(baseStats)

	stats.Attack = stats.Attack or 0
	stats.ForceAttack = stats.ForceAttack or 0
	stats.Defense = stats.Defense or 0
	stats.MaxHP = stats.MaxHP or 0
	stats.MaxFP = stats.MaxFP or 0
	stats.MoveSpeed = stats.MoveSpeed or 16
	stats.CritChance = stats.CritChance or 0.05
	stats.CritResistance = stats.CritResistance or 0
	stats.Accuracy = stats.Accuracy or 0
	stats.BlockChance = stats.BlockChance or 0
	stats.RangeMultiplier = stats.RangeMultiplier or 1
	stats.LifeStealPercent = stats.LifeStealPercent or 0
	stats.IgnoreBlockChance = stats.IgnoreBlockChance or 0
	stats.ElementalResistanceFlat = stats.ElementalResistanceFlat or 0
	stats.ElementalResistancePercent = stats.ElementalResistancePercent or 0
	stats.LauncherAttackDelayReduction = stats.LauncherAttackDelayReduction or 0
	stats.DebuffDurationReduction = stats.DebuffDurationReduction or 0
	stats.FPCostReduction = stats.FPCostReduction or 0
	stats.IsRareDForceHybrid = stats.IsRareDForceHybrid or false

	for _, effect in ipairs(effects or {}) do
		if effect.Type == "AttackPercent" then
			stats.Attack += math.floor(stats.Attack * effect.Value)

		elseif effect.Type == "ForceAttackPercent" then
			stats.ForceAttack += math.floor(stats.ForceAttack * effect.Value)

		elseif effect.Type == "DefensePercent" then
			stats.Defense += math.floor(stats.Defense * effect.Value)

		elseif effect.Type == "MaxHPPercent" then
			stats.MaxHP += math.floor(stats.MaxHP * effect.Value)

		elseif effect.Type == "MaxFPPercent" then
			stats.MaxFP += math.floor(stats.MaxFP * effect.Value)

		elseif effect.Type == "MoveSpeedFlat" then
			stats.MoveSpeed += effect.Value

		elseif effect.Type == "CriticalChanceFlat" then
			stats.CritChance += effect.Value

		elseif effect.Type == "CriticalResistanceFlat" then
			stats.CritResistance += effect.Value

		elseif effect.Type == "AccuracyFlat" then
			stats.Accuracy += effect.Value

		elseif effect.Type == "AccuracyPercent" then
			local baseAccuracy = math.max(stats.Accuracy, 1)
			stats.Accuracy += math.floor(baseAccuracy * effect.Value)

		elseif effect.Type == "BlockChanceFlat" then
			stats.BlockChance += effect.Value

		elseif effect.Type == "RangePercent" then
			stats.RangeMultiplier += effect.Value

		elseif effect.Type == "LifeStealPercent" then
			stats.LifeStealPercent += effect.Value

		elseif effect.Type == "IgnoreBlockChance" then
			stats.IgnoreBlockChance += effect.Value

		elseif effect.Type == "ElementalResistanceFlat" then
			stats.ElementalResistanceFlat += effect.Value

		elseif effect.Type == "ElementalResistancePercent" then
			stats.ElementalResistancePercent += effect.Value

		elseif effect.Type == "LauncherAttackDelayReduction" then
			stats.LauncherAttackDelayReduction += effect.Value

		elseif effect.Type == "DebuffDurationReduction" then
			stats.DebuffDurationReduction += effect.Value

		elseif effect.Type == "FPCostReduction" then
			stats.FPCostReduction += effect.Value

		elseif effect.Type == "RareDForceHybrid" then
			stats.IsRareDForceHybrid = true
		end
	end

	stats.MoveSpeed = math.max(4, stats.MoveSpeed)
	stats.CritChance = math.clamp(stats.CritChance, 0, 0.95)
	stats.CritResistance = math.clamp(stats.CritResistance, 0, 0.80)
	stats.BlockChance = math.clamp(stats.BlockChance, 0, 0.75)
	stats.LifeStealPercent = math.clamp(stats.LifeStealPercent, 0, 0.50)
	stats.IgnoreBlockChance = math.clamp(stats.IgnoreBlockChance, 0, 1)
	stats.FPCostReduction = math.clamp(stats.FPCostReduction, 0, 0.80)
	stats.DebuffDurationReduction = math.clamp(stats.DebuffDurationReduction, 0, 0.80)
	stats.ElementalResistancePercent = math.clamp(stats.ElementalResistancePercent, -0.80, 0.80)

	return stats
end

return WeaponEffectService