local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local Weapons = require(game.ReplicatedStorage.Shared.Database.Weapons.Weapons)

local InventoryService = require(script.Parent.InventoryService)
local WeaponEffectService = require(script.Parent.WeaponEffectService)

local EquipmentService = {}

local function getItemDefinition(item)
	if not item then
		return nil
	end

	return ItemDefinitions[item.ItemId] or Weapons[item.ItemId]
end

local function getEquipmentSlot(itemDef)
	return itemDef.EquipSlot or itemDef.Slot
end

function EquipmentService.CanEquip(playerData, item)
	local itemDef = getItemDefinition(item)

	if not itemDef then
		return false, "Unknown item"
	end

	local equipmentSlot = getEquipmentSlot(itemDef)

	if not equipmentSlot then
		return false, "Item has no equipment slot"
	end

	if itemDef.FactionId ~= nil and itemDef.FactionId ~= "ALL" and itemDef.FactionId ~= playerData.FactionId then
		return false, "Wrong faction"
	end

	if itemDef.RequiredLevel and playerData.Level < itemDef.RequiredLevel then
		return false, "Level too low"
	end

	if itemDef.RequiredPT then
		local requiredPT = itemDef.RequiredPT
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

function EquipmentService.Equip(playerData, itemUid)
	local item = InventoryService.FindItem(playerData, itemUid)

	if not item then
		return false, "Item not found"
	end

	local itemDef = getItemDefinition(item)

	if not itemDef then
		return false, "Invalid item"
	end

	local ok, reason = EquipmentService.CanEquip(playerData, item)

	if not ok then
		return false, reason
	end

	local equipmentSlot = getEquipmentSlot(itemDef)

	if not equipmentSlot then
		return false, "Item has no equipment slot"
	end

	playerData.Equipment[equipmentSlot] = itemUid

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
			local itemDef = getItemDefinition(item)

			if itemDef then
				local upgradeLevel = item.UpgradeLevel or 0

				local attackAverage = math.floor(
					((itemDef.AttackMin or 0) + (itemDef.AttackMax or 0)) / 2
				)

				local forceAverage = math.floor(
					((itemDef.ForceAttackMin or 0) + (itemDef.ForceAttackMax or 0)) / 2
				)

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
		Dodge = 0,

		BlockChance = 0,
		RangeMultiplier = 1,

		LifeStealPercent = 0,
		IgnoreBlockChance = 0,

		ElementalResistanceFlat = 0,
		ElementalResistancePercent = 0,

		LauncherAttackDelayReduction = 0,
		ForceDelayReduction = 0,

		DebuffDurationReduction = 0,
		DebuffDurationIncrease = 0,

		FPCostReduction = 0,
		FPCostIncrease = 0,
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