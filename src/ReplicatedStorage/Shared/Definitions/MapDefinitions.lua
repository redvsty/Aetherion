-- MapDefinitions.lua
-- Peta Aetherion Phase 1 (Level 50 cap) — layout mengacu RF Classic
--
-- Layout tiga ras (pandangan atas, Z negatif = utara):
--
--        UTARA  (Z negatif)
--
--  B_HQ (-3000,-2500)  [CHIP_MINE_CORE] (0,-2200)  A_HQ (3000,-2500)
--      \                    |                    /
--    ELAN_W (-2000,-1400) CHIP_APP (0,-1000) ELAN_E (2000,-1400)
--        \                  |                  /
--        NOVUS_NW(-1400,-600) | NOVUS_NE(1400,-600)
--              \             |             /
--              NOVUS_SOUTH (0,800) ← dari selatan
--                          |
--                    NOVUS_CENTER (0,0)
--                          |
--                    ELAN_SOUTH (0,1800)
--                          |
--                     C_HQ (0,3500)
--
--        SELATAN (Z positif)

local MapDefinitions = {}

MapDefinitions.MAP_HALF  = 4000      -- map total 8000 x 8000 studs
MapDefinitions.GROUND_Y  = 0         -- Y permukaan tanah
MapDefinitions.TERRAIN_DEPTH = 30    -- kedalaman terrain di bawah tanah

-- ============================================================
-- Zone Definitions
-- ============================================================
MapDefinitions.Zones = {

	-- ── SAFE ZONES (Race HQ) ─────────────────────────────────

	BELLATO_HQ = {
		Id          = "BELLATO_HQ",
		Name        = "Bellato Union HQ",
		Race        = "Bellato",
		SafeZone    = true,
		PvP         = false,
		LevelRange  = { 1, 15 },
		Center      = Vector3.new(-3000, 0, -2500),
		Radius      = 420,
		Terrain     = Enum.Material.SmoothPlastic,
		SpawnPos    = Vector3.new(-3000, 5, -2500),
	},

	CORA_HQ = {
		Id          = "CORA_HQ",
		Name        = "Holy Cora Alliance HQ",
		Race        = "Cora",
		SafeZone    = true,
		PvP         = false,
		LevelRange  = { 1, 15 },
		Center      = Vector3.new(0, 0, 3500),
		Radius      = 420,
		Terrain     = Enum.Material.Grass,
		SpawnPos    = Vector3.new(0, 5, 3500),
	},

	ACCRETIA_HQ = {
		Id          = "ACCRETIA_HQ",
		Name        = "Accretia Empire HQ",
		Race        = "Accretia",
		SafeZone    = true,
		PvP         = false,
		LevelRange  = { 1, 15 },
		Center      = Vector3.new(3000, 0, -2500),
		Radius      = 420,
		Terrain     = Enum.Material.Metal,
		SpawnPos    = Vector3.new(3000, 5, -2500),
	},

	-- ── EARLY ZONES (L5-L20) ────────────────────────────────

	ELAN_WEST = {
		Id         = "ELAN_WEST",
		Name       = "Elan Western Plains",
		SafeZone   = false,
		PvP        = false,
		LevelRange = { 5, 18 },
		Center     = Vector3.new(-2000, 0, -1400),
		Radius     = 520,
		Terrain    = Enum.Material.Grass,
	},

	ELAN_EAST = {
		Id         = "ELAN_EAST",
		Name       = "Elan Eastern Plains",
		SafeZone   = false,
		PvP        = false,
		LevelRange = { 5, 18 },
		Center     = Vector3.new(2000, 0, -1400),
		Radius     = 520,
		Terrain    = Enum.Material.Grass,
	},

	ELAN_SOUTH = {
		Id         = "ELAN_SOUTH",
		Name       = "Elan Southern Grasslands",
		SafeZone   = false,
		PvP        = false,
		LevelRange = { 8, 22 },
		Center     = Vector3.new(0, 0, 1800),
		Radius     = 520,
		Terrain    = Enum.Material.Grass,
	},

	-- ── MID ZONES (L20-L35) — PvP mulai aktif ─────────────

	NOVUS_NORTHWEST = {
		Id         = "NOVUS_NORTHWEST",
		Name       = "Novus Northwest",
		SafeZone   = false,
		PvP        = true,
		LevelRange = { 20, 32 },
		Center     = Vector3.new(-1400, 0, -600),
		Radius     = 560,
		Terrain    = Enum.Material.Grass,
	},

	NOVUS_NORTHEAST = {
		Id         = "NOVUS_NORTHEAST",
		Name       = "Novus Northeast",
		SafeZone   = false,
		PvP        = true,
		LevelRange = { 20, 32 },
		Center     = Vector3.new(1400, 0, -600),
		Radius     = 560,
		Terrain    = Enum.Material.Grass,
	},

	NOVUS_SOUTH = {
		Id         = "NOVUS_SOUTH",
		Name       = "Novus South",
		SafeZone   = false,
		PvP        = true,
		LevelRange = { 22, 35 },
		Center     = Vector3.new(0, 0, 800),
		Radius     = 560,
		Terrain    = Enum.Material.Grass,
	},

	-- ── CORE ZONE (L30-L42) — PvP berat ────────────────────

	NOVUS_CENTER = {
		Id         = "NOVUS_CENTER",
		Name       = "Novus Center",
		SafeZone   = false,
		PvP        = true,
		LevelRange = { 30, 42 },
		Center     = Vector3.new(0, 0, 0),
		Radius     = 620,
		Terrain    = Enum.Material.Grass,
	},

	-- ── ENDGAME ZONES (L38-L50) — Chip War ─────────────────

	CHIP_MINE_APPROACH = {
		Id         = "CHIP_MINE_APPROACH",
		Name       = "Chip Mine Approach",
		SafeZone   = false,
		PvP        = true,
		LevelRange = { 38, 48 },
		Center     = Vector3.new(0, 0, -1000),
		Radius     = 500,
		Terrain    = Enum.Material.Rock,
	},

	CHIP_MINE_CORE = {
		Id          = "CHIP_MINE_CORE",
		Name        = "Chip Mine Core",
		SafeZone    = false,
		PvP         = true,
		ChipWar     = true,
		LevelRange  = { 45, 50 },
		Center      = Vector3.new(0, 5, -2200),
		Radius      = 400,
		Terrain     = Enum.Material.Rock,
		Description = "Sumber Force Core. Area utama Chip War tiga ras.",
	},
}

-- ============================================================
-- Spawn Configuration per Zone
-- { DefId = monster id, Count = jumlah spawner, Spread = radius sebaran }
-- ============================================================
MapDefinitions.SpawnConfig = {

	BELLATO_HQ = {
		{ DefId = "anabola",  Count = 5, Spread = 280 },
		{ DefId = "frog",     Count = 4, Spread = 240 },
	},
	CORA_HQ = {
		{ DefId = "anabola",  Count = 5, Spread = 280 },
		{ DefId = "tweezer",  Count = 4, Spread = 240 },
	},
	ACCRETIA_HQ = {
		{ DefId = "anabola",  Count = 5, Spread = 280 },
		{ DefId = "frog",     Count = 4, Spread = 240 },
	},

	ELAN_WEST = {
		{ DefId = "tweezer",  Count = 6, Spread = 400 },
		{ DefId = "splinter", Count = 5, Spread = 360 },
	},
	ELAN_EAST = {
		{ DefId = "tweezer",  Count = 6, Spread = 400 },
		{ DefId = "splinter", Count = 5, Spread = 360 },
	},
	ELAN_SOUTH = {
		{ DefId = "splinter", Count = 6, Spread = 400 },
		{ DefId = "warbeast", Count = 4, Spread = 360 },
	},

	NOVUS_NORTHWEST = {
		{ DefId = "warbeast", Count = 6, Spread = 440 },
		{ DefId = "snatcher", Count = 5, Spread = 400 },
	},
	NOVUS_NORTHEAST = {
		{ DefId = "warbeast", Count = 6, Spread = 440 },
		{ DefId = "snatcher", Count = 5, Spread = 400 },
	},
	NOVUS_SOUTH = {
		{ DefId = "snatcher", Count = 6, Spread = 440 },
		{ DefId = "vafer",    Count = 5, Spread = 400 },
	},

	NOVUS_CENTER = {
		{ DefId = "vafer",    Count = 6, Spread = 480 },
		{ DefId = "crawler",  Count = 5, Spread = 440 },
	},

	CHIP_MINE_APPROACH = {
		{ DefId = "crawler",      Count = 5, Spread = 380 },
		{ DefId = "high_elf_guard", Count = 5, Spread = 340 },
		{ DefId = "dark_warbeast",  Count = 4, Spread = 300 },
	},

	CHIP_MINE_CORE = {
		{ DefId = "dark_warbeast", Count = 4, Spread = 300 },
		{ DefId = "mine_guardian", Count = 4, Spread = 260 },
		{ DefId = "force_titan",   Count = 2, Spread = 180 },
	},
}

-- ============================================================
-- Road connections (untuk MapGenerator — urutan penting untuk arah)
-- ============================================================
MapDefinitions.Roads = {
	{ "BELLATO_HQ",        "ELAN_WEST"           },
	{ "ACCRETIA_HQ",       "ELAN_EAST"           },
	{ "CORA_HQ",           "ELAN_SOUTH"          },
	{ "ELAN_WEST",         "NOVUS_NORTHWEST"     },
	{ "ELAN_EAST",         "NOVUS_NORTHEAST"     },
	{ "ELAN_SOUTH",        "NOVUS_SOUTH"         },
	{ "NOVUS_NORTHWEST",   "NOVUS_CENTER"        },
	{ "NOVUS_NORTHEAST",   "NOVUS_CENTER"        },
	{ "NOVUS_SOUTH",       "NOVUS_CENTER"        },
	{ "NOVUS_CENTER",      "CHIP_MINE_APPROACH"  },
	{ "CHIP_MINE_APPROACH","CHIP_MINE_CORE"      },
}

-- Spawn positions per ras (digunakan GameServer untuk teleport respawn)
MapDefinitions.RaceSpawn = {
	Bellato  = Vector3.new(-3000, 5, -2500),
	Cora     = Vector3.new(0,     5,  3500),
	Accretia = Vector3.new(3000,  5, -2500),
}

return MapDefinitions
