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

function WeaponService.CanEquipWeapon(playerData, weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return false, "Weapon not found"
	end

	if weapon.FactionId ~= "ALL" and weapon.FactionId ~= playerData.FactionId then
		return false, "Wrong faction"
	end

	if playerData.Level < weapon.RequiredLevel then
		return false, "Level too low"
	end

	local requiredPT = weapon.RequiredPT
	local pt = playerData.PT[requiredPT.Type]

	if not pt then
		return false, "Missing PT type: " .. requiredPT.Type
	end

	if pt.Level < requiredPT.Level then
		return false, "PT too low"
	end

	return true, "Can equip"
end

function WeaponService.GetAttackRoll(weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return 1
	end

	return math.random(weapon.AttackMin, weapon.AttackMax)
end

function WeaponService.GetForceAttackRoll(weaponId)
	local weapon = Weapons[weaponId]

	if not weapon then
		return 0
	end

	if weapon.ForceAttackMax <= 0 then
		return 0
	end

	return math.random(weapon.ForceAttackMin, weapon.ForceAttackMax)
end

return WeaponService