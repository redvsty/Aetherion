local GameConfig = require(script.Parent.Parent.GameConfig)
local CurrencyDefinitions = require(script.Parent.CurrencyDefinitions)

-- RF Classic race modifiers:
--   MECHA  (Bellato) : balanced, HP sedikit lebih tinggi, bisa MAU
--   CYBORG (Accretia): HP paling tinggi, FP lebih rendah, Blood Ammo heal
--   MYSTIC (Cora)    : FP paling tinggi, HP paling rendah, Animus system
--
-- StatMod = multiplier yang dikali ke CalcStatsAtLevel() result
-- Semua ras bisa Force/Spiritualist tapi power berbeda (ForcePowerMod)

local RaceDefinitions = {
	[GameConfig.Factions.MECHA] = {
		Id = GameConfig.Factions.MECHA,
		DisplayName = "Asterion Mechanica",
		ShortName = "MECHA",
		Lore = "Industrial empire. Masters of mechanical warfare and the MAU battle system.",
		CurrencyId = CurrencyDefinitions.GetFactionCurrencyId(GameConfig.Factions.MECHA),

		AllowedStartingClasses = {
			GameConfig.StartingClasses.Warrior,
			GameConfig.StartingClasses.Ranger,
			GameConfig.StartingClasses.Spiritualist,
			GameConfig.StartingClasses.Specialist,
		},

		-- Stat multiplier diterapkan di atas CalcStatsAtLevel
		StatMod = {
			HP = 1.10,  -- +10% HP
			FP = 1.00,  -- normal FP
			SP = 1.00,  -- normal SP
		},

		ForcePowerMod = 0.85,    -- Force skill 15% lebih lemah dari MYSTIC
		CanUseMagic   = true,
		MagicSchool   = "Holy",  -- MECHA Spiritualist pakai Holy element
		CanUseLauncher = false,
		CanUseMAU      = true,   -- MECHA exclusive: bisa naik MAU
		CanUseAnimus   = false,
		CanUseBloodAmmo = false,
		SpawnLocationId = "mecha_hq_spawn",
	},

	[GameConfig.Factions.CYBORG] = {
		Id = GameConfig.Factions.CYBORG,
		DisplayName = "Iron Dominion",
		ShortName = "CYBORG",
		Lore = "Cybernetic race. Unmatched durability and the unique Blood Ammo healing system.",
		CurrencyId = CurrencyDefinitions.GetFactionCurrencyId(GameConfig.Factions.CYBORG),

		-- Accretia tidak punya Spiritualist — tidak ada class magic di RF Classic
		AllowedStartingClasses = {
			GameConfig.StartingClasses.Warrior,
			GameConfig.StartingClasses.Ranger,
			GameConfig.StartingClasses.Specialist,
		},

		StatMod = {
			HP = 1.20,  -- +20% HP (paling tahan)
			FP = 0.60,  -- -40% FP (hampir tidak pakai FP, gantinya Blood Ammo)
			SP = 1.05,  -- sedikit lebih tinggi
		},

		ForcePowerMod = 0,       -- tidak bisa Force sama sekali
		CanUseMagic    = false,  -- Accretia tidak bisa magic
		MagicSchool    = nil,
		CanUseLauncher = true,   -- CYBORG exclusive: bisa pakai Launcher
		CanUseMAU      = false,
		CanUseAnimus   = false,
		CanUseBloodAmmo = true,  -- CYBORG Specialist exclusive: Blood Ammo
		SpawnLocationId = "cyborg_hq_spawn",
	},

	[GameConfig.Factions.MYSTIC] = {
		Id = GameConfig.Factions.MYSTIC,
		DisplayName = "Elyndra Covenant",
		ShortName = "MYSTIC",
		Lore = "Mystical race. Strongest Force power and the Animus companion system.",
		CurrencyId = CurrencyDefinitions.GetFactionCurrencyId(GameConfig.Factions.MYSTIC),

		AllowedStartingClasses = {
			GameConfig.StartingClasses.Warrior,
			GameConfig.StartingClasses.Ranger,
			GameConfig.StartingClasses.Spiritualist,
			GameConfig.StartingClasses.Specialist,
		},

		StatMod = {
			HP = 0.90,  -- -10% HP (paling fragile)
			FP = 1.20,  -- +20% FP (Force terkuat)
			SP = 0.95,  -- sedikit lebih rendah
		},

		ForcePowerMod = 1.00,    -- MYSTIC = baseline Force power (paling kuat)
		CanUseMagic    = true,
		MagicSchool    = "Dark", -- MYSTIC Spiritualist pakai Dark element (Cora = dark magic)
		CanUseLauncher = false,
		CanUseMAU      = false,
		CanUseAnimus   = true,   -- MYSTIC exclusive: bisa punya Animus companion
		CanUseBloodAmmo = false,
		SpawnLocationId = "mystic_hq_spawn",
	},
}

-- ============================================================
-- Helper Functions
-- ============================================================

function RaceDefinitions.IsValidRace(factionId)
	return RaceDefinitions[factionId] ~= nil
end

function RaceDefinitions.IsClassAllowed(factionId, classId)
	local race = RaceDefinitions[factionId]
	if not race then return false end
	for _, allowedClassId in ipairs(race.AllowedStartingClasses) do
		if allowedClassId == classId then return true end
	end
	return false
end

-- Terapkan StatMod ras ke stats dasar class
-- Input: { MaxHP, MaxFP, MaxSP } dari ClassDefinitions.CalcStatsAtLevel
-- Output: stats setelah race modifier diapply (dibulatkan ke bawah)
function RaceDefinitions.ApplyStatMod(factionId, baseStats)
	local race = RaceDefinitions[factionId]
	if not race or not race.StatMod then return baseStats end

	return {
		MaxHP = math.floor(baseStats.MaxHP * race.StatMod.HP),
		MaxFP = math.floor(baseStats.MaxFP * race.StatMod.FP),
		MaxSP = math.floor(baseStats.MaxSP * race.StatMod.SP),
	}
end

-- Hitung stats final player: class scaling + race modifier
function RaceDefinitions.CalcFinalStats(factionId, startingClassId, level)
	local ClassDefinitions = require(script.Parent.ClassDefinitions)
	local base = ClassDefinitions.CalcStatsAtLevel(startingClassId, level)
	return RaceDefinitions.ApplyStatMod(factionId, base)
end

return RaceDefinitions
