local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local WeaponEnums = require(script.Parent.WeaponEnums)
local WeaponAbilityDefinitions = require(script.Parent.WeaponAbilityDefinitions)
local LeonEffectDefinitions = require(script.Parent.LeonEffectDefinitions)

local WeaponFactory = {}

local function slugify(text)
	local value = string.lower(text)
	value = string.gsub(value, "’", "")
	value = string.gsub(value, "'", "")
	value = string.gsub(value, "%.", "")
	value = string.gsub(value, "%s+", "_")
	value = string.gsub(value, "[^%w_]", "_")
	value = string.gsub(value, "_+", "_")
	return string.gsub(value, "^_*(.-)_*$", "%1")
end

function WeaponFactory.InferType(name)
	local lowerName = string.lower(name)

	if string.find(lowerName, "throwing") then
		return WeaponEnums.WeaponType.Throwing
	elseif string.find(lowerName, "knife") or string.find(lowerName, "blade") or string.find(lowerName, "fang") then
		return WeaponEnums.WeaponType.Knife
	elseif string.find(lowerName, "sword") or string.find(lowerName, "saber") then
		return WeaponEnums.WeaponType.Sword
	elseif string.find(lowerName, "axe") or string.find(lowerName, "bullova") then
		return WeaponEnums.WeaponType.Axe
	elseif string.find(lowerName, "mace") or string.find(lowerName, "hammer") or string.find(lowerName, "maul") then
		return WeaponEnums.WeaponType.Mace
	elseif string.find(lowerName, "lance") or string.find(lowerName, "spear") then
		return WeaponEnums.WeaponType.Spear
	elseif string.find(lowerName, "bow") then
		return WeaponEnums.WeaponType.Bow
	elseif string.find(lowerName, "rifle") or string.find(lowerName, "fire arm") or string.find(lowerName, "gun") then
		return WeaponEnums.WeaponType.Rifle
	elseif string.find(lowerName, "vulcan") or string.find(lowerName, "gatling") then
		return WeaponEnums.WeaponType.Gatling
	elseif string.find(lowerName, "grenade") then
		return WeaponEnums.WeaponType.GrenadeLauncher
	elseif string.find(lowerName, "launcher") or string.find(lowerName, "faust") or string.find(lowerName, "flame") then
		return WeaponEnums.WeaponType.Launcher
	elseif string.find(lowerName, "staff") or string.find(lowerName, "bead") or string.find(lowerName, "stick") then
		return WeaponEnums.WeaponType.Staff
	elseif string.find(lowerName, "wand") then
		return WeaponEnums.WeaponType.Wand
	end

	return WeaponEnums.WeaponType.Unknown
end

function WeaponFactory.GetPTType(weaponType)
	if
		weaponType == WeaponEnums.WeaponType.Bow
		or weaponType == WeaponEnums.WeaponType.Rifle
		or weaponType == WeaponEnums.WeaponType.Gatling
		or weaponType == WeaponEnums.WeaponType.Throwing
	then
		return GameConfig.PTTypes.Ranged
	end

	if weaponType == WeaponEnums.WeaponType.Launcher or weaponType == WeaponEnums.WeaponType.GrenadeLauncher then
		return GameConfig.PTTypes.Launcher
	end

	if weaponType == WeaponEnums.WeaponType.Staff or weaponType == WeaponEnums.WeaponType.Wand then
		return GameConfig.PTTypes.Magic
	end

	return GameConfig.PTTypes.Melee
end

function WeaponFactory.GetFactionId(weaponType)
	if weaponType == WeaponEnums.WeaponType.Launcher or weaponType == WeaponEnums.WeaponType.GrenadeLauncher then
		return GameConfig.Factions.CYBORG
	end

	if weaponType == WeaponEnums.WeaponType.Staff or weaponType == WeaponEnums.WeaponType.Wand then
		return GameConfig.Factions.MYSTIC
	end

	return "ALL"
end

function WeaponFactory.GetAmmoTypes(weaponType)
	if weaponType == WeaponEnums.WeaponType.Bow then
		return { WeaponEnums.AmmoType.Arrow }
	elseif weaponType == WeaponEnums.WeaponType.Rifle or weaponType == WeaponEnums.WeaponType.Gatling then
		return { WeaponEnums.AmmoType.Bullet }
	elseif weaponType == WeaponEnums.WeaponType.Launcher then
		return { WeaponEnums.AmmoType.LauncherShell }
	elseif weaponType == WeaponEnums.WeaponType.GrenadeLauncher then
		return { WeaponEnums.AmmoType.GrenadeShell }
	elseif weaponType == WeaponEnums.WeaponType.Staff or weaponType == WeaponEnums.WeaponType.Wand then
		return { WeaponEnums.AmmoType.ForceReaver }
	elseif weaponType == WeaponEnums.WeaponType.Throwing then
		return { WeaponEnums.AmmoType.ThrowingKnife }
	end

	return { WeaponEnums.AmmoType.None }
end

function WeaponFactory.ParseSpecialEffectText(text)
	local effects = {}

	if not text or text == "None" then
		return effects
	end

	local lower = string.lower(text)

	local function percentAfter(pattern)
		local value = string.match(lower, pattern .. "%s*([%d%.]+)")
		return value and (tonumber(value) / 100) or nil
	end

	if string.find(lower, "moving speed") and not string.find(lower, "decrease") then
		local value = tonumber(string.match(lower, "increase%s*([%d%.]+)%s*moving speed")) or 1
		table.insert(effects, { Type = "MoveSpeedFlat", Value = value })
	end

	if string.find(lower, "decrease") and string.find(lower, "moving speed") then
		local value = tonumber(string.match(lower, "moving speed%s*([%d%.]+)")) or 1
		table.insert(effects, { Type = "MoveSpeedFlat", Value = -value, IsNegative = true })
	end

	local criticalChance = percentAfter("critical probability")
	if criticalChance then
		if string.find(lower, "decrease critical probability") then
			criticalChance = -criticalChance
		end
		table.insert(effects, { Type = "CriticalChanceFlat", Value = criticalChance })
	end

	local maxHP = percentAfter("max%. hp") or percentAfter("hp")
	if maxHP then
		table.insert(effects, { Type = "MaxHPPercent", Value = maxHP })
	end

	local allResistance = percentAfter("all resistance")
	if allResistance then
		if string.find(lower, "decrease") and string.find(lower, "all resistance") then
			allResistance = -allResistance
		end
		table.insert(effects, { Type = "ElementalResistancePercent", Value = allResistance })
	end

	if string.find(lower, "ignore") and string.find(lower, "blocking") then
		local value = percentAfter("blocking is") or percentAfter("ignore rate of an opponent.s blocking is") or 1
		table.insert(effects, { Type = "IgnoreBlockChance", Value = value })
	end

	local range = percentAfter("range")
	if range then
		table.insert(effects, { Type = "RangePercent", Value = range })
	end

	if string.find(lower, "attack delay of launcher") then
		table.insert(effects, { Type = "LauncherAttackDelayReduction", Value = 0.10 })
	end

	local lifeSteal = tonumber(string.match(lower, "exchange%s*([%d%.]+)%%"))
	if lifeSteal and string.find(lower, "hp") then
		table.insert(effects, { Type = "LifeStealPercent", Value = lifeSteal / 100 })
	end

	local defense = percentAfter("defense ability by")
	if defense then
		table.insert(effects, { Type = "DefensePercent", Value = defense })
	end

	local accuracy = percentAfter("accuracy rate")
	if accuracy then
		table.insert(effects, { Type = "AccuracyPercent", Value = accuracy })
	end

	local allAttack = percentAfter("increase of all attack")
	if allAttack then
		table.insert(effects, { Type = "AllAttackPercent", Value = allAttack })
	end

	local forceAttack = percentAfter("force attack power")
	if forceAttack then
		table.insert(effects, { Type = "ForceAttackPercent", Value = forceAttack })
	end

	local dodge = tonumber(string.match(lower, "damage avoidance increase%s*([%d%.]+)"))
	if dodge then
		table.insert(effects, { Type = "DodgeFlat", Value = dodge })
	end

	local debuffDuration = percentAfter("duration of force debuff is")
	if debuffDuration then
		table.insert(effects, { Type = "DebuffDurationIncrease", Value = debuffDuration, IsNegative = true })
	end

	return effects
end

function WeaponFactory.GetGradeConfig(series, name)
	if series == WeaponEnums.Series.TypeA then
		return {
			Grade = WeaponEnums.Grade.A,
			SlotMin = 0,
			SlotMax = 7,
			AbilityId = WeaponFactory.InferTypeAAbility(name),
			AttackMultiplier = 1.00,
			CanExtractAbility = true,
			CanBeTypeCMaterial = true,
		}
	end

	if series == WeaponEnums.Series.TypeB then
		return {
			Grade = WeaponEnums.Grade.B,
			SlotMin = 0,
			SlotMax = 7,
			AbilityId = nil,
			AttackMultiplier = 1.00,
			CanExtractAbility = false,
			CanBeTypeCMaterial = true,
		}
	end

	if series == WeaponEnums.Series.TypeC then
		return {
			Grade = WeaponEnums.Grade.C,
			SlotMin = 0,
			SlotMax = 7,
			AbilityId = WeaponFactory.InferTypeAAbility(name),
			AttackMultiplier = 1.00,
			CanExtractAbility = false,
			CanBeTypeCMaterial = false,
		}
	end

	if series == WeaponEnums.Series.RareD then
		return {
			Grade = WeaponEnums.Grade.D,
			SlotMin = 0,
			SlotMax = 7,
			AbilityId = nil,
			AttackMultiplier = 1.00,
			CanExtractAbility = false,
			CanBeTypeCMaterial = false,
		}
	end

	if series == WeaponEnums.Series.Leon then
		return {
			Grade = WeaponEnums.Grade.Leon,
			SlotMin = 0,
			SlotMax = 7,
			AbilityId = nil,
			AttackMultiplier = 1.00,
			CanExtractAbility = false,
			CanBeTypeCMaterial = false,
		}
	end

	if series == WeaponEnums.Series.Relic then
		return {
			Grade = WeaponEnums.Grade.Relic,
			SlotMin = 0,
			SlotMax = 7,
			AbilityId = nil,
			AttackMultiplier = 1.00,
			CanExtractAbility = false,
			CanBeTypeCMaterial = false,
		}
	end

	return {
		Grade = WeaponEnums.Grade.N,
		SlotMin = 0,
		SlotMax = 7,
		AbilityId = nil,
		AttackMultiplier = 1.00,
		CanExtractAbility = false,
		CanBeTypeCMaterial = false,
	}
end

function WeaponFactory.InferTypeAAbility(name)
	local lower = string.lower(name)

	if string.find(lower, "wind") then
		return WeaponEnums.AbilityId.Wind
	elseif string.find(lower, "strong") then
		return WeaponEnums.AbilityId.Strong
	elseif string.find(lower, "fine") then
		return WeaponEnums.AbilityId.Fine
	elseif string.find(lower, "smart") then
		return WeaponEnums.AbilityId.Smart
	elseif string.find(lower, "solid") then
		return WeaponEnums.AbilityId.Solid
	elseif string.find(lower, "strength") then
		return WeaponEnums.AbilityId.Strength
	elseif string.find(lower, "vampire") then
		return WeaponEnums.AbilityId.Vampire
	elseif string.find(lower, "guardian") then
		return WeaponEnums.AbilityId.Guardian
	elseif string.find(lower, "sharp") and not string.find(lower, "anti") then
		return WeaponEnums.AbilityId.Sharp
	elseif string.find(lower, "anti") and string.find(lower, "sharp") then
		return WeaponEnums.AbilityId.AntiSharp
	elseif string.find(lower, "protection") then
		return WeaponEnums.AbilityId.Protection
	elseif string.find(lower, "grand") then
		return WeaponEnums.AbilityId.Grand
	elseif string.find(lower, "saving") then
		return WeaponEnums.AbilityId.Saving
	elseif string.find(lower, "endurance") then
		return WeaponEnums.AbilityId.Endurance
	elseif string.find(lower, "level down") then
		return WeaponEnums.AbilityId.LevelDown
	end

	return nil
end

function WeaponFactory.CreateFromGeneratedRow(row)
	local weaponType = WeaponFactory.InferType(row.Name)
	local ptType = WeaponFactory.GetPTType(weaponType)
	local gradeConfig = WeaponFactory.GetGradeConfig(row.Series, row.Name)

	local effects = WeaponFactory.ParseSpecialEffectText(row.SpecialEffectText)
	local rarity = row.Series == WeaponEnums.Series.Classic and WeaponEnums.Rarity.Normal or row.Series

	if row.Series == WeaponEnums.Series.Leon then
		local leonEffects, leonGrade = LeonEffectDefinitions.GetEffects(row.Name, weaponType)
		effects = leonEffects
		if leonGrade == LeonEffectDefinitions.Grades.Low then
			rarity = WeaponEnums.Rarity.LeonLow
		elseif leonGrade == LeonEffectDefinitions.Grades.Med then
			rarity = WeaponEnums.Rarity.LeonMedium
		elseif leonGrade == LeonEffectDefinitions.Grades.High then
			rarity = WeaponEnums.Rarity.LeonHigh
		end
	end

	if gradeConfig.AbilityId then
		for _, effect in ipairs(WeaponAbilityDefinitions.GetEffects(gradeConfig.AbilityId)) do
			table.insert(effects, effect)
		end
	end

	local attackMin = math.floor(row.AttackMin * gradeConfig.AttackMultiplier)
	local attackMax = math.floor(row.AttackMax * gradeConfig.AttackMultiplier)

	local requiredLevel = row.RequiredLevel

	if gradeConfig.AbilityId == WeaponEnums.AbilityId.LevelDown then
		requiredLevel = math.max(1, requiredLevel - 5)
	end

	return {
		Id = row.Id,
		Name = row.Name,
		Series = row.Series,
		Rarity = rarity,
		Grade = gradeConfig.Grade,

		WeaponType = weaponType,
		EquipSlot = GameConfig.EquipmentSlots.Weapon,
		FactionId = WeaponFactory.GetFactionId(weaponType),

		RequiredLevel = requiredLevel,
		OriginalRequiredLevel = row.RequiredLevel,

		RequiredPT = {
			Type = ptType,
			Level = math.min(row.RequiredSkillLevel or row.RequiredLevel, GameConfig.MaxLevel),
		},

		AttackMin = attackMin,
		AttackMax = attackMax,
		ForceAttackMin = row.ForceAttackMin,
		ForceAttackMax = row.ForceAttackMax,

		AllowedAmmoTypes = WeaponFactory.GetAmmoTypes(weaponType),

		SlotMin = gradeConfig.SlotMin,
		SlotMax = gradeConfig.SlotMax,
		TalicSlots = {},
		MaxUpgrade = 7,
		CanUpgrade = true,

		AbilityId = gradeConfig.AbilityId,
		Ability = gradeConfig.AbilityId,
		CanExtractAbility = gradeConfig.CanExtractAbility,
		CanBeTypeCMaterial = gradeConfig.CanBeTypeCMaterial,

		Effects = effects,
		SpecialEffectText = row.SpecialEffectText,
		SourceUrl = row.SourceUrl,
	}
end

return WeaponFactory
