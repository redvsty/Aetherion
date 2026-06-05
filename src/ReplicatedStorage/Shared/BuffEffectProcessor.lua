-- BuffEffectProcessor.lua
-- Patch RF-Accuracy: Menerapkan efek buff/debuff yang akurat sesuai RF Classic
-- Sumber: https://wiki.rfdatabase.net/game-controls/skill-force-buffs-and-debuffs
--
-- Di RF Classic, setiap buff punya efek numerik per level (1-7/GM).
-- Level skill = 1..7 (GM = level 7)
-- Durasi buff: Level1=90s, Lv2=140s, Lv3=210s, Lv4=320s, Lv5=480s, Lv6=720s, GM=1080s
--
-- BuffEffectProcessor.ApplyBuffStats(baseStats, activeBuffs, skillLevels)
--   → return modifiedStats (copy, tidak mengubah baseStats)

local BuffEffectProcessor = {}

-- Durasi per skill level (RF official: 90/140/210/320/480/720/1080 detik)
BuffEffectProcessor.BUFF_DURATIONS = { 90, 140, 210, 320, 480, 720, 1080 }

-- ============================================================
-- Tabel efek buff per skill level (1..7)
-- Sesuai wiki RF: https://wiki.rfdatabase.net/game-controls/skill-force-buffs-and-debuffs
-- ============================================================

-- === WARRIOR SKILL BUFFS ===

-- Wild Rage: +ATK% (melee only)
local WILD_RAGE_ATK = { 0.10, 0.12, 0.15, 0.18, 0.21, 0.25, 0.30 }

-- Accuracy (warrior): +Accuracy flat
local WARRIOR_ACCURACY = { 10, 12, 15, 18, 21, 25, 30 }

-- Extend Range (melee): +attack range flat
-- wiki label: "Wide Range" untuk warrior → +5/+10/+15/+20/+25/+30/+35
local WARRIOR_WIDE_RANGE = { 5, 10, 15, 20, 25, 30, 35 }

-- Skill Stretch: extend buff duration %
local SKILL_STRETCH_PCT = { 0.20, 0.30, 0.40, 0.50, 0.65, 0.80, 1.00 }

-- Counter Attack: % chance dodge + counter
local COUNTER_ATTACK_CHANCE = { 0.05, 0.07, 0.10, 0.12, 0.15, 0.18, 0.20 }

-- Shield Rupture / Guard Break: % chance ignore block
local GUARD_BREAK_CHANCE = { 0.05, 0.07, 0.10, 0.12, 0.15, 0.18, 0.20 }

-- Bull's Eye: +CritChance flat
local BULLS_EYE_CRIT = { 10, 12, 15, 18, 21, 25, 30 }

-- === RANGER SKILL BUFFS ===

-- Speed Load / Fast Reload: reduce attack delay seconds
local FAST_RELOAD_DELAY = { 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4 }

-- Precision: +Accuracy (ranged only)
local RANGER_ACCURACY = { 10, 12, 15, 18, 21, 25, 30 }

-- Wide Range (ranged): +range flat
local RANGER_WIDE_RANGE = { 10, 20, 30, 45, 60, 75, 100 }

-- Evasion: +Dodge flat
local EVASION_DODGE = { 10, 12, 15, 18, 21, 25, 30 }

-- Crossfire: +CritChance flat (same as bull's eye, different skill)
local CROSSFIRE_CRIT = { 10, 12, 15, 18, 21, 25, 30 }

-- === HOLY FORCE BUFFS (MECHA/Bellato) ===

-- Focus / Bless: extend force buff duration %
local BLESS_DURATION_PCT = { 0.20, 0.30, 0.40, 0.50, 0.65, 0.80, 1.00 }

-- Energize / Restoration: recover SP% instantly
local RESTORATION_SP_PCT = { 0.20, 0.25, 0.30, 0.40, 0.60, 0.70, 1.00 }

-- Soul Vitality / Soul Ballad: +HP/FP regen rate multiplier
local SOUL_BALLAD_REGEN = { 0.50, 1.00, 1.20, 1.40, 1.60, 1.80, 2.00 }

-- Resistance / Elemental Resist: +elemental resistance flat
local ELEM_RESIST = { 1, 2, 3, 4, 5, 7, 15 }

-- Healing: recover HP% instantly
local HEALING_HP_PCT = { 0.10, 0.12, 0.15, 0.18, 0.21, 0.25, 0.30 }

-- Velocity: +move speed flat
local VELOCITY_SPEED = { 1.0, 1.1, 1.2, 1.4, 1.6, 1.8, 2.0 }

-- Agility: +dodge flat
local AGILITY_DODGE = { 10, 12, 15, 18, 21, 25, 30 }

-- Aegis / Holy Shield: +defense% 
local HOLY_SHIELD_DEF_PCT = { 0.10, 0.12, 0.15, 0.18, 0.21, 0.25, 0.30 }

-- Conservation / Effective Consume: reduce FP cost %
local CONSERVATION_FP_PCT = { 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35 }

-- === DARK FORCE BUFFS (MYSTIC/Cora) ===

-- Exertion / Celerity: reduce melee attack delay (seconds)
local CELERITY_DELAY = { 0.10, 0.12, 0.15, 0.18, 0.21, 0.25, 0.30 }

-- Rush / Tempo: reduce force cooldown (seconds)
local TEMPO_CD = { 0.1, 0.2, 0.4, 0.7, 1.1, 1.6, 2.2 }

-- Might / Adept: +ForceAttack%
local ADEPT_FA_PCT = { 0.10, 0.12, 0.15, 0.18, 0.21, 0.25, 0.30 }

-- Broad Outlook / Vista: +cast range flat
local VISTA_RANGE = { 50, 50, 50, 50, 50, 50, 50 }

-- Acute Sight / Acuity: +accuracy all weapons
local ACUITY_ACC = { 10, 12, 15, 18, 21, 25, 30 }

-- Efficiency / Conservation (dark): reduce FP cost %
local EFFICIENCY_FP_PCT = { 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35 }

-- === FORCE DEBUFFS ===
-- Hell Bless: drain HP/FP/SP per second
local HELL_BLESS_DRAIN = { 100, 100, 100, 100, 100, 100, 100 }

-- Debuff durations: 30/36/45/54/63/75/90
BuffEffectProcessor.DEBUFF_DURATIONS = { 30, 36, 45, 54, 63, 75, 90 }

-- ============================================================
-- Helper: clamp level ke 1..7
-- ============================================================
local function clampLevel(level)
	return math.max(1, math.min(7, math.floor(level or 1)))
end

-- ============================================================
-- GetBuffDuration(skillLevel, isDebuff) → seconds
-- Dipakai SkillService saat menerapkan buff ke ActiveBuffs
-- ============================================================
function BuffEffectProcessor.GetBuffDuration(skillLevel, isDebuff)
	local idx = clampLevel(skillLevel)
	if isDebuff then
		return BuffEffectProcessor.DEBUFF_DURATIONS[idx]
	end
	return BuffEffectProcessor.BUFF_DURATIONS[idx]
end

-- ============================================================
-- ApplyBuffStats(baseStats, activeBuffs, playerData)
-- Kalkulasi stats final termasuk semua efek buff aktif.
-- activeBuffs = { [skillId] = { SkillId, ExpiresAt, SkillLevel } }
-- Return: modifiedStats (table baru, tidak modifikasi baseStats)
-- ============================================================
function BuffEffectProcessor.ApplyBuffStats(baseStats, activeBuffs, playerData)
	if not baseStats then return {} end
	if not activeBuffs then return baseStats end

	-- Deep copy baseStats
	local stats = {}
	for k, v in pairs(baseStats) do
		stats[k] = v
	end

	-- Tambahkan default jika belum ada
	stats.AttackPercent  = stats.AttackPercent  or 0   -- % multiplier tambahan
	stats.Accuracy       = stats.Accuracy       or 0
	stats.AttackRange    = stats.AttackRange    or 0
	stats.CritChance     = stats.CritChance     or 0.05
	stats.Dodge          = stats.Dodge          or 0
	stats.DefensePercent = stats.DefensePercent or 0
	stats.ForceAttackPct = stats.ForceAttackPct or 0
	stats.MoveSpeed      = stats.MoveSpeed      or 16  -- Studs/s baseline
	stats.FPCostReductPct= stats.FPCostReductPct or 0
	stats.AttackDelay    = stats.AttackDelay    or 0   -- pengurangan delay (detik)
	stats.ForceCooldownReduct = stats.ForceCooldownReduct or 0
	stats.ElemResist     = stats.ElemResist     or 0
	stats.CastRange      = stats.CastRange      or 0
	stats.CounterChance  = stats.CounterChance  or 0
	stats.GuardBreakChance = stats.GuardBreakChance or 0
	stats.SkillStretchPct  = stats.SkillStretchPct  or 0
	stats.HellBlessDrain   = stats.HellBlessDrain   or 0   -- debuff

	local now = os.time()
	local skillStretchApplied = 0 -- untuk extend durasi buff lain

	-- Pass 1: cek Skill Stretch / Bless dulu (keduanya extend durasi)
	for skillId, buffEntry in pairs(activeBuffs) do
		if buffEntry.ExpiresAt > now then
			local lvl = clampLevel(buffEntry.SkillLevel or 1)
			if skillId == "skill_stretch" then
				skillStretchApplied = math.max(skillStretchApplied, SKILL_STRETCH_PCT[lvl])
			elseif skillId == "focus" or skillId == "bless" then
				skillStretchApplied = math.max(skillStretchApplied, BLESS_DURATION_PCT[lvl])
			end
		end
	end
	stats.SkillStretchPct = skillStretchApplied

	-- Pass 2: apply semua buff lain
	for skillId, buffEntry in pairs(activeBuffs) do
		if buffEntry.ExpiresAt > now then
			local lvl = clampLevel(buffEntry.SkillLevel or 1)

			-- ---- WARRIOR BUFFS ----
			if skillId == "wild_rage" then
				stats.AttackPercent = stats.AttackPercent + WILD_RAGE_ATK[lvl]

			elseif skillId == "accuracy_skill" then
				stats.Accuracy = stats.Accuracy + WARRIOR_ACCURACY[lvl]

			elseif skillId == "extend_range" then
				stats.AttackRange = stats.AttackRange + WARRIOR_WIDE_RANGE[lvl]

			elseif skillId == "counter_attack" then
				stats.CounterChance = stats.CounterChance + COUNTER_ATTACK_CHANCE[lvl]

			elseif skillId == "shield_rupture" then
				stats.GuardBreakChance = stats.GuardBreakChance + GUARD_BREAK_CHANCE[lvl]

			elseif skillId == "bulls_eye" then
				-- +flat crit (konversi ke fraction, wiki pakai flat +10..30 → +0.10..0.30 frac)
				stats.CritChance = stats.CritChance + (BULLS_EYE_CRIT[lvl] / 100)

			-- ---- RANGER BUFFS ----
			elseif skillId == "speed_load" then
				stats.AttackDelay = stats.AttackDelay + FAST_RELOAD_DELAY[lvl]

			elseif skillId == "precision" then
				stats.Accuracy = stats.Accuracy + RANGER_ACCURACY[lvl]

			elseif skillId == "wide_range" then
				stats.AttackRange = stats.AttackRange + RANGER_WIDE_RANGE[lvl]

			elseif skillId == "evasion" then
				stats.Dodge = stats.Dodge + EVASION_DODGE[lvl]

			elseif skillId == "crossfire" then
				stats.CritChance = stats.CritChance + (CROSSFIRE_CRIT[lvl] / 100)

			-- ---- HOLY FORCE BUFFS (MECHA) ----
			elseif skillId == "focus" then
				-- durasi extend sudah di pass 1
				-- no additional stat

			elseif skillId == "energize" then
				-- SP recovery: ditangani saat cast (instant), tidak persistent
				-- tapi kita simpan flag untuk SP regen
				stats.SpRegenBonus = (stats.SpRegenBonus or 0) + RESTORATION_SP_PCT[lvl]

			elseif skillId == "soul_vitality" then
				-- HP/FP regen rate multiplier
				stats.HpFpRegenMult = (stats.HpFpRegenMult or 1.0) + SOUL_BALLAD_REGEN[lvl]

			elseif skillId == "resistance" then
				stats.ElemResist = stats.ElemResist + ELEM_RESIST[lvl]

			elseif skillId == "healing" then
				-- Healing = instant HP restore saat cast, sudah ditangani SkillService
				-- Tapi bisa dijadikan passive HP regen jika di-stack
				stats.PassiveHpRestorePct = (stats.PassiveHpRestorePct or 0) + HEALING_HP_PCT[lvl]

			elseif skillId == "velocity" then
				stats.MoveSpeed = stats.MoveSpeed + VELOCITY_SPEED[lvl]

			elseif skillId == "agility" then
				stats.Dodge = stats.Dodge + AGILITY_DODGE[lvl]

			elseif skillId == "aegis" then
				stats.DefensePercent = stats.DefensePercent + HOLY_SHIELD_DEF_PCT[lvl]

			elseif skillId == "conservation" then
				stats.FPCostReductPct = stats.FPCostReductPct + CONSERVATION_FP_PCT[lvl]

			-- ---- DARK FORCE BUFFS (MYSTIC) ----
			elseif skillId == "exertion" then
				stats.AttackDelay = stats.AttackDelay + CELERITY_DELAY[lvl]

			elseif skillId == "sacrifice" then
				-- Instant HP→FP convert saat cast, tidak persistent

			elseif skillId == "rush" then
				stats.ForceCooldownReduct = stats.ForceCooldownReduct + TEMPO_CD[lvl]

			elseif skillId == "might" then
				stats.ForceAttackPct = stats.ForceAttackPct + ADEPT_FA_PCT[lvl]

			elseif skillId == "broad_outlook" then
				stats.CastRange = stats.CastRange + VISTA_RANGE[lvl]

			-- velocity dark = sama dengan holy velocity
			-- (jika ada skillId "velocity_dark", map ke sini)

			elseif skillId == "acute_sight" then
				stats.Accuracy = stats.Accuracy + ACUITY_ACC[lvl]

			elseif skillId == "efficiency" then
				stats.FPCostReductPct = stats.FPCostReductPct + EFFICIENCY_FP_PCT[lvl]

			-- ---- FORCE DEBUFFS ----
			elseif skillId == "hell_bless" then
				stats.HellBlessDrain = stats.HellBlessDrain + HELL_BLESS_DRAIN[lvl]

			end
		end
	end

	-- Apply AttackPercent ke Attack final
	if stats.AttackPercent > 0 then
		stats.Attack = math.floor((stats.Attack or 1) * (1 + stats.AttackPercent))
	end

	-- Apply DefensePercent ke Defense final
	if stats.DefensePercent > 0 then
		stats.Defense = math.floor((stats.Defense or 0) * (1 + stats.DefensePercent))
	end

	-- Apply ForceAttackPct ke ForceAttack
	if stats.ForceAttackPct > 0 and stats.ForceAttack then
		stats.ForceAttack = math.floor(stats.ForceAttack * (1 + stats.ForceAttackPct))
	end

	-- Clamp CritChance
	stats.CritChance = math.min(0.95, stats.CritChance)

	return stats
end

-- ============================================================
-- GetAdjustedFPCost(baseCost, stats)
-- Kurangi FP cost berdasarkan Conservation/Efficiency buff
-- ============================================================
function BuffEffectProcessor.GetAdjustedFPCost(baseCost, stats)
	if not stats or not stats.FPCostReductPct or stats.FPCostReductPct <= 0 then
		return baseCost
	end
	local reduced = baseCost * (1 - math.min(0.80, stats.FPCostReductPct))
	return math.max(1, math.floor(reduced))
end

-- ============================================================
-- GetAdjustedCooldown(baseCooldown, stats, isForce)
-- Kurangi cooldown berdasarkan Rush/Tempo buff (force only)
-- ============================================================
function BuffEffectProcessor.GetAdjustedCooldown(baseCooldown, stats, isForce)
	if not isForce or not stats or not stats.ForceCooldownReduct then
		return baseCooldown
	end
	return math.max(0.5, baseCooldown - stats.ForceCooldownReduct)
end

-- ============================================================
-- TickDebuffs(playerData, deltaTime)
-- Proses Hell Bless drain per tick. Dipanggil dari loop server.
-- ============================================================
function BuffEffectProcessor.TickDebuffs(playerData, deltaTime)
	if not playerData or not playerData.ActiveBuffs then return end

	local now = os.time()
	local stats = playerData.Stats
	if not stats then return end

	for skillId, buffEntry in pairs(playerData.ActiveBuffs) do
		if buffEntry.ExpiresAt <= now then
			playerData.ActiveBuffs[skillId] = nil
		elseif skillId == "hell_bless" then
			local lvl = math.max(1, math.min(7, buffEntry.SkillLevel or 1))
			local drain = HELL_BLESS_DRAIN[lvl] * deltaTime
			stats.HP = math.max(0, (stats.HP or 0) - drain)
			stats.FP = math.max(0, (stats.FP or 0) - drain)
			-- SP jika ada
			if stats.SP then
				stats.SP = math.max(0, stats.SP - drain)
			end
		end
	end
end

-- ============================================================
-- GetSkillBuff_HealingAmount(playerData, skillLevel)
-- Untuk skill "healing" — instant HP restore
-- ============================================================
function BuffEffectProcessor.GetHealingAmount(playerData, skillLevel)
	local lvl = clampLevel(skillLevel)
	local maxHP = (playerData.Stats and playerData.Stats.MaxHP) or 100
	return math.floor(maxHP * HEALING_HP_PCT[lvl])
end

return BuffEffectProcessor
