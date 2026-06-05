local GameConfig = require(script.Parent.GameConfig)

local CombatFormulas = {}

local function randomFloat(minValue, maxValue)
	return minValue + math.random() * (maxValue - minValue)
end

-- Hitung FP cost untuk satu Force Attack, mempertimbangkan FPCostReduction dari equipment.
-- FPCostReduction: 0.0 (tidak ada pengurangan) s/d 0.80 (80% lebih murah).
-- FPCostIncrease: multiplier tambahan, 0.0 = tidak ada tambahan, 0.5 = 50% lebih mahal.
function CombatFormulas.GetFPCost(attackerStats)
	local base = GameConfig.ForceAttack.FPCostBase
	local reduction = math.clamp(attackerStats.FPCostReduction or 0, 0, 0.80)
	local increase = math.clamp(attackerStats.FPCostIncrease or 0, 0, 3.00)
	local cost = base * (1 - reduction) * (1 + increase)
	return math.max(1, math.floor(cost))
end

-- Hitung damage Force Attack.
-- Menggunakan ForceAttack stat (dari weapon dengan ForceAttackMin/Max),
-- dengan defense reduction dan variance terpisah dari normal attack.
function CombatFormulas.CalculateForceAttack(attackerStats, defenderStats)
	local forceAttack = attackerStats.ForceAttack or 0
	local defense = defenderStats.Defense or 0
	local critChance = attackerStats.CritChance or 0.05

	if forceAttack <= 0 then
		return 0, false
	end

	local variance = randomFloat(
		GameConfig.ForceAttack.DamageVarianceMin,
		GameConfig.ForceAttack.DamageVarianceMax
	)

	local defenseReduction = defense / (defense + GameConfig.Combat.DefenseScale)
	local rawDamage = forceAttack * variance
	local damage = rawDamage * (1 - defenseReduction)

	local isCrit = math.random() < critChance

	if isCrit then
		damage *= GameConfig.Combat.CritMultiplier
	end

	return math.max(1, math.floor(damage)), isCrit
end

function CombatFormulas.GetRequiredPlayerExp(level)
	return math.floor(100 + (level ^ 2.25) * 55)
end

function CombatFormulas.GetPTExpGain(playerLevel, targetLevel, baseModifier)
	playerLevel = math.max(playerLevel or 1, 1)
	targetLevel = math.max(targetLevel or 1, 1)
	baseModifier = baseModifier or 1

	return (targetLevel / playerLevel) * baseModifier
end

function CombatFormulas.GetRequiredPTExp(ptLevel)
	return math.floor(50 + (ptLevel ^ 2.15) * 18)
end

function CombatFormulas.CalculateDamage(attackerStats, defenderStats)
	local attack = attackerStats.Attack or 1
	local defense = defenderStats.Defense or 0
	local critChance = attackerStats.CritChance or 0.05

	local variance = randomFloat(
		GameConfig.Combat.BaseDamageVarianceMin,
		GameConfig.Combat.BaseDamageVarianceMax
	)

	local defenseReduction = defense / (defense + GameConfig.Combat.DefenseScale)
	local rawDamage = attack * variance
	local damage = rawDamage * (1 - defenseReduction)

	local isCrit = math.random() < critChance

	if isCrit then
		damage *= GameConfig.Combat.CritMultiplier
	end

	return math.max(1, math.floor(damage)), isCrit
end

function CombatFormulas.GetUpgradeAttackBonus(baseAttack, upgradeLevel)
	return math.floor((baseAttack or 0) * (upgradeLevel or 0) * 0.08)
end

function CombatFormulas.GetUpgradeDefenseBonus(baseDefense, upgradeLevel)
	return math.floor((baseDefense or 0) * (upgradeLevel or 0) * 0.07)
end

return CombatFormulas
