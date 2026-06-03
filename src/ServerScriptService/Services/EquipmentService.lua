local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local InventoryService = require(script.Parent.InventoryService)
local Weapons = require(game.ReplicatedStorage.Shared.Database.Weapons.Weapons)
local WeaponEffectService = require(script.Parent.WeaponEffectService)

local EquipmentService = {}

function EquipmentService.CanEquip(playerData, item)
	local itemDef = ItemDefinitions[item.ItemId]

	if not itemDef then
		return false, "Unknown item"
	end

	if itemDef.FactionId ~= "ALL" and itemDef.FactionId ~= playerData.FactionId then
		return false, "Wrong faction"
	end

	if playerData.Level < itemDef.RequiredLevel then
		return false, "Level too low"
	end

	if itemDef.RequiredPT then
		local pt = playerData.PT[itemDef.RequiredPT.Type]

		if not pt or pt.Level < itemDef.RequiredPT.Level then
			return false, "PT too low"
		end
	end

	return true, "Can equip"
end

function EquipmentService.Equip(playerData, itemUid)
	local item = InventoryService.FindItem(playerData, itemUid)

	if not item then
		return false, "Item not found"
	end

	local itemDef = ItemDefinitions[item.ItemId]

	if not itemDef then
		return false, "Invalid item"
	end

	local ok, reason = EquipmentService.CanEquip(playerData, item)

	if not ok then
		return false, reason
	end

	playerData.Equipment[itemDef.Slot] = itemUid

	return true, "Equipped"
end

function EquipmentService.GetEquippedItem(playerData, slot)
	local itemUid = playerData.Equipment[slot]

	if not itemUid then
		return nil
	end

	return InventoryService.FindItem(playerData, itemUid)
end

function EquipmentService.GetTotalStats(playerData)
	local attack = 5
	local forceAttack = 0
	local defense = 5

	for _, slot in ipairs({ "Weapon", "Armor", "Shield", "Cloak" }) do
		local item = EquipmentService.GetEquippedItem(playerData, slot)

		if item then
			local itemDef = ItemDefinitions[item.ItemId] or Weapons[item.ItemId]

			if itemDef then
				local upgradeLevel = item.UpgradeLevel or 0
				local attackAverage = math.floor(((itemDef.AttackMin or 0) + (itemDef.AttackMax or 0)) / 2)
				local forceAverage = math.floor(((itemDef.ForceAttackMin or 0) + (itemDef.ForceAttackMax or 0)) / 2)

				attack += attackAverage
				forceAttack += forceAverage
				defense += itemDef.Defense or 0

				attack += math.floor(attackAverage * upgradeLevel * 0.08)
				forceAttack += math.floor(forceAverage * upgradeLevel * 0.08)
				defense += math.floor((itemDef.Defense or 0) * upgradeLevel * 0.07)
			end
		end
	end

	local stats = {
		Attack = attack,
		ForceAttack = forceAttack,
		Defense = defense,
		MaxHP = playerData.Stats.MaxHP or 150,
		MaxFP = playerData.Stats.MaxFP or 100,
		MoveSpeed = 16,
		CritChance = 0.05,
		CritResistance = 0,
		Accuracy = 1,
		BlockChance = 0,
		RangeMultiplier = 1,
		LifeStealPercent = 0,
		IgnoreBlockChance = 0,
		ElementalResistanceFlat = 0,
		ElementalResistancePercent = 0,
		LauncherAttackDelayReduction = 0,
		DebuffDurationReduction = 0,
		FPCostReduction = 0,
		IsRareDForceHybrid = false,
	}

	local weaponUid = playerData.Equipment.Weapon

	if weaponUid then
		local weaponItem = InventoryService.FindItem(playerData, weaponUid)

		if weaponItem then
			local weaponDef = Weapons[weaponItem.ItemId]

			if weaponDef and weaponDef.Effects then
				stats = WeaponEffectService.ApplyEffectsToStats(stats, weaponDef.Effects)
			end
		end
	end

	return stats
end

return EquipmentService
