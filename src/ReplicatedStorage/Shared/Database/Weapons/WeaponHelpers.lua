local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local WeaponEnums = require(script.Parent.WeaponEnums)
local TypeCAbilityDefinitions = require(script.Parent.TypeCAbilityDefinitions)

local WeaponHelpers = {}

local function slugify(text)
	local value = string.lower(text)
	value = string.gsub(value, "%[", "")
	value = string.gsub(value, "%]", "")
	value = string.gsub(value, "%(", "")
	value = string.gsub(value, "%)", "")
	value = string.gsub(value, "'", "")
	value = string.gsub(value, "%.", "")
	value = string.gsub(value, "%s+", "_")
	value = string.gsub(value, "[^%w_]", "_")
	value = string.gsub(value, "_+", "_")
	value = string.gsub(value, "^_", "")
	value = string.gsub(value, "_$", "")
	return value
end

function WeaponHelpers.InferType(name)
	local lowerName = string.lower(name)

	if string.find(lowerName, "throwing") then
		return WeaponEnums.WeaponType.Throwing
	end

	if string.find(lowerName, "knife") or string.find(lowerName, "blade") or string.find(lowerName, "fang") then
		return WeaponEnums.WeaponType.Knife
	end

	if string.find(lowerName, "great sword") or string.find(lowerName, "two hand") then
		return WeaponEnums.WeaponType.TwoHandSword
	end

	if string.find(lowerName, "sword") or string.find(lowerName, "saber") then
		return WeaponEnums.WeaponType.Sword
	end

	if string.find(lowerName, "axe") or string.find(lowerName, "bullova") or string.find(lowerName, "burova") or string.find(lowerName, "broma") then
		return WeaponEnums.WeaponType.Axe
	end

	if string.find(lowerName, "mace") or string.find(lowerName, "hammer") or string.find(lowerName, "maul") or string.find(lowerName, "pressure") then
		return WeaponEnums.WeaponType.Mace
	end

	if string.find(lowerName, "lance") or string.find(lowerName, "spear") or string.find(lowerName, "halberd") then
		return WeaponEnums.WeaponType.Spear
	end

	if string.find(lowerName, "bow") or string.find(lowerName, "arbalest") then
		return WeaponEnums.WeaponType.Bow
	end

	if string.find(lowerName, "rifle") or string.find(lowerName, "fire arm") or string.find(lowerName, "bullet") or string.find(lowerName, "gun blade") then
		return WeaponEnums.WeaponType.Rifle
	end

	if string.find(lowerName, "gatling") or string.find(lowerName, "vulcan") then
		return WeaponEnums.WeaponType.Gatling
	end

	if string.find(lowerName, "grenade") then
		return WeaponEnums.WeaponType.GrenadeLauncher
	end

	if string.find(lowerName, "launcher") or string.find(lowerName, "faust") or string.find(lowerName, "flame thrower") or string.find(lowerName, "flamethrower") then
		return WeaponEnums.WeaponType.Launcher
	end

	if string.find(lowerName, "staff") or string.find(lowerName, "stick") or string.find(lowerName, "bead") then
		return WeaponEnums.WeaponType.Staff
	end

	if string.find(lowerName, "wand") then
		return WeaponEnums.WeaponType.Wand
	end

	return WeaponEnums.WeaponType.Unknown
end

function WeaponHelpers.GetPTType(weaponType)
	if weaponType == WeaponEnums.WeaponType.Bow
		or weaponType == WeaponEnums.WeaponType.Gun
		or weaponType == WeaponEnums.WeaponType.Rifle
		or weaponType == WeaponEnums.WeaponType.Gatling
		or weaponType == WeaponEnums.WeaponType.Throwing
	then
		return GameConfig.PTTypes.Ranged
	end

	if weaponType == WeaponEnums.WeaponType.Launcher
		or weaponType == WeaponEnums.WeaponType.GrenadeLauncher
	then
		return GameConfig.PTTypes.Launcher
	end

	if weaponType == WeaponEnums.WeaponType.Staff
		or weaponType == WeaponEnums.WeaponType.Wand
	then
		return GameConfig.PTTypes.Magic
	end

	return GameConfig.PTTypes.Melee
end

function WeaponHelpers.GetAmmoTypes(weaponType)
	if weaponType == WeaponEnums.WeaponType.Bow then
		return { WeaponEnums.AmmoType.Arrow }
	end

	if weaponType == WeaponEnums.WeaponType.Rifle
		or weaponType == WeaponEnums.WeaponType.Gun
		or weaponType == WeaponEnums.WeaponType.Gatling
	then
		return { WeaponEnums.AmmoType.Bullet }
	end

	if weaponType == WeaponEnums.WeaponType.Launcher then
		return { WeaponEnums.AmmoType.LauncherShell }
	end

	if weaponType == WeaponEnums.WeaponType.GrenadeLauncher then
		return { WeaponEnums.AmmoType.GrenadeShell }
	end

	if weaponType == WeaponEnums.WeaponType.Staff
		or weaponType == WeaponEnums.WeaponType.Wand
	then
		return { WeaponEnums.AmmoType.ForceReaver }
	end

	if weaponType == WeaponEnums.WeaponType.Throwing then
		return { WeaponEnums.AmmoType.ThrowingKnife }
	end

	return { WeaponEnums.AmmoType.None }
end

function WeaponHelpers.GetFactionId(weaponType)
	if weaponType == WeaponEnums.WeaponType.Launcher
		or weaponType == WeaponEnums.WeaponType.GrenadeLauncher
	then
		return GameConfig.Factions.CYBORG
	end

	if weaponType == WeaponEnums.WeaponType.Staff
		or weaponType == WeaponEnums.WeaponType.Wand
	then
		return GameConfig.Factions.MYSTIC
	end

	return "ALL"
end

function WeaponHelpers.GetAttackSpeed(weaponType)
	if weaponType == WeaponEnums.WeaponType.Knife then
		return 1.35
	elseif weaponType == WeaponEnums.WeaponType.Sword then
		return 1.10
	elseif weaponType == WeaponEnums.WeaponType.TwoHandSword then
		return 0.90
	elseif weaponType == WeaponEnums.WeaponType.Axe then
		return 0.90
	elseif weaponType == WeaponEnums.WeaponType.Mace then
		return 0.95
	elseif weaponType == WeaponEnums.WeaponType.Spear then
		return 0.85
	elseif weaponType == WeaponEnums.WeaponType.Bow then
		return 0.90
	elseif weaponType == WeaponEnums.WeaponType.Rifle then
		return 0.95
	elseif weaponType == WeaponEnums.WeaponType.Gatling then
		return 0.75
	elseif weaponType == WeaponEnums.WeaponType.Launcher then
		return 0.65
	elseif weaponType == WeaponEnums.WeaponType.GrenadeLauncher then
		return 0.75
	elseif weaponType == WeaponEnums.WeaponType.Staff then
		return 0.85
	elseif weaponType == WeaponEnums.WeaponType.Wand then
		return 0.95
	end

	return 1.00
end

function WeaponHelpers.GetRange(weaponType)
	if weaponType == WeaponEnums.WeaponType.Knife then
		return 7
	elseif weaponType == WeaponEnums.WeaponType.Sword then
		return 8
	elseif weaponType == WeaponEnums.WeaponType.TwoHandSword then
		return 9
	elseif weaponType == WeaponEnums.WeaponType.Axe then
		return 8
	elseif weaponType == WeaponEnums.WeaponType.Mace then
		return 8
	elseif weaponType == WeaponEnums.WeaponType.Spear then
		return 11
	elseif weaponType == WeaponEnums.WeaponType.Bow then
		return 85
	elseif weaponType == WeaponEnums.WeaponType.Rifle then
		return 90
	elseif weaponType == WeaponEnums.WeaponType.Gatling then
		return 75
	elseif weaponType == WeaponEnums.WeaponType.Launcher then
		return 100
	elseif weaponType == WeaponEnums.WeaponType.GrenadeLauncher then
		return 75
	elseif weaponType == WeaponEnums.WeaponType.Staff then
		return 55
	elseif weaponType == WeaponEnums.WeaponType.Wand then
		return 50
	end

	return 8
end

local function getLeonGrade(rarity)
	if rarity == WeaponEnums.Rarity.LeonLow then
		return "Low"
	elseif rarity == WeaponEnums.Rarity.LeonMedium then
		return "Med"
	elseif rarity == WeaponEnums.Rarity.LeonHigh then
		return "High"
	end

	return nil
end

local function getLeonGradeValue(rarity, lowValue, medValue, highValue)
	if rarity == WeaponEnums.Rarity.LeonLow then
		return lowValue
	elseif rarity == WeaponEnums.Rarity.LeonMedium then
		return medValue
	elseif rarity == WeaponEnums.Rarity.LeonHigh then
		return highValue
	end

	return nil
end

function WeaponHelpers.GetLeonEffects(name, rarity, weaponType)
	local effects = {}
	local grade = getLeonGrade(rarity)

	if not grade then
		return effects
	end

	local lowerName = string.lower(name)

	-- Leon Knife / Gun Blade:
	-- +HP, +Defense, +Shield block, -MoveSpeed.
	if weaponType == WeaponEnums.WeaponType.Knife then
		table.insert(effects, {
			Type = "MaxHPPercent",
			Value = getLeonGradeValue(rarity, 0.08, 0.10, 0.13),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "DefensePercent",
			Value = getLeonGradeValue(rarity, 0.20, 0.25, 0.30),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "BlockChanceFlat",
			Value = getLeonGradeValue(rarity, 0.03, 0.05, 0.08),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "MoveSpeedFlat",
			Value = -getLeonGradeValue(rarity, 3.00, 2.50, 2.00),
			Source = "LeonNegative",
		})

		return effects
	end

	-- Leon Rifle / Vulcan:
	-- +Attack, +Accuracy, +Ignore block, -Critical chance.
	if weaponType == WeaponEnums.WeaponType.Rifle
		or weaponType == WeaponEnums.WeaponType.Gatling
	then
		table.insert(effects, {
			Type = "AttackPercent",
			Value = getLeonGradeValue(rarity, 0.20, 0.25, 0.30),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "AccuracyPercent",
			Value = getLeonGradeValue(rarity, 0.20, 0.25, 0.30),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "IgnoreBlockChance",
			Value = getLeonGradeValue(rarity, 0.15, 0.20, 0.25),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "CriticalChanceFlat",
			Value = -getLeonGradeValue(rarity, 0.405, 0.36, 0.315),
			Source = "LeonNegative",
		})

		return effects
	end

	-- Leon Spear / Lance:
	-- +Attack, +Accuracy, +Lifesteal, -All resistance.
	if weaponType == WeaponEnums.WeaponType.Spear then
		table.insert(effects, {
			Type = "AttackPercent",
			Value = getLeonGradeValue(rarity, 0.15, 0.20, 0.25),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "AccuracyPercent",
			Value = getLeonGradeValue(rarity, 0.25, 0.30, 0.35),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "LifeStealPercent",
			Value = getLeonGradeValue(rarity, 0.20, 0.25, 0.30),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "ElementalResistancePercent",
			Value = -getLeonGradeValue(rarity, 0.20, 0.25, 0.30),
			Source = "LeonNegative",
		})

		return effects
	end

	-- Leon Bow:
	-- Aetherion balancing: +Range, +Accuracy, +Attack, -Defense.
	if weaponType == WeaponEnums.WeaponType.Bow then
		table.insert(effects, {
			Type = "RangePercent",
			Value = getLeonGradeValue(rarity, 0.05, 0.08, 0.10),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "AccuracyPercent",
			Value = getLeonGradeValue(rarity, 0.15, 0.20, 0.25),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "AttackPercent",
			Value = getLeonGradeValue(rarity, 0.10, 0.15, 0.20),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "DefensePercent",
			Value = -getLeonGradeValue(rarity, 0.05, 0.07, 0.10),
			Source = "LeonNegative",
		})

		return effects
	end

	-- Leon Launcher:
	-- Aetherion balancing: +Attack, +Range, +Launcher delay reduction, -MoveSpeed.
	if weaponType == WeaponEnums.WeaponType.Launcher
		or weaponType == WeaponEnums.WeaponType.GrenadeLauncher
	then
		table.insert(effects, {
			Type = "AttackPercent",
			Value = getLeonGradeValue(rarity, 0.15, 0.20, 0.25),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "RangePercent",
			Value = getLeonGradeValue(rarity, 0.05, 0.08, 0.10),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "LauncherAttackDelayReduction",
			Value = getLeonGradeValue(rarity, 0.05, 0.08, 0.10),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "MoveSpeedFlat",
			Value = -getLeonGradeValue(rarity, 1.50, 1.25, 1.00),
			Source = "LeonNegative",
		})

		return effects
	end

	-- Leon Staff:
	-- Aetherion balancing: +ForceAttack, +FP saving, +MaxFP, -Defense.
	if weaponType == WeaponEnums.WeaponType.Staff
		or weaponType == WeaponEnums.WeaponType.Wand
	then
		table.insert(effects, {
			Type = "ForceAttackPercent",
			Value = getLeonGradeValue(rarity, 0.12, 0.16, 0.20),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "FPCostReduction",
			Value = getLeonGradeValue(rarity, 0.05, 0.08, 0.10),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "MaxFPPercent",
			Value = getLeonGradeValue(rarity, 0.08, 0.10, 0.13),
			Source = "Leon",
		})

		table.insert(effects, {
			Type = "DefensePercent",
			Value = -getLeonGradeValue(rarity, 0.05, 0.08, 0.10),
			Source = "LeonNegative",
		})

		return effects
	end

	-- Fallback untuk Leon yang belum terklasifikasi.
	table.insert(effects, {
		Type = "AttackPercent",
		Value = getLeonGradeValue(rarity, 0.10, 0.15, 0.20),
		Source = "Leon",
	})

	if string.find(lowerName, "hora") then
		table.insert(effects, {
			Type = "AccuracyPercent",
			Value = getLeonGradeValue(rarity, 0.10, 0.15, 0.20),
			Source = "Leon",
		})
	end

	return effects
end

function WeaponHelpers.ParseSpecialEffects(effectText)
	local effects = {}

	if not effectText or effectText == "None" then
		return effects
	end

	local lowerText = string.lower(effectText)

	if string.find(lowerText, "moving speed") and not string.find(lowerText, "decrease") then
		table.insert(effects, {
			Type = "MoveSpeedFlat",
			Value = 1,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "decrease") and string.find(lowerText, "moving speed") then
		table.insert(effects, {
			Type = "MoveSpeedFlat",
			Value = -2,
			Source = "Negative",
		})
	end

	if string.find(lowerText, "critical probability 20") then
		table.insert(effects, {
			Type = "CriticalChanceFlat",
			Value = 0.20,
			Source = "Relic",
		})
	elseif string.find(lowerText, "critical probability 10") then
		table.insert(effects, {
			Type = "CriticalChanceFlat",
			Value = 0.10,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "decrease critical probability") then
		table.insert(effects, {
			Type = "CriticalChanceFlat",
			Value = -0.315,
			Source = "Negative",
		})
	end

	if string.find(lowerText, "hp 20") then
		table.insert(effects, {
			Type = "MaxHPPercent",
			Value = 0.20,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "all resistance 30") and not string.find(lowerText, "decrease") then
		table.insert(effects, {
			Type = "ElementalResistancePercent",
			Value = 0.30,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "all resistance") and string.find(lowerText, "decrease") then
		table.insert(effects, {
			Type = "ElementalResistancePercent",
			Value = -0.25,
			Source = "Negative",
		})
	end

	if string.find(lowerText, "ignore opponent blocking") or string.find(lowerText, "ignore rate of an opponent") then
		table.insert(effects, {
			Type = "IgnoreBlockChance",
			Value = 1.00,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "range 10") then
		table.insert(effects, {
			Type = "RangePercent",
			Value = 0.10,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "attack delay of launcher") then
		table.insert(effects, {
			Type = "LauncherAttackDelayReduction",
			Value = 0.10,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "exchange 10%% attack damage to hp") then
		table.insert(effects, {
			Type = "LifeStealPercent",
			Value = 0.10,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "exchange 25%% of attack damage to hp") then
		table.insert(effects, {
			Type = "LifeStealPercent",
			Value = 0.25,
			Source = "Leon",
		})
	end

	if string.find(lowerText, "defense ability 20") then
		table.insert(effects, {
			Type = "DefensePercent",
			Value = 0.20,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "accuracy rate 20") then
		table.insert(effects, {
			Type = "AccuracyPercent",
			Value = 0.20,
			Source = "Relic",
		})
	end

	if string.find(lowerText, "increase of all attack 20") then
		table.insert(effects, {
			Type = "AttackPercent",
			Value = 0.20,
			Source = "Leon",
		})
	end

	return effects
end

function WeaponHelpers.GetRareDEffects(_name, _weaponType)
	-- Dari RFDatabase, Rare D / Crimson tidak menampilkan special effect eksplisit
	-- seperti Leon. Di Aetherion, Rare D diberi identitas sebagai hybrid force weapon:
	-- physical weapon yang tetap punya ForceAttack bawaan.
	return {
		{
			Type = "RareDForceHybrid",
			Value = 1,
			Source = "RareD",
		},
	}
end

function WeaponHelpers.MergeEffects(...)
	local merged = {}

	for _, effects in ipairs({ ... }) do
		for _, effect in ipairs(effects or {}) do
			table.insert(merged, effect)
		end
	end

	return merged
end

function WeaponHelpers.CreateWeapon(row)
	local name = row[1]
	local series = row[2]
	local rarity = row[3]
	local level = row[4]
	local attackMin = row[5]
	local attackMax = row[6]
	local forceMin = row[7]
	local forceMax = row[8]
	local specialEffect = row[9]
	local typeCAbilityId = row[10]

	local weaponType = WeaponHelpers.InferType(name)
	local ptType = WeaponHelpers.GetPTType(weaponType)

	local baseEffects = WeaponHelpers.ParseSpecialEffects(specialEffect)
	local typeCEffects = {}
	local leonEffects = {}
	local rareDEffects = {}

	if series == WeaponEnums.Series.TypeC and typeCAbilityId then
		typeCEffects = TypeCAbilityDefinitions.GetEffects(typeCAbilityId)
	end

	if series == WeaponEnums.Series.Leon then
		leonEffects = WeaponHelpers.GetLeonEffects(name, rarity, weaponType)
	end

	if series == WeaponEnums.Series.RareD then
		rareDEffects = WeaponHelpers.GetRareDEffects(name, weaponType)
	end

	local requiredLevel = level

	if series == WeaponEnums.Series.TypeC and typeCAbilityId == "LevelDown" then
		requiredLevel = math.max(1, level - 5)
	end

	return {
		Id = slugify(series .. "_" .. name),
		Name = name,
		Series = series,
		Rarity = rarity,
		WeaponType = weaponType,
		EquipSlot = GameConfig.EquipmentSlots.Weapon,
		FactionId = WeaponHelpers.GetFactionId(weaponType),

		RequiredLevel = requiredLevel,
		OriginalRequiredLevel = level,

		RequiredPT = {
			Type = ptType,
			Level = math.min(level, 50),
		},

		AttackMin = attackMin,
		AttackMax = attackMax,
		ForceAttackMin = forceMin,
		ForceAttackMax = forceMax,

		AttackSpeed = WeaponHelpers.GetAttackSpeed(weaponType),
		Range = WeaponHelpers.GetRange(weaponType),
		AllowedAmmoTypes = WeaponHelpers.GetAmmoTypes(weaponType),

		MaxUpgrade = 7,
		CanUpgrade = true,
		CanTrade = true,
		CanAuction = true,
		IsEventItem = false,

		IsTypeC = series == WeaponEnums.Series.TypeC,
		TypeCAbilityId = typeCAbilityId,

		Effects = WeaponHelpers.MergeEffects(
			baseEffects,
			typeCEffects,
			leonEffects,
			rareDEffects
		),

		SpecialEffectText = specialEffect or "None",
		Source = "AetherionWeaponDatabase",
	}
end

return WeaponHelpers