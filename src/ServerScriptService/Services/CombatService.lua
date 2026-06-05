-- CombatService.lua
-- Fix 2: PT Exp diberikan ke attacker setelah berhasil hit, sesuai weapon PT type.
-- Fix 5: Server-side validation diperkuat.
-- Batch 2: Force Attack system
-- Patch RF-Accuracy: Integrasi DefenseGaugeService untuk drain gauge per hit.
--   Weapon sub-type (Sword/Axe/Knife/Bow/Staff/dll) mempengaruhi laju drain
--   tergantung armor class defender (warrior/force/launcher).
--   BuffEffectProcessor.ApplyBuffStats digunakan untuk damage calc dengan buff aktif.

local Players = game:GetService("Players")

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local ClassDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ClassDefinitions)
local CombatFormulas = require(game.ReplicatedStorage.Shared.CombatFormulas)
local EquipmentService = require(script.Parent.EquipmentService)
local LevelService = require(script.Parent.LevelService)
-- Patch RF-Accuracy
local DefenseGaugeService = require(script.Parent.DefenseGaugeService)
local BuffEffectProcessor = require(game.ReplicatedStorage.Shared.BuffEffectProcessor)

local CombatService = {}

-- Fix 5: Rate limit — minimum detik antar attack per player (server-side)
local ATTACK_COOLDOWN = 0.4 -- detik, sesuaikan dengan attack speed design
local lastAttackTime = {} -- [player] = tick()

local function getPlayerFromModel(model)
	return Players:GetPlayerFromCharacter(model)
end

-- Ambil PT type dari weapon yang sedang diequip attacker
local function getAttackerWeaponPTType(attackerData)
	local weaponUid = attackerData.Equipment and attackerData.Equipment.Weapon

	if not weaponUid then
		return GameConfig.PTTypes.Melee -- default fallback
	end

	-- Cari item di inventory
	for _, item in ipairs(attackerData.Inventory) do
		if item.Uid == weaponUid then
			local itemDef = ItemDefinitions[item.ItemId]

			if itemDef and itemDef.WeaponType then
				return itemDef.WeaponType
			end
		end
	end

	return GameConfig.PTTypes.Melee
end

-- Fix 2: Beri PT exp ke attacker sesuai weapon type, lalu cek PT level up
local function addPTExp(playerData, ptType, amount)
	if not playerData.PT then
		return 0
	end

	local pt = playerData.PT[ptType]

	if not pt then
		return 0
	end

	local gain = math.max(0, math.floor(amount or 0))

	pt.Exp += gain

	-- Cek level up PT
	while true do
		local required = CombatFormulas.GetRequiredPTExp(pt.Level)

		if pt.Exp < required then
			break
		end

		pt.Exp -= required
		pt.Level += 1
	end

	return gain
end

local function grantPTExp(attackerData, ptType, targetLevel)
	if not attackerData.PT then
		return 0
	end

	local pt = attackerData.PT[ptType]

	if not pt then
		return 0
	end

	local gain = math.max(1, math.floor(CombatFormulas.GetPTExpGain(pt.Level, targetLevel or 1, 10)))

	return addPTExp(attackerData, ptType, gain)
end

local function grantPartyDefenseBonus(attackerPlayer, attackerData, profiles, attackerPTGain)
	local party = attackerData.Party

	if not party or type(party.Members) ~= "table" or attackerPTGain <= 0 then
		return
	end

	local bonusGain = math.max(1, math.floor(attackerPTGain * 0.1))

	for _, member in ipairs(party.Members) do
		if member.UserId ~= attackerPlayer.UserId then
			local memberPlayer = Players:GetPlayerByUserId(member.UserId)
			local memberData = memberPlayer and profiles[memberPlayer]

			if memberData then
				addPTExp(memberData, GameConfig.PTTypes.Defense, bonusGain)
			end
		end
	end
end

-- ============================================================
-- Force Attack / FP helpers
-- ============================================================

-- Cek apakah kondisi memungkinkan Force Attack:
-- 1. Hanya Magic class (Spiritualist dan advancement-nya) yang bisa Force Attack
-- 2. Weapon harus punya ForceAttack stat (ForceAttackMin > 0)
-- 3. FP harus >= cost DAN >= MinFPRequired
local function canUseForceAttack(attackerData, attackerStats)
	-- Gate 1: class role harus Magic
	local role = ClassDefinitions.GetStartingClassRole(attackerData)
	if role ~= "Magic" then
		return false
	end

	-- Gate 2: weapon harus support force attack
	if not EquipmentService.HasForceAttack(attackerData) then
		return false
	end

	-- Gate 3: FP harus cukup (lebih besar dari cost dan min threshold)
	local fp = attackerData.Stats and attackerData.Stats.FP or 0
	local cost = CombatFormulas.GetFPCost(attackerStats)
	local minRequired = math.max(cost, GameConfig.ForceAttack.MinFPRequired)

	return fp >= minRequired
end

-- Kurangi FP attacker setelah Force Attack berhasil.
local function consumeFP(attackerData, attackerStats, attackerPlayer)
	local cost = CombatFormulas.GetFPCost(attackerStats)
	local stats = attackerData.Stats

	if not stats then
		return 0
	end

	local actual = math.min(cost, stats.FP)
	stats.FP = math.max(0, stats.FP - actual)

	-- Notifikasi GameServer agar regen delay dimulai ulang
	if actual > 0 and CombatService.OnFPConsumed and attackerPlayer then
		CombatService.OnFPConsumed(attackerPlayer)
	end

	return actual
end

function CombatService.CanDamage(attackerData, targetData)
	if not attackerData or not targetData then
		return false
	end

	if attackerData.FactionId ~= targetData.FactionId then
		return true
	end

	local now = os.time()

	if attackerData.ChaosUntil and attackerData.ChaosUntil > now then
		return true
	end

	return false
end

function CombatService.Attack(attackerPlayer, targetModel, profiles)
	-- Fix 5a: Rate limiting
	local now = tick()
	local lastTime = lastAttackTime[attackerPlayer] or 0

	if (now - lastTime) < ATTACK_COOLDOWN then
		return false, "Attack too fast"
	end

	lastAttackTime[attackerPlayer] = now

	-- Fix 5b: Validasi attacker data
	local attackerData = profiles[attackerPlayer]

	if not attackerData then
		return false, "No attacker data"
	end

	-- Fix 5c: Validasi attacker belum memilih faction (baru join)
	if not attackerData.FactionId then
		return false, "Attacker has no faction"
	end

	-- Fix 5d: Ambil character attacker dari SERVER (bukan percaya client)
	local attackerCharacter = attackerPlayer.Character

	if not attackerCharacter then
		return false, "Attacker has no character"
	end

	-- Fix 5e: Validasi target model valid (bukan nil / bukan string)
	if not targetModel or typeof(targetModel) ~= "Instance" then
		return false, "Invalid target"
	end

	local attackerRoot = attackerCharacter:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")

	if not attackerRoot or not targetRoot or not targetHumanoid then
		return false, "Invalid target model"
	end

	-- Fix 5f: Cek target masih hidup di server
	if targetHumanoid.Health <= 0 then
		return false, "Target already dead"
	end

	-- Fix 5g: Validasi jarak SERVER-SIDE (tidak percaya posisi dari client)
	local distance = (attackerRoot.Position - targetRoot.Position).Magnitude

	if distance > GameConfig.Combat.MaxAttackDistance then
		return false, "Target too far"
	end

	-- Fix 5h: Cek faction / PvP rules
	local targetPlayer = getPlayerFromModel(targetModel)
	local targetData = targetPlayer and profiles[targetPlayer] or nil

	if targetData and not CombatService.CanDamage(attackerData, targetData) then
		return false, "Cannot damage same faction"
	end

	-- Hitung damage
	local attackerStats = EquipmentService.GetTotalStats(attackerData)

	-- Patch RF-Accuracy: apply buff aktif ke attacker stats
	attackerStats = BuffEffectProcessor.ApplyBuffStats(
		attackerStats,
		attackerData.ActiveBuffs or {},
		attackerData
	)

	local defenderStats = { Defense = 5 }

	if targetData then
		local baseDefStats = EquipmentService.GetTotalStats(targetData)
		-- Patch RF-Accuracy: apply defender buff stats
		defenderStats = BuffEffectProcessor.ApplyBuffStats(
			baseDefStats,
			targetData.ActiveBuffs or {},
			targetData
		)
	end

	-- Batch 2: Gunakan Force Attack jika weapon support dan FP cukup.
	local damage, isCrit, isForceAttack
	local fpConsumed = 0

	if canUseForceAttack(attackerData, attackerStats) then
		damage, isCrit = CombatFormulas.CalculateForceAttack(attackerStats, defenderStats)
		fpConsumed = consumeFP(attackerData, attackerStats, attackerPlayer)
		isForceAttack = true
	else
		damage, isCrit = CombatFormulas.CalculateDamage(attackerStats, defenderStats)
		isForceAttack = false
	end

	targetHumanoid:TakeDamage(damage)

	-- Patch RF-Accuracy: Drain defense gauge defender sesuai weapon type
	if targetData then
		local weaponItemId = attackerData.Equipment and attackerData.Equipment.Weapon
		local weaponSubType = "Monster"  -- default
		if weaponItemId then
			for _, item in ipairs(attackerData.Inventory or {}) do
				if item.Uid == weaponItemId then
					weaponSubType = item.WeaponSubType or item.WeaponType or "Monster"
					break
				end
			end
		end
		-- Ambil level weapon
		local weaponLevel = 1
		for _, item in ipairs(attackerData.Inventory or {}) do
			if item.Uid == (attackerData.Equipment and attackerData.Equipment.Weapon) then
				local def = ItemDefinitions[item.ItemId]
				weaponLevel = (def and def.Level) or 1
				break
			end
		end
		local armorLevel = targetData.Level or 1
		DefenseGaugeService.TakeDrainHit(targetData, weaponSubType, weaponLevel, armorLevel, ClassDefinitions)
	end

	-- Fix 2: Grant PT exp ke attacker sesuai weapon type
	local ptType = getAttackerWeaponPTType(attackerData)
	local targetLevel = targetData and targetData.Level or 1
	local attackerPTGain = grantPTExp(attackerData, ptType, targetLevel)

	if not targetData then
		grantPartyDefenseBonus(attackerPlayer, attackerData, profiles, attackerPTGain)
	end

	-- Juga grant Defense PT ke defender jika player
	if targetData then
		grantPTExp(targetData, GameConfig.PTTypes.Defense, attackerData.Level)
	end

	return true, {
		Damage = damage,
		Crit = isCrit,
		IsForceAttack = isForceAttack,
		FPConsumed = fpConsumed,
	}
end

-- Cleanup rate limit saat player leave
function CombatService.OnPlayerRemoving(player)
	lastAttackTime[player] = nil
end

return CombatService
