-- UpgradeService.lua
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

local function getItemDef(item)
    if not item then
        return nil
    end
    return ItemDefinitions[item.ItemId]
end

local function isTalic(item)
    local def = getItemDef(item)
    return def ~= nil and (def.Type == "Talic" or def.UpgradeRole == "Talic")
end

local function isCatalyst(item)
    local def = getItemDef(item)
    return def ~= nil and (def.Type == "UpgradeCatalyst" or def.UpgradeRole == "Catalyst")
end

local function isUpgradeable(item)
    local def = getItemDef(item)
    return def ~= nil and (tonumber(def.MaxUpgrade or 0) > 0)
end

local function getUpgradeSlotLimit(item)
    local def = getItemDef(item)
    if not item or not def then
        return 4
    end
    return math.max(0, tonumber(item.Slots or def.SlotMax or 4) or 4)
end

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

local RANGED_WEAPON_TYPES = {
	[GameConfig.PTTypes.Ranged]   = true,
	[GameConfig.PTTypes.Launcher] = true,
}

local MELEE_WEAPON_TYPES = {
	[GameConfig.PTTypes.Melee]  = true,
	[GameConfig.PTTypes.Magic]  = true,  -- reaver/staff dianggap melee range
}

local function appliesToItem(talicItem, equipmentItem)
	local talicDef     = getItemDef(talicItem)
	local equipmentDef = getItemDef(equipmentItem)

	if not talicDef or not equipmentDef then
		return false
	end

	-- Restoration Talic berlaku untuk semua item
	if talicDef.UpgradeRole == "Restoration" then
		return true
	end

	-- Catalyst berlaku untuk semua item
	if talicDef.UpgradeRole == "Catalyst" then
		return true
	end

	-- Tidak ada AppliesTo = berlaku untuk semua (backward compat)
	if not talicDef.AppliesTo then
		return true
	end

	local groupKey = talicDef.AppliesTo
	local group    = GameConfig.TalicTargetGroups[groupKey]

	-- Jika key tidak dikenal, fallback ke exact match kategori
	if not group then
		return talicDef.AppliesTo == equipmentDef.Category
	end

	-- Cek slot item ada di group
	local itemSlot = equipmentDef.Slot or equipmentDef.EquipSlot
	if not group[itemSlot] then
		return false
	end

	-- Subset weapon: RangedWeapon hanya untuk Ranged/Launcher
	if groupKey == "RangedWeapon" then
		return RANGED_WEAPON_TYPES[equipmentDef.WeaponType] == true
	end

	-- Subset weapon: MeleeWeapon hanya untuk Melee/Magic
	if groupKey == "MeleeWeapon" then
		return MELEE_WEAPON_TYPES[equipmentDef.WeaponType] == true
	end

	-- Subset UpperLowerShieldJetpackMelee: jika slot Weapon, harus melee
	if groupKey == "UpperLowerShieldJetpackMelee" and itemSlot == "Weapon" then
		return MELEE_WEAPON_TYPES[equipmentDef.WeaponType] == true
	end

	return true
end

local function removeIfEquipped(playerData, uid)
    if not playerData or not playerData.Equipment then
        return
    end

    for slot, equippedUid in pairs(playerData.Equipment) do
        if equippedUid == uid then
            playerData.Equipment[slot] = nil
        end
    end
end

local function consumeItem(playerData, uid)
    if not InventoryService.RemoveItem(playerData, uid) then
        return false, "Item not found: " .. tostring(uid)
    end

    removeIfEquipped(playerData, uid)
    return true
end

local function getMaterialBonus(item)
    local def = getItemDef(item)
    if not def then
        return 0
    end
    return tonumber(def.UpgradePower or def.CatalystPower or def.SuccessBonus or 0) or 0
end

function UpgradeService.TryUpgrade(playerData, itemUid, talicUids, catalystUid)
    local legacyCatalystBonus = 0
    if type(talicUids) == "number" then
        legacyCatalystBonus = math.max(0, tonumber(talicUids) or 0)
        talicUids = {}
        catalystUid = nil
    end

    local item = InventoryService.FindItem(playerData, itemUid)
    if not item then
        return false, "Item not found"
    end

    if item.Locked then
        return false, "Item upgrade is locked"
    end

    local itemDef = getItemDef(item)
    if not itemDef then
        return false, "Unknown item"
    end

    if not isUpgradeable(item) then
        return false, "Item is not upgradeable"
    end

    local currentLevel = tonumber(item.UpgradeLevel or 0) or 0
    local nextLevel = currentLevel + 1
    local maxUpgrade = tonumber(itemDef.MaxUpgrade or 7) or 7

    if nextLevel > maxUpgrade then
        return false, "Max upgrade reached"
    end

    local chance = UpgradeChances[nextLevel]
    if not chance then
        return false, "Invalid upgrade level"
    end

    if type(talicUids) ~= "table" then
        talicUids = {}
    end

    local uniqueTalics = {}
    local seen = {}
    local slotLimit = getUpgradeSlotLimit(item)

    for _, uid in ipairs(talicUids) do
        if type(uid) ~= "string" or uid == "" then
            return false, "Invalid talic UID"
        end

        if seen[uid] then
            return false, "Duplicate talic UID"
        end
        seen[uid] = true

        local talic = InventoryService.FindItem(playerData, uid)
        if not talic then
            return false, "Talic not found: " .. uid
        end
        if not isTalic(talic) then
            return false, "Invalid talic item: " .. uid
        end
        if not appliesToItem(talic, item) then
            return false, "Talic cannot be used on this item"
        end

        table.insert(uniqueTalics, talic)
    end

    if #uniqueTalics <= 0 then
        return false, "Put at least one talic into upgrade slot"
    end

    if #uniqueTalics > slotLimit then
        return false, "Equipment only has " .. tostring(slotLimit) .. " upgrade slots"
    end

    local catalyst = nil
    local catalystBonus = 0
    if catalystUid ~= nil then
        if type(catalystUid) ~= "string" or catalystUid == "" then
            return false, "Invalid catalyst UID"
        end

        catalyst = InventoryService.FindItem(playerData, catalystUid)
        if not catalyst then
            return false, "Catalyst not found: " .. tostring(catalystUid)
        end
        if not isCatalyst(catalyst) then
            return false, "Invalid catalyst item"
        end

        catalystBonus = getMaterialBonus(catalyst)
    end

	-- Cek apakah salah satu talic adalah Restoration Talic (kasus khusus)
	-- Restoration menghapus talic terakhir dari item, tidak ada upgrade roll
	for _, talic in ipairs(uniqueTalics) do
		local tDef = getItemDef(talic)
		if tDef and tDef.UpgradeRole == "Restoration" then
			if #uniqueTalics > 1 then
				return false, "Restoration Talic harus digunakan sendiri (tanpa talic lain)"
			end

			-- Ambil dan hapus talic terakhir dari InstalledTalics
			local installed = item.InstalledTalics
			if not installed or #installed == 0 then
				return false, "Tidak ada talic yang bisa dihapus dari item ini"
			end

			-- Konsumsi Restoration Talic
			local ok, err = consumeItem(playerData, talic.Uid)
			if not ok then return false, err end

			local removed = table.remove(installed)  -- hapus yang terakhir

			return true, {
				Result         = "RESTORATION",
				RemovedEffect  = removed,
				UpgradeLevel   = item.UpgradeLevel,
			}
		end
	end

	-- Pasang talic ke InstalledTalics pada item (tracking efek per slot)
	if not item.InstalledTalics then
		item.InstalledTalics = {}
	end

	-- Konsumsi semua talic yang dipakai
	for _, talic in ipairs(uniqueTalics) do
		local ok, err = consumeItem(playerData, talic.Uid)
		if not ok then
			return false, err
		end
	end

	if catalyst then
		local ok, err = consumeItem(playerData, catalyst.Uid)
		if not ok then
			return false, err
		end
	end

    local bonus = legacyCatalystBonus + catalystBonus
    for _, talic in ipairs(uniqueTalics) do
        bonus += getMaterialBonus(talic)
    end

    local successChance = math.clamp(chance.Success + bonus, 0, 0.95)
    local roll = math.random()

    if roll <= successChance then
        item.UpgradeLevel = nextLevel

		-- Catat efek talic yang berhasil dipasang ke item
		for _, talic in ipairs(uniqueTalics) do
			local tDef = getItemDef(talic)
			if tDef and tDef.UpgradeEffect then
				table.insert(item.InstalledTalics, {
					TalicId = tDef.Id,
					Effect  = tDef.UpgradeEffect,
				})
			end
		end

        return true, {
            Result = "SUCCESS",
            UpgradeLevel = item.UpgradeLevel,
			InstalledTalics = item.InstalledTalics,
        }
    end

    local destroyThreshold = successChance + chance.Destroy
    if roll <= destroyThreshold then
        InventoryService.RemoveItem(playerData, itemUid)
        removeIfEquipped(playerData, itemUid)
        return true, {
            Result = "DESTROYED",
        }
    end

    local downgradeThreshold = destroyThreshold + chance.Downgrade
    local didDowngrade = false
    if roll <= downgradeThreshold then
        item.UpgradeLevel = math.max(0, currentLevel - math.random(1, 2))
        didDowngrade = true
    end

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