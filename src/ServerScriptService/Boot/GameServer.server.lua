local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataFactory = require(script.Parent.Parent.Services.PlayerDataFactory)
local CharacterCreationService = require(script.Parent.Parent.Services.CharacterCreationService)
local EquipmentService = require(script.Parent.Parent.Services.EquipmentService)
local UpgradeService = require(script.Parent.Parent.Services.UpgradeService)
local CombatService = require(script.Parent.Parent.Services.CombatService)
local WeaponService = require(script.Parent.Parent.Services.WeaponService)

local profiles = {}

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

local GetPlayerDataRequest = ensureRemoteFunction("GetPlayerDataRequest")
local SelectRaceAndClassRequest = ensureRemoteFunction("SelectRaceAndClassRequest")
local SelectLevel30ClassRequest = ensureRemoteFunction("SelectLevel30ClassRequest")
local SelectLevel40ClassRequest = ensureRemoteFunction("SelectLevel40ClassRequest")
local GetClassOptionsRequest = ensureRemoteFunction("GetClassOptionsRequest")
local EquipItemRequest = ensureRemoteFunction("EquipItemRequest")
local UpgradeItemRequest = ensureRemoteFunction("UpgradeItemRequest")
local AttackRequest = ensureRemoteFunction("AttackRequest")
local GetWeaponSummaryRequest = ensureRemoteFunction("GetWeaponSummaryRequest")
local GetWeaponsByLevelRequest = ensureRemoteFunction("GetWeaponsByLevelRequest")
local GetWeaponsByGradeRequest = ensureRemoteFunction("GetWeaponsByGradeRequest")
local GiveWeaponRequest = ensureRemoteFunction("GiveWeaponRequest")
local GetPlayerStatsRequest = ensureRemoteFunction("GetPlayerStatsRequest")

Players.PlayerAdded:Connect(function(player)
	-- Untuk tahap debug logic, data masih in-memory.
	-- Setelah flow stabil, sambungkan kembali ke DataStoreService.
	profiles[player] = PlayerDataFactory.Create(player)

	player.CharacterAdded:Connect(function(character)
		local data = profiles[player]
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.MaxHealth = data.Stats.MaxHP
		humanoid.Health = data.Stats.HP
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	profiles[player] = nil
end)

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
	return CombatService.Attack(player, targetModel, profiles)
end

GetWeaponSummaryRequest.OnServerInvoke = function(_player)
	return WeaponService.GetSummary()
end

GetWeaponsByLevelRequest.OnServerInvoke = function(_player, level, limit)
	local weapons = WeaponService.ListByLevel(level)
	return WeaponService.ToDebugRows(weapons, limit or 50)
end

GetWeaponsByGradeRequest.OnServerInvoke = function(_player, grade, limit)
	local weapons = WeaponService.ListByGrade(grade)
	return WeaponService.ToDebugRows(weapons, limit or 50)
end

GiveWeaponRequest.OnServerInvoke = function(player, weaponId)
	local data = profiles[player]

	if not data then
		return false, "No player data"
	end

	local inventoryWeapon = WeaponService.CreateInventoryWeapon(weaponId)

	if not inventoryWeapon then
		return false, "Weapon not found"
	end

	table.insert(data.Inventory, inventoryWeapon)

	return true, {
		Uid = inventoryWeapon.Uid,
		ItemId = inventoryWeapon.ItemId,
	}
end

GetPlayerStatsRequest.OnServerInvoke = function(player)
	local data = profiles[player]

	if not data then
		return false, "No player data"
	end

	local stats = EquipmentService.GetTotalStats(data)

	return true, stats
end