local InventoryService = require(script.Parent.InventoryService)
local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local Weapons = require(game.ReplicatedStorage.Shared.Database.Weapons.Weapons)
local WeaponUpgradeDefinitions = require(game.ReplicatedStorage.Shared.Database.Weapons.WeaponUpgradeDefinitions)

local UpgradeService = {}

local UpgradeChances = {
	[1] = { Success = 1.00, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[2] = { Success = 1.00, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[3] = { Success = 0.70, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[4] = { Success = 0.50, Destroy = 0.00, Downgrade = 0.10, Lock = 0.00 },
	[5] = { Success = 0.30, Destroy = 0.00, Downgrade = 0.60, Lock = 0.70 },
	[6] = { Success = 0.15, Destroy = 0.35, Downgrade = 0.40, Lock = 0.50 },
	[7] = { Success = 0.07, Destroy = 0.55, Downgrade = 0.30, Lock = 0.60 },
}

local function getDefinition(itemId)
	return Weapons[itemId] or ItemDefinitions[itemId]
end

local function getMaterialCounts(uidList)
	local counts = {}

	for _, uid in ipairs(uidList or {}) do
		if type(uid) == "string" and uid ~= "" then
			counts[uid] = (counts[uid] or 0) + 1
		end
	end

	return counts
end

local function getInventoryQuantity(item)
	return item.Quantity or 1
end

local function consumeInventoryItem(playerData, itemUid, amount)
	local item = InventoryService.FindItem(playerData, itemUid)

	if not item then
		return false, "Material not found"
	end

	local quantity = getInventoryQuantity(item)

	if quantity < amount then
		return false, "Not enough material quantity"
	end

	if quantity > amount then
		item.Quantity = quantity - amount
	else
		InventoryService.RemoveItem(playerData, itemUid)
	end

	return true
end

local function getUsedTalicCount(item)
	local talics = item.Talics or item.TalicSlots or {}
	return #talics
end

local function getSlotLimit(item, itemDef)
	return item.Slots or itemDef.SlotMax or WeaponUpgradeDefinitions.Slot.Max or 0
end

local function normalizeUpgradeMaterials(talicUids, catalystUid)
	if type(talicUids) == "number" then
		return {}, nil, talicUids
	end

	local normalizedTalics = {}

	if type(talicUids) == "table" then
		for _, uid in ipairs(talicUids) do
			if type(uid) == "string" and uid ~= "" then
				table.insert(normalizedTalics, uid)
			end
		end
	end

	if type(catalystUid) ~= "string" or catalystUid == "" then
		catalystUid = nil
	end

	return normalizedTalics, catalystUid, 0
end

local function talicAppliesToTarget(talicDef, talicDefinition, itemDef)
	local appliesTo = talicDef.AppliesTo or talicDefinition.AppliesTo

	if not appliesTo then
		return true
	end

	return appliesTo == itemDef.Category
end

function UpgradeService.TryUpgrade(playerData, itemUid, talicUids, catalystUid)
	local item = InventoryService.FindItem(playerData, itemUid)

	if not item then
		return false, "Item not found"
	end

	if item.Locked then
		return false, "Item upgrade is locked"
	end

	local itemDef = getDefinition(item.ItemId)

	if not itemDef then
		return false, "Unknown item"
	end

	if not itemDef.MaxUpgrade then
		return false, "Item cannot be upgraded"
	end

	local normalizedTalics, normalizedCatalystUid, legacyCatalystPower =
		normalizeUpgradeMaterials(talicUids, catalystUid)

	local talicCounts = getMaterialCounts(normalizedTalics)
	local talicItems = {}
	local catalystPower = legacyCatalystPower or 0
	local consumedTalics = {}
	local consumedCatalyst = nil

	for talicUid, count in pairs(talicCounts) do
		if talicUid == itemUid then
			return false, "Equipment cannot be used as talic"
		end

		local talicItem = InventoryService.FindItem(playerData, talicUid)
		local talicDef = talicItem and ItemDefinitions[talicItem.ItemId]

		if not talicItem or not talicDef or talicDef.UpgradeRole ~= "Talic" then
			return false, "Invalid talic"
		end

		if getInventoryQuantity(talicItem) < count then
			return false, "Not enough talic quantity"
		end

		local talicDefinition = WeaponUpgradeDefinitions.Talic[talicDef.TalicId]

		if not talicDefinition then
			return false, "Unknown talic effect"
		end

		if not talicAppliesToTarget(talicDef, talicDefinition, itemDef) then
			return false, "Talic cannot be used on this item"
		end

		table.insert(talicItems, {
			Uid = talicUid,
			ItemId = talicItem.ItemId,
			TalicId = talicDef.TalicId,
			Count = count,
		})
	end

	if normalizedCatalystUid then
		if normalizedCatalystUid == itemUid then
			return false, "Equipment cannot be used as catalyst"
		end

		local catalystItem = InventoryService.FindItem(playerData, normalizedCatalystUid)
		local catalystDef = catalystItem and ItemDefinitions[catalystItem.ItemId]

		if not catalystItem or not catalystDef or catalystDef.UpgradeRole ~= "Catalyst" then
			return false, "Invalid catalyst"
		end

		catalystPower = catalystPower + (catalystDef.CatalystPower or 0)
		consumedCatalyst = catalystItem.ItemId
	end

	local currentLevel = item.UpgradeLevel or 0
	local nextLevel = currentLevel + 1

	if nextLevel > (itemDef.MaxUpgrade or 7) then
		return false, "Max upgrade reached"
	end

	local chance = UpgradeChances[nextLevel]

	if not chance then
		return false, "Invalid upgrade level"
	end

	local slotLimit = getSlotLimit(item, itemDef)
	local talicCount = #normalizedTalics

	if talicCount <= 0 then
		return false, "Talic required"
	end

	if getUsedTalicCount(item) + talicCount > slotLimit then
		return false, "Not enough upgrade slots"
	end

	for _, talicInfo in ipairs(talicItems) do
		local ok, reason = consumeInventoryItem(playerData, talicInfo.Uid, talicInfo.Count)

		if not ok then
			return false, reason
		end

		for _ = 1, talicInfo.Count do
			table.insert(consumedTalics, talicInfo.ItemId)
		end
	end

	if normalizedCatalystUid then
		local ok, reason = consumeInventoryItem(playerData, normalizedCatalystUid, 1)

		if not ok then
			return false, reason
		end
	end

	local successChance = math.clamp(chance.Success + (catalystPower or 0), 0, 0.95)

	if math.random() <= successChance then
		item.UpgradeLevel = nextLevel
		item.Talics = item.Talics or item.TalicSlots or {}

		for _, talicInfo in ipairs(talicItems) do
			for _ = 1, talicInfo.Count do
				table.insert(item.Talics, {
					ItemId = talicInfo.ItemId,
					TalicId = talicInfo.TalicId,
				})
			end
		end

		return true,
			{
				Result = "SUCCESS",
				UpgradeLevel = item.UpgradeLevel,
				Talics = item.Talics,
				Consumed = {
					Talics = consumedTalics,
					Catalyst = consumedCatalyst,
				},
			}
	end

	if math.random() <= chance.Destroy then
		InventoryService.RemoveItem(playerData, itemUid)

		for slot, equippedUid in pairs(playerData.Equipment) do
			if equippedUid == itemUid then
				playerData.Equipment[slot] = nil
			end
		end

		return true,
			{
				Result = "DESTROYED",
				Consumed = {
					Talics = consumedTalics,
					Catalyst = consumedCatalyst,
				},
			}
	end

	if math.random() <= chance.Downgrade then
		item.UpgradeLevel = math.max(0, currentLevel - math.random(1, 2))
	end

	if math.random() <= chance.Lock then
		item.Locked = true
	end

	return true,
		{
			Result = "FAILED",
			UpgradeLevel = item.UpgradeLevel,
			Locked = item.Locked,
			Consumed = {
				Talics = consumedTalics,
				Catalyst = consumedCatalyst,
			},
		}
end

return UpgradeService
