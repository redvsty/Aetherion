local HttpService = game:GetService("HttpService")

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local RaceDefinitions = require(game.ReplicatedStorage.Shared.Definitions.RaceDefinitions)
local ClassDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ClassDefinitions)
local CurrencyDefinitions = require(game.ReplicatedStorage.Shared.Definitions.CurrencyDefinitions)
local InventoryService = require(script.Parent.InventoryService)

local CharacterCreationService = {}

local StarterArmorByFaction = {
	[GameConfig.Factions.MECHA] = "mecha_training_armor_001",
	[GameConfig.Factions.CYBORG] = "cyborg_training_armor_001",
	[GameConfig.Factions.MYSTIC] = "mystic_training_robe_001",
}

local STARTER_UPGRADER_ITEM_ID = "upgrader"

local function createInventoryItem(itemId)
	return {
		Uid = HttpService:GenerateGUID(false),
		ItemId = itemId,
		UpgradeLevel = 0,
		Locked = false,
		Slots = math.random(0, 3),
		Durability = 100,
		MaxDurability = 100,
	}
end

local function createPermanentItem(itemId)
	return {
		Uid = HttpService:GenerateGUID(false),
		ItemId = itemId,
		UpgradeLevel = 0,
		Locked = true,
		Slots = 0,
		Durability = 0,
		MaxDurability = 0,
		IsPermanent = true,
	}
end

local function giveItem(playerData, itemId)
	local item = createInventoryItem(itemId)
	InventoryService.AddItem(playerData, item)
	return item
end

local function givePermanentItem(playerData, itemId)
	local item = createPermanentItem(itemId)
	InventoryService.AddItem(playerData, item)
	return item
end

local function giveStartingCurrency(playerData, factionId)
	local factionCurrencyId = CurrencyDefinitions.GetFactionCurrencyId(factionId)

	playerData.Currencies.Gold = 100
	playerData.Currencies[factionCurrencyId] = 1000
end

function CharacterCreationService.SelectRaceAndClass(playerData, factionId, startingClassId)
	if not playerData then
		return false, "Missing player data"
	end

	if playerData.FactionId ~= nil then
		return false, "Race already selected"
	end

	if not RaceDefinitions.IsValidRace(factionId) then
		return false, "Invalid race"
	end

	if not ClassDefinitions.IsValidStartingClass(startingClassId) then
		return false, "Invalid starting class"
	end

	if not RaceDefinitions.IsClassAllowed(factionId, startingClassId) then
		return false, "This class is not allowed for selected race"
	end

	local startingClass = ClassDefinitions.Starting[startingClassId]
	local weaponId = startingClass.StarterWeaponByFaction[factionId]
	local armorId = StarterArmorByFaction[factionId]

	if not weaponId or not armorId then
		return false, "Missing starter item configuration"
	end

	playerData.FactionId = factionId
	playerData.StartingClassId = startingClassId
	playerData.NeedsRaceSelection = false
	playerData.NeedsStartingClassSelection = false

	giveStartingCurrency(playerData, factionId)

	local weapon = giveItem(playerData, weaponId)
	local armor = giveItem(playerData, armorId)
	local upgrader = givePermanentItem(playerData, STARTER_UPGRADER_ITEM_ID)

	playerData.Equipment.Weapon = weapon.Uid
	playerData.Equipment.Armor = armor.Uid

	return true, {
		FactionId = factionId,
		StartingClassId = startingClassId,
		StarterWeaponUid = weapon.Uid,
		StarterArmorUid = armor.Uid,
		StarterUpgraderUid = upgrader.Uid,
	}
end

function CharacterCreationService.GetAvailableLevel30Classes(playerData)
	if not playerData or playerData.Level < GameConfig.AdvancementLevels.First then
		return nil
	end

	return ClassDefinitions.GetLevel30Options(
		playerData.FactionId,
		playerData.StartingClassId
	)
end

function CharacterCreationService.SelectLevel30Class(playerData, classId)
	if not playerData then
		return false, "Missing player data"
	end

	if playerData.Level < GameConfig.AdvancementLevels.First then
		return false, "Level 30 class advancement is locked"
	end

	if playerData.ClassLevel30Id ~= nil then
		return false, "Level 30 class already selected"
	end

	local options = ClassDefinitions.GetLevel30Options(
		playerData.FactionId,
		playerData.StartingClassId
	)

	if not ClassDefinitions.ContainsOption(options, classId) then
		return false, "Invalid level 30 class"
	end

	playerData.ClassLevel30Id = classId
	playerData.NeedsLevel30ClassSelection = false

	return true, classId
end

function CharacterCreationService.GetAvailableLevel40Classes(playerData)
	if not playerData or playerData.Level < GameConfig.AdvancementLevels.Second then
		return nil
	end

	return ClassDefinitions.GetLevel40Options(
		playerData.FactionId,
		playerData.ClassLevel30Id
	)
end

function CharacterCreationService.SelectLevel40Class(playerData, classId)
	if not playerData then
		return false, "Missing player data"
	end

	if playerData.Level < GameConfig.AdvancementLevels.Second then
		return false, "Level 40 class advancement is locked"
	end

	if playerData.ClassLevel30Id == nil then
		return false, "Select level 30 class first"
	end

	if playerData.ClassLevel40Id ~= nil then
		return false, "Level 40 class already selected"
	end

	local options = ClassDefinitions.GetLevel40Options(
		playerData.FactionId,
		playerData.ClassLevel30Id
	)

	if not ClassDefinitions.ContainsOption(options, classId) then
		return false, "Invalid level 40 class"
	end

	playerData.ClassLevel40Id = classId
	playerData.NeedsLevel40ClassSelection = false

	return true, classId
end

return CharacterCreationService