-- GameServer.server.lua
-- Updated: Integrasi DataPersistence (Fix 3), CombatService cleanup (Fix 5),
-- dan semua service yang sudah dipatch.

local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataPersistence          = require(script.Parent.Parent.Services.DataPersistence)
local CharacterCreationService = require(script.Parent.Parent.Services.CharacterCreationService)
local EquipmentService         = require(script.Parent.Parent.Services.EquipmentService)
local UpgradeService           = require(script.Parent.Parent.Services.UpgradeService)
local CombatService            = require(script.Parent.Parent.Services.CombatService)

-- profiles: [Player] = playerData (in-memory, sync dari DataStore)
-- isLoadFailed: [Player] = bool — jika true, data tidak akan disave untuk proteksi
local profiles       = {}
local isLoadFailed   = {}

-- ============================================================
-- Remotes Setup
-- ============================================================

local remotes = ReplicatedStorage:FindFirstChild("Remotes")

if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name   = "Remotes"
	remotes.Parent = ReplicatedStorage
end

local function ensureRemoteFunction(name)
	local remote = remotes:FindFirstChild(name)

	if not remote then
		remote        = Instance.new("RemoteFunction")
		remote.Name   = name
		remote.Parent = remotes
	end

	return remote
end

local GetPlayerDataRequest      = ensureRemoteFunction("GetPlayerDataRequest")
local SelectRaceAndClassRequest = ensureRemoteFunction("SelectRaceAndClassRequest")
local SelectLevel30ClassRequest = ensureRemoteFunction("SelectLevel30ClassRequest")
local SelectLevel40ClassRequest = ensureRemoteFunction("SelectLevel40ClassRequest")
local GetClassOptionsRequest    = ensureRemoteFunction("GetClassOptionsRequest")
local EquipItemRequest          = ensureRemoteFunction("EquipItemRequest")
local UpgradeItemRequest        = ensureRemoteFunction("UpgradeItemRequest")
local AttackRequest             = ensureRemoteFunction("AttackRequest")

-- ============================================================
-- Player Events
-- ============================================================

Players.PlayerAdded:Connect(function(player)
	-- Fix 3: Load dari DataStore (dengan retry)
	local data, loadFailed = DataPersistence.Load(player)
	profiles[player]     = data
	isLoadFailed[player] = loadFailed

	player.CharacterAdded:Connect(function(character)
		local currentData = profiles[player]

		if not currentData then
			return
		end

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = currentData.Stats.MaxHP
		humanoid.Health    = currentData.Stats.HP
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local data   = profiles[player]
	local failed = isLoadFailed[player]

	-- Fix 3: Save saat leave, kecuali load awal gagal (proteksi overwrite data valid)
	if data and not failed then
		DataPersistence.Save(player, data)
	end

	-- Fix 5: Cleanup rate limit table di CombatService
	CombatService.OnPlayerRemoving(player)

	profiles[player]     = nil
	isLoadFailed[player] = nil
end)

-- Fix 3: Auto-save setiap 2 menit
DataPersistence.StartAutoSave(profiles)

-- ============================================================
-- Remote Handlers
-- ============================================================

GetPlayerDataRequest.OnServerInvoke = function(player)
	return profiles[player]
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

UpgradeItemRequest.OnServerInvoke = function(player, itemUid, catalystPower)
	local data = profiles[player]

	if not data then
		return false, "No player data"
	end

	return UpgradeService.TryUpgrade(data, itemUid, catalystPower or 0)
end

AttackRequest.OnServerInvoke = function(player, targetModel)
	-- Fix 5: Attack validation ada di CombatService
	return CombatService.Attack(player, targetModel, profiles)
end
