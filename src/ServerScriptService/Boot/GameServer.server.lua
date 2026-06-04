-- GameServer.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local DataPersistence = require(script.Parent.Parent.Services.DataPersistence)
local CharacterCreationService = require(script.Parent.Parent.Services.CharacterCreationService)
local EquipmentService = require(script.Parent.Parent.Services.EquipmentService)
local UpgradeService = require(script.Parent.Parent.Services.UpgradeService)
local CombatService = require(script.Parent.Parent.Services.CombatService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local PartyService = require(script.Parent.Parent.Services.PartyService)

local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local Weapons = require(game.ReplicatedStorage.Shared.Database.Weapons.Weapons)

-- profiles: [Player] = playerData (in-memory, sync dari DataStore)
-- isLoadFailed: [Player] = bool — jika true, data tidak akan disave untuk proteksi
local profiles = {}
local isLoadFailed = {}

-- ============================================================
-- Remotes Setup
-- ============================================================
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end

local function ensureRemoteFunction(name)
	local remote = remotes:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteFunction")
		remote.Name = name
		remote.Parent = remotes
	end
	return remote
end

local function ensureRemoteEvent(name)
	local remote = remotes:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = remotes
	end
	return remote
end

local GetPlayerDataRequest = ensureRemoteFunction("GetPlayerDataRequest")
local GetPlayerStatsRequest = ensureRemoteFunction("GetPlayerStatsRequest")
local SelectRaceAndClassRequest = ensureRemoteFunction("SelectRaceAndClassRequest")
local SelectLevel30ClassRequest = ensureRemoteFunction("SelectLevel30ClassRequest")
local SelectLevel40ClassRequest = ensureRemoteFunction("SelectLevel40ClassRequest")
local GetClassOptionsRequest = ensureRemoteFunction("GetClassOptionsRequest")
local EquipItemRequest = ensureRemoteFunction("EquipItemRequest")
local UpgradeItemRequest = ensureRemoteFunction("UpgradeItemRequest")
local AttackRequest = ensureRemoteFunction("AttackRequest")
local GiveWeaponRequest = ensureRemoteFunction("GiveWeaponRequest")
local GiveItemRequest = ensureRemoteFunction("GiveItemRequest")
local GetPartyDataRequest = ensureRemoteFunction("GetPartyDataRequest")
local PartyInviteRequest = ensureRemoteFunction("PartyInviteRequest")
local PartyInviteResponseRequest = ensureRemoteFunction("PartyInviteResponseRequest")
local PartyLeaveRequest = ensureRemoteFunction("PartyLeaveRequest")
local PartyToggleLockRequest = ensureRemoteFunction("PartyToggleLockRequest")
local PartyInviteReceived = ensureRemoteEvent("PartyInviteReceived")

local function createInventoryItem(itemId, definition, overrides)
	overrides = overrides or {}

	local item = {
		Uid = HttpService:GenerateGUID(false),
		ItemId = itemId,
		UpgradeLevel = overrides.UpgradeLevel or 0,
		Locked = overrides.Locked or false,
		Slots = overrides.Slots or 0,
		Durability = overrides.Durability or 100,
		MaxDurability = overrides.MaxDurability or 100,
		Quantity = overrides.Quantity or 1,
	}

	if definition then
		item.Category = definition.Category
		item.Slot = definition.Slot or definition.EquipSlot
		item.EquipSlot = definition.EquipSlot or definition.Slot
		item.WeaponType = definition.WeaponType
		item.Grade = definition.Grade
		item.Type = definition.Type
		item.SpecialAction = definition.SpecialAction
		item.IsPermanent = definition.IsPermanent
	end

	return item
end

local function grantItem(playerData, itemId, definition, overrides)
	local item = createInventoryItem(itemId, definition, overrides)
	InventoryService.AddItem(playerData, item)
	return item
end

local function normalizeAmount(amount)
	local n = math.floor(tonumber(amount) or 1)
	if n < 1 then
		n = 1
	end
	if n > 999 then
		n = 999
	end
	return n
end

-- ============================================================
-- Player Events
-- ============================================================
Players.PlayerAdded:Connect(function(player)
	local data, loadFailed = DataPersistence.Load(player)
	profiles[player] = data
	isLoadFailed[player] = loadFailed

	player.CharacterAdded:Connect(function(character)
		local currentData = profiles[player]
		if not currentData then
			return
		end

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = currentData.Stats.MaxHP
		humanoid.Health = currentData.Stats.HP
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local data = profiles[player]
	local failed = isLoadFailed[player]

	if data and not failed then
		DataPersistence.Save(player, data)
	end

	CombatService.OnPlayerRemoving(player)
	PartyService.OnPlayerRemoving(player, profiles)
	profiles[player] = nil
	isLoadFailed[player] = nil
end)

DataPersistence.StartAutoSave(profiles)

-- ============================================================
-- Remote Handlers
-- ============================================================
GetPlayerDataRequest.OnServerInvoke = function(player)
	return profiles[player]
end

GetPlayerStatsRequest.OnServerInvoke = function(player)
	local data = profiles[player]
	if not data then
		return false, "No player data"
	end

	return true, data.Stats
end

SelectRaceAndClassRequest.OnServerInvoke = function(player, factionId, startingClassId)
	local data = profiles[player]
	return CharacterCreationService.SelectRaceAndClass(data, factionId, startingClassId)
end

SelectLevel30ClassRequest.OnServerInvoke = function(player, classId)
	local data = profiles[player]
	return CharacterCreationService.SelectLevel30Class(data, classId)
end

SelectLevel40ClassRequest.OnServerInvoke = function(player, classId)
	local data = profiles[player]
	return CharacterCreationService.SelectLevel40Class(data, classId)
end

GetClassOptionsRequest.OnServerInvoke = function(player, advancementLevel)
	local data = profiles[player]
	if advancementLevel == 30 then
		return CharacterCreationService.GetAvailableLevel30Classes(data)
	elseif advancementLevel == 40 then
		return CharacterCreationService.GetAvailableLevel40Classes(data)
	end
	return nil
end

EquipItemRequest.OnServerInvoke = function(player, itemUid)
	local data = profiles[player]
	if not data then
		return false, "No player data"
	end

	return EquipmentService.Equip(data, itemUid)
end

UpgradeItemRequest.OnServerInvoke = function(player, itemUid, talicUids, catalystUid)
	local data = profiles[player]
	if not data then
		return false, "No player data"
	end

	return UpgradeService.TryUpgrade(data, itemUid, talicUids, catalystUid)
end

GiveWeaponRequest.OnServerInvoke = function(player, weaponId, amount)
	local data = profiles[player]
	if not data then
		return false, "No player data"
	end

	if type(weaponId) ~= "string" then
		return false, "Invalid weapon id"
	end

	local definition = Weapons[weaponId]
	if not definition then
		return false, "Unknown weapon"
	end

	local count = normalizeAmount(amount)
	local granted = {}

	for _ = 1, count do
		table.insert(
			granted,
			grantItem(data, weaponId, definition, {
				Slots = definition.SlotMax or definition.Slots or 0,
				UpgradeLevel = 0,
				Locked = false,
			})
		)
	end

	return true, granted
end

GiveItemRequest.OnServerInvoke = function(player, itemId, amount)
	local data = profiles[player]
	if not data then
		return false, "No player data"
	end

	if type(itemId) ~= "string" then
		return false, "Invalid item id"
	end

	local definition = ItemDefinitions[itemId] or Weapons[itemId]
	if not definition then
		return false, "Unknown item"
	end

	local count = normalizeAmount(amount)
	local granted = {}

	for _ = 1, count do
		local overrides = nil
		if itemId == "upgrader" then
			overrides = {
				Locked = true,
				Slots = 0,
				Durability = 0,
				MaxDurability = 0,
			}
		end

		table.insert(granted, grantItem(data, itemId, definition, overrides))
	end

	return true, granted
end

GetPartyDataRequest.OnServerInvoke = function(player)
	return true, PartyService.GetPartyData(player, profiles)
end

PartyInviteRequest.OnServerInvoke = function(player, targetUserId)
	local ok, result = PartyService.RequestInvite(player, targetUserId, profiles)

	if ok and type(result) == "table" then
		local target = Players:GetPlayerByUserId(result.TargetUserId)

		if target then
			PartyInviteReceived:FireClient(target, result)
		end
	end

	return ok, result
end

PartyInviteResponseRequest.OnServerInvoke = function(player, accepted)
	return PartyService.RespondToInvite(player, accepted == true, profiles)
end

PartyLeaveRequest.OnServerInvoke = function(player)
	return PartyService.LeaveParty(player, profiles)
end

PartyToggleLockRequest.OnServerInvoke = function(player)
	return PartyService.ToggleLock(player, profiles)
end

AttackRequest.OnServerInvoke = function(player, targetModel)
	return CombatService.Attack(player, targetModel, profiles)
end
