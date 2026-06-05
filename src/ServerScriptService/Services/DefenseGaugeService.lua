-- DefenseGaugeService.lua
-- Patch RF-Accuracy: Sistem Defense Gauge sesuai RF Classic
-- Sumber: https://wiki.rfdatabase.net/game-controls/defense-gauge
--
-- Defense Gauge = bar terpisah dari HP, menentukan efektivitas armor & dodge.
-- State: Stable (100%) → Reduced (orange) → Danger (red)
-- Perlahan pulih sendiri seiring waktu.
-- Talic upgrade effect dipengaruhi gauge; base armor/buff dari skill TIDAK dipengaruhi.
--
-- Weapon type affect gauge drain laju berbeda tergantung armor type target.

local DefenseGaugeService = {}

-- ============================================================
-- Konstanta
-- ============================================================

-- State threshold
DefenseGaugeService.STATE = {
	STABLE  = "Stable",   -- gauge >= 60%
	REDUCED = "Reduced",  -- gauge 30%..60%
	DANGER  = "Danger",   -- gauge < 30%
}

-- Recovery rate per detik (pasif)
local GAUGE_REGEN_PER_SEC = 2.0  -- 2% per detik saat tidak diserang

-- Defense effectiveness per state
-- Di Stable: talic boost 100% | Reduced: 50% | Danger: 0%
local GAUGE_EFFECTIVENESS = {
	Stable  = 1.00,
	Reduced = 0.50,
	Danger  = 0.05,
}

-- ============================================================
-- Weapon type drain table sesuai wiki RF
-- Key = weaponSubType, value = { WarriorArmor, ForceArmor, LauncherArmor }
-- (drain pct dari 100 gauge per hit, bukan actual number — relative weight)
-- ============================================================
local WEAPON_DRAIN = {
	-- Melee
	Axe   = { warrior = 12, force = 3,  launcher = 3  },
	Mace  = { warrior = 12, force = 3,  launcher = 3  },
	Spear = { warrior = 10, force = 4,  launcher = 4  },
	Sword = { warrior = 10, force = 4,  launcher = 4  },
	Knife = { warrior = 7,  force = 8,  launcher = 8  },
	-- Ranged
	Bow     = { warrior = 4, force = 12, launcher = 12 },
	Firearm = { warrior = 4, force = 12, launcher = 12 },
	-- Magic / Staff
	Staff   = { warrior = 10, force = 5, launcher = 5 },
	Reaver  = { warrior = 10, force = 5, launcher = 5 },
	-- Launcher
	Launcher = { warrior = 7, force = 7, launcher = 7 },
	-- Monster attack = same as Knife
	Monster = { warrior = 7, force = 8, launcher = 8 },
}

-- Armor type mapping (class-based)
-- Warrior class = warrior armor, Magic class = force armor, Launcher (CYBORG Ranger) = launcher
local CLASS_ARMOR_TYPE = {
	Melee         = "warrior",
	Ranged        = "force",     -- bow/rifle → force armor class di RF
	Magic         = "force",
	SupportCraft  = "warrior",
	-- Accretia Ranger / Launcher
	Launcher      = "launcher",
}

-- ============================================================
-- Inisialisasi gauge data di playerData
-- dipanggil saat player pertama dibuat / load
-- ============================================================
function DefenseGaugeService.InitGauge(playerData)
	if not playerData.DefenseGauge then
		playerData.DefenseGauge = {
			Current = 100,  -- 0-100
			Max     = 100,
			State   = DefenseGaugeService.STATE.STABLE,
		}
	end
end

-- ============================================================
-- GetState(gaugeValue) → state string
-- ============================================================
local function getState(val)
	if val >= 60 then
		return DefenseGaugeService.STATE.STABLE
	elseif val >= 30 then
		return DefenseGaugeService.STATE.REDUCED
	else
		return DefenseGaugeService.STATE.DANGER
	end
end

-- ============================================================
-- GetWeaponDrain(weaponSubType, armorClass) → drain amount
-- ============================================================
local function getWeaponDrain(weaponSubType, armorClass)
	local drainTable = WEAPON_DRAIN[weaponSubType] or WEAPON_DRAIN.Monster
	return drainTable[armorClass] or 7
end

-- ============================================================
-- GetDefenderArmorClass(defenderData) → "warrior" | "force" | "launcher"
-- ============================================================
local function getDefenderArmorClass(defenderData, ClassDefinitions)
	if not defenderData then return "warrior" end
	local role = ClassDefinitions and ClassDefinitions.GetStartingClassRole(defenderData) or "Melee"
	return CLASS_ARMOR_TYPE[role] or "warrior"
end

-- ============================================================
-- TakeDrainHit(defenderData, weaponSubType, weaponLevel, armorLevel, ClassDefs)
-- Dipanggil setelah setiap hit diterima defender.
-- Mengurangi gauge berdasarkan weapon type vs armor class.
-- weaponLevel & armorLevel mempengaruhi drain (weapon lebih tinggi = lebih drain)
-- ============================================================
function DefenseGaugeService.TakeDrainHit(defenderData, weaponSubType, weaponLevel, armorLevel, ClassDefs)
	DefenseGaugeService.InitGauge(defenderData)
	local gauge = defenderData.DefenseGauge

	local armorClass = getDefenderArmorClass(defenderData, ClassDefs)
	local baseDrain = getWeaponDrain(weaponSubType or "Monster", armorClass)

	-- Level difference modifier: +10% drain per 5 levels weapon lebih tinggi dari armor
	local levelDiff = (weaponLevel or 1) - (armorLevel or 1)
	local levelMod = 1.0 + math.max(0, levelDiff) * 0.02  -- +2% per level diff, max reasonable

	local drain = math.floor(baseDrain * levelMod)
	gauge.Current = math.max(0, gauge.Current - drain)
	gauge.State = getState(gauge.Current)
end

-- ============================================================
-- RegenTick(defenderData, deltaSeconds)
-- Dipanggil dari server loop setiap detik untuk regen gauge.
-- ============================================================
function DefenseGaugeService.RegenTick(defenderData, deltaSeconds)
	if not defenderData or not defenderData.DefenseGauge then return end
	local gauge = defenderData.DefenseGauge

	if gauge.Current < gauge.Max then
		gauge.Current = math.min(gauge.Max, gauge.Current + GAUGE_REGEN_PER_SEC * deltaSeconds)
		gauge.State = getState(gauge.Current)
	end
end

-- ============================================================
-- GetTalicEffectiveness(defenderData) → 0.0..1.0
-- Seberapa efektif talic upgrade bonuses di state sekarang.
-- Base armor dan buff dari skill/force TIDAK dipengaruhi (selalu 1.0).
-- ============================================================
function DefenseGaugeService.GetTalicEffectiveness(defenderData)
	if not defenderData or not defenderData.DefenseGauge then return 1.0 end
	local state = defenderData.DefenseGauge.State or DefenseGaugeService.STATE.STABLE
	return GAUGE_EFFECTIVENESS[state] or 1.0
end

-- ============================================================
-- ApplyGaugeToDefense(baseDefense, talicBonus, talichEffectiveness)
-- Hitung defense final dengan gauge effect.
-- baseDef = defense dari equipment (tidak dipengaruhi gauge)
-- talicBonus = bonus dari talic upgrade (dipengaruhi gauge)
-- ============================================================
function DefenseGaugeService.ApplyGaugeToDefense(baseDefense, talicBonus, talicEffectiveness)
	return baseDefense + math.floor((talicBonus or 0) * (talicEffectiveness or 1.0))
end

-- ============================================================
-- GetGaugeInfo(defenderData) → { Current, Max, State, Percent }
-- Info untuk dikirim ke client UI
-- ============================================================
function DefenseGaugeService.GetGaugeInfo(defenderData)
	DefenseGaugeService.InitGauge(defenderData)
	local gauge = defenderData.DefenseGauge
	return {
		Current = gauge.Current,
		Max     = gauge.Max,
		State   = gauge.State,
		Percent = (gauge.Current / gauge.Max) * 100,
	}
end

return DefenseGaugeService
