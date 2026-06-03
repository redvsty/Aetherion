local HttpService = game:GetService("HttpService")

local Weapons = require(game.ReplicatedStorage.Shared.Database.Weapons.Weapons)

local WeaponService = {}

function WeaponService.GetWeapon(weaponId)
	return Weapons[weaponId]
end

function WeaponService.GetAllWeapons()
	return Weapons
end

function WeaponService.ListWeapons()
	local result = {}

	for _, weapon in pairs(Weapons) do
		table.insert(result, weapon)
	end

	table.sort(result, function(a, b)
		if a.RequiredLevel == b.RequiredLevel then
			return a.Name < b.Name
		end

		return a.RequiredLevel < b.RequiredLevel
	end)

	return result
end

function WeaponService.ListByLevel(level)
	local result = {}

	for _, weapon in pairs(Weapons) do
		if weapon.RequiredLevel == level then
			table.insert(result, weapon)
		end
	end

	table.sort(result, function(a, b)
		if a.Grade == b.Grade then
			return a.Name < b.Name
		end

		return tostring(a.Grade) < tostring(b.Grade)
	end)

	return result
end

function WeaponService.ListByGrade(grade)
	local result = {}

	for _, weapon in pairs(Weapons) do
		if weapon.Grade == grade then
			table.insert(result, weapon)
		end
	end

	table.sort(result, function(a, b)
		if a.RequiredLevel == b.RequiredLevel then
			return a.Name < b.Name
		end

		return a.RequiredLevel < b.RequiredLevel
	end)

	return result
end

function WeaponService.ListBySeries(series)
	local result = {}

	for _, weapon in pairs(Weapons) do
		if weapon.Series == series then
			table.insert(result, weapon)
		end
	end

	table.sort(result, function(a, b)
		if a.RequiredLevel == b.RequiredLevel then
			return a.Name < b.Name
		end

		return a.RequiredLevel < b.RequiredLevel
	end)

	return result
end

function WeaponService.ListEquipable(playerData)
	local result = {}

	for weaponId, weapon in pairs(Weapons) do
		local ok = WeaponService.CanEquipWeapon(playerData, weaponId)

		if ok then
			table.insert(result, weapon)
		end
	end

	table.sort(result, function(a, b)
		if a.RequiredLevel == b.RequiredLevel then
			return a.Name < b.Name
		end

		return a.RequiredLevel < b.RequiredLevel
	end)

	return result
end

function WeaponService.CanEquipWeapon(playerData, weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return false, "Weapon not found"
	end

	if weapon.FactionId ~= nil and weapon.FactionId ~= "ALL" and weapon.FactionId ~= playerData.FactionId then
		return false, "Wrong faction"
	end

	if weapon.RequiredLevel and playerData.Level < weapon.RequiredLevel then
		return false, "Level too low"
	end

	if weapon.RequiredPT then
		local requiredPT = weapon.RequiredPT
		local pt = playerData.PT[requiredPT.Type]

		if not pt then
			return false, "Missing PT type: " .. tostring(requiredPT.Type)
		end

		if pt.Level < requiredPT.Level then
			return false, "PT too low"
		end
	end

	return true, "Can equip"
end

function WeaponService.CreateInventoryWeapon(weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return nil
	end

	return {
		Uid = HttpService:GenerateGUID(false),
		ItemId = weaponId,

		UpgradeLevel = 0,
		Locked = false,

		Slots = weapon.SlotMax or 0,
		Talics = {},

		Durability = 100,
		MaxDurability = 100,
	}
end

function WeaponService.GetAttackRoll(weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return 1
	end

	local minAttack = weapon.AttackMin or 1
	local maxAttack = weapon.AttackMax or minAttack

	return math.random(minAttack, maxAttack)
end

function WeaponService.GetForceAttackRoll(weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return 0
	end

	local minForce = weapon.ForceAttackMin or 0
	local maxForce = weapon.ForceAttackMax or minForce

	if maxForce <= 0 then
		return 0
	end

	return math.random(minForce, maxForce)
end

function WeaponService.GetSummary()
	local summary = {
		Total = 0,
		ByLevel = {},
		ByGrade = {},
		BySeries = {},
	}

	for _, weapon in pairs(Weapons) do
		summary.Total += 1

		local level = weapon.RequiredLevel or 0
		local grade = weapon.Grade or "UNKNOWN"
		local series = weapon.Series or "UNKNOWN"

		summary.ByLevel[level] = (summary.ByLevel[level] or 0) + 1
		summary.ByGrade[grade] = (summary.ByGrade[grade] or 0) + 1
		summary.BySeries[series] = (summary.BySeries[series] or 0) + 1
	end

	return summary
end

function WeaponService.ToDebugRow(weapon)
	return {
		Id = weapon.Id,
		Name = weapon.Name,
		Series = weapon.Series,
		Grade = weapon.Grade,
		GradeDisplayName = weapon.GradeDisplayName,
		Rarity = weapon.Rarity,

		RequiredLevel = weapon.RequiredLevel,
		OriginalRequiredLevel = weapon.OriginalRequiredLevel,

		RequiredPT = weapon.RequiredPT,

		WeaponType = weapon.WeaponType,
		FactionId = weapon.FactionId,

		AttackMin = weapon.AttackMin,
		AttackMax = weapon.AttackMax,

		ForceAttackMin = weapon.ForceAttackMin,
		ForceAttackMax = weapon.ForceAttackMax,

		SlotMin = weapon.SlotMin,
		SlotMax = weapon.SlotMax,

		AbilityId = weapon.AbilityId,
		SpecialEffectText = weapon.SpecialEffectText,
		Effects = weapon.Effects,

		SourceUrl = weapon.SourceUrl,
	}
end

function WeaponService.ToDebugRows(weapons, limit)
	local result = {}
	local count = 0
	limit = limit or 50

	for _, weapon in ipairs(weapons) do
		count += 1

		if count > limit then
			break
		end

		table.insert(result, WeaponService.ToDebugRow(weapon))
	end

	return result
end

return WeaponService