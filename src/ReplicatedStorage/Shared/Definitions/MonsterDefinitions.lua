-- MonsterDefinitions.lua
-- Batch 4: Definisi semua monster Phase 1 (Level 1-50)
-- Nama monster mengacu RF Classic (Anabola, Warbeast, dll) sesuai memory rf_items_database.md
--
-- Fields per monster:
--   Id          = unique string identifier
--   Name        = display name
--   Level       = monster level (menentukan EXP dan item yang bisa drop)
--   MaxHP       = maximum HP
--   Attack      = base attack damage
--   Defense     = base defense
--   MoveSpeed   = movement speed studs/sec
--   AggroRadius = radius deteksi player (studs)
--   AttackRange = jarak serangan melee (studs)
--   AttackDelay = detik antar serangan
--   LeashRadius = jarak max dari spawn sebelum reset aggro
--   ExpReward   = EXP diberikan saat mati
--   GoldMin/Max = range gold drop
--   DropTable   = { { ItemId=string, Chance=0-1, MinQty=1, MaxQty=1 } }
--   RespawnTime = detik sebelum respawn

local MonsterDefinitions = {}

-- ============================================================
-- LEVEL 1-10 — Near HQ / Starter Zone
-- ============================================================

MonsterDefinitions["anabola"] = {
	Id          = "anabola",
	Name        = "Anabola",
	Level       = 3,
	MaxHP       = 80,
	Attack      = 8,
	Defense     = 3,
	MoveSpeed   = 8,
	AggroRadius = 12,
	AttackRange = 4,
	AttackDelay = 2.0,
	LeashRadius = 40,
	ExpReward   = 15,
	GoldMin = 2, GoldMax = 5,
	RespawnTime = 30,
	DropTable   = {},
}

MonsterDefinitions["frog"] = {
	Id          = "frog",
	Name        = "Frog",
	Level       = 5,
	MaxHP       = 110,
	Attack      = 12,
	Defense     = 4,
	MoveSpeed   = 9,
	AggroRadius = 10,
	AttackRange = 4,
	AttackDelay = 2.0,
	LeashRadius = 40,
	ExpReward   = 25,
	GoldMin = 3, GoldMax = 7,
	RespawnTime = 30,
	DropTable   = {},
}

MonsterDefinitions["tweezer"] = {
	Id          = "tweezer",
	Name        = "Tweezer",
	Level       = 7,
	MaxHP       = 150,
	Attack      = 16,
	Defense     = 6,
	MoveSpeed   = 10,
	AggroRadius = 12,
	AttackRange = 4,
	AttackDelay = 2.5,
	LeashRadius = 45,
	ExpReward   = 38,
	GoldMin = 4, GoldMax = 10,
	RespawnTime = 35,
	DropTable   = {},
}

MonsterDefinitions["splinter"] = {
	Id          = "splinter",
	Name        = "Splinter",
	Level       = 10,
	MaxHP       = 210,
	Attack      = 22,
	Defense     = 9,
	MoveSpeed   = 9,
	AggroRadius = 14,
	AttackRange = 5,
	AttackDelay = 2.5,
	LeashRadius = 50,
	ExpReward   = 60,
	GoldMin = 6, GoldMax = 15,
	RespawnTime = 40,
	DropTable   = {},
}

-- ============================================================
-- LEVEL 11-20 — Mid Starter Zone
-- ============================================================

MonsterDefinitions["warbeast"] = {
	Id          = "warbeast",
	Name        = "Warbeast",
	Level       = 15,
	MaxHP       = 330,
	Attack      = 35,
	Defense     = 14,
	MoveSpeed   = 11,
	AggroRadius = 16,
	AttackRange = 5,
	AttackDelay = 2.5,
	LeashRadius = 55,
	ExpReward   = 110,
	GoldMin = 10, GoldMax = 25,
	RespawnTime = 45,
	DropTable   = {},
}

-- ============================================================
-- LEVEL 21-35 — Mid Zone (Haram/213 area equivalents)
-- ============================================================

MonsterDefinitions["snatcher"] = {
	Id          = "snatcher",
	Name        = "Snatcher",
	Level       = 22,
	MaxHP       = 490,
	Attack      = 52,
	Defense     = 20,
	MoveSpeed   = 10,
	AggroRadius = 14,
	AttackRange = 5,
	AttackDelay = 3.0,
	LeashRadius = 60,
	ExpReward   = 180,
	GoldMin = 18, GoldMax = 40,
	RespawnTime = 50,
	DropTable   = {},
}

MonsterDefinitions["vafer"] = {
	Id          = "vafer",
	Name        = "Vafer",
	Level       = 28,
	MaxHP       = 700,
	Attack      = 72,
	Defense     = 28,
	MoveSpeed   = 10,
	AggroRadius = 14,
	AttackRange = 5,
	AttackDelay = 3.0,
	LeashRadius = 60,
	ExpReward   = 270,
	GoldMin = 25, GoldMax = 60,
	RespawnTime = 55,
	DropTable   = {},
}

-- ============================================================
-- LEVEL 36-50 — High Zone (Ether/Elan area equivalents)
-- ============================================================

MonsterDefinitions["crawler"] = {
	Id          = "crawler",
	Name        = "Crawler",
	Level       = 35,
	MaxHP       = 960,
	Attack      = 98,
	Defense     = 38,
	MoveSpeed   = 9,
	AggroRadius = 12,
	AttackRange = 5,
	AttackDelay = 3.5,
	LeashRadius = 65,
	ExpReward   = 420,
	GoldMin = 35, GoldMax = 80,
	RespawnTime = 60,
	DropTable   = {},
}

MonsterDefinitions["high_elf_guard"] = {
	Id          = "high_elf_guard",
	Name        = "High Elf Guard",
	Level       = 45,
	MaxHP       = 1800,
	Attack      = 145,
	Defense     = 58,
	MoveSpeed   = 10,
	AggroRadius = 16,
	AttackRange = 5,
	AttackDelay = 3.0,
	LeashRadius = 70,
	ExpReward   = 900,
	GoldMin = 60, GoldMax = 130,
	RespawnTime = 70,
	DropTable   = {},
}

-- ============================================================
-- Helper Functions
-- ============================================================

function MonsterDefinitions.Get(id)
	return MonsterDefinitions[id]
end

function MonsterDefinitions.GetAll()
	local result = {}
	for _, def in pairs(MonsterDefinitions) do
		if type(def) == "table" and def.Id then
			table.insert(result, def)
		end
	end
	return result
end

return MonsterDefinitions
