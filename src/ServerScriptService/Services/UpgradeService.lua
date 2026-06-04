-- UpgradeService.lua
-- Fix: upgrade roll sekarang pakai single roll + cumulative threshold
-- sehingga hasil DESTROY / DOWNGRADE / SUCCESS mutually exclusive.
-- LOCK tetap roll independen (sama seperti RF asli).

local InventoryService = require(script.Parent.InventoryService)
local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)

local UpgradeService = {}

-- Success / Destroy / Downgrade dalam satu kolom = cumulative probability.
-- Lock independen karena di RF, lock bisa terjadi bersamaan dengan FAIL/DOWNGRADE.
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

	-- FIX: Single roll untuk menentukan SUCCESS / DESTROY / DOWNGRADE / FAIL
	-- Cumulative threshold, mutually exclusive.
	local successChance = math.clamp(chance.Success + (catalystPower or 0), 0, 0.95)
	local roll = math.random()

	-- 1. Cek SUCCESS
	if roll <= successChance then
		item.UpgradeLevel = nextLevel

		return true, {
			Result = "SUCCESS",
			UpgradeLevel = item.UpgradeLevel,
		}
	end

	-- 2. Cek DESTROY (range setelah success)
	local destroyThreshold = successChance + chance.Destroy

	if roll <= destroyThreshold then
		-- Hapus dari inventory
		InventoryService.RemoveItem(playerData, itemUid)

		-- Unequip jika sedang dipakai
		for slot, equippedUid in pairs(playerData.Equipment) do
			if equippedUid == itemUid then
				playerData.Equipment[slot] = nil
			end
		end

		return true, {
			Result = "DESTROYED",
		}
	end

	-- 3. Cek DOWNGRADE (range setelah destroy)
	local downgradeThreshold = destroyThreshold + chance.Downgrade
	local didDowngrade = false

	if roll <= downgradeThreshold then
		item.UpgradeLevel = math.max(0, currentLevel - math.random(1, 2))
		didDowngrade = true
	end

	-- 4. LOCK: roll independen (bisa terjadi bersamaan dengan DOWNGRADE / FAIL biasa)
	local didLock = false

	if chance.Lock > 0 and math.random() <= chance.Lock then
		item.Locked = true
		didLock = true
	end

	return true, {
		Result = didDowngrade and "DOWNGRADED" or "FAILED",
		UpgradeLevel = item.UpgradeLevel,
		Locked = didLock,
	}
end

return UpgradeService
