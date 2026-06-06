-- MonsterDefinitions.lua
-- Semua monster RF Classic Phase 1 (Level 1-50) — nama, level, dan zona mengacu
-- screenshot peta resmi RF Classic (Bellato-occupied, Accretia-occupied, Cora-occupied,
-- Armory 117, Armory 213, Crag Mine, Sette Desert, Platform Ether, Haram/Numerus Stockade).

local MonsterDefinitions = {}

-- ── Stat scaling reference (approx RF Classic):
--   HP  ≈ 35 * Level^1.5
--   ATK ≈ 4  * Level^1.35
--   DEF ≈ Level * 1.4

local function def(id, name, level, hp, atk, defe, speed, aggro, range, delay, leash, exp, gMin, gMax, respawn, aggressive)
	MonsterDefinitions[id] = {
		Id          = id,
		Name        = name,
		Level       = level,
		MaxHP       = hp,
		Attack      = atk,
		Defense     = defe,
		MoveSpeed   = speed,
		AggroRadius = aggressive and 20 or aggro,   -- aggressive = lebih besar radius
		AttackRange = range,
		AttackDelay = delay,
		LeashRadius = leash,
		ExpReward   = exp,
		GoldMin     = gMin,
		GoldMax     = gMax,
		RespawnTime = respawn,
		Aggressive  = aggressive or false,   -- serang player tanpa diprovokasi
		DropTable   = {},
	}
end

-- =====================================================================
-- L1-3 — Near HQ (Young Flem, Wing, Flem, Deserklan)
-- =====================================================================
--                          id             name            lv  hp    atk def spd  ag  rng dly  lsh  exp   gMn gMx  resp  agg
def("young_flem",           "Young Flem",   1,  38,   4,  1,  8,  10, 4,  2.0, 30,   8,   1,  3,  25)
def("wing",                 "Wing",         2,  58,   7,  2,  9,  11, 4,  2.0, 32,  14,   2,  5,  28)
def("flem",                 "Flem",         3,  80,  10,  3, 10,  12, 4,  2.0, 35,  22,   3,  7,  30)
def("deserklan",            "Deserklan",    3,  85,  11,  3, 10,  11, 4,  2.2, 35,  24,   3,  8,  30)

-- =====================================================================
-- L4-8 — Early Zones (Stinkbug, Mahr, Klan, Adult Stinkbug, Heavy Wing)
-- =====================================================================
def("stinkbug",             "Stinkbug",     4, 115,  14,  5, 10,  12, 4,  2.2, 38,  36,   4, 10,  32)
def("flem_guard",           "Flem Guard",   5, 145,  18,  7, 10,  13, 4,  2.5, 40,  50,   5, 12,  35)
def("heavy_wing",           "Heavy Wing",   5, 135,  17,  7, 11,  13, 4,  2.5, 40,  46,   5, 12,  35)
def("adult_stinkbug",       "Adult Stinkbug",6, 165, 22,  9, 10,  14, 4,  2.5, 42,  62,   6, 15,  35)
def("demolis",              "Demolis",      6, 168,  22,  9, 10,  13, 4,  2.5, 42,  64,   6, 15,  35)
def("mahr",                 "Mahr",         6, 172,  23,  9, 10,  14, 4,  2.5, 42,  66,   6, 16,  35)
def("klan",                 "Klan",         8, 220,  29, 12, 10,  14, 5,  2.5, 45,  98,   8, 20,  38)

-- =====================================================================
-- L9-14 — Mid-Early (Lunker, Splinter, Ratmoth, Warbeast, Boklan, etc.)
-- =====================================================================
def("lunker",               "Lunker",       9, 258,  34, 14, 10,  15, 5,  2.5, 48, 130,  10, 25,  40)
def("splinter_brat",        "Splinter Brat",9, 248,  33, 14, 10,  15, 5,  2.5, 48, 124,  10, 24,  40)
def("host_mahr",            "Host Mahr",   10, 288,  38, 16, 10,  14, 5,  2.8, 50, 150,  12, 28,  42)
def("warbeast",             "Warbeast",    10, 285,  38, 16, 11,  15, 5,  2.8, 50, 148,  12, 28,  42)
def("ratmoth",              "Ratmoth",     11, 320,  43, 18, 10,  15, 5,  2.8, 52, 172,  14, 32,  42)
def("splinter",             "Splinter",    12, 355,  48, 20, 10,  15, 5,  2.8, 55, 196,  16, 36,  45)
def("snatcher_cheat",       "Snatcher Cheat",13,392, 53, 22, 10,  16, 5,  3.0, 55, 222,  18, 40,  45)
def("boklan",               "Boklan",      13, 388,  52, 22, 10,  16, 5,  3.0, 55, 218,  18, 40,  45)
def("neowarbeast",          "Neowarbeast", 14, 428,  58, 24, 11,  16, 5,  3.0, 58, 248,  20, 44,  48)

-- =====================================================================
-- L15-20 — Mid Zones (Block Lunker, Vafer Nipper, Arghol, Big Ratmoth, etc.)
-- =====================================================================
def("block_lunker",         "Block Lunker",15, 475,  64, 26, 10,  16, 5,  3.0, 58, 282,  22, 48,  48)
def("vafer_nipper",         "Vafer Nipper",16, 518,  70, 29, 11,  16, 5,  3.0, 60, 318,  24, 54,  50)
def("big_ratmoth",          "Big Ratmoth", 17, 562,  76, 31, 10,  17, 5,  3.0, 60, 358,  28, 60,  50)
def("arghol",               "Arghol",      18, 610,  83, 34, 10,  17, 5,  3.2, 62, 400,  32, 68,  50)
def("cannibal",             "Cannibal",    19, 660,  89, 37, 10,  17, 5,  3.2, 62, 445,  34, 74,  52)
def("gaff_tail",            "Gaff Tail",   20, 712,  96, 39, 10,  17, 5,  3.2, 65, 492,  38, 82,  52)
def("bulky_lunker",         "Bulky Lunker",19, 668,  90, 37, 10,  16, 5,  3.2, 62, 450,  35, 75,  52)
def("frenzy_ratmoth",       "Frenzy Ratmoth",8,2400,160, 65, 12,  22, 6,  3.0, 80,1800,  60,150,  90, true) -- Boss L8

-- =====================================================================
-- L21-26 — High Mid (Argholquich, Lapis, Snatcher Hurl, Lizard, Grumble, etc.)
-- =====================================================================
def("argholquich",          "Argholquich", 21, 770,  104, 43, 10, 17, 5,  3.2, 65, 546,  42, 88,  55)
def("lapis",                "Lapis",       22, 825,  111, 46, 10, 18, 5,  3.2, 65, 604,  45, 94,  55)
def("snatcher_hurl",        "Snatcher Hurl",22,830,  112, 46, 10, 18, 5,  3.5, 65, 608,  46, 96,  55)
def("laya",                 "Laya",        23, 882,  119, 49, 10, 17, 5,  3.5, 68, 664,  48,100,  58)
def("gaff",                 "Gaff",        24, 940,  127, 52, 10, 18, 5,  3.5, 68, 724,  52,108,  58)
def("tweezer",              "Tweezer",     24, 935,  126, 52, 10, 18, 5,  3.5, 68, 720,  52,108,  58)
def("lizard",               "Lizard",      25,1000,  135, 55, 10, 18, 5,  3.5, 70, 788,  56,116,  60)
def("grumble",              "Grumble",     25,1000,  135, 55, 10, 18, 5,  3.5, 70, 786,  56,116,  60)
def("crawler_bunch",        "Crawler Bunch",25,1010, 136, 56, 10, 18, 5,  3.5, 70, 792,  56,118,  60)
def("ops_lava",             "Ops Lava",    27,1100,  149, 61, 10, 18, 6,  3.5, 70, 900,  62,128,  62)

-- =====================================================================
-- L27-30 — Late Mid (Ghost, Vafer Ruder, Rigor Lapis, Grumble Hook, etc.)
-- =====================================================================
def("ghost",                "Ghost",       27,1110,  150, 61, 10, 18, 6,  3.5, 72, 906,  62,130,  62)
def("vafer_ruder",          "Vafer Ruder", 27,1108,  150, 61, 10, 18, 6,  3.5, 72, 904,  62,130,  62)
def("rigor_lapis",          "Rigor Lapis", 28,1160,  157, 64, 10, 17, 6,  3.5, 72, 970,  65,136,  65)
def("grumble_hook",         "Grumble Hook",28,1165,  158, 64, 10, 18, 6,  3.8, 72, 972,  65,136,  65)
def("warbeast_keen",        "Warbeast Keen",8,3200,  220, 90, 12, 24, 6,  2.8, 90,2800,  80,200,  90, true) -- Boss

-- =====================================================================
-- L31-35 — Armory / Stockade Zones
-- =====================================================================
def("sandworm",             "Sandworm",    31,1360,  185, 76, 10, 18, 6,  3.8, 75,1220,  75,155,  68)
def("crawler_cast",         "Crawler Cast",31,1360,  185, 76,  9, 18, 6,  3.8, 75,1220,  75,155,  68)
def("anabola_high",         "Anabola",     31,1355,  184, 76, 10, 18, 5,  3.8, 75,1216,  75,154,  68) -- L31 Haram Stockade
def("villain_cannibal",     "Villain Cannibal",32,1430,194, 80,  9, 18, 5, 3.8, 75,1300, 78,162,  68)
def("crook",                "Crook",       32,1425,  193, 80, 10, 18, 6,  3.8, 75,1296,  78,162,  68)
def("hu_gaff",              "Hu Gaff",     33,1505,  204, 84,  9, 18, 6,  3.8, 78,1384,  82,170,  70)
def("vafer_sly",            "Vafer Sly",   33,1500,  203, 84, 10, 18, 5,  4.0, 78,1380,  82,170,  70)
def("heller",               "Heller",      34,1585,  215, 88,  9, 18, 6,  4.0, 78,1475,  86,178,  70)
def("crawler_axle",         "Crawler Axle",34,1580,  214, 88,  9, 18, 6,  4.0, 78,1470,  86,178,  70)
def("vafer_mortar",         "Vafer Mortar",34,1580,  214, 88, 10, 18, 5,  4.0, 78,1470,  86,178,  70)
def("vafer_barbar",         "Vafer Barbar",34,1575,  213, 88, 10, 18, 5,  4.0, 78,1465,  86,176,  70)
def("clod",                 "Clod",        35,1665,  225, 92,  9, 18, 6,  4.0, 80,1570,  90,188,  72)
def("crawler_maul",         "Crawler Maul",35,1670,  226, 92,  9, 18, 6,  4.0, 80,1575,  90,188,  72)
def("armed_ghost",          "Armed Ghost", 35,1660,  225, 92, 10, 19, 6,  4.0, 80,1565,  90,186,  72)
def("snatcher_bite",        "Snatcher Bite",34,1578, 213, 88, 10, 18, 5,  4.0, 78,1468,  86,176,  70)
def("snatcher_horn",        "Snatcher Horn",34,1580, 214, 88, 10, 18, 5,  4.0, 78,1470,  86,178,  70)
def("elder_lizard",         "Elder Lizard",35,1665,  225, 92, 10, 18, 5,  4.0, 80,1570,  90,188,  72)
def("rook_snatcher",        "Rook Snatcher",8,3500,  240, 98, 11, 24, 6,  3.0, 90,3000,  90,220,  90, true) -- Boss

-- =====================================================================
-- L36-41 — Late Armory / High Stockade
-- =====================================================================
def("robust_lava",          "Robust Lava", 36,1760,  238, 98, 10, 19, 6,  4.0, 80,1680,  95,196,  72)
def("naiad_heller",         "Naiad Heller",36,1758,  238, 98,  9, 19, 6,  4.0, 80,1678,  95,196,  72)
def("grumble_owl",          "Grumble Owl", 37,1855,  251,103, 10, 19, 6,  4.2, 82,1790,  99,205,  75)
def("mass_sandworm",        "Mass Sandworm",37,1860, 252,103, 10, 19, 6,  4.2, 82,1796,  99,205,  75)
def("king_tweezer",         "King Tweezer",38,1960,  265,109, 10, 19, 5,  4.2, 82,1910, 104,215,  75)
def("queen_crook",          "Queen Crook", 38,1958,  265,109,  9, 19, 6,  4.2, 82,1908, 104,214,  75)
def("anabola_cyst",         "Anabola Cyst",39,2060,  279,115, 10, 20, 5,  4.2, 85,2035, 108,224,  78, true) -- Aggressive
def("meat_clod",            "Meat Clod",   39,2055,  278,115,  9, 20, 6,  4.2, 85,2030, 108,224,  78)
def("brutal",               "Brutal",      40,2160,  292,121,  9, 20, 6,  4.5, 85,2164, 112,232,  80)
def("lizard_khan",          "Lizard Khan", 8,4000,   280,115, 11, 24, 7,  3.0, 95,3600, 100,250, 100, true) -- Boss AS2
def("king_crook",           "King Crook",  8,4200,   290,120, 11, 24, 7,  3.0, 95,3800, 105,260, 100, true) -- Boss AS2

-- =====================================================================
-- L42-46 — Sette Desert / Platform Ether early
-- =====================================================================
def("turncoat_archer",      "Turncoat Archer",  43,2500,338,140, 10, 20, 6, 4.5, 88,2900, 130,268, 82)
def("turncoat_hunter",      "Turncoat Hunter",  43,2505,339,140, 10, 20, 6, 4.5, 88,2905, 130,268, 82)
def("turncoat_caster",      "Turncoat Caster",  43,2490,337,140, 10, 20, 6, 4.5, 88,2895, 130,266, 82)
def("turncoat_summoner",    "Turncoat Summoner",43,2495,337,140, 10, 20, 6, 4.5, 88,2900, 130,268, 82)
def("turncoat_champion",    "Turncoat Champion",43,2510,340,141, 10, 20, 6, 4.5, 88,2910, 131,270, 82)
def("turncoat_gunner",      "Turncoat Gunner",  43,2500,338,140, 12, 20, 7, 4.5, 88,2900, 130,268, 82)
def("turncoat_scouter",     "Turncoat Scouter", 43,2490,337,140, 12, 20, 7, 4.5, 88,2895, 130,266, 82)
def("turncoat_destroyer",   "Turncoat Destroyer",43,2510,340,141,10, 20, 6, 4.5, 88,2912, 131,270, 82)
def("turncoat_desperado",   "Turncoat Desperado",43,2508,339,141,10, 20, 6, 4.5, 88,2908, 131,270, 82)
def("turncoat_sniper",      "Turncoat Sniper",  43,2495,337,140, 12, 20, 8, 4.5, 88,2898, 130,268, 82)
def("turncoat_knights",     "Turncoat Knights", 45,2700,365,151, 10, 20, 6, 4.5, 90,3200, 142,293, 85)
def("turncoat_miler",       "Turncoat Miler",   45,2698,365,151, 11, 20, 6, 4.5, 90,3198, 142,293, 85)
def("turncoat_gladius",     "Turncoat Gladius", 45,2702,366,151, 10, 20, 6, 4.5, 90,3202, 142,294, 85)
def("hobo_sword",           "Hobo Sword",       41,2258,305,126, 10, 20, 6, 4.5, 87,2500, 118,244, 80, true)
def("hobo_mite",            "Hobo Mite",        41,2255,305,126, 10, 20, 5, 4.5, 87,2498, 118,243, 80, true)
def("hobo_cutter",          "Hobo Cutter",      43,2495,337,140, 10, 20, 6, 4.5, 88,2895, 130,266, 82, true)
def("hobo_turnpike",        "Hobo Turnpike",    43,2498,338,140, 10, 20, 6, 4.5, 88,2898, 130,268, 82, true)
def("passer",               "Passer",           44,2600,351,145, 11, 20, 6, 4.5, 88,3050, 136,280, 82)
def("hobo_robber",          "Hobo Robber",      45,2695,364,151, 10, 20, 6, 4.5, 90,3195, 142,292, 85)
def("hobo_blade",           "Hobo Blade",       45,2698,365,151, 10, 20, 6, 4.5, 90,3198, 142,293, 85)
def("yafer_rex",            "Yafer Rex",        44,2598,350,145,  9, 19, 6, 4.8, 88,3048, 136,279, 82)
def("snatcher_rex",         "Snatcher Rex",     44,2600,351,145, 10, 19, 5, 4.8, 88,3050, 136,280, 82)
def("fierce_snatcher_rex",  "Fierce Snatcher Rex",8,5000,360,148,11,24, 6, 3.5,100,5000, 150,320, 100, true) -- Boss

-- =====================================================================
-- L47-50 — Platform Ether endgame
-- =====================================================================
def("calliana_crue",        "Calliana Crue",    47,3000,406,168, 10, 20, 6, 4.8, 90,4200, 158,325, 88, true)
def("calliana_atroc",       "Calliana Atroc",   47,3005,407,168, 10, 20, 6, 4.8, 90,4205, 158,326, 88, true)
def("calliana_archer",      "Calliana Archer",  47,2995,405,167, 12, 20, 7, 4.8, 90,4195, 158,324, 88, true)
def("calliana_princess",    "Calliana Princess",50,4000,541,224, 11, 21, 6, 5.0, 95,8000, 200,400, 95, true)
def("assassin_builder_a",   "Assassin Builder A",50,4200,568,235,10, 22, 6, 5.0, 95,9000, 210,420, 95, true)
def("assassin_builder_b",   "Assassin Builder B",50,4500,609,252,10, 22, 6, 5.0, 95,9500, 220,440, 95, true)

-- =====================================================================
-- Crag Mine — Lazhuwardian (L31-42)
-- =====================================================================
def("little_lazhuwardian",  "Little Lazhuwardian",31,1360,185, 76, 9, 18, 5, 3.8, 75,1220, 75,155, 68)
def("lazhuwardian_warrior", "Lazhuwardian Warrior",38,1960,265,109,10, 20, 6, 4.2, 82,1910,104,215, 75)
def("spell_lazhuwardian",   "Spell Lazhuwardian",42,2380,321,133, 9, 20, 6, 4.5, 87,2850,128,264, 82)

-- =====================================================================
-- Helper
-- =====================================================================
function MonsterDefinitions.Get(id)
	return MonsterDefinitions[id]
end

function MonsterDefinitions.GetAll()
	local result = {}
	for k, v in pairs(MonsterDefinitions) do
		if type(v) == "table" and v.Id then
			table.insert(result, v)
		end
	end
	return result
end

return MonsterDefinitions
