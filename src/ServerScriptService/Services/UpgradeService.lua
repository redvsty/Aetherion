local InventoryService = require(script.Parent.InventoryService)
local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)

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

function UpgradeService.TryUpgrade(playerData, itemUid, catalystPower)
	local item = InventoryService.FindItem(playerData, itemUid)

	if not item then
		return false, "Item not found"
	end

	if item.Locked then
		return false, "Item upgrade is locked"
	end

	local itemDef = ItemDefinitions[item.ItemId]

	if not itemDef then
		return false, "Unknown item"
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

	local successChance = math.clamp(chance.Success + (catalystPower or 0), 0, 0.95)

	if math.random() <= successChance then
		item.UpgradeLevel = nextLevel

		return true, {
			Result = "SUCCESS",
			UpgradeLevel = item.UpgradeLevel,
		}
	end

	if math.random() <= chance.Destroy then
		InventoryService.RemoveItem(playerData, itemUid)

		for slot, equippedUid in pairs(playerData.Equipment) do
			if equippedUid == itemUid then
				playerData.Equipment[slot] = nil
			end
		end

		return true, {
			Result = "DESTROYED",
		}
	end

	if math.random() <= chance.Downgrade then
		item.UpgradeLevel = math.max(0, currentLevel - math.random(1, 2))
	end

	if math.random() <= chance.Lock then
		item.Locked = true
	end

	return true, {
		Result = "FAILED",
		UpgradeLevel = item.UpgradeLevel,
		Locked = item.Locked,
	}
end

return UpgradeService
