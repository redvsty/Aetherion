local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local InventoryService = require(script.Parent.InventoryService)

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
	local defense = 5

	for _, slot in ipairs({ "Weapon", "Armor", "Shield", "Cloak" }) do
		local item = EquipmentService.GetEquippedItem(playerData, slot)

		if item then
			local itemDef = ItemDefinitions[item.ItemId]

			if itemDef then
				local upgradeLevel = item.UpgradeLevel or 0
				local attackAverage = math.floor(((itemDef.AttackMin or 0) + (itemDef.AttackMax or 0)) / 2)

				attack += attackAverage
				defense += itemDef.Defense or 0

				attack += math.floor(attackAverage * upgradeLevel * 0.08)
				defense += math.floor((itemDef.Defense or 0) * upgradeLevel * 0.07)
			end
		end
	end

	return {
		Attack = attack,
		Defense = defense,
		CritChance = 0.05,
	}
end

return EquipmentService
