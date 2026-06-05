local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local Weapons = require(game.ReplicatedStorage.Shared.Database.Weapons.Weapons)
local InventoryService = require(script.Parent.InventoryService)
local WeaponEffectService = require(script.Parent.WeaponEffectService)

local EquipmentService = {}

local EQUIPMENT_STAT_SLOTS = {
	GameConfig.EquipmentSlots.Weapon,
	GameConfig.EquipmentSlots.Helmet,
	GameConfig.EquipmentSlots.Upper,
	GameConfig.EquipmentSlots.Lower,
	GameConfig.EquipmentSlots.Gloves,
	GameConfig.EquipmentSlots.Boots,
	GameConfig.EquipmentSlots.Shield,
	GameConfig.EquipmentSlots.Cloak,
	GameConfig.EquipmentSlots.Ring1,
	GameConfig.EquipmentSlots.Ring2,
	GameConfig.EquipmentSlots.Amulet1,
	GameConfig.EquipmentSlots.Amulet2,
}

local ELEMENT_RESISTANCE_EFFECTS = {
	FireResistanceFlat = true,
	AquaResistanceFlat = true,
	TerraResistanceFlat = true,
	WindResistanceFlat = true,
}

local function getItemDef(itemOrId)
	local itemId = type(itemOrId) == "table" and itemOrId.ItemId or itemOrId
	if not itemId then
		return nil
	end

	return ItemDefinitions[itemId] or Weapons[itemId]
end

local function getEquipSlot(itemDef)
	return itemDef and (itemDef.Slot or itemDef.EquipSlot) or nil
end

local function getAverage(minValue, maxValue)
	minValue = tonumber(minValue or 0) or 0
	maxValue = tonumber(maxValue or minValue) or minValue

	if maxValue < minValue then
		maxValue = minValue
	end

	return math.floor((minValue + maxValue) / 2)
end

local function addTalicEffect(stats, effects, installedTalic)
	local talicEffect = installedTalic and installedTalic.Effect
	if not talicEffect or talicEffect.Type == "RemoveLastTalic" then
		return
	end

	local value = talicEffect.Value
	if value == nil then
		value = talicEffect.ValuePerTalic
	end

	if talicEffect.Type == "WeaponAttackUpgrade" then
		table.insert(effects, {
			Type = "AttackPercent",
			Value = value or (installedTalic.TalicId == "keen_talic" and 0.10 or 0.08),
		})
	elseif talicEffect.Type == "DefenseFlat" then
		stats.Defense += value or 0
	elseif talicEffect.Type == "RangeMultiplier" then
		table.insert(effects, {
			Type = "RangePercent",
			Value = value or 0,
		})
	elseif ELEMENT_RESISTANCE_EFFECTS[talicEffect.Type] then
		stats.ElementalResistanceFlat += value or 0
	elseif talicEffect.Type == "CriticalChanceFlat" then
		table.insert(effects, {
			Type = "CriticalChanceFlat",
			Value = value or 0,
		})
	else
		table.insert(effects, {
			Type = talicEffect.Type,
			Value = value or 0,
		})
	end
end

local function collectInstalledTalicEffects(stats, effects, item)
	for _, installed in ipairs(item.InstalledTalics or {}) do
		addTalicEffect(stats, effects, installed)
	end
end

-- Sync Stats.MaxHP dan Stats.MaxFP dari total equipment stats ke playerData.
-- Dipanggil setelah Equip/Unequip agar MaxFP dari weapon ability (misal Advanced
-- Strength Wand: MaxFPPercent +6%) langsung tercermin di Stats player.
-- HP/FP aktual di-clamp agar tidak melebihi max baru.
function EquipmentService.SyncDerivedStats(playerData)
	local equipStats = EquipmentService.GetTotalStats(playerData)
	local stats = playerData.Stats

	if not stats then
		return
	end

	-- Base MaxHP/MaxFP dari level (sederhana, bisa dikembangkan dengan formula level nanti)
	local baseMaxHP = 150
	local baseMaxFP = 100

	local newMaxHP = baseMaxHP + (equipStats.MaxHP or 0)
	local newMaxFP = baseMaxFP + (equipStats.MaxFP or 0)

	stats.MaxHP = math.max(1, newMaxHP)
	stats.MaxFP = math.max(1, newMaxFP)

	-- Clamp HP/FP aktual agar tidak melebihi max baru
	stats.HP = math.clamp(stats.HP or stats.MaxHP, 0, stats.MaxHP)
	stats.FP = math.clamp(stats.FP or stats.MaxFP, 0, stats.MaxFP)
end

function EquipmentService.CanEquip(playerData, item)
	local itemDef = getItemDef(item)

	if not itemDef then
		return false, "Unknown item"
	end

	if itemDef.FactionId and itemDef.FactionId ~= "ALL" and itemDef.FactionId ~= playerData.FactionId then
		return false, "Wrong faction"
	end

	if itemDef.RequiredLevel and playerData.Level < itemDef.RequiredLevel then
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

	local itemDef = getItemDef(item)

	if not itemDef then
		return false, "Invalid item"
	end

	local ok, reason = EquipmentService.CanEquip(playerData, item)

	if not ok then
		return false, reason
	end

	local slot = getEquipSlot(itemDef)
	if not slot then
		return false, "Item cannot be equipped"
	end

	playerData.Equipment[slot] = itemUid

	-- Sync MaxHP/MaxFP setelah equip karena weapon ability bisa mengubah max stats
	EquipmentService.SyncDerivedStats(playerData)

	return true, "Equipped"
end

-- Kembalikan definisi item dari weapon yang sedang diequip.
-- Digunakan CombatService untuk cek apakah weapon support Force Attack.
function EquipmentService.GetEquippedWeaponDef(playerData)
	local item = EquipmentService.GetEquippedItem(playerData, GameConfig.EquipmentSlots.Weapon)
	if not item then
		return nil
	end
	return getItemDef(item)
end

-- Cek apakah weapon yang diequip memiliki ForceAttack (ForceAttackMin > 0).
-- Magic class weapons (reaver, staff) yang punya field ini.
function EquipmentService.HasForceAttack(playerData)
	local weaponDef = EquipmentService.GetEquippedWeaponDef(playerData)
	if not weaponDef then
		return false
	end
	local min = tonumber(weaponDef.ForceAttackMin) or 0
	return min > 0
end

function EquipmentService.GetEquippedItem(playerData, slot)
	local itemUid = playerData.Equipment[slot]

	if not itemUid then
		return nil
	end

	return InventoryService.FindItem(playerData, itemUid)
end

function EquipmentService.GetTotalStats(playerData)
	local stats = {
		Attack = 5,
		ForceAttack = 0,
		Defense = 5,
		MaxHP = 0,
		MaxFP = 0,
		MoveSpeed = 16,
		CritChance = 0.05,
		CritResistance = 0,
		Accuracy = 0,
		BlockChance = 0,
		Dodge = 0,
		RangeMultiplier = 1,
		LifeStealPercent = 0,
		IgnoreBlockChance = 0,
		ElementalResistanceFlat = 0,
		ElementalResistancePercent = 0,
		LauncherAttackDelayReduction = 0,
		DebuffDurationReduction = 0,
		FPCostReduction = 0,
		FPCostIncrease = 0,
		ForceDelayReduction = 0,
		DebuffDurationIncrease = 0,
	}

	local effects = {}

	for _, slot in ipairs(EQUIPMENT_STAT_SLOTS) do
		local item = EquipmentService.GetEquippedItem(playerData, slot)

		if item then
			local itemDef = getItemDef(item)

			if itemDef then
				local upgradeLevel = item.UpgradeLevel or 0
				local attackAverage = getAverage(itemDef.AttackMin, itemDef.AttackMax)
				local forceAttackAverage = getAverage(itemDef.ForceAttackMin, itemDef.ForceAttackMax)
				local defense = itemDef.Defense or 0

				stats.Attack += attackAverage
				stats.ForceAttack += forceAttackAverage
				stats.Defense += defense

				stats.Attack += math.floor(attackAverage * upgradeLevel * 0.08)
				stats.ForceAttack += math.floor(forceAttackAverage * upgradeLevel * 0.08)
				stats.Defense += math.floor(defense * upgradeLevel * 0.07)

				for _, effect in ipairs(itemDef.Effects or {}) do
					table.insert(effects, effect)
				end

				collectInstalledTalicEffects(stats, effects, item)
			end
		end
	end

	return WeaponEffectService.ApplyEffectsToStats(stats, effects)
end

return EquipmentService
