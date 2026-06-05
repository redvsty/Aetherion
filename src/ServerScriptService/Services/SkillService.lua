-- SkillService.lua
-- Batch 2.5: Handle casting Skill dan Force.
-- Setiap skill/force memiliki FP cost sendiri (bukan FPCostBase global).
-- Level skill naik dari pemakaian (EXP per hit), bukan dari level karakter.
-- Tier unlock: Basic (default) → Expert (30 PT Basic) → Elite (50 PT Expert).
--
-- Alur cast:
--   1. Client request CastSkill(skillId, targetModel)
--   2. SkillService.Cast() validasi: cooldown, FP, tier unlock, target valid
--   3. Hitung damage (jika attack skill) atau apply buff
--   4. Konsumsi FP, beri SkillExp ke skill tersebut
--   5. Return result ke GameServer → reply ke client

local Players = game:GetService("Players")

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local SkillDefinitions = require(game.ReplicatedStorage.Shared.Definitions.SkillDefinitions)
local ForceDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ForceDefinitions)
local CombatFormulas = require(game.ReplicatedStorage.Shared.CombatFormulas)
local RaceDefinitions = require(game.ReplicatedStorage.Shared.Definitions.RaceDefinitions)

local SkillService = {}

-- Cooldown tracking per player per skill: [player][skillId] = tickExpiry
local cooldowns = {} -- { [player] = { [skillId] = tickExpiry } }

-- ============================================================
-- Cooldown helpers
-- ============================================================

local function isOnCooldown(player, skillId)
	local pc = cooldowns[player]

	if not pc then
		return false
	end

	local expiry = pc[skillId] or 0
	return tick() < expiry
end

local function setCooldown(player, skillId, delaySeconds)
	if not cooldowns[player] then
		cooldowns[player] = {}
	end

	cooldowns[player][skillId] = tick() + delaySeconds
end

local function getRemainingCooldown(player, skillId)
	local pc = cooldowns[player]

	if not pc then
		return 0
	end

	local expiry = pc[skillId] or 0
	return math.max(0, expiry - tick())
end

-- ============================================================
-- Skill EXP & Level
-- ============================================================

-- Kalkulasi EXP yang dibutuhkan untuk naik level skill
-- Setiap level butuh lebih banyak EXP (curved)
local function getRequiredSkillExp(level)
	return math.floor(20 + (level ^ 1.8) * 8)
end

-- Tambah EXP ke skill tertentu di playerData.Skills
-- Return: { LevelUp = bool, NewLevel = int }
local function addSkillExp(playerData, skillId, amount)
	if not playerData.Skills then
		return { LevelUp = false, NewLevel = 1 }
	end

	local skillEntry = playerData.Skills[skillId]

	if not skillEntry then
		return { LevelUp = false, NewLevel = 1 }
	end

	local gain = math.max(1, math.floor(amount))
	local leveledUp = false

	skillEntry.Exp = skillEntry.Exp + gain

	-- Cek level up (max level tergantung skill def, default 99)
	local skillDef = SkillDefinitions[skillId] or ForceDefinitions[skillId]
	local maxLevel = (skillDef and skillDef.ExpLevelMax) or 99

	while skillEntry.Level < maxLevel do
		local required = getRequiredSkillExp(skillEntry.Level)

		if skillEntry.Exp < required then
			break
		end

		skillEntry.Exp = skillEntry.Exp - required
		skillEntry.Level = skillEntry.Level + 1
		leveledUp = true
	end

	-- Hitung aggregate PT untuk tier unlock
	-- PT = total level yang sudah diraih di tier ini
	local tierPTKey = skillDef and skillDef.Tier or nil

	if tierPTKey and playerData.SkillPT then
		local cat = skillDef.Category or skillDef.School or "Force"
		local ptEntry = playerData.SkillPT[cat] or {}
		ptEntry[tierPTKey] = (ptEntry[tierPTKey] or 0) + (leveledUp and 1 or 0)
		playerData.SkillPT[cat] = ptEntry
	end

	return { LevelUp = leveledUp, NewLevel = skillEntry.Level }
end

-- ============================================================
-- Unlock validation
-- ============================================================

-- Cek apakah player bisa menggunakan skill ini
-- (tier unlock, race restriction)
local function checkUnlockRequirement(playerData, skillId)
	local skillDef = SkillDefinitions[skillId]
	local isForce = false

	if not skillDef then
		skillDef = ForceDefinitions[skillId]
		isForce = true
	end

	if not skillDef then
		return false, "Unknown skill: " .. tostring(skillId)
	end

	-- Cek race restriction (untuk Force)
	if isForce then
		local race = RaceDefinitions[playerData.FactionId]

		-- CYBORG tidak bisa Force
		if not race or not race.CanUseMagic then
			return false, "Race cannot use Force"
		end

		-- Cek school restriction
		if skillDef.School == "Holy" and race.MagicSchool ~= "Holy" then
			return false, "Race cannot use Holy force"
		end

		if skillDef.School == "Dark" and race.MagicSchool ~= "Dark" then
			return false, "Race cannot use Dark force"
		end
	end

	-- Cek PT tier requirement
	if skillDef.PTTierReq then
		local cat = skillDef.Category or skillDef.School or "Force"
		local ptData = playerData.SkillPT and playerData.SkillPT[cat]
		local ptInTier = ptData and ptData[skillDef.PTTierReq] or 0

		if ptInTier < skillDef.PTReqAmount then
			return false, string.format(
				"Need %d PT in %s tier to unlock %s",
				skillDef.PTReqAmount,
				skillDef.PTTierReq,
				skillDef.Name
			)
		end
	end

	return true, skillDef
end

-- ============================================================
-- FP Consumption
-- ============================================================

-- Konsumsi FP berdasarkan skill def. Sacrifice force mengkonsumsi HP bukan FP.
-- Return: consumed (number), error (string|nil)
local function consumeResources(playerData, skillDef, onFPConsumed, player)
	local stats = playerData.Stats

	if not stats then
		return 0, "No stats"
	end

	-- Sacrifice: HP → FP conversion
	if skillDef.HPCost and skillDef.HPCost > 0 then
		if stats.HP <= skillDef.HPCost then
			return 0, "Not enough HP for Sacrifice"
		end

		stats.HP = math.max(1, stats.HP - skillDef.HPCost)

		local fpRestored = skillDef.HPCost -- convert 1:1
		stats.FP = math.min(stats.MaxFP or 100, stats.FP + fpRestored)

		return skillDef.HPCost, nil
	end

	-- Normal FP cost
	local cost = skillDef.FPCost or 0

	if stats.FP < cost then
		return 0, string.format("Not enough FP (need %d, have %d)", cost, stats.FP)
	end

	stats.FP = stats.FP - cost

	-- Notifikasi regen delay
	if cost > 0 and onFPConsumed and player then
		onFPConsumed(player)
	end

	return cost, nil
end

-- ============================================================
-- Damage calculation untuk attack skills/forces
-- ============================================================

local function calculateSkillDamage(attackerStats, defenderStats, skillDef)
	local baseDamage = attackerStats.Attack or 1

	-- Force elemental skills pakai ForceAttack stat
	if skillDef.School == "Elemental" or skillDef.BuffType == "Damage" then
		baseDamage = attackerStats.ForceAttack or attackerStats.Attack or 1
	end

	-- Tier multiplier
	local tierMultiplier = 1.0

	if skillDef.Tier == "Expert" then
		tierMultiplier = 1.5
	elseif skillDef.Tier == "Elite" then
		tierMultiplier = 2.2
	end

	-- Skill level bonus (max +50% at level 99)
	local skillEntry = nil -- akan diisi caller jika tersedia
	local levelBonus = 1.0

	local variance = 0.92 + math.random() * 0.16
	local defense = defenderStats.Defense or 0
	local defReduction = defense / (defense + GameConfig.Combat.DefenseScale)

	local rawDamage = baseDamage * tierMultiplier * levelBonus * variance
	local damage = rawDamage * (1 - defReduction)

	local critChance = attackerStats.CritChance or 0.05
	local isCrit = math.random() < critChance

	if isCrit then
		damage = damage * GameConfig.Combat.CritMultiplier
	end

	return math.max(1, math.floor(damage)), isCrit
end

-- ============================================================
-- Main Cast Function
-- ============================================================

function SkillService.Cast(player, skillId, targetModel, attackerStats, defenderStats, profiles, onFPConsumed)
	local playerData = profiles[player]

	if not playerData then
		return false, "No player data"
	end

	-- 1. Validasi cooldown
	if isOnCooldown(player, skillId) then
		local remaining = getRemainingCooldown(player, skillId)
		return false, string.format("Skill on cooldown (%.1fs)", remaining)
	end

	-- 2. Validasi unlock & dapatkan skillDef
	local ok, skillDefOrErr = checkUnlockRequirement(playerData, skillId)

	if not ok then
		return false, skillDefOrErr
	end

	local skillDef = skillDefOrErr

	-- 3. Validasi target jika attack skill
	local targetHumanoid = nil
	local targetData = nil

	if skillDef.Target == "Enemy" then
		if not targetModel or typeof(targetModel) ~= "Instance" then
			return false, "Invalid target"
		end

		targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")

		if not targetHumanoid or targetHumanoid.Health <= 0 then
			return false, "Target dead or invalid"
		end

		local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
		targetData = targetPlayer and profiles[targetPlayer] or nil
	end

	-- 4. Konsumsi resources (FP atau HP untuk Sacrifice)
	local consumed, consumeErr = consumeResources(playerData, skillDef, onFPConsumed, player)

	if consumeErr then
		return false, consumeErr
	end

	-- 5. Set cooldown
	setCooldown(player, skillId, skillDef.CastDelay)

	-- 6. Apply efek
	local result = {
		SkillId = skillId,
		SkillName = skillDef.Name,
		Tier = skillDef.Tier,
		FPConsumed = consumed,
		LevelUp = false,
		NewSkillLevel = 1,
	}

	if skillDef.Target == "Enemy" and skillDef.BuffType ~= "Buff" then
		-- Attack skill: hitung damage
		local defStats = defenderStats or { Defense = 5 }
		local damage, isCrit = calculateSkillDamage(attackerStats, defStats, skillDef)

		targetHumanoid:TakeDamage(damage)

		result.Damage = damage
		result.IsCrit = isCrit
		result.IsAoe = (skillDef.TargetType == "Area")

		-- Grant exp ke skill
		local expGain = math.max(1, math.floor(damage / 10))
		local expResult = addSkillExp(playerData, skillId, expGain)
		result.LevelUp = expResult.LevelUp
		result.NewSkillLevel = expResult.NewLevel
	elseif skillDef.Target == "Self" or skillDef.BuffType == "Buff" or skillDef.BuffType == "Debuff" then
		-- Buff/Debuff: apply ke playerData.ActiveBuffs
		-- (implementasi buff effect via ActiveBuffs yang diproses GameServer setiap tick)
		if not playerData.ActiveBuffs then
			playerData.ActiveBuffs = {}
		end

		-- Durasi buff: 10s + 2s per skill level
		local skillEntry = playerData.Skills and playerData.Skills[skillId]
		local skillLevel = (skillEntry and skillEntry.Level) or 1
		local duration = 10 + skillLevel * 2

		playerData.ActiveBuffs[skillId] = {
			SkillId = skillId,
			ExpiresAt = os.time() + duration,
			School = skillDef.School,
			Tier = skillDef.Tier,
		}

		result.BuffApplied = skillId
		result.BuffDuration = duration

		-- EXP gain untuk cast buff berhasil
		local expResult = addSkillExp(playerData, skillId, 5)
		result.LevelUp = expResult.LevelUp
		result.NewSkillLevel = expResult.NewLevel
	end

	return true, result
end

-- ============================================================
-- Aggregate SkillPT per tier (untuk unlock check)
-- Dipanggil sekali saat data player di-load, atau setelah level up skill
-- ============================================================

function SkillService.RebuildSkillPT(playerData)
	if not playerData.Skills then
		return
	end

	playerData.SkillPT = {}

	for skillId, entry in pairs(playerData.Skills) do
		local skillDef = SkillDefinitions[skillId] or ForceDefinitions[skillId]

		if skillDef then
			local cat = skillDef.Category or skillDef.School or "Force"
			local tier = skillDef.Tier

			if not playerData.SkillPT[cat] then
				playerData.SkillPT[cat] = {}
			end

			playerData.SkillPT[cat][tier] = (playerData.SkillPT[cat][tier] or 0) + entry.Level
		end
	end
end

-- ============================================================
-- Get skill cooldown status untuk client
-- ============================================================

function SkillService.GetCooldowns(player)
	local pc = cooldowns[player]

	if not pc then
		return {}
	end

	local result = {}
	local now = tick()

	for skillId, expiry in pairs(pc) do
		result[skillId] = math.max(0, expiry - now)
	end

	return result
end

-- ============================================================
-- Cleanup
-- ============================================================

function SkillService.OnPlayerRemoving(player)
	cooldowns[player] = nil
end

return SkillService
