-- GameServer.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DataPersistence = require(script.Parent.Parent.Services.DataPersistence)
local CharacterCreationService = require(script.Parent.Parent.Services.CharacterCreationService)
local EquipmentService = require(script.Parent.Parent.Services.EquipmentService)
local UpgradeService = require(script.Parent.Parent.Services.UpgradeService)
local CombatService = require(script.Parent.Parent.Services.CombatService)
local InventoryService = require(script.Parent.Parent.Services.InventoryService)
local PartyService = require(script.Parent.Parent.Services.PartyService)
local WeaponService = require(script.Parent.Parent.Services.WeaponService)
local SkillService = require(script.Parent.Parent.Services.SkillService)
-- Patch RF-Accuracy: sistem baru
local DefenseGaugeService = require(script.Parent.Parent.Services.DefenseGaugeService)
local StaminaService = require(script.Parent.Parent.Services.StaminaService)
local MacroService = require(script.Parent.Parent.Services.MacroService)
local BuffEffectProcessor = require(game.ReplicatedStorage.Shared.BuffEffectProcessor)
local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
-- Batch 4: Monster + PvE
local MonsterService = require(script.Parent.Parent.Services.MonsterService)
local LevelService   = require(script.Parent.Parent.Services.LevelService)

local EquipmentServiceRef = EquipmentService -- alias untuk dipakai di SkillService cast

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

-- Batch 4: Monster remotes
local AttackMonsterRequest = ensureRemoteFunction("AttackMonsterRequest")
local DamageNumberEvent    = ensureRemoteEvent("DamageNumberEvent")
local LootGoldEvent        = ensureRemoteEvent("LootGoldEvent")

local GetPlayerDataRequest = ensureRemoteFunction("GetPlayerDataRequest")
local GetPlayerStatsRequest = ensureRemoteFunction("GetPlayerStatsRequest")
local SelectRaceAndClassRequest = ensureRemoteFunction("SelectRaceAndClassRequest")
local SelectLevel30ClassRequest = ensureRemoteFunction("SelectLevel30ClassRequest")
local SelectLevel40ClassRequest = ensureRemoteFunction("SelectLevel40ClassRequest")
local GetClassOptionsRequest = ensureRemoteFunction("GetClassOptionsRequest")
local EquipItemRequest = ensureRemoteFunction("EquipItemRequest")
local UpgradeItemRequest = ensureRemoteFunction("UpgradeItemRequest")
local AttackRequest = ensureRemoteFunction("AttackRequest")
-- Batch 2.5: Skill & Force remotes
local CastSkillRequest = ensureRemoteFunction("CastSkillRequest")
local GetSkillDataRequest = ensureRemoteFunction("GetSkillDataRequest")
local GetSkillCooldownsRequest = ensureRemoteFunction("GetSkillCooldownsRequest")
local GiveWeaponRequest = ensureRemoteFunction("GiveWeaponRequest")
local GiveItemRequest = ensureRemoteFunction("GiveItemRequest")
-- Weapon query remotes (dipanggil dari AetherionDebug)
local GetWeaponSummaryRequest = ensureRemoteFunction("GetWeaponSummaryRequest")
local GetWeaponsByLevelRequest = ensureRemoteFunction("GetWeaponsByLevelRequest")
local GetWeaponsByGradeRequest = ensureRemoteFunction("GetWeaponsByGradeRequest")
local GetPartyDataRequest = ensureRemoteFunction("GetPartyDataRequest")
local PartyInviteRequest = ensureRemoteFunction("PartyInviteRequest")
local PartyInviteResponseRequest = ensureRemoteFunction("PartyInviteResponseRequest")
local PartyLeaveRequest = ensureRemoteFunction("PartyLeaveRequest")
local PartyToggleLockRequest = ensureRemoteFunction("PartyToggleLockRequest")
local PartyInviteReceived = ensureRemoteEvent("PartyInviteReceived")
-- Patch RF-Accuracy: Stamina / Walk-Run remotes
local ToggleRunWalkRequest = ensureRemoteEvent("ToggleRunWalkRequest")
local RunWalkStateChanged  = ensureRemoteEvent("RunWalkStateChanged")
local SPUpdateEvent        = ensureRemoteEvent("SPUpdateEvent")
-- Patch RF-Accuracy: Macro remotes
local SetMacroRequest = ensureRemoteFunction("SetMacroRequest")
local ClearMacroRequest = ensureRemoteFunction("ClearMacroRequest")
local ExecuteMacroRequest = ensureRemoteFunction("ExecuteMacroRequest")
local GetMacrosRequest = ensureRemoteFunction("GetMacrosRequest")
-- Patch RF-Accuracy: Defense Gauge
local GetDefenseGaugeRequest = ensureRemoteFunction("GetDefenseGaugeRequest")
-- Patch RF-Accuracy: Buff Stats (stats dengan buff applied)
local GetBuffedStatsRequest = ensureRemoteFunction("GetBuffedStatsRequest")

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

	-- Patch RF-Accuracy: init defense gauge dan stamina
	DefenseGaugeService.InitGauge(data)
	StaminaService.InitPlayer(player, data)
	MacroService.InitMacros(data)

	player.CharacterAdded:Connect(function(character)
		local currentData = profiles[player]
		if not currentData then
			return
		end

		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = currentData.Stats.MaxHP

		-- RF Classic: respawn = HP penuh. Stats.HP juga di-restore agar HUD sync.
		currentData.Stats.HP = currentData.Stats.MaxHP
		humanoid.Health = currentData.Stats.MaxHP

		-- Apply run/walk speed sesuai stamina state
		local staminaState = StaminaService.GetState(player)
		if staminaState then
			StaminaService.ApplySpeedToCharacter(player, staminaState)
		end

		-- Sync Humanoid.Health → data.Stats.HP setiap kali berubah.
		-- Ini adalah single source of truth: apapun yang mengubah Humanoid.Health
		-- (TakeDamage PvP, PvE monster, status effect) langsung tercermin di HUD.
		humanoid.HealthChanged:Connect(function(health)
			local data = profiles[player]
			if data and data.Stats then
				data.Stats.HP = math.floor(math.max(0, health))
			end
		end)

		-- Batch 4: Death penalty (RF Classic)
		humanoid.Died:Connect(function()
			local data = profiles[player]
			if not data then return end
			-- Cek apakah dibunuh player (tag "KilledByPlayer" di character, di-set CombatService)
			local killedByPlayer = character:FindFirstChild("KilledByPlayer") ~= nil
			LevelService.ApplyDeathPenalty(data, killedByPlayer)
		end)
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
	SkillService.OnPlayerRemoving(player)
	StaminaService.OnPlayerRemoving(player)  -- Patch RF-Accuracy
	lastFPUseTime[player] = nil
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

	return true, EquipmentService.GetTotalStats(data)
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

GetWeaponSummaryRequest.OnServerInvoke = function(_player)
	return WeaponService.GetSummary()
end

GetWeaponsByLevelRequest.OnServerInvoke = function(_player, level, limit)
	if type(level) ~= "number" then
		return false, "Level harus berupa angka"
	end
	return WeaponService.GetByLevel(math.floor(level), limit or 50)
end

GetWeaponsByGradeRequest.OnServerInvoke = function(_player, grade, limit)
	if type(grade) ~= "string" then
		return false, "Grade harus berupa string"
	end
	return WeaponService.GetByGrade(grade, limit or 50)
end

-- ============================================================
-- FP Regen Loop
-- Regen FP passif semua player tiap detik.
-- IdleRegenRate (3 FP/s) aktif jika tidak baru pakai FP dalam RegenDelay detik.
-- CombatRegenRate (1 FP/s) aktif selama dalam combat delay.
-- Menggunakan task.spawn agar tidak blocking server init.
-- ============================================================
local FP_TICK = 1 -- interval regen dalam detik
local lastFPUseTime = {} -- [player] = tick(), diupdate CombatService via callback

-- Expose callback agar CombatService bisa catat kapan FP terakhir dipakai
local function onFPConsumed(player)
	lastFPUseTime[player] = tick()
end

-- Injeksi callback ke CombatService setelah keduanya loaded
CombatService.OnFPConsumed = onFPConsumed

task.spawn(function()
	while true do
		task.wait(FP_TICK)

		local regenConfig = GameConfig.FPRegen
		local now = tick()

		for player, data in pairs(profiles) do
			if player and player.Parent and data and data.Stats then
				local stats = data.Stats
				local maxFP = stats.MaxFP or 100

				-- FP regen
				if stats.FP < maxFP then
					local sinceLastUse = now - (lastFPUseTime[player] or 0)
					local isIdle = sinceLastUse >= regenConfig.RegenDelay
					local rate = isIdle and regenConfig.IdleRegenRate or regenConfig.CombatRegenRate
					stats.FP = math.min(maxFP, stats.FP + rate)
				end

				-- Patch RF-Accuracy: Defense Gauge regen
				DefenseGaugeService.RegenTick(data, FP_TICK)

				-- Patch RF-Accuracy: HellBless drain dan expire expired buffs
				BuffEffectProcessor.TickDebuffs(data, FP_TICK)

				-- Patch RF-Accuracy: HP regen dari Soul Vitality buff
				if data.ActiveBuffs then
					local buffedStats = BuffEffectProcessor.ApplyBuffStats(stats, data.ActiveBuffs, data)
					if buffedStats.HpFpRegenMult and buffedStats.HpFpRegenMult > 1 then
						local hpRegenBonus = (buffedStats.HpFpRegenMult - 1) * 2  -- 2 HP/s bonus per mult
						stats.HP = math.min(stats.MaxHP or stats.HP, stats.HP + hpRegenBonus * FP_TICK)
					end
				end
			end
		end

		-- Patch RF-Accuracy: Stamina tick (walk/run SP system)
		StaminaService.Tick(FP_TICK, profiles, function(player)
			local data = profiles[player]
			if not data or not data.ActiveBuffs then return 0 end
			local buffedStats = BuffEffectProcessor.ApplyBuffStats(
				EquipmentService.GetTotalStats(data),
				data.ActiveBuffs,
				data
			)
			return (buffedStats.MoveSpeed or 16) - 16
		end)

		-- Push SP ke tiap client langsung (reliable, tidak perlu polling)
		for _, p in ipairs(Players:GetPlayers()) do
			local st = StaminaService.GetState(p)
			if st then
				SPUpdateEvent:FireClient(p, math.floor(st.SP), st.MaxSP, st.IsRunning)
			end
		end
	end
end)

-- Cleanup lastFPUseTime saat player leave (sudah ada di PlayerRemoving tapi perlu tambah ini)

-- ============================================================
-- Batch 2.5: Skill & Force Handlers
-- ============================================================

-- CastSkillRequest(skillId, targetModel?) → ok, result
CastSkillRequest.OnServerInvoke = function(player, skillId, targetModel)
	local data = profiles[player]

	if not data then
		return false, "No player data"
	end

	if not data.FactionId then
		return false, "No faction selected"
	end

	if type(skillId) ~= "string" then
		return false, "Invalid skill id"
	end

	-- Ambil attacker stats
	local attackerStats = EquipmentServiceRef.GetTotalStats(data)

	-- Ambil defender stats jika target adalah player
	local defenderStats = { Defense = 5 }

	if targetModel and typeof(targetModel) == "Instance" then
		local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
		local targetData = targetPlayer and profiles[targetPlayer]

		if targetData then
			defenderStats = EquipmentServiceRef.GetTotalStats(targetData)
		end
	end

	return SkillService.Cast(
		player,
		skillId,
		targetModel,
		attackerStats,
		defenderStats,
		profiles,
		onFPConsumed
	)
end

-- GetSkillDataRequest() → ok, { Skills, SkillPT }
GetSkillDataRequest.OnServerInvoke = function(player)
	local data = profiles[player]

	if not data then
		return false, "No player data"
	end

	return true, {
		Skills = data.Skills or {},
		SkillPT = data.SkillPT or {},
		ActiveBuffs = data.ActiveBuffs or {},
	}
end

-- GetSkillCooldownsRequest() → ok, { [skillId] = remainingSeconds }
GetSkillCooldownsRequest.OnServerInvoke = function(player)
	return true, SkillService.GetCooldowns(player)
end

local BattleModeNotify = ensureRemoteEvent("BattleModeNotify")
-- AttackRequest handler sekarang di blok "Batch 4: Monster System" agar bisa route ke MonsterService

-- ============================================================
-- Patch RF-Accuracy: Stamina / Walk-Run handlers
-- ============================================================

-- Client mengirim event saat player tekan hotkey toggle run/walk
ToggleRunWalkRequest.OnServerEvent:Connect(function(player)
	local isRunning = StaminaService.ToggleRunWalk(player)
	RunWalkStateChanged:FireClient(player, isRunning)
end)

-- ============================================================
-- Patch RF-Accuracy: Macro handlers
-- ============================================================

SetMacroRequest.OnServerInvoke = function(player, slotIndex, skillList, label)
	local data = profiles[player]
	if not data then return false, "No player data" end
	return MacroService.SetMacro(data, slotIndex, skillList, label)
end

ClearMacroRequest.OnServerInvoke = function(player, slotIndex)
	local data = profiles[player]
	if not data then return false, "No player data" end
	return MacroService.ClearMacro(data, slotIndex)
end

ExecuteMacroRequest.OnServerInvoke = function(player, slotIndex, targetModel)
	local data = profiles[player]
	if not data then return false, "No player data" end
	if not data.FactionId then return false, "No faction" end

	return MacroService.ExecuteMacro(
		player,
		slotIndex,
		targetModel,
		profiles,
		SkillService,
		EquipmentService,
		onFPConsumed
	)
end

GetMacrosRequest.OnServerInvoke = function(player)
	local data = profiles[player]
	if not data then return false, "No player data" end
	return true, MacroService.GetMacros(data)
end

-- ============================================================
-- UseItemRequest — konsumsi item dari inventory (belt execution)
-- ============================================================

local UseItemRequest = ensureRemoteFunction("UseItemRequest")

UseItemRequest.OnServerInvoke = function(player, itemUid)
	local data = profiles[player]
	if not data then return false, "No player data" end

	local found, foundIdx = nil, nil
	for i, item in ipairs(data.Inventory or {}) do
		if item.Uid == itemUid then
			found, foundIdx = item, i
			break
		end
	end

	if not found then return false, "Item not found" end

	local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
	local def = ItemDefinitions[found.ItemId]

	if not def or not (def.RestoreHP or def.RestoreFP or def.RestoreSP) then
		return false, "Item is not usable"
	end

	-- Kurangi quantity atau hapus jika qty = 1
	if found.Quantity and found.Quantity > 1 then
		data.Inventory[foundIdx].Quantity = found.Quantity - 1
	else
		table.remove(data.Inventory, foundIdx)
	end

	-- Apply efek (HP/FP/SP restore)
	if def.RestoreHP then
		data.Stats.HP = math.min((data.Stats.HP or 0) + def.RestoreHP, data.Stats.MaxHP or 150)
	end
	if def.RestoreFP then
		data.Stats.FP = math.min((data.Stats.FP or 0) + def.RestoreFP, data.Stats.MaxFP or 100)
	end
	if def.RestoreSP then
		data.Stats.SP = math.min((data.Stats.SP or 0) + def.RestoreSP, data.Stats.MaxSP or 100)
	end

	return true, { ItemId = found.ItemId }
end

-- ============================================================
-- Batch 4: Monster System
-- ============================================================

-- Callback: monster mati → beri EXP + gold ke killer
local function onMonsterKilled(killerPlayer, _monsterUid, def)
	local data = profiles[killerPlayer]
	if not data then return end

	-- EXP reward
	local levelsGained = 0
	if def.ExpReward and def.ExpReward > 0 then
		levelsGained = LevelService.AddExp(data, def.ExpReward, killerPlayer, StaminaService)
	end

	-- Notif level up ke client (reuse GetPlayerDataRequest — client akan poll)
	if levelsGained > 0 then
		print(string.format("[MonsterKilled] %s naik %d level(s)! Level sekarang: %d",
			killerPlayer.Name, levelsGained, data.Level))
	end
end

-- Callback: damage ke player dari monster → kirim floating number ke client.
-- Stats.HP tidak perlu diupdate manual di sini — sudah dihandle oleh
-- humanoid.HealthChanged listener di CharacterAdded (sync otomatis).
local function onMonsterDamage(targetCharacter, damage, isCrit, _attacker)
	local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
	if hrp then
		DamageNumberEvent:FireAllClients(hrp.Position, damage, isCrit, false)
	end
end

-- Callback: player ambil loot bag → deliver gold
local function onLootDelivered(player, bag)
	local data = profiles[player]
	if not data then return end

	local gold = bag.gold or 0
	if gold > 0 then
		data.Currencies = data.Currencies or {}
		data.Currencies.Gold = (data.Currencies.Gold or 0) + gold
		LootGoldEvent:FireClient(player, gold)
	end
end

-- Set callbacks dan init spawners
MonsterService.SetCallbacks(onMonsterKilled, onMonsterDamage, onLootDelivered)

-- AttackMonsterRequest: client target monster model, server resolve damage
AttackMonsterRequest.OnServerInvoke = function(player, targetModel)
	local data = profiles[player]
	if not data then return false, "No player data" end
	if not data.FactionId then return false, "No faction" end

	if not MonsterService.IsMonster(targetModel) then
		return false, "Target bukan monster"
	end

	local attackerStats = EquipmentService.GetTotalStats(data)
	local ok, result = MonsterService.AttackMonster(player, targetModel, attackerStats)

	if ok and result then
		-- Kirim damage number ke client
		local hrp = targetModel:FindFirstChild("HumanoidRootPart")
		if hrp then
			DamageNumberEvent:FireAllClients(hrp.Position, result.Damage, result.IsCrit, true)
		end
		BattleModeNotify:FireClient(player)
	end

	return ok, result
end

-- AttackRequest: route ke MonsterService jika target monster, PvP ke CombatService
AttackRequest.OnServerInvoke = function(player, targetModel)
	if MonsterService.IsMonster(targetModel) then
		local data = profiles[player]
		if not data then return false, "No player data" end
		if not data.FactionId then return false, "No faction" end

		local attackerStats = EquipmentService.GetTotalStats(data)
		local ok, result = MonsterService.AttackMonster(player, targetModel, attackerStats)

		if ok and result then
			local hrp = targetModel:FindFirstChild("HumanoidRootPart")
			if hrp then
				DamageNumberEvent:FireAllClients(hrp.Position, result.Damage, result.IsCrit, true)
			end
			BattleModeNotify:FireClient(player)
		end
		return ok, result
	end

	-- Default: PvP via CombatService
	local ok, result = CombatService.Attack(player, targetModel, profiles)
	if ok and result and result.Damage then
		BattleModeNotify:FireClient(player)
		local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
		if targetPlayer then
			BattleModeNotify:FireClient(targetPlayer)
		end
	end
	return ok, result
end

-- Init monster spawners (cari Part di workspace dengan attribute MonsterDefId)
task.spawn(function()
	task.wait(2) -- tunggu workspace fully loaded
	MonsterService.InitSpawners()
end)

-- ============================================================
-- Chat commands: /party, /guild, /whisper
-- ============================================================

local PartyChatReceived = ensureRemoteEvent("PartyChatReceived")

game:GetService("Players").PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(msg)
		local data = profiles[player]
		if not data then return end

		-- /party <message>
		local partyMsg = msg:match("^/party%s+(.+)$") or msg:match("^/p%s+(.+)$")
		if partyMsg then
			local partyData = data.Party
			if partyData and type(partyData.Members) == "table" then
				for _, member in ipairs(partyData.Members) do
					local target = game:GetService("Players"):FindFirstChild(member.Name or "")
					if target and target ~= player then
						PartyChatReceived:FireClient(target, player.Name, partyMsg, "Party")
					end
				end
			end
			PartyChatReceived:FireClient(player, player.Name, partyMsg, "Party")
			return
		end

		-- /guild <message>
		local guildMsg = msg:match("^/guild%s+(.+)$") or msg:match("^/g%s+(.+)$")
		if guildMsg then
			-- guild system belum ada, echo ke diri sendiri
			PartyChatReceived:FireClient(player, player.Name, guildMsg, "Guild")
			return
		end

		-- /w <name> <message>  atau  /whisper <name> <message>
		local wTarget, wMsg = msg:match("^/w%s+(%S+)%s+(.+)$")
		if not wTarget then
			wTarget, wMsg = msg:match("^/whisper%s+(%S+)%s+(.+)$")
		end
		if wTarget and wMsg then
			local targetPlayer = game:GetService("Players"):FindFirstChild(wTarget)
			if targetPlayer then
				PartyChatReceived:FireClient(targetPlayer, player.Name, wMsg, "Whisper")
				PartyChatReceived:FireClient(player, player.Name .. "→" .. wTarget, wMsg, "Whisper")
			else
				PartyChatReceived:FireClient(player, "System", "Player '" .. wTarget .. "' not found", "Whisper")
			end
			return
		end
	end)
end)

-- ============================================================
-- Patch RF-Accuracy: Defense Gauge handler
-- ============================================================

GetDefenseGaugeRequest.OnServerInvoke = function(player)
	local data = profiles[player]
	if not data then return false, "No player data" end
	DefenseGaugeService.InitGauge(data)
	return true, DefenseGaugeService.GetGaugeInfo(data)
end

-- ============================================================
-- Patch RF-Accuracy: Buffed Stats handler
-- Mengembalikan stats player setelah semua buff aktif di-apply.
-- Digunakan client UI untuk menampilkan stats yang benar.
-- ============================================================

GetBuffedStatsRequest.OnServerInvoke = function(player)
	local data = profiles[player]
	if not data then return false, "No player data" end

	local baseStats = EquipmentService.GetTotalStats(data)
	local buffedStats = BuffEffectProcessor.ApplyBuffStats(
		baseStats,
		data.ActiveBuffs or {},
		data
	)
	return true, buffedStats
end
