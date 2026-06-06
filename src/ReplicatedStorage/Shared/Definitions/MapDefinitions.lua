-- MapDefinitions.lua
-- Semua zone RF Classic Phase 1 (Level cap 50) berdasarkan peta resmi.
--
-- Layout Roblox (Y=0 = ground, Z negatif = utara):
--
--         [SETTE DESERT]        [PLATFORM ETHER (tinggi Y=400)]
--    [ARM.117]  [CRAG MINE]  [ARM.213]
-- [BELLATO]  [SHARED NEUTRAL]  [ACCRETIA]
--                [CORA]
--
-- Koordinat mengikuti skala: 1 stud ≈ 1 unit jarak RF Classic
-- Map total ± 14000 x 14000 studs

local MapDefinitions = {}

MapDefinitions.MAP_HALF  = 7000
MapDefinitions.GROUND_Y  = 0
MapDefinitions.TERRAIN_DEPTH = 30

-- ============================================================
-- ZONES
-- Radius = radius zona dalam studs (bola 2D, deteksi ZoneService)
-- SafeZone = tidak bisa di-PK
-- PvP = serangan antar player diizinkan
-- Race = "Bellato"|"Cora"|"Accretia"|nil (nil = netral)
-- ============================================================
MapDefinitions.Zones = {

	-- ═══════════════════════════════════════════════════════
	-- BELLATO-OCCUPIED AREA (barat, X negatif)
	-- ═══════════════════════════════════════════════════════

	BELLATO_HQ = {
		Id = "BELLATO_HQ", Name = "Bellato HQ",
		Race = "Bellato", SafeZone = true, PvP = false,
		LevelRange = {1, 10},
		Center = Vector3.new(-5500, 0, 500),
		Radius = 440, SpawnPos = Vector3.new(-5500, 5, 500),
	},
	REAR_GARDEN_B = {
		Id = "REAR_GARDEN_B", Name = "Rear Garden",
		Race = "Bellato", SafeZone = false, PvP = false,
		LevelRange = {3, 8},
		Center = Vector3.new(-4900, 0, 1200), Radius = 420,
	},
	WIND_CLIFF = {
		Id = "WIND_CLIFF", Name = "Wind Cliff",
		Race = "Bellato", SafeZone = false, PvP = false,
		LevelRange = {15, 20},
		Center = Vector3.new(-4600, 0, -400), Radius = 460,
	},
	SKY_CAVE_B = {
		Id = "SKY_CAVE_B", Name = "Sky Cave",
		Race = "Bellato", SafeZone = false, PvP = false,
		LevelRange = {9, 12},
		Center = Vector3.new(-4100, 0, 300), Radius = 420,
	},
	BELLATO_CANYON = {
		Id = "BELLATO_CANYON", Name = "Bellato Canyon",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {20, 26},
		Center = Vector3.new(-3600, 0, 1500), Radius = 480,
	},
	CRAWLER_CORRIDOR = {
		Id = "CRAWLER_CORRIDOR", Name = "Crawler Corridor",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {25, 29},
		Center = Vector3.new(-3200, 0, 2400), Radius = 460,
	},
	LODE_FALLS = {
		Id = "LODE_FALLS", Name = "Lode Falls",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {27, 30},
		Center = Vector3.new(-3800, 0, 3000), Radius = 400,
	},
	DRY_MOOR_B = {
		Id = "DRY_MOOR_B", Name = "Dry Moor",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {25, 29},
		Center = Vector3.new(-2800, 0, 2800), Radius = 460,
	},
	OUTPOST_B = {
		Id = "OUTPOST_B", Name = "Outpost",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {25, 26},
		Center = Vector3.new(-2400, 0, 1000), Radius = 380,
	},
	GATEWAY_VALLEY_B = {
		Id = "GATEWAY_VALLEY_B", Name = "Gateway Valley",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {21, 24},
		Center = Vector3.new(-2000, 0, 1600), Radius = 420,
	},

	-- ═══════════════════════════════════════════════════════
	-- ACCRETIA-OCCUPIED AREA (timur, X positif)
	-- ═══════════════════════════════════════════════════════

	ACCRETIA_HQ = {
		Id = "ACCRETIA_HQ", Name = "Accretia HQ",
		Race = "Accretia", SafeZone = true, PvP = false,
		LevelRange = {1, 10},
		Center = Vector3.new(5500, 0, 500),
		Radius = 440, SpawnPos = Vector3.new(5500, 5, 500),
	},
	ARID_CAVE = {
		Id = "ARID_CAVE", Name = "Arid Cave",
		Race = "Accretia", SafeZone = false, PvP = false,
		LevelRange = {1, 6},
		Center = Vector3.new(5100, 0, -400), Radius = 360,
	},
	CRATER_DESERT = {
		Id = "CRATER_DESERT", Name = "Crater Desert",
		Race = "Accretia", SafeZone = false, PvP = false,
		LevelRange = {4, 9},
		Center = Vector3.new(4500, 0, -800), Radius = 460,
	},
	RAMBLER_LAND = {
		Id = "RAMBLER_LAND", Name = "Rambler Land",
		Race = "Accretia", SafeZone = false, PvP = false,
		LevelRange = {12, 16},
		Center = Vector3.new(3900, 0, -600), Radius = 460,
	},
	ANCIENT_PEOPLES_ALTAR = {
		Id = "ANCIENT_PEOPLES_ALTAR", Name = "Ancient People's Altar",
		Race = "Accretia", SafeZone = false, PvP = false,
		LevelRange = {17, 22},
		Center = Vector3.new(3400, 0, -200), Radius = 460,
	},
	CRATER_VALLEY = {
		Id = "CRATER_VALLEY", Name = "Crater Valley",
		Race = "Accretia", SafeZone = false, PvP = true,
		LevelRange = {23, 26},
		Center = Vector3.new(2900, 0, 600), Radius = 440,
	},
	SNATCHER_SHRINE = {
		Id = "SNATCHER_SHRINE", Name = "Snatcher Shrine",
		Race = "Accretia", SafeZone = false, PvP = true,
		LevelRange = {27, 30},
		Center = Vector3.new(3300, 0, 1400), Radius = 420,
	},
	OUTPOST_A = {
		Id = "OUTPOST_A", Name = "Outpost",
		Race = "Accretia", SafeZone = false, PvP = true,
		LevelRange = {9, 12},
		Center = Vector3.new(2500, 0, 800), Radius = 380,
	},
	GATEWAY_VALLEY_A = {
		Id = "GATEWAY_VALLEY_A", Name = "Gateway Valley",
		Race = "Accretia", SafeZone = false, PvP = true,
		LevelRange = {21, 24},
		Center = Vector3.new(2000, 0, 1600), Radius = 420,
	},

	-- ═══════════════════════════════════════════════════════
	-- CORA-OCCUPIED AREA (selatan, Z positif)
	-- ═══════════════════════════════════════════════════════

	CORA_HQ = {
		Id = "CORA_HQ", Name = "Cora HQ",
		Race = "Cora", SafeZone = true, PvP = false,
		LevelRange = {1, 10},
		Center = Vector3.new(0, 0, 5800),
		Radius = 440, SpawnPos = Vector3.new(0, 5, 5800),
	},
	SPIRE_PLAIN = {
		Id = "SPIRE_PLAIN", Name = "Spire Plain",
		Race = "Cora", SafeZone = false, PvP = false,
		LevelRange = {4, 6},
		Center = Vector3.new(800, 0, 5000), Radius = 420,
	},
	SUNNY_PLAIN = {
		Id = "SUNNY_PLAIN", Name = "Sunny Plain",
		Race = "Cora", SafeZone = false, PvP = false,
		LevelRange = {10, 16},
		Center = Vector3.new(-1000, 0, 4600), Radius = 460,
	},
	OUTPOST_C = {
		Id = "OUTPOST_C", Name = "Outpost",
		Race = "Cora", SafeZone = false, PvP = false,
		LevelRange = {17, 20},
		Center = Vector3.new(0, 0, 3800), Radius = 380,
	},
	HUNTER_CAVE = {
		Id = "HUNTER_CAVE", Name = "Hunter Cave",
		Race = "Cora", SafeZone = false, PvP = true,
		LevelRange = {20, 28},
		Center = Vector3.new(-800, 0, 3200), Radius = 460,
	},
	RED_BEACH = {
		Id = "RED_BEACH", Name = "Red Beach",
		Race = "Cora", SafeZone = false, PvP = true,
		LevelRange = {27, 28},
		Center = Vector3.new(-1800, 0, 2800), Radius = 400,
	},
	DARK_PLAIN = {
		Id = "DARK_PLAIN", Name = "Dark Plain",
		Race = "Cora", SafeZone = false, PvP = true,
		LevelRange = {21, 27},
		Center = Vector3.new(-1800, 0, 3800), Radius = 440,
	},
	SPIRE_FOREST = {
		Id = "SPIRE_FOREST", Name = "Spire Forest",
		Race = "Cora", SafeZone = false, PvP = true,
		LevelRange = {23, 26},
		Center = Vector3.new(600, 0, 3200), Radius = 420,
	},
	FOG_MARSH = {
		Id = "FOG_MARSH", Name = "Fog Marsh",
		Race = "Cora", SafeZone = false, PvP = true,
		LevelRange = {23, 30},
		Center = Vector3.new(1200, 0, 2800), Radius = 440,
	},

	-- ═══════════════════════════════════════════════════════
	-- SHARED NEUTRAL ZONES (tengah)
	-- ═══════════════════════════════════════════════════════

	-- Haram Stockade (CS1 Cora — netral semua ras)
	HARAM_STOCKADE = {
		Id = "HARAM_STOCKADE", Name = "Haram Stockade",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 35},
		Center = Vector3.new(-1800, 0, -800), Radius = 380,
	},
	CHILLY_HIGHLAND = {
		Id = "CHILLY_HIGHLAND", Name = "Chilly Highland",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 38},
		Center = Vector3.new(-2200, 0, -1200), Radius = 420,
	},
	SILENCE_MARSH = {
		Id = "SILENCE_MARSH", Name = "Silence Marsh",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 39},
		Center = Vector3.new(-1600, 0, -400), Radius = 440,
	},
	ROCKY_CAVERN = {
		Id = "ROCKY_CAVERN", Name = "Rocky Cavern",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 38},
		Center = Vector3.new(-2000, 0, -1800), Radius = 380,
	},
	SHADOW_FOREST = {
		Id = "SHADOW_FOREST", Name = "Shadow Forest",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 50},
		Center = Vector3.new(-1200, 0, -1600), Radius = 460,
	},
	CRIMSON_COAST = {
		Id = "CRIMSON_COAST", Name = "Crimson Coast",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 50},
		Center = Vector3.new(-800, 0, -2000), Radius = 440,
	},

	-- Numerus Stockade (CS2 Cora — netral semua ras)
	NUMERUS_STOCKADE = {
		Id = "NUMERUS_STOCKADE", Name = "Numerus Stockade",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 35},
		Center = Vector3.new(1800, 0, -800), Radius = 380,
	},
	NUMERUS_HIGHLAND = {
		Id = "NUMERUS_HIGHLAND", Name = "Numerus Highland",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {34, 35},
		Center = Vector3.new(2000, 0, -1200), Radius = 380,
	},
	HOLY_FOREST = {
		Id = "HOLY_FOREST", Name = "Holy Forest",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 38},
		Center = Vector3.new(2200, 0, -1600), Radius = 440,
	},
	MAZE_VALLEY = {
		Id = "MAZE_VALLEY", Name = "Maze Valley",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 38},
		Center = Vector3.new(1600, 0, -1400), Radius = 420,
	},
	DRIZZLE_VEIL = {
		Id = "DRIZZLE_VEIL", Name = "Drizzle Veil",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 41},
		Center = Vector3.new(1200, 0, -2000), Radius = 420,
	},
	VAPER_SHRINE = {
		Id = "VAPER_SHRINE", Name = "Vaper Shrine",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 41},
		Center = Vector3.new(800, 0, -2400), Radius = 400,
	},

	-- Anacaade Settlement (Bellato neutral zone)
	ANACAADE_SETTLEMENT = {
		Id = "ANACAADE_SETTLEMENT", Name = "Anacaade Settlement",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 33},
		Center = Vector3.new(-600, 0, -1200), Radius = 340,
	},
	ANACAADE_PLAIN = {
		Id = "ANACAADE_PLAIN", Name = "Anacaade Plain",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 41},
		Center = Vector3.new(-200, 0, -1800), Radius = 440,
	},
	ANACAADE_PLATEAU = {
		Id = "ANACAADE_PLATEAU", Name = "Anacaade Plateau",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 38},
		Center = Vector3.new(-400, 0, -2400), Radius = 380,
	},
	CRAWLER_HIGHLAND = {
		Id = "CRAWLER_HIGHLAND", Name = "Crawler Highland",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 36},
		Center = Vector3.new(-800, 0, -2600), Radius = 380,
	},
	THUNDER_CLIFF = {
		Id = "THUNDER_CLIFF", Name = "Thunder Cliff",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {36, 39},
		Center = Vector3.new(-400, 0, -3000), Radius = 380,
	},
	BELLATO_HIGHLANDS = {
		Id = "BELLATO_HIGHLANDS", Name = "Bellato Highlands",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 41},
		Center = Vector3.new(0, 0, -3000), Radius = 400,
	},

	-- Solus Settlement (Accretia neutral zone)
	SOLUS_SETTLEMENT = {
		Id = "SOLUS_SETTLEMENT", Name = "Solus Settlement",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 34},
		Center = Vector3.new(600, 0, -1200), Radius = 340,
	},
	GRIM_HILL = {
		Id = "GRIM_HILL", Name = "Grim Hill",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {34, 35},
		Center = Vector3.new(400, 0, -1800), Radius = 380,
	},
	ARAYAN_MOUNTAIN_RANGE = {
		Id = "ARAYAN_MOUNTAIN_RANGE", Name = "Arayan Mountain Range",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {32, 34},
		Center = Vector3.new(200, 0, -2400), Radius = 380,
	},
	SOLUS_PRAIRIE = {
		Id = "SOLUS_PRAIRIE", Name = "Solus Prairie",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 38},
		Center = Vector3.new(600, 0, -2800), Radius = 420,
	},
	CANYON_VALLEY_S = {
		Id = "CANYON_VALLEY_S", Name = "Canyon Valley",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {34, 40},
		Center = Vector3.new(400, 0, -3200), Radius = 400,
	},
	TWINS_CAVE = {
		Id = "TWINS_CAVE", Name = "Twins Cave",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 41},
		Center = Vector3.new(800, 0, -3600), Radius = 380,
	},
	CRAWLER_FOREST = {
		Id = "CRAWLER_FOREST", Name = "Crawler Forest",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 41},
		Center = Vector3.new(1000, 0, -3000), Radius = 400,
	},

	-- ═══════════════════════════════════════════════════════
	-- ARMORY 117 (AS2) — L31-40, barat laut
	-- ═══════════════════════════════════════════════════════

	ARMORY_117_SETTLEMENT = {
		Id = "ARMORY_117_SETTLEMENT", Name = "Armory 117 Settlement",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 33},
		Center = Vector3.new(-2800, 0, -3800), Radius = 340,
	},
	SOMORA_MOOR = {
		Id = "SOMORA_MOOR", Name = "Somora Moor",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 39},
		Center = Vector3.new(-3200, 0, -3200), Radius = 420,
	},
	GROUND_UNIT_HANGER = {
		Id = "GROUND_UNIT_HANGER", Name = "Ground Unit Hanger",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 40},
		Center = Vector3.new(-2800, 0, -3200), Radius = 380,
	},
	ENGINE_ROOM = {
		Id = "ENGINE_ROOM", Name = "Engine Room",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 38},
		Center = Vector3.new(-2400, 0, -3000), Radius = 380,
	},
	AIR_UNIT_HANGER = {
		Id = "AIR_UNIT_HANGER", Name = "Air Unit Hanger",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 40},
		Center = Vector3.new(-2000, 0, -3400), Radius = 400,
	},
	WAREHOUSE_117 = {
		Id = "WAREHOUSE_117", Name = "Warehouse",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {34, 35},
		Center = Vector3.new(-1800, 0, -3000), Radius = 340,
	},
	WRECKED_SHIP = {
		Id = "WRECKED_SHIP", Name = "Wrecked Ship",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 39},
		Center = Vector3.new(-1600, 0, -3600), Radius = 360,
	},
	LABORATORY_117 = {
		Id = "LABORATORY_117", Name = "Laboratory",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 40},
		Center = Vector3.new(-2600, 0, -3700), Radius = 380,
	},

	-- ═══════════════════════════════════════════════════════
	-- ARMORY 213 (AS1) — L34-42, timur laut
	-- ═══════════════════════════════════════════════════════

	ARMORY_213_SETTLEMENT = {
		Id = "ARMORY_213_SETTLEMENT", Name = "Armory 213 Settlement",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {31, 33},
		Center = Vector3.new(2800, 0, -3800), Radius = 340,
	},
	ARMORY_213_MAIN = {
		Id = "ARMORY_213_MAIN", Name = "213 Armory",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {34, 36},
		Center = Vector3.new(2400, 0, -3400), Radius = 400,
	},
	CATACOM = {
		Id = "CATACOM", Name = "Catacom",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {35, 50},
		Center = Vector3.new(2600, 0, -3800), Radius = 400,
	},
	DEATH_VALLEY = {
		Id = "DEATH_VALLEY", Name = "Death Valley",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 50},
		Center = Vector3.new(2200, 0, -3800), Radius = 380,
	},
	SNAKE_CANYON = {
		Id = "SNAKE_CANYON", Name = "Snake Canyon",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {37, 38},
		Center = Vector3.new(1800, 0, -3600), Radius = 380,
	},
	CRUEL_MOOR = {
		Id = "CRUEL_MOOR", Name = "Cruel Moor",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {38, 41},
		Center = Vector3.new(1600, 0, -3200), Radius = 400,
	},
	SNATCHER_GATE = {
		Id = "SNATCHER_GATE", Name = "Snatcher Gate",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {30, 44},
		Center = Vector3.new(2000, 0, -3400), Radius = 380,
	},

	-- ═══════════════════════════════════════════════════════
	-- CRAG MINE — Mining + PvP (L31-42), di utara center
	-- ═══════════════════════════════════════════════════════

	CRAG_MINE = {
		Id = "CRAG_MINE", Name = "Crag Mine",
		Race = nil, SafeZone = false, PvP = true, ChipWar = false,
		LevelRange = {31, 42},
		Center = Vector3.new(0, 0, -3500), Radius = 800,
		SpawnPos = Vector3.new(0, 5, -3500),
	},

	-- ═══════════════════════════════════════════════════════
	-- SETTE DESERT — Netral PvP (L25-45), utara
	-- ═══════════════════════════════════════════════════════

	SETTE_RUINS = {
		Id = "SETTE_RUINS", Name = "Sette Ruins",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {25, 29},
		Center = Vector3.new(400, 0, -5000), Radius = 380,
	},
	NADIR_PLAIN = {
		Id = "NADIR_PLAIN", Name = "Nadir Plain",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {25, 29},
		Center = Vector3.new(-600, 0, -5200), Radius = 380,
	},
	SETTE_HIGHLAND = {
		Id = "SETTE_HIGHLAND", Name = "Sette Highland",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {43, 45},
		Center = Vector3.new(800, 0, -5600), Radius = 460,
	},
	WINDY_CAVE = {
		Id = "WINDY_CAVE", Name = "Windy Cave",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {43, 45},
		Center = Vector3.new(-200, 0, -5600), Radius = 420,
	},
	THIRST_CAVE = {
		Id = "THIRST_CAVE", Name = "Thirst Cave",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {43, 45},
		Center = Vector3.new(600, 0, -5400), Radius = 380,
	},

	-- ═══════════════════════════════════════════════════════
	-- PLATFORM ETHER — L41-50, area melayang (Y tinggi)
	-- ═══════════════════════════════════════════════════════

	PLATFORM_ETHER = {
		Id = "PLATFORM_ETHER", Name = "Ether Platform",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {41, 50},
		Center = Vector3.new(0, 400, -4200),
		Radius = 1000,
		SpawnPos = Vector3.new(0, 405, -4200),
	},
	BELLATO_WHARF = {
		Id = "BELLATO_WHARF", Name = "Bellato Wharf",
		Race = "Bellato", SafeZone = false, PvP = true,
		LevelRange = {41, 44},
		Center = Vector3.new(-600, 400, -4400), Radius = 300,
	},
	ACCRETIA_WHARF = {
		Id = "ACCRETIA_WHARF", Name = "Accretia Wharf",
		Race = "Accretia", SafeZone = false, PvP = true,
		LevelRange = {41, 44},
		Center = Vector3.new(600, 400, -4400), Radius = 300,
	},
	CORA_WHARF = {
		Id = "CORA_WHARF", Name = "Cora Wharf",
		Race = "Cora", SafeZone = false, PvP = true,
		LevelRange = {41, 44},
		Center = Vector3.new(0, 400, -4600), Radius = 300,
	},
	WHITE_HALL = {
		Id = "WHITE_HALL", Name = "White Hall",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {45, 50},
		Center = Vector3.new(0, 400, -4000), Radius = 380,
	},
	FASCINATING_LAND = {
		Id = "FASCINATING_LAND", Name = "Fascinating Land",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {45, 50},
		Center = Vector3.new(600, 400, -3800), Radius = 360,
	},
	JACKS_LAND = {
		Id = "JACKS_LAND", Name = "Jack's Land",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {45, 47},
		Center = Vector3.new(-600, 400, -3800), Radius = 340,
	},

	-- ═══════════════════════════════════════════════════════
	-- CAULDRON VOLCANIC AREA — L48-57 (boss Belphegor L60)
	-- Posisi: utara jauh melewati Sette Desert (Z -6200 ke -7200)
	-- Akses via portal dari Sette Highland / Windy Cave
	-- ═══════════════════════════════════════════════════════

	ABADON_PASSAGE = {
		Id = "ABADON_PASSAGE", Name = "Abadon Passage",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {48, 49},
		Center = Vector3.new(0, 0, -6200), Radius = 380,
		SpawnPos = Vector3.new(0, 5, -6200),
	},
	ABADON_CAVE_NW = {
		Id = "ABADON_CAVE_NW", Name = "Abadon Cave",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {48, 49},
		Center = Vector3.new(-700, 0, -6500), Radius = 380,
	},
	GENIAL_SPRING = {
		Id = "GENIAL_SPRING", Name = "Genial Spring",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {49, 50},
		Center = Vector3.new(200, 0, -6500), Radius = 380,
	},
	BELPHEGOR_CASTLE = {
		Id = "BELPHEGOR_CASTLE", Name = "Belphegor Castle",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {50, 52},
		Center = Vector3.new(-400, 0, -6850), Radius = 400,
	},
	EVIL_HALL = {
		Id = "EVIL_HALL", Name = "Evil Hall",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {50, 51},
		Center = Vector3.new(300, 0, -6800), Radius = 360,
	},
	BAFER_LAKE = {
		Id = "BAFER_LAKE", Name = "Bafer Lake",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {52, 53},
		Center = Vector3.new(0, 0, -7100), Radius = 360,
	},
	HWATT_LAND = {
		Id = "HWATT_LAND", Name = "Hwatt Land",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {52, 54},
		Center = Vector3.new(-600, 0, -7200), Radius = 340,
	},
	ABADON_CAVE_E = {
		Id = "ABADON_CAVE_E", Name = "Abadon Cave",
		Race = nil, SafeZone = false, PvP = true,
		LevelRange = {52, 57},
		Center = Vector3.new(800, 0, -6700), Radius = 420,
	},
}

-- ============================================================
-- SPAWN CONFIG — monster per zone, dipakai MapGenerator
-- { DefId=string, Count=int, Spread=int }
-- ============================================================
MapDefinitions.SpawnConfig = {

	-- HQ areas (L1-3)
	BELLATO_HQ  = { {DefId="young_flem",Count=6,Spread=300}, {DefId="wing",Count=4,Spread=260}, {DefId="flem",Count=3,Spread=220} },
	CORA_HQ     = { {DefId="young_flem",Count=6,Spread=300}, {DefId="wing",Count=4,Spread=260}, {DefId="flem",Count=3,Spread=220} },
	ACCRETIA_HQ = { {DefId="young_flem",Count=6,Spread=300}, {DefId="wing",Count=4,Spread=260}, {DefId="deserklan",Count=3,Spread=220} },

	-- Bellato early
	REAR_GARDEN_B  = { {DefId="flem",Count=5,Spread=300}, {DefId="stinkbug",Count=4,Spread=280}, {DefId="flem_guard",Count=3,Spread=260} },
	WIND_CLIFF     = { {DefId="vafer_nipper",Count=5,Spread=360}, {DefId="block_lunker",Count=4,Spread=320}, {DefId="bulky_lunker",Count=3,Spread=280} },
	SKY_CAVE_B     = { {DefId="ratmoth",Count=5,Spread=300}, {DefId="klan",Count=4,Spread=280}, {DefId="lunker",Count=4,Spread=260}, {DefId="warbeast",Count=3,Spread=240} },
	BELLATO_CANYON = { {DefId="crawler_bunch",Count=6,Spread=360}, {DefId="grumble",Count=5,Spread=320}, {DefId="big_ratmoth",Count=3,Spread=280} },
	CRAWLER_CORRIDOR={ {DefId="grumble",Count=5,Spread=360}, {DefId="vafer_ruder",Count=5,Spread=320}, {DefId="grumble_hook",Count=4,Spread=280} },
	LODE_FALLS     = { {DefId="ghost",Count=4,Spread=300}, {DefId="vafer_ruder",Count=4,Spread=280}, {DefId="rigor_lapis",Count=3,Spread=260} },
	DRY_MOOR_B     = { {DefId="crawler_bunch",Count=5,Spread=360}, {DefId="grumble",Count=5,Spread=320}, {DefId="rigor_lapis",Count=4,Spread=280} },
	OUTPOST_B      = { {DefId="crawler_bunch",Count=5,Spread=280}, {DefId="grumble",Count=4,Spread=260} },
	GATEWAY_VALLEY_B={ {DefId="laya",Count=5,Spread=320}, {DefId="gaff",Count=4,Spread=300}, {DefId="argholquich",Count=3,Spread=280} },

	-- Accretia early
	ARID_CAVE      = { {DefId="young_flem",Count=5,Spread=260}, {DefId="wing",Count=4,Spread=240}, {DefId="deserklan",Count=3,Spread=220} },
	CRATER_DESERT  = { {DefId="mahr",Count=5,Spread=360}, {DefId="adult_stinkbug",Count=5,Spread=320}, {DefId="klan",Count=3,Spread=280} },
	RAMBLER_LAND   = { {DefId="boklan",Count=5,Spread=360}, {DefId="block_lunker",Count=4,Spread=320}, {DefId="snatcher_cheat",Count=3,Spread=280}, {DefId="neowarbeast",Count=3,Spread=260} },
	ANCIENT_PEOPLES_ALTAR={ {DefId="big_ratmoth",Count=4,Spread=360}, {DefId="arghol",Count=4,Spread=320}, {DefId="cannibal",Count=3,Spread=280}, {DefId="gaff_tail",Count=3,Spread=260} },
	CRATER_VALLEY  = { {DefId="lapis",Count=5,Spread=340}, {DefId="gaff",Count=4,Spread=300}, {DefId="lizard",Count=4,Spread=280} },
	SNATCHER_SHRINE= { {DefId="ghost",Count=4,Spread=320}, {DefId="grumble_hook",Count=4,Spread=280} },
	OUTPOST_A      = { {DefId="splinter",Count=4,Spread=280}, {DefId="host_mahr",Count=3,Spread=260}, {DefId="splinter_brat",Count=3,Spread=240} },
	GATEWAY_VALLEY_A={ {DefId="laya",Count=5,Spread=320}, {DefId="gaff",Count=4,Spread=300}, {DefId="argholquich",Count=3,Spread=280} },

	-- Cora early
	SPIRE_PLAIN    = { {DefId="stinkbug",Count=5,Spread=320}, {DefId="adult_stinkbug",Count=4,Spread=280}, {DefId="deserklan",Count=3,Spread=240} },
	SUNNY_PLAIN    = { {DefId="lunker",Count=4,Spread=360}, {DefId="warbeast",Count=4,Spread=320}, {DefId="block_lunker",Count=4,Spread=300}, {DefId="arghol",Count=3,Spread=260} },
	OUTPOST_C      = { {DefId="big_ratmoth",Count=4,Spread=280}, {DefId="vafer_nipper",Count=3,Spread=260} },
	HUNTER_CAVE    = { {DefId="lizard",Count=5,Spread=360}, {DefId="ops_lava",Count=5,Spread=320}, {DefId="big_ratmoth",Count=3,Spread=260} },
	RED_BEACH      = { {DefId="lizard",Count=5,Spread=300}, {DefId="ops_lava",Count=4,Spread=280} },
	DARK_PLAIN     = { {DefId="bulky_lunker",Count=4,Spread=340}, {DefId="laya",Count=4,Spread=300}, {DefId="snatcher_hurl",Count=3,Spread=280}, {DefId="ops_lava",Count=4,Spread=260} },
	SPIRE_FOREST   = { {DefId="snatcher_hurl",Count=4,Spread=320}, {DefId="tweezer",Count=4,Spread=280} },
	FOG_MARSH      = { {DefId="snatcher_hurl",Count=4,Spread=340}, {DefId="tweezer",Count=4,Spread=300}, {DefId="grumble_hook",Count=3,Spread=260}, {DefId="rigor_lapis",Count=3,Spread=240} },

	-- Haram Stockade zones
	HARAM_STOCKADE  = { {DefId="anabola_high",Count=5,Spread=280}, {DefId="villain_cannibal",Count=4,Spread=240}, {DefId="vafer_sly",Count=3,Spread=220} },
	CHILLY_HIGHLAND = { {DefId="grumble_owl",Count=5,Spread=320}, {DefId="king_tweezer",Count=4,Spread=280} },
	SILENCE_MARSH   = { {DefId="queen_crook",Count=5,Spread=340}, {DefId="armed_ghost",Count=4,Spread=300}, {DefId="robust_lava",Count=4,Spread=280}, {DefId="naiad_heller",Count=4,Spread=260} },
	ROCKY_CAVERN    = { {DefId="grumble_owl",Count=4,Spread=300}, {DefId="king_tweezer",Count=4,Spread=260} },
	SHADOW_FOREST   = { {DefId="armed_ghost",Count=4,Spread=360}, {DefId="robust_lava",Count=4,Spread=320}, {DefId="naiad_heller",Count=4,Spread=280}, {DefId="queen_crook",Count=3,Spread=260}, {DefId="mass_sandworm",Count=3,Spread=240}, {DefId="assassin_builder_a",Count=1,Spread=180} },
	CRIMSON_COAST   = { {DefId="queen_crook",Count=4,Spread=340}, {DefId="anabola_cyst",Count=3,Spread=300}, {DefId="brutal",Count=3,Spread=260}, {DefId="meat_clod",Count=3,Spread=240}, {DefId="assassin_builder_a",Count=1,Spread=160} },

	-- Numerus zones
	NUMERUS_STOCKADE = { {DefId="anabola_high",Count=4,Spread=280}, {DefId="villain_cannibal",Count=4,Spread=240}, {DefId="vafer_sly",Count=3,Spread=220} },
	NUMERUS_HIGHLAND = { {DefId="vafer_mortar",Count=4,Spread=280}, {DefId="vafer_barbar",Count=4,Spread=260}, {DefId="clod",Count=3,Spread=220} },
	HOLY_FOREST      = { {DefId="queen_crook",Count=4,Spread=340}, {DefId="anabola_cyst",Count=3,Spread=300}, {DefId="armed_ghost",Count=3,Spread=280}, {DefId="robust_lava",Count=3,Spread=260}, {DefId="naiad_heller",Count=3,Spread=240} },
	MAZE_VALLEY      = { {DefId="grumble_owl",Count=4,Spread=320}, {DefId="mass_sandworm",Count=4,Spread=280}, {DefId="king_tweezer",Count=4,Spread=260} },
	DRIZZLE_VEIL     = { {DefId="queen_crook",Count=4,Spread=320}, {DefId="anabola_cyst",Count=3,Spread=280}, {DefId="meat_clod",Count=3,Spread=260}, {DefId="brutal",Count=2,Spread=220} },
	VAPER_SHRINE     = { {DefId="queen_crook",Count=4,Spread=300}, {DefId="anabola_cyst",Count=3,Spread=260}, {DefId="mass_sandworm",Count=3,Spread=240}, {DefId="brutal",Count=2,Spread=200} },

	-- Anacaade zones
	ANACAADE_SETTLEMENT = { {DefId="crawler_cast",Count=4,Spread=260}, {DefId="crook",Count=4,Spread=240}, {DefId="hu_gaff",Count=3,Spread=220} },
	ANACAADE_PLAIN      = { {DefId="heller",Count=4,Spread=340}, {DefId="naiad_heller",Count=3,Spread=300}, {DefId="armed_ghost",Count=3,Spread=280}, {DefId="robust_lava",Count=3,Spread=260}, {DefId="brutal",Count=2,Spread=220}, {DefId="assassin_builder_a",Count=1,Spread=160} },
	ANACAADE_PLATEAU    = { {DefId="grumble_owl",Count=4,Spread=300}, {DefId="king_tweezer",Count=4,Spread=260} },
	CRAWLER_HIGHLAND    = { {DefId="armed_ghost",Count=4,Spread=300}, {DefId="robust_lava",Count=3,Spread=260} },
	THUNDER_CLIFF       = { {DefId="queen_crook",Count=4,Spread=300}, {DefId="meat_clod",Count=3,Spread=260}, {DefId="robust_lava",Count=3,Spread=240}, {DefId="mass_sandworm",Count=3,Spread=220}, {DefId="anabola_cyst",Count=2,Spread=200} },
	BELLATO_HIGHLANDS   = { {DefId="queen_crook",Count=4,Spread=320}, {DefId="meat_clod",Count=3,Spread=280}, {DefId="brutal",Count=3,Spread=260}, {DefId="mass_sandworm",Count=3,Spread=240}, {DefId="anabola_cyst",Count=2,Spread=200}, {DefId="assassin_builder_a",Count=1,Spread=160} },

	-- Solus zones
	SOLUS_SETTLEMENT     = { {DefId="crawler_cast",Count=4,Spread=260}, {DefId="crook",Count=4,Spread=240}, {DefId="hu_gaff",Count=3,Spread=220}, {DefId="heller",Count=3,Spread=200} },
	GRIM_HILL            = { {DefId="crawler_axle",Count=4,Spread=280}, {DefId="heller",Count=3,Spread=260}, {DefId="crawler_maul",Count=3,Spread=240} },
	ARAYAN_MOUNTAIN_RANGE= { {DefId="crook",Count=4,Spread=280}, {DefId="hu_gaff",Count=3,Spread=260}, {DefId="crawler_axle",Count=3,Spread=240} },
	SOLUS_PRAIRIE        = { {DefId="crawler_maul",Count=4,Spread=320}, {DefId="mass_sandworm",Count=4,Spread=280}, {DefId="king_tweezer",Count=3,Spread=260}, {DefId="armed_ghost",Count=3,Spread=240} },
	CANYON_VALLEY_S      = { {DefId="crawler_axle",Count=4,Spread=300}, {DefId="heller",Count=3,Spread=260}, {DefId="crawler_maul",Count=3,Spread=240}, {DefId="queen_crook",Count=2,Spread=200}, {DefId="meat_clod",Count=2,Spread=180} },
	TWINS_CAVE           = { {DefId="king_tweezer",Count=4,Spread=280}, {DefId="queen_crook",Count=4,Spread=260}, {DefId="meat_clod",Count=3,Spread=240}, {DefId="brutal",Count=2,Spread=200} },
	CRAWLER_FOREST       = { {DefId="queen_crook",Count=4,Spread=300}, {DefId="meat_clod",Count=3,Spread=260}, {DefId="yafer_rex",Count=2,Spread=220}, {DefId="meat_clod",Count=2,Spread=200}, {DefId="brutal",Count=2,Spread=180} },

	-- Armory 117
	ARMORY_117_SETTLEMENT = { {DefId="sandworm",Count=4,Spread=260}, {DefId="crook",Count=3,Spread=240}, {DefId="hu_gaff",Count=3,Spread=220} },
	SOMORA_MOOR           = { {DefId="mass_sandworm",Count=5,Spread=320}, {DefId="king_tweezer",Count=4,Spread=280}, {DefId="naiad_heller",Count=4,Spread=260}, {DefId="anabola_cyst",Count=2,Spread=220} },
	GROUND_UNIT_HANGER    = { {DefId="armed_ghost",Count=4,Spread=300}, {DefId="robust_lava",Count=4,Spread=260}, {DefId="naiad_heller",Count=3,Spread=240}, {DefId="queen_crook",Count=2,Spread=200}, {DefId="brutal",Count=2,Spread=180} },
	ENGINE_ROOM           = { {DefId="armed_ghost",Count=4,Spread=280}, {DefId="robust_lava",Count=4,Spread=260}, {DefId="naiad_heller",Count=3,Spread=240}, {DefId="grumble_owl",Count=3,Spread=220}, {DefId="mass_sandworm",Count=3,Spread=200} },
	AIR_UNIT_HANGER       = { {DefId="mass_sandworm",Count=4,Spread=300}, {DefId="king_tweezer",Count=4,Spread=260}, {DefId="queen_crook",Count=3,Spread=240}, {DefId="brutal",Count=3,Spread=220}, {DefId="naiad_heller",Count=3,Spread=200}, {DefId="anabola_cyst",Count=2,Spread=180} },
	WAREHOUSE_117         = { {DefId="snatcher_bite",Count=4,Spread=260}, {DefId="snatcher_horn",Count=4,Spread=240}, {DefId="elder_lizard",Count=3,Spread=220} },
	WRECKED_SHIP          = { {DefId="grumble_owl",Count=4,Spread=280}, {DefId="mass_sandworm",Count=4,Spread=260}, {DefId="king_tweezer",Count=3,Spread=240}, {DefId="meat_clod",Count=3,Spread=220} },
	LABORATORY_117        = { {DefId="queen_crook",Count=4,Spread=280}, {DefId="brutal",Count=3,Spread=260}, {DefId="armed_ghost",Count=3,Spread=240} },

	-- Armory 213
	ARMORY_213_SETTLEMENT = { {DefId="sandworm",Count=4,Spread=260}, {DefId="crook",Count=3,Spread=240}, {DefId="hu_gaff",Count=3,Spread=220} },
	ARMORY_213_MAIN       = { {DefId="snatcher_bite",Count=4,Spread=300}, {DefId="snatcher_horn",Count=4,Spread=280}, {DefId="elder_lizard",Count=3,Spread=260}, {DefId="armed_ghost",Count=3,Spread=240}, {DefId="robust_lava",Count=3,Spread=220}, {DefId="naiad_heller",Count=3,Spread=200} },
	CATACOM               = { {DefId="queen_crook",Count=4,Spread=300}, {DefId="king_tweezer",Count=4,Spread=280}, {DefId="brutal",Count=3,Spread=260}, {DefId="armed_ghost",Count=3,Spread=240}, {DefId="naiad_heller",Count=3,Spread=220}, {DefId="mass_sandworm",Count=2,Spread=200}, {DefId="assassin_builder_a",Count=1,Spread=160} },
	DEATH_VALLEY          = { {DefId="mass_sandworm",Count=4,Spread=300}, {DefId="queen_crook",Count=3,Spread=280}, {DefId="king_tweezer",Count=3,Spread=260}, {DefId="brutal",Count=3,Spread=240}, {DefId="anabola_cyst",Count=2,Spread=200}, {DefId="meat_clod",Count=2,Spread=180}, {DefId="assassin_builder_a",Count=1,Spread=140} },
	SNAKE_CANYON          = { {DefId="grumble_owl",Count=4,Spread=280}, {DefId="mass_sandworm",Count=4,Spread=260}, {DefId="king_tweezer",Count=3,Spread=240} },
	CRUEL_MOOR            = { {DefId="queen_crook",Count=4,Spread=300}, {DefId="mass_sandworm",Count=3,Spread=260}, {DefId="anabola_cyst",Count=3,Spread=240}, {DefId="meat_clod",Count=3,Spread=220}, {DefId="robust_lava",Count=2,Spread=200}, {DefId="naiad_heller",Count=2,Spread=180} },
	SNATCHER_GATE         = { {DefId="brutal",Count=4,Spread=280}, {DefId="queen_crook",Count=3,Spread=260}, {DefId="snatcher_rex",Count=2,Spread=220}, {DefId="robust_lava",Count=3,Spread=200}, {DefId="naiad_heller",Count=2,Spread=180}, {DefId="king_tweezer",Count=2,Spread=160}, {DefId="meat_clod",Count=2,Spread=140}, {DefId="assassin_builder_a",Count=1,Spread=120} },

	-- Crag Mine
	CRAG_MINE = { {DefId="little_lazhuwardian",Count=6,Spread=600}, {DefId="lazhuwardian_warrior",Count=6,Spread=500}, {DefId="spell_lazhuwardian",Count=4,Spread=400} },

	-- Sette Desert
	SETTE_RUINS    = { {DefId="ghost",Count=4,Spread=280}, {DefId="rigor_lapis",Count=3,Spread=260} },
	NADIR_PLAIN    = { {DefId="grumble_hook",Count=4,Spread=280}, {DefId="bulky_lunker",Count=3,Spread=240} },
	SETTE_HIGHLAND = { {DefId="turncoat_desperado",Count=4,Spread=360}, {DefId="turncoat_sniper",Count=3,Spread=320}, {DefId="turncoat_gunner",Count=3,Spread=300}, {DefId="turncoat_knights",Count=2,Spread=260}, {DefId="turncoat_miler",Count=2,Spread=240} },
	WINDY_CAVE     = { {DefId="turncoat_archer",Count=4,Spread=320}, {DefId="turncoat_hunter",Count=3,Spread=300}, {DefId="turncoat_caster",Count=3,Spread=280}, {DefId="turncoat_summoner",Count=3,Spread=260}, {DefId="turncoat_champion",Count=2,Spread=240}, {DefId="turncoat_knights",Count=2,Spread=220} },
	THIRST_CAVE    = { {DefId="turncoat_gunner",Count=4,Spread=300}, {DefId="turncoat_scouter",Count=3,Spread=280}, {DefId="turncoat_destroyer",Count=3,Spread=260}, {DefId="turncoat_gladius",Count=2,Spread=240} },

	-- Platform Ether
	BELLATO_WHARF  = { {DefId="hobo_sword",Count=4,Spread=220}, {DefId="hobo_mite",Count=3,Spread=200} },
	ACCRETIA_WHARF = { {DefId="hobo_sword",Count=4,Spread=220}, {DefId="hobo_mite",Count=3,Spread=200} },
	CORA_WHARF     = { {DefId="hobo_sword",Count=4,Spread=220}, {DefId="hobo_mite",Count=3,Spread=200} },
	WHITE_HALL     = { {DefId="calliana_crue",Count=4,Spread=280}, {DefId="calliana_atroc",Count=3,Spread=260}, {DefId="hobo_blade",Count=3,Spread=240}, {DefId="passer",Count=2,Spread=200}, {DefId="calliana_princess",Count=1,Spread=150} },
	FASCINATING_LAND={ {DefId="calliana_princess",Count=3,Spread=260}, {DefId="calliana_crue",Count=3,Spread=240}, {DefId="calliana_atroc",Count=3,Spread=220}, {DefId="calliana_archer",Count=2,Spread=200}, {DefId="assassin_builder_b",Count=1,Spread=140} },
	JACKS_LAND     = { {DefId="passer",Count=4,Spread=260}, {DefId="hobo_robber",Count=3,Spread=240}, {DefId="calliana_crue",Count=2,Spread=200}, {DefId="calliana_atroc",Count=2,Spread=180} },

	-- Cauldron Volcanic Area
	ABADON_PASSAGE   = { {DefId="infernal_demolis",Count=4,Spread=280}, {DefId="infernal_lava",Count=3,Spread=260} },
	ABADON_CAVE_NW   = { {DefId="infernal_demolis",Count=4,Spread=280}, {DefId="infernal_lava",Count=4,Spread=260} },
	GENIAL_SPRING    = { {DefId="fever_lapis",Count=4,Spread=280}, {DefId="infernal_grumble",Count=4,Spread=260} },
	BELPHEGOR_CASTLE = { {DefId="bolide",Count=4,Spread=300}, {DefId="ash",Count=4,Spread=280}, {DefId="burn_ash",Count=3,Spread=260}, {DefId="belphegor",Count=1,Spread=80} },
	EVIL_HALL        = { {DefId="infernal_grumble",Count=4,Spread=280}, {DefId="bolide",Count=4,Spread=260}, {DefId="heavy_scud",Count=3,Spread=240}, {DefId="burn_ash",Count=3,Spread=220} },
	BAFER_LAKE       = { {DefId="cur",Count=5,Spread=280}, {DefId="great_cur",Count=4,Spread=260} },
	HWATT_LAND       = { {DefId="cur",Count=4,Spread=260}, {DefId="great_cur",Count=3,Spread=240}, {DefId="granite_block",Count=2,Spread=200} },
	ABADON_CAVE_E    = { {DefId="cur",Count=4,Spread=320}, {DefId="great_cur",Count=4,Spread=280}, {DefId="granite_block",Count=3,Spread=260}, {DefId="hum_baba",Count=2,Spread=220}, {DefId="giant_baba",Count=2,Spread=200}, {DefId="infernal_draco",Count=1,Spread=160} },
}

-- Race spawn positions (dipakai GameServer)
MapDefinitions.RaceSpawn = {
	Bellato  = Vector3.new(-5500, 5,  500),
	Cora     = Vector3.new(    0, 5, 5800),
	Accretia = Vector3.new( 5500, 5,  500),
}

return MapDefinitions
