-- MapGenerator.server.lua
-- Generate terrain, struktur HQ, area kunci, dan monster spawner.
-- Layout akurat mengacu peta resmi RF Classic:
--   Bellato (barat), Accretia (timur), Cora (selatan)
--   Crag Mine (utara tengah), Sette Desert (utara jauh)
--   Platform Ether (platform melayang), Armory 117/213 (timur/barat laut)
--   Stockade zones (Haram, Numerus, Anacaade, Solus) di tengah

local MapDefinitions = require(game.ReplicatedStorage.Shared.Definitions.MapDefinitions)

print("[MapGen] Starting map generation...")

if workspace:FindFirstChild("_MapGenerated") then
	print("[MapGen] Map already generated, skipping.")
	return
end

-- Hapus Baseplate default Roblox yang menutupi terrain
for _, name in ipairs({"Baseplate", "Base", "BasePlate"}) do
	local bp = workspace:FindFirstChild(name)
	if bp and bp:IsA("BasePart") then
		bp:Destroy()
		print("[MapGen] Removed default Baseplate:", name)
	end
end

local Terrain = workspace.Terrain
local Zones      = MapDefinitions.Zones

-- ================================================================
-- EMERGENCY SPAWN — sebelum helper functions, agar player tidak jatuh
-- saat map sedang generate
-- ================================================================
Terrain:FillBlock(CFrame.new(0, -15, 0), Vector3.new(500, 30, 500), Enum.Material.Grass)
do
	local es = Instance.new("SpawnLocation")
	es.Name = "EmergencySpawn"; es.Size = Vector3.new(8,1,8)
	es.CFrame = CFrame.new(0, 2, 0); es.Neutral = true
	es.Anchored = true
	es.BrickColor = BrickColor.new("Medium stone grey")
	es.Material = Enum.Material.SmoothPlastic
	es.Parent = workspace
end
print("[MapGen] Emergency spawn ready")
local GROUND_Y   = MapDefinitions.GROUND_Y
local DEPTH      = MapDefinitions.TERRAIN_DEPTH   -- 30
local MAP_HALF   = MapDefinitions.MAP_HALF         -- 7000

-- ================================================================
-- Helpers
-- ================================================================

local MAX_FILL = 4096  -- Roblox terrain FillBlock max per axis
local function fill(cx, cz, w, d, mat, yBase, height)
	yBase  = yBase  or GROUND_Y
	height = height or DEPTH
	if w <= MAX_FILL and d <= MAX_FILL then
		Terrain:FillBlock(
			CFrame.new(cx, yBase - height / 2, cz),
			Vector3.new(w, height, d),
			mat
		)
		return
	end
	-- Pecah jadi tiles agar tidak melebihi batas Roblox
	local tileW = math.min(w, MAX_FILL)
	local tileD = math.min(d, MAX_FILL)
	local x0 = cx - w / 2
	local z0 = cz - d / 2
	local x = x0
	while x < cx + w / 2 do
		local tw = math.min(tileW, (cx + w / 2) - x)
		local z = z0
		while z < cz + d / 2 do
			local td = math.min(tileD, (cz + d / 2) - z)
			Terrain:FillBlock(
				CFrame.new(x + tw / 2, yBase - height / 2, z + td / 2),
				Vector3.new(tw, height, td),
				mat
			)
			task.wait()  -- yield tiap tile agar tidak timeout
			z = z + tileD
		end
		x = x + tileW
	end
end

local function ball(x, y, z, radius, mat)
	Terrain:FillBall(Vector3.new(x, y, z), radius, mat)
end

local function part(parent, name, size, cf, color, mat, anchored)
	local p = Instance.new("Part")
	p.Name       = name
	p.Size       = size
	p.CFrame     = cf
	p.BrickColor = BrickColor.new(color)
	p.Material   = mat or Enum.Material.SmoothPlastic
	p.Anchored   = anchored ~= false
	p.CanCollide = true
	p.Parent     = parent
	return p
end

local function wedge(parent, name, size, cf, color, mat)
	local p = Instance.new("WedgePart")
	p.Name = name; p.Size = size; p.CFrame = cf
	p.BrickColor = BrickColor.new(color)
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Anchored = true; p.CanCollide = true
	p.Parent = parent
	return p
end

local function neonLight(parent, pos, color3, range, brightness)
	local p = Instance.new("Part")
	p.Name = "Light"; p.Size = Vector3.new(2,2,2)
	p.CFrame = CFrame.new(pos); p.Anchored = true
	p.CanCollide = false; p.Transparency = 1; p.Parent = parent
	local l = Instance.new("PointLight")
	l.Range = range or 40; l.Brightness = brightness or 1.5
	l.Color = color3; l.Parent = p
end

local function makeRoad(fromPos, toPos, width)
	width = width or 24
	local dir  = (toPos - fromPos)
	local dist = dir.Magnitude
	if dist < 1 then return end
	local mid  = (fromPos + toPos) / 2
	local ang  = math.atan2(dir.X, dir.Z)
	Terrain:FillBlock(
		CFrame.new(mid.X, GROUND_Y - 6, mid.Z) * CFrame.Angles(0, ang, 0),
		Vector3.new(width, 12, dist),
		Enum.Material.Cobblestone
	)
end

local function spawnLoc(parent, name, pos, color)
	local s = Instance.new("SpawnLocation")
	s.Name = name; s.Size = Vector3.new(8,1,8)
	s.CFrame = CFrame.new(pos); s.Neutral = true
	s.BrickColor = BrickColor.new(color)
	s.Material = Enum.Material.Neon; s.Parent = parent
end

-- ================================================================
-- STEP 1: Base Terrain
-- ================================================================
print("[MapGen] 1/10 Base terrain...")

-- Dasar besar (grass)
fill(0, 0, MAP_HALF*2, MAP_HALF*2, Enum.Material.Grass, GROUND_Y, DEPTH)
task.wait()

-- Barat laut (Armory 117) — tekstur concrete lebih industrial
fill(-2400, -3400, 3600, 2400, Enum.Material.Concrete, GROUND_Y, DEPTH)
task.wait()

-- Timur laut (Armory 213) — concrete
fill(2400, -3400, 3200, 2400, Enum.Material.Concrete, GROUND_Y, DEPTH)
task.wait()

-- Utara jauh (Sette Desert) — pasir
fill(0, -5200, 3600, 2400, Enum.Material.Sand, GROUND_Y, DEPTH)
task.wait()

-- Cauldron Volcanic Area — batu gelap + material volcanic
-- Zona Z -6000 sampai -7400, lebar 3000
fill(0, -6700, 3000, 2800, Enum.Material.Rock, GROUND_Y, DEPTH)
task.wait()
-- Lava pools di Cauldron (CrackedLava = material terrain lava)
for _, lv in ipairs({
	{-500, -6600, 200, 400}, {300, -6900, 300, 200}, {-200, -7100, 400, 200},
	{600, -6700, 200, 300}, {-600, -7000, 200, 200},
}) do
	Terrain:FillBlock(
		CFrame.new(lv[1], GROUND_Y - 2, lv[2]),
		Vector3.new(lv[3], 4, lv[4]),
		Enum.Material.CrackedLava
	)
end
task.wait()
-- Rocky hills di Cauldron
for _, h in ipairs({
	{-400, 0, -6300, 100}, {400, 0, -6300, 90},
	{-750, 0, -6600, 110}, {750, 0, -6600, 110},
	{0, 0, -7300, 120},
}) do
	ball(h[1], h[2], h[3], h[4], Enum.Material.Rock)
end
task.wait()

-- Accretia territory (timur): lebih gersang / pasir
fill(4200, 0, 5000, 5000, Enum.Material.Sand, GROUND_Y, DEPTH)
task.wait()

-- Cora territory (selatan): rawa/hijau
fill(0, 4400, 3000, 3000, Enum.Material.Grass, GROUND_Y, DEPTH)
task.wait()

-- Bellato territory (barat): padang rumput + sedikit berbatu
fill(-4200, 800, 3600, 4000, Enum.Material.Grass, GROUND_Y, DEPTH)
task.wait()

-- Neutral stockade area (tengah): batu gelap/dirt
fill(0, -800, 6000, 3000, Enum.Material.Slate, GROUND_Y, DEPTH)
task.wait()

-- Crag Mine — batu
fill(0, -3500, 2000, 1800, Enum.Material.Rock, GROUND_Y, DEPTH)
task.wait()

-- Area chip-mine approach (antara center dan crag mine)
fill(0, -1800, 2400, 2000, Enum.Material.Rock, GROUND_Y, DEPTH)
task.wait()

-- Area Haram/Numerus (tengah): sedikit lebih gelap (dirt)
fill(0, -1000, 5000, 2600, Enum.Material.Mud, GROUND_Y, DEPTH)
task.wait()

-- Platform Ether: base platform di udara (Marble = material terrain untuk platform)
local ETHER_Y = 400
Terrain:FillBlock(
	CFrame.new(0, ETHER_Y - 15, -4200),
	Vector3.new(2400, 30, 1800),
	Enum.Material.Marble
)
task.wait()

print("[MapGen] 1b/10 Batas pegunungan...")
-- Border mountains
local bh = 140
fill(0,          -MAP_HALF, MAP_HALF*2, 500, Enum.Material.Rock, GROUND_Y+bh/2, bh)
fill(0,           MAP_HALF, MAP_HALF*2, 500, Enum.Material.Rock, GROUND_Y+bh/2, bh)
fill(-MAP_HALF,  0,  500, MAP_HALF*2, Enum.Material.Rock, GROUND_Y+bh/2, bh)
fill( MAP_HALF,  0,  500, MAP_HALF*2, Enum.Material.Rock, GROUND_Y+bh/2, bh)
task.wait()

-- Hills untuk variasi terrain
local hills = {
	{-4200, 0, 1800, 160}, {-3500, 0, 2200, 130},
	{4200,  0,  800, 160}, {3600, 0,  1400, 140},
	{-800,  0,  4200, 150}, {600, 0, 4000, 130},
	{-2000, 0, -2400, 110}, {2000, 0, -2600, 110},
}
for _, h in ipairs(hills) do
	ball(h[1], h[2], h[3], h[4] or 120, Enum.Material.Rock)
	task.wait()
end

-- ================================================================
-- STEP 2: Roads
-- ================================================================
print("[MapGen] 2/10 Roads...")

-- Format: { fromCenter, toCenter, width }
local roads = {
	-- Bellato paths
	{Zones.BELLATO_HQ.Center,      Zones.REAR_GARDEN_B.Center,    22},
	{Zones.BELLATO_HQ.Center,      Zones.WIND_CLIFF.Center,       22},
	{Zones.BELLATO_HQ.Center,      Zones.SKY_CAVE_B.Center,       22},
	{Zones.SKY_CAVE_B.Center,      Zones.BELLATO_CANYON.Center,   22},
	{Zones.WIND_CLIFF.Center,      Zones.BELLATO_CANYON.Center,   20},
	{Zones.BELLATO_CANYON.Center,  Zones.CRAWLER_CORRIDOR.Center, 20},
	{Zones.BELLATO_CANYON.Center,  Zones.DRY_MOOR_B.Center,      20},
	{Zones.CRAWLER_CORRIDOR.Center,Zones.LODE_FALLS.Center,       18},
	{Zones.DRY_MOOR_B.Center,      Zones.GATEWAY_VALLEY_B.Center, 20},
	{Zones.GATEWAY_VALLEY_B.Center,Zones.OUTPOST_B.Center,        20},
	-- Bellato → neutral
	{Zones.OUTPOST_B.Center,       Zones.HARAM_STOCKADE.Center,   20},
	{Zones.GATEWAY_VALLEY_B.Center,Zones.ANACAADE_SETTLEMENT.Center,18},

	-- Accretia paths
	{Zones.ACCRETIA_HQ.Center,     Zones.ARID_CAVE.Center,        22},
	{Zones.ACCRETIA_HQ.Center,     Zones.CRATER_DESERT.Center,    22},
	{Zones.CRATER_DESERT.Center,   Zones.RAMBLER_LAND.Center,     22},
	{Zones.RAMBLER_LAND.Center,    Zones.ANCIENT_PEOPLES_ALTAR.Center,22},
	{Zones.ANCIENT_PEOPLES_ALTAR.Center,Zones.CRATER_VALLEY.Center,20},
	{Zones.CRATER_VALLEY.Center,   Zones.SNATCHER_SHRINE.Center,  20},
	{Zones.CRATER_VALLEY.Center,   Zones.GATEWAY_VALLEY_A.Center, 20},
	{Zones.GATEWAY_VALLEY_A.Center,Zones.OUTPOST_A.Center,        20},
	-- Accretia → neutral
	{Zones.OUTPOST_A.Center,       Zones.NUMERUS_STOCKADE.Center, 20},
	{Zones.GATEWAY_VALLEY_A.Center,Zones.SOLUS_SETTLEMENT.Center, 18},

	-- Cora paths
	{Zones.CORA_HQ.Center,         Zones.SPIRE_PLAIN.Center,      22},
	{Zones.CORA_HQ.Center,         Zones.SUNNY_PLAIN.Center,      22},
	{Zones.SUNNY_PLAIN.Center,     Zones.OUTPOST_C.Center,        22},
	{Zones.OUTPOST_C.Center,       Zones.HUNTER_CAVE.Center,      20},
	{Zones.HUNTER_CAVE.Center,     Zones.RED_BEACH.Center,        18},
	{Zones.HUNTER_CAVE.Center,     Zones.DARK_PLAIN.Center,       18},
	{Zones.DARK_PLAIN.Center,      Zones.FOG_MARSH.Center,        18},
	{Zones.FOG_MARSH.Center,       Zones.SPIRE_FOREST.Center,     18},
	-- Cora → neutral
	{Zones.SPIRE_FOREST.Center,    Zones.SOLUS_SETTLEMENT.Center, 18},
	{Zones.RED_BEACH.Center,       Zones.ANACAADE_SETTLEMENT.Center,18},

	-- Neutral → Armory 117
	{Zones.HARAM_STOCKADE.Center,  Zones.ARMORY_117_SETTLEMENT.Center,18},
	{Zones.ARMORY_117_SETTLEMENT.Center,Zones.WAREHOUSE_117.Center,16},
	{Zones.WAREHOUSE_117.Center,   Zones.ENGINE_ROOM.Center,      16},
	{Zones.ENGINE_ROOM.Center,     Zones.GROUND_UNIT_HANGER.Center,16},
	{Zones.GROUND_UNIT_HANGER.Center,Zones.SOMORA_MOOR.Center,    16},
	{Zones.GROUND_UNIT_HANGER.Center,Zones.LABORATORY_117.Center, 16},
	{Zones.AIR_UNIT_HANGER.Center, Zones.WRECKED_SHIP.Center,     16},

	-- Neutral → Armory 213
	{Zones.NUMERUS_STOCKADE.Center,Zones.ARMORY_213_SETTLEMENT.Center,18},
	{Zones.ARMORY_213_SETTLEMENT.Center,Zones.ARMORY_213_MAIN.Center,16},
	{Zones.ARMORY_213_MAIN.Center, Zones.CATACOM.Center,          16},
	{Zones.ARMORY_213_MAIN.Center, Zones.SNATCHER_GATE.Center,    16},
	{Zones.SNAKE_CANYON.Center,    Zones.CRUEL_MOOR.Center,       16},

	-- Neutral → Crag Mine
	{Zones.ANACAADE_PLATEAU.Center,Zones.CRAG_MINE.Center,        20},
	{Zones.BELLATO_HIGHLANDS.Center,Zones.CRAG_MINE.Center,       20},
	{Zones.CANYON_VALLEY_S.Center, Zones.CRAG_MINE.Center,        20},

	-- Crag Mine → Sette Desert
	{Zones.CRAG_MINE.Center,       Zones.SETTE_RUINS.Center,      20},
	{Zones.SETTE_RUINS.Center,     Zones.SETTE_HIGHLAND.Center,   18},
	{Zones.SETTE_RUINS.Center,     Zones.WINDY_CAVE.Center,       18},
	{Zones.THIRST_CAVE.Center,     Zones.SETTE_HIGHLAND.Center,   16},
}

for _, r in ipairs(roads) do
	makeRoad(r[1], r[2], r[3])
	task.wait()
end

-- ================================================================
-- STEP 3: Folders
-- ================================================================
print("[MapGen] 3/10 Folders...")

local worldFolder = Instance.new("Folder")
worldFolder.Name = "World"; worldFolder.Parent = workspace

local spawnerFolder = Instance.new("Folder")
spawnerFolder.Name = "MonsterSpawners"; spawnerFolder.Parent = workspace

local raceSpawnFolder = Instance.new("Folder")
raceSpawnFolder.Name = "RaceSpawns"; raceSpawnFolder.Parent = workspace

-- ================================================================
-- STEP 4: Bellato HQ
-- ================================================================
print("[MapGen] 4/10 Bellato HQ...")

local function buildBellatoHQ()
	local m = Instance.new("Model"); m.Name = "BellatoHQ"; m.Parent = worldFolder
	local cx, cy, cz = -5500, GROUND_Y, 500

	-- Palet warna RF Classic Bellato HQ
	local cream  = "Sand yellow"       -- dinding interior beige/cream
	local stone  = "Light stone grey"  -- lantai batu abu
	local dark   = "Dark stone grey"   -- trim gelap
	local black  = "Really black"      -- aksen hitam
	local grnExt = "Medium green"      -- eksterior hijau
	local grnDrk = "Sand green"        -- eksterior hijau gelap
	local red    = "Bright red"
	local dkred  = "Dark red"
	local gold   = "Bright yellow"
	local silver = "Medium stone grey"
	local steel  = "Dark stone grey"
	local beige  = "Sand yellow"       -- untuk bPavilion (jangan hapus)
	local orange = "Bright orange"     -- untuk bPavilion (jangan hapus)
	local teal   = "Teal"
	local pi     = math.pi

	local WH     = 55       -- tinggi dinding interior
	local HW     = 220      -- half-width X (menutupi NPC cx±185)
	local NZ     = cz - 170 -- Z dinding utara (330) → TETAP untuk NPC
	local FZ     = NZ + 26  -- Z referensi (untuk kompatibilitas)
	local SouthZ = cz + 210 -- Z pintu selatan (710)

	local floorCZ = (NZ + SouthZ) / 2  -- 520
	local floorD  = SouthZ - NZ + 20   -- 400

	-- ── LANTAI BATU (stone tiles, ref image 4/7) ──────────────────
	part(m,"Flr", Vector3.new(HW*2, 4, floorD),
		CFrame.new(cx, cy+2, floorCZ), stone, Enum.Material.SmoothPlastic)
	-- Grid tile lines
	for i = -4, 4 do
		part(m,"TLX"..i, Vector3.new(HW*2, 2, 3),
			CFrame.new(cx, cy+4, floorCZ + i*50), stone, Enum.Material.SmoothPlastic)
	end
	for i = -3, 3 do
		part(m,"TLZ"..i, Vector3.new(3, 2, floorD),
			CFrame.new(cx + i*62, cy+4, floorCZ), stone, Enum.Material.SmoothPlastic)
	end
	-- Border emas tepi lantai
	part(m,"BrdN", Vector3.new(HW*2+10, 3, 8), CFrame.new(cx,cy+4,NZ-4), gold, Enum.Material.SmoothPlastic)
	part(m,"BrdW", Vector3.new(8, 3, floorD+12), CFrame.new(cx-HW-4,cy+4,floorCZ), gold, Enum.Material.SmoothPlastic)
	part(m,"BrdE", Vector3.new(8, 3, floorD+12), CFrame.new(cx+HW+4,cy+4,floorCZ), gold, Enum.Material.SmoothPlastic)

	-- ── STAR MEDALLION (ref image 7 - pola bintang 8 sisi) ────────
	-- Di tengah lantai utama (antara vendor zone Z=534 dan entrance Z=710)
	local MZ = SouthZ - 110  -- 710-110=600 (tengah lantai, selatan vendor area)
	-- Gold ring border (terlihat di sekeliling background hitam)
	part(m,"MedRing", Vector3.new(172, 2, 172),
		CFrame.new(cx, cy+4.2, MZ), gold, Enum.Material.SmoothPlastic)
	part(m,"MedBg", Vector3.new(160, 2, 160),
		CFrame.new(cx, cy+4.5, MZ), black, Enum.Material.SmoothPlastic)
	for si = 0, 3 do
		local a = si * (pi/4)
		part(m,"MedRed"..si, Vector3.new(30, 3, 134),
			CFrame.new(cx, cy+5, MZ)*CFrame.Angles(0, a, 0), red, Enum.Material.SmoothPlastic)
		part(m,"MedGld"..si, Vector3.new(20, 3, 95),
			CFrame.new(cx, cy+5.4, MZ)*CFrame.Angles(0, a+pi/4, 0), gold, Enum.Material.SmoothPlastic)
	end
	part(m,"MedCirc", Vector3.new(70, 2, 70),
		CFrame.new(cx, cy+5.8, MZ), "Bright green", Enum.Material.SmoothPlastic)
	part(m,"MedCtr",  Vector3.new(40, 4, 40),
		CFrame.new(cx, cy+6, MZ), black, Enum.Material.Metal)
	part(m,"MedGlw",  Vector3.new(26, 5, 26),
		CFrame.new(cx, cy+6.5, MZ), gold, Enum.Material.Neon)
	neonLight(m, Vector3.new(cx, cy+10, MZ), Color3.fromRGB(255, 200, 0), 100, 1.5)

	-- ── DINDING INTERIOR ORNATE (cream, ref image 2/3/7) ──────────
	-- Dinding utara
	part(m,"IWN",  Vector3.new(HW*2+14, WH, 12),
		CFrame.new(cx, cy+WH/2, NZ+6), cream, Enum.Material.SmoothPlastic)
	part(m,"IWNr", Vector3.new(HW*2+14, 8, 10),
		CFrame.new(cx, cy+6, NZ+5), dkred, Enum.Material.SmoothPlastic)
	-- Dinding barat
	part(m,"IWW",  Vector3.new(12, WH, floorD+14),
		CFrame.new(cx-HW-6, cy+WH/2, floorCZ), cream, Enum.Material.SmoothPlastic)
	part(m,"IWWr", Vector3.new(10, 8, floorD+14),
		CFrame.new(cx-HW-5, cy+6, floorCZ), dkred, Enum.Material.SmoothPlastic)
	-- Dinding timur
	part(m,"IWE",  Vector3.new(12, WH, floorD+14),
		CFrame.new(cx+HW+6, cy+WH/2, floorCZ), cream, Enum.Material.SmoothPlastic)
	part(m,"IWEr", Vector3.new(10, 8, floorD+14),
		CFrame.new(cx+HW+5, cy+6, floorCZ), dkred, Enum.Material.SmoothPlastic)
	-- Cornice (molding atas dinding) - orange/copper seperti di screenshot
	part(m,"CorN", Vector3.new(HW*2+22, 8, 18),
		CFrame.new(cx, cy+WH+5, NZ+5), orange, Enum.Material.SmoothPlastic)
	part(m,"CorW", Vector3.new(18, 8, floorD+26),
		CFrame.new(cx-HW-7, cy+WH+5, floorCZ), orange, Enum.Material.SmoothPlastic)
	part(m,"CorE", Vector3.new(18, 8, floorD+26),
		CFrame.new(cx+HW+7, cy+WH+5, floorCZ), orange, Enum.Material.SmoothPlastic)
	-- Langit-langit
	part(m,"Ceil", Vector3.new(HW*2+32, 6, floorD+36),
		CFrame.new(cx, cy+WH+11, floorCZ), cream, Enum.Material.SmoothPlastic)

	-- Pilaster di dinding barat & timur (ref image 7 - flat columns)
	for pi_i = 0, 6 do
		local oz = NZ + 18 + pi_i * 56
		for _, sx in ipairs({-HW-8, HW+8}) do
			local sg = sx<0 and "W" or "E"
			part(m,"Pil"..sg..pi_i, Vector3.new(20, WH+8, 17),
				CFrame.new(cx+sx, cy+(WH+8)/2, oz), cream, Enum.Material.SmoothPlastic)
			part(m,"PilC"..sg..pi_i, Vector3.new(26, 6, 23),
				CFrame.new(cx+sx, cy+WH+7, oz), dark, Enum.Material.Metal)
			part(m,"PilB"..sg..pi_i, Vector3.new(26, 5, 23),
				CFrame.new(cx+sx, cy+3, oz), dark, Enum.Material.Metal)
			-- Sun ornament di muka interior pilaster (ref image 16 - ornamen bunga/matahari besar)
			local psX = sx < 0 and cx+sx+11 or cx+sx-11  -- muka interior pilaster
			-- Disc latar (dark brown background untuk kontras)
			part(m,"PSunBg"..sg..pi_i, Vector3.new(3, 28, 28),
				CFrame.new(psX, cy+WH*0.45, oz), dkred, Enum.Material.SmoothPlastic)
			-- 4 ray salib + diagonal = 8 sisi
			for ai = 0, 3 do
				part(m,"PSR"..sg..pi_i.."_"..ai, Vector3.new(3, 26, 7),
					CFrame.new(psX, cy+WH*0.45, oz)*CFrame.Angles(0,0,ai*pi/4),
					gold, Enum.Material.SmoothPlastic)
			end
			-- Center glowing
			part(m,"PSC"..sg..pi_i, Vector3.new(3, 9, 9),
				CFrame.new(psX, cy+WH*0.45, oz), gold, Enum.Material.Neon)
			-- Relief panel diamond antara pilasters
			if pi_i < 6 then
				local rz = oz + 28
				part(m,"PanO"..sg..pi_i, Vector3.new(7, 26, 32),
					CFrame.new(cx+sx, cy+WH*0.5, rz), dark, Enum.Material.SmoothPlastic)
				part(m,"PanI"..sg..pi_i, Vector3.new(5, 18, 22),
					CFrame.new(cx+sx, cy+WH*0.5, rz), cream, Enum.Material.SmoothPlastic)
			end
		end
	end

	-- ── KOLOM INTERIOR ORNATE (ref image 4/7) ─────────────────────
	local COLH = WH + 8   -- tinggi kolom (63)
	local COLX = 150      -- offset X dari center
	for ci = 0, 5 do
		local oz = NZ + 30 + ci * 58
		for _, sx in ipairs({-COLX, COLX}) do
			local key = (sx<0 and "W" or "E")..ci
			-- Base
			part(m,"CB"..key, Vector3.new(30, 7, 30),
				CFrame.new(cx+sx, cy+3.5, oz), stone, Enum.Material.SmoothPlastic)
			-- Shaft - stone gray (bukan cream, lebih gelap seperti di screenshot)
			part(m,"CS"..key, Vector3.new(20, COLH, 20),
				CFrame.new(cx+sx, cy+4+COLH/2, oz), stone, Enum.Material.SmoothPlastic)
			-- Capital
			part(m,"CC"..key, Vector3.new(28, 7, 28),
				CFrame.new(cx+sx, cy+COLH+7, oz), dark, Enum.Material.SmoothPlastic)
		end
	end
	task.wait()

	-- ── LAYAR HOLOGRAFIK (ref image 2/5/6 - layar biru) ──────────
	-- Posisi: 2 stud di dalam dari permukaan interior dinding supaya frame terlihat
	-- North wall interior face = NZ+12; west/east interior face = cx±220
	local function holoScreen(name, x, y, z, w, h, ry)
		local cf = CFrame.new(x, y, z)*CFrame.Angles(0, ry, 0)
		part(m,name.."F", Vector3.new(w, h, 2),     cf, dark, Enum.Material.SmoothPlastic)
		part(m,name.."S", Vector3.new(w-4, h-4, 3), cf*CFrame.new(0,0,-1), "Cyan", Enum.Material.Neon)
		neonLight(m, Vector3.new(x, y, z), Color3.fromRGB(0, 180, 255), 50, 1)
		task.wait()
	end
	-- North wall (ry=pi → frame menghadap selatan/interior)
	holoScreen("HS1", cx-130, cy+42, NZ+14, 64, 38, pi)
	holoScreen("HS2", cx+130, cy+42, NZ+14, 64, 38, pi)
	-- West wall interior face at cx-HW=cx-220; frame di cx-218 (ry=pi/2 → menghadap timur/interior)
	holoScreen("HS3", cx-HW+2, cy+40, cz-55, 58, 34, pi/2)
	holoScreen("HS4", cx-HW+2, cy+40, cz+55, 58, 34, pi/2)
	-- East wall interior face at cx+HW=cx+220; frame di cx+218 (ry=-pi/2 → menghadap barat/interior)
	holoScreen("HS5", cx+HW-2, cy+40, cz-55, 58, 34, -pi/2)
	holoScreen("HS6", cx+HW-2, cy+40, cz+55, 58, 34, -pi/2)

	-- ── DINDING EKSTERIOR HIJAU (ref image 9) ─────────────────────
	local EW  = HW + 88     -- half-width eksterior (308)
	local EH  = 36          -- tinggi dinding eksterior
	local ENZ = NZ - 88     -- batas utara eksterior (242)
	local ESZ = SouthZ + 85 -- batas selatan eksterior (795)
	local ECZ = (ENZ+ESZ)/2

	part(m,"EWN", Vector3.new(EW*2+20, EH, 16),
		CFrame.new(cx, cy+EH/2, ENZ), grnExt, Enum.Material.SmoothPlastic)
	part(m,"EWW", Vector3.new(16, EH, ESZ-ENZ),
		CFrame.new(cx-EW-8, cy+EH/2, ECZ), grnExt, Enum.Material.SmoothPlastic)
	part(m,"EWE", Vector3.new(16, EH, ESZ-ENZ),
		CFrame.new(cx+EW+8, cy+EH/2, ECZ), grnExt, Enum.Material.SmoothPlastic)
	-- Cornice eksterior
	part(m,"ECN", Vector3.new(EW*2+32, 8, 22),
		CFrame.new(cx, cy+EH+6, ENZ), grnDrk, Enum.Material.SmoothPlastic)
	part(m,"ECW", Vector3.new(22, 8, ESZ-ENZ+12),
		CFrame.new(cx-EW-7, cy+EH+6, ECZ), grnDrk, Enum.Material.SmoothPlastic)
	part(m,"ECE", Vector3.new(22, 8, ESZ-ENZ+12),
		CFrame.new(cx+EW+7, cy+EH+6, ECZ), grnDrk, Enum.Material.SmoothPlastic)
	-- Arcade arches di sisi (ref image 9)
	for ai = 0, 5 do
		local oz = ENZ + 55 + ai * 80
		for _, exWall in ipairs({{-EW-4, "W"}, {EW+4, "E"}}) do
			local bx, sg = cx+exWall[1], exWall[2]
			part(m,"Arch"..sg..ai.."L", Vector3.new(16, EH+10, 14),
				CFrame.new(bx, cy+(EH+10)/2, oz-13), grnExt, Enum.Material.SmoothPlastic)
			part(m,"Arch"..sg..ai.."R", Vector3.new(16, EH+10, 14),
				CFrame.new(bx, cy+(EH+10)/2, oz+13), grnExt, Enum.Material.SmoothPlastic)
			part(m,"Arch"..sg..ai.."T", Vector3.new(16, 12, 32),
				CFrame.new(bx, cy+EH+12, oz), grnDrk, Enum.Material.SmoothPlastic)
		end
	end
	task.wait()

	-- ── GRAND STAIRCASE (tangga luar menuju gerbang) ──────────────
	local stW   = 280
	local stepH = 5
	local stepD = 16
	local nStep = 12
	for s = 0, nStep-1 do
		part(m,"St"..s, Vector3.new(stW, stepH, stepD),
			CFrame.new(cx, cy+stepH*0.5+s*stepH, SouthZ+stepD*0.5+s*stepD),
			stone, Enum.Material.SmoothPlastic)
		part(m,"StG"..s, Vector3.new(stW+4, 2, 4),
			CFrame.new(cx, cy+stepH*(s+1), SouthZ+s*stepD), gold, Enum.Material.SmoothPlastic)
	end
	-- Stair retaining wall (segmen selatan gate, pendek)
	for s = 7, nStep-1 do
		local rh = (nStep-s)*stepH + 6
		for _, sw in ipairs({-stW/2-8, stW/2+8}) do
			part(m,"StSide"..sw.."_"..s, Vector3.new(14, rh, stepD+2),
				CFrame.new(cx+sw, cy+s*stepH+rh/2, SouthZ+stepD*0.5+s*stepD),
				grnExt, Enum.Material.SmoothPlastic)
		end
	end

	-- ── BELLATO FRONT GATE (gerbang utama selatan, ref images 1/5/8) ─
	local GZ    = ESZ              -- Z center gate = SouthZ+85 = 795
	local GD    = 32               -- kedalaman gate
	local GPILX = 84               -- offset center pilar dari cx
	local GPILW = 40               -- lebar pilar
	local GAH   = 24               -- tinggi arcade bawah
	local GOAR  = 72               -- outer arch radius (kaki di cx±~64.5)
	local GIAR  = 57               -- inner arch radius
	local GOAR2 = 48               -- inner deco arch outer radius
	local GIAR2 = 38               -- inner deco arch inner radius
	local GNSEG = 7                -- segmen per setengah
	local ARSY  = cy + GAH + 8     -- springline arch = cy+32
	local GPILH = GAH + GOAR + 12  -- tinggi pilar = 108

	-- Arch builder: semi-lingkaran, kiri+kanan sekaligus
	local function gArch(pfx, ax, sy, az, oR, iR, ns, dep, col, mat)
		local mR    = (oR + iR) * 0.5
		local thick = oR - iR
		local segA  = (pi * 0.5) / ns
		for i = 0, ns - 1 do
			local th = (i + 0.5) * segA
			local sl = mR * segA * 1.22
			local rx = mR * math.cos(th)
			local ry = mR * math.sin(th)
			part(m, pfx.."R"..i, Vector3.new(thick, sl, dep),
				CFrame.new(ax+rx, sy+ry, az) * CFrame.Angles(0, 0, -th), col, mat)
			part(m, pfx.."L"..i, Vector3.new(thick, sl, dep),
				CFrame.new(ax-rx, sy+ry, az) * CFrame.Angles(0, 0,  th), col, mat)
		end
		-- Keystone di puncak arch
		local ksL = mR * (pi * 0.5 / ns) * 1.1
		part(m, pfx.."Ks", Vector3.new(thick, ksL, dep),
			CFrame.new(ax, sy+mR, az) * CFrame.Angles(0, 0, -pi*0.5), col, mat)
	end

	-- A. PILAR UTAMA (kiri & kanan gate) ─────────────────────────
	for _, sd in ipairs({{-1,"L"},{1,"R"}}) do
		local dir, k = sd[1], sd[2]
		local px = cx + dir * GPILX
		-- Badan pilar
		part(m,"GP"..k,    Vector3.new(GPILW, GPILH, GD),
			CFrame.new(px, cy+GPILH*0.5, GZ), cream, Enum.Material.SmoothPlastic)
		-- Cap (double layer)
		part(m,"GPC"..k,   Vector3.new(GPILW+12, 9, GD+8),
			CFrame.new(px, cy+GPILH+5.5, GZ), dark, Enum.Material.SmoothPlastic)
		part(m,"GPC2"..k,  Vector3.new(GPILW+6,  5, GD+4),
			CFrame.new(px, cy+GPILH+11, GZ), grnDrk, Enum.Material.SmoothPlastic)
		-- Base (double layer)
		part(m,"GPB"..k,   Vector3.new(GPILW+12, 7, GD+8),
			CFrame.new(px, cy+4.5, GZ), dark, Enum.Material.SmoothPlastic)
		part(m,"GPB2"..k,  Vector3.new(GPILW+6,  5, GD+4),
			CFrame.new(px, cy+10.5, GZ), grnDrk, Enum.Material.SmoothPlastic)
		-- Relief strip di tengah badan pilar
		part(m,"GPRS"..k,  Vector3.new(12, GPILH-18, GD+4),
			CFrame.new(px, cy+9+(GPILH-18)*0.5, GZ), grnDrk, Enum.Material.SmoothPlastic)
		-- Sun ornament (sesuai style interior HQ)
		part(m,"GPSun"..k, Vector3.new(GD+5, 18, 18),
			CFrame.new(px, cy+GPILH*0.45, GZ), gold, Enum.Material.Neon)
	end

	-- B. SIDE WALL + BOLLARDS (pilar ke perimeter EWW/EWE) ────────
	local GpilEdge = GPILX + GPILW * 0.5   -- tepi luar pilar dari cx = 104
	local GsideLen = EW - GpilEdge - 8      -- 308-104-8 = 196
	for _, sd in ipairs({{-1,"L"},{1,"R"}}) do
		local dir, k = sd[1], sd[2]
		local wCX = cx + dir * (GpilEdge + GsideLen * 0.5)
		-- Wall body
		part(m,"GSW"..k,   Vector3.new(GsideLen, EH, GD),
			CFrame.new(wCX, cy+EH*0.5, GZ), grnExt, Enum.Material.SmoothPlastic)
		-- Cornice
		part(m,"GSWC"..k,  Vector3.new(GsideLen+8, 8, GD+10),
			CFrame.new(wCX, cy+EH+5, GZ), grnDrk, Enum.Material.SmoothPlastic)
		-- Bollards di atas wall (grup 3, setiap 26 stud)
		local bN = math.floor(GsideLen / 26)
		for bi = 0, bN-1 do
			local bx = cx + dir * (GpilEdge + 13 + bi * 26)
			for bj = -1, 1 do
				part(m,"Bll"..k..bi.."_"..bj, Vector3.new(9, 13, 9),
					CFrame.new(bx, cy+EH+7.5, GZ + bj*8),
					grnDrk, Enum.Material.SmoothPlastic)
				part(m,"BllT"..k..bi.."_"..bj, Vector3.new(11, 4, 11),
					CFrame.new(bx, cy+EH+15, GZ + bj*8),
					dark, Enum.Material.SmoothPlastic)
			end
		end
	end
	task.wait()

	-- C. ARCADE BAWAH (4 kolom slim, 3 bays) ─────────────────────
	for _, acx in ipairs({-54, -18, 18, 54}) do
		local k = "AC"..acx
		-- Base kolom
		part(m, k.."B", Vector3.new(13, 5, 13),
			CFrame.new(cx+acx, cy+3, GZ), stone, Enum.Material.SmoothPlastic)
		-- Shaft
		part(m, k.."S", Vector3.new(10, GAH-4, 10),
			CFrame.new(cx+acx, cy+5+(GAH-4)*0.5, GZ), stone, Enum.Material.SmoothPlastic)
		-- Capital
		part(m, k.."C", Vector3.new(15, 5, 15),
			CFrame.new(cx+acx, cy+GAH+0.5, GZ), dark, Enum.Material.SmoothPlastic)
	end
	-- Lintel horizontal atas arcade
	part(m,"GAcLin", Vector3.new(GPILX*2-8, 7, GD-8),
		CFrame.new(cx, cy+GAH+5.5, GZ), cream, Enum.Material.SmoothPlastic)
	-- Small arch per bay (3 arch, 4 segmen per setengah)
	for i, bmx in ipairs({cx-36, cx, cx+36}) do
		gArch("SAr"..i, bmx, cy+GAH-13, GZ, 16, 9, 4, GD-10, cream, Enum.Material.SmoothPlastic)
	end

	-- D. PLATFORM WALKWAY (di atas arcade) ────────────────────────
	part(m,"GPFlr",  Vector3.new(GPILX*2+20, 9, GD+12),
		CFrame.new(cx, ARSY+1.5, GZ), stone, Enum.Material.SmoothPlastic)
	part(m,"GPGld",  Vector3.new(GPILX*2+22, 3, GD+14),
		CFrame.new(cx, ARSY+6.5, GZ), gold, Enum.Material.SmoothPlastic)
	-- Parapet luar platform
	part(m,"GPPar",  Vector3.new(GPILX*2+10, 13, 7),
		CFrame.new(cx, ARSY+14, GZ+(GD+14)*0.5-2), cream, Enum.Material.SmoothPlastic)
	part(m,"GPParG", Vector3.new(GPILX*2+10, 3, 5),
		CFrame.new(cx, ARSY+21, GZ+(GD+14)*0.5-2), gold, Enum.Material.SmoothPlastic)
	-- Guard posts di ujung kiri & kanan platform
	for _, sx in ipairs({-(GPILX-8), (GPILX-8)}) do
		local k = sx < 0 and "L" or "R"
		part(m,"GGP"..k,    Vector3.new(22, 26, 22),
			CFrame.new(cx+sx, ARSY+14, GZ), grnExt, Enum.Material.SmoothPlastic)
		part(m,"GGPCp"..k,  Vector3.new(28, 6, 28),
			CFrame.new(cx+sx, ARSY+28, GZ), grnDrk, Enum.Material.SmoothPlastic)
		part(m,"GGPTop"..k, Vector3.new(18, 18, 18),
			CFrame.new(cx+sx, ARSY+40, GZ), cream, Enum.Material.SmoothPlastic)
		part(m,"GGPNn"..k,  Vector3.new(10, 10, 10),
			CFrame.new(cx+sx, ARSY+52, GZ), gold, Enum.Material.Neon)
		neonLight(m, Vector3.new(cx+sx, ARSY+58, GZ), Color3.fromRGB(255, 200, 0), 28, 1)
	end
	task.wait()

	-- E. ARCH UTAMA (double layer + molding luar) ─────────────────
	local archSY = ARSY + 6   -- springline final = cy+38
	-- Molding border luar (dark green, paling luar)
	gArch("OAM", cx, archSY, GZ, GOAR+6, GOAR,   GNSEG, GD+10, grnDrk, Enum.Material.SmoothPlastic)
	-- Arch utama (hijau, mengisi antara outer dan inner radius)
	gArch("OA",  cx, archSY, GZ, GOAR,   GIAR,   GNSEG, GD,    grnExt, Enum.Material.SmoothPlastic)
	-- Inner deco arch (cream, lebih kecil, di dalam)
	gArch("IA",  cx, archSY, GZ, GOAR2,  GIAR2,  GNSEG, GD-8,  cream,  Enum.Material.SmoothPlastic)

	-- F. PORTCULLIS BAR (horizontal melintang, ref images 3/4) ────
	part(m,"GBar", Vector3.new(GPILX*2-10, 7, 8),
		CFrame.new(cx, archSY + GOAR*0.38, GZ - GD*0.22), dark, Enum.Material.Metal)

	-- G. TOP CAP + CROWN FINIAL ────────────────────────────────────
	local GTopY = archSY + GOAR
	-- Cap slab lebar
	part(m,"GTCap",  Vector3.new(GPILX*2+GPILW+30, 10, GD+14),
		CFrame.new(cx, GTopY+10, GZ), grnDrk, Enum.Material.SmoothPlastic)
	part(m,"GTCap2", Vector3.new(GPILX*2+GPILW+18, 6,  GD+8),
		CFrame.new(cx, GTopY+17, GZ), dark, Enum.Material.SmoothPlastic)
	-- Crown center finial
	part(m,"GCrn",  Vector3.new(16, 22, 16),
		CFrame.new(cx, GTopY+25, GZ), grnDrk, Enum.Material.SmoothPlastic)
	part(m,"GCrnG", Vector3.new(10, 7, 10),
		CFrame.new(cx, GTopY+38, GZ), gold, Enum.Material.Neon)
	-- Neon accent
	neonLight(m, Vector3.new(cx, GTopY+12, GZ-GD*0.5), Color3.fromRGB(255, 210, 50), 100, 2.0)
	neonLight(m, Vector3.new(cx, GTopY+12, GZ+GD*0.5), Color3.fromRGB(255, 210, 50),  60, 1.5)
	task.wait()

	-- ── HALL OF FAME (ref image 9 - di luar/utara) ────────────────
	local HFX, HFZ = cx, ENZ - 45
	part(m,"HF_Plat",   Vector3.new(190, 8, 85),
		CFrame.new(HFX, cy+5, HFZ), dark, Enum.Material.Metal)
	part(m,"HF_SBase",  Vector3.new(48, 8, 48),
		CFrame.new(HFX, cy+8, HFZ), dkred, Enum.Material.Metal)
	part(m,"HF_Stat",   Vector3.new(38, 62, 38),
		CFrame.new(HFX, cy+35, HFZ), dark, Enum.Material.Metal)
	part(m,"HF_Arch",   Vector3.new(155, 30, 20),
		CFrame.new(HFX, cy+76, HFZ), dkred, Enum.Material.SmoothPlastic)
	part(m,"HF_Glow",   Vector3.new(140, 22, 10),
		CFrame.new(HFX, cy+79, HFZ), red, Enum.Material.Neon)
	for _, sx in ipairs({-70, 70}) do
		part(m,"HF_T"..sx,  Vector3.new(22, 88, 22),
			CFrame.new(HFX+sx, cy+45, HFZ), dark, Enum.Material.Metal)
		part(m,"HF_TC"..sx, Vector3.new(28, 10, 28),
			CFrame.new(HFX+sx, cy+90, HFZ), dkred, Enum.Material.Metal)
		part(m,"HF_TN"..sx, Vector3.new(18, 18, 18),
			CFrame.new(HFX+sx, cy+102, HFZ), red, Enum.Material.Neon)
		neonLight(m, Vector3.new(HFX+sx, cy+108, HFZ), Color3.fromRGB(255, 0, 0), 55, 1.5)
	end
	neonLight(m, Vector3.new(HFX, cy+72, HFZ-6), Color3.fromRGB(255, 0, 0), 90, 3)
	task.wait()

	-- ── NPC PAVILION ──────────────────────────────────────────────
	local function bPavilion(name, px, pz, col)
		part(m,name.."Plt", Vector3.new(28,3,28),  CFrame.new(px,cy+1.5,pz), silver, Enum.Material.Metal)
		for _, cor in ipairs({{8,8},{8,-8},{-8,8},{-8,-8}}) do
			part(m,name.."Col"..cor[1]..cor[2], Vector3.new(5,12,5),
				CFrame.new(px+cor[1],cy+8,pz+cor[2]), beige, Enum.Material.SmoothPlastic)
		end
		local diam = {27,22,18,12,6}
		for di, d in ipairs(diam) do
			part(m,name.."D"..di, Vector3.new(d,3,d),
				CFrame.new(px,cy+13+(di-1)*3,pz), col, Enum.Material.SmoothPlastic)
		end
	end
	-- Posisi berdasarkan rf_guide.txt grid (X Y), formula: rx=cx+(gx-19)*33, rz=NZ+(gy-19)*17
	-- Barat laut: official government
	bPavilion("RaceM",   cx-185, NZ+17,  silver) -- Eldon Carter RACEMANAGER        (13,20)
	bPavilion("Com",     cx-165, NZ+34,  silver) -- Jhan Chrisdoff committee         (14,21)
	bPavilion("Guild",   cx-99,  NZ,     silver) -- Rezzo Gihon GuildManager         (16,19)
	-- Barat: vendor belt
	bPavilion("GemArm",  cx-165, NZ+68,  red)    -- Gem Master + Nosta Bell          (14,23)
	bPavilion("TalcOre", cx-165, NZ+85,  silver) -- T-310/Reel Mars/Durba            (14,24)
	bPavilion("GateK",   cx-165, NZ+102, silver) -- Gapaeng GATEKEEPER               (14,25)
	-- Utara tengah: utility + MAU
	bPavilion("CapKpr",  cx-66,  NZ,     dark)   -- Captured Keeper                  (17,19)
	bPavilion("WpnTool", cx-66,  NZ+119, orange) -- Rockwell/Tatar/Tosca             (17,26)
	bPavilion("MAUnpc",  cx-66,  NZ+170, steel)  -- Ashton Shar MAU                  (17,29)
	-- Tengah
	bPavilion("TemplH",  cx-33,  NZ+68,  beige)  -- Temple of Honor                  (18,23)
	bPavilion("DkAmb",   cx+33,  NZ+102, dark)   -- Dark Ambassadors + Emperial Dragon(20,25)
	bPavilion("FrnVnd",  cx+33,  NZ+119, silver) -- AW63 FOREIGN VENDOR              (20,26)
	-- Timur tengah: services
	bPavilion("Misc",    cx+99,  NZ+68,  steel)  -- MISCELLANEOUS ×3                 (22,23)
	bPavilion("PtItem",  cx+66,  NZ+85,  silver) -- PointItemNPC                     (21,24)
	bPavilion("CoupM",   cx+66,  NZ+102, silver) -- CouponMan                        (21,25)
	bPavilion("Pot",     cx+66,  NZ+153, red)    -- Charlie POTION                   (21,28)
	bPavilion("Tool",    cx+66,  NZ+170, silver) -- Jun TOOL                         (21,29)
	bPavilion("Insp",    cx+66,  NZ+187, beige)  -- Honkey Inspector                 (21,30)
	-- Timur: weapon/armor/force
	bPavilion("PotFrc",  cx+165, NZ+85,  red)    -- El Luna/Honakan POTION/FORCE     (24,24)
	bPavilion("WpnE",    cx+185, NZ+51,  orange) -- Green Eye WEAPON                 (25,22)
	bPavilion("ArmE",    cx+185, NZ+68,  red)    -- Monk ARMOR                       (25,23)
	-- Selatan: vendor row dekat pintu masuk
	bPavilion("ShldRow", cx,     NZ+204, orange) -- Asehan/Caden/Carrion/Jaden/Nayan (19,31)
	bPavilion("WpnRow",  cx+33,  NZ+204, orange) -- Accloma/Draka Bell/Madison       (20,31)
	bPavilion("Aide",    cx+165, NZ+204, silver) -- Sly Aide                         (24,31)
	-- PAYBOX (luar bangunan, sebelah timur arc wall)
	bPavilion("PayBx",   cx+220, NZ+17,  steel)  -- Miti PAYBOX                      (32,20)
	task.wait()

	-- ── HUMANOID NPC (Bellato HQ, sesuai rf_guide.txt) ──────────
	local function makeNPC(npcName, designation, px, pz, shirtCol)
		local nm = Instance.new("Model"); nm.Name = npcName; nm.Parent = m
		local hrp = Instance.new("Part")
		hrp.Name = "HumanoidRootPart"
		hrp.Size = Vector3.new(2,2,1)
		hrp.CFrame = CFrame.new(px, cy+3, pz)
		hrp.Anchored = true; hrp.CanCollide = true; hrp.Transparency = 1
		hrp.Parent = nm
		local torso = Instance.new("Part")
		torso.Name = "UpperTorso"; torso.Size = Vector3.new(2,2,1)
		torso.CFrame = CFrame.new(px, cy+5, pz)
		torso.Anchored = true; torso.CanCollide = false
		torso.BrickColor = BrickColor.new(shirtCol); torso.Parent = nm
		local head = Instance.new("Part")
		head.Name = "Head"; head.Size = Vector3.new(1.5,1.5,1.5)
		head.CFrame = CFrame.new(px, cy+7, pz)
		head.Anchored = true; head.CanCollide = false
		head.BrickColor = BrickColor.new("Nougat"); head.Parent = nm
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0,180,0,44); bb.StudsOffset = Vector3.new(0,2.5,0)
		bb.AlwaysOnTop = false; bb.Adornee = head; bb.Parent = head
		local nl = Instance.new("TextLabel")
		nl.Size = UDim2.new(1,0,0.55,0); nl.BackgroundTransparency = 1
		nl.TextColor3 = Color3.new(1,1,1); nl.TextScaled = true
		nl.Font = Enum.Font.GothamBold; nl.Text = npcName; nl.Parent = bb
		local rl = Instance.new("TextLabel")
		rl.Size = UDim2.new(1,0,0.45,0); rl.Position = UDim2.new(0,0,0.55,0)
		rl.BackgroundTransparency = 1; rl.TextColor3 = Color3.fromRGB(255,220,60)
		rl.TextScaled = true; rl.Font = Enum.Font.Gotham
		rl.Text = "["..designation.."]"; rl.Parent = bb
		local hum = Instance.new("Humanoid")
		hum.MaxHealth = 100; hum.Health = 100; hum.WalkSpeed = 0; hum.JumpPower = 0
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
		hum.Parent = nm; nm.PrimaryPart = hrp
	end
	-- Barat laut: officials
	makeNPC("Eldon Carter",    "Race Manager",     cx-185, NZ+17,  "Bright blue")
	makeNPC("Jhan Chrisdoff",  "Committee",        cx-165, NZ+34,  "Bright blue")
	makeNPC("Rezzo Gihon",     "Guild Manager",    cx-99,  NZ+5,   "Bright blue")
	-- Barat: vendor belt
	makeNPC("Gem Master",      "Gem Collector",    cx-165, NZ+68,  "Sand yellow")
	makeNPC("Nosta Bell",      "Armor Type B",     cx-152, NZ+68,  "Medium stone grey")
	makeNPC("Reel Mars",       "Shield Type B",    cx-165, NZ+85,  "Medium stone grey")
	makeNPC("T-310",           "Talic Collector",  cx-152, NZ+85,  "Sand yellow")
	makeNPC("Durba",           "Ore",              cx-139, NZ+85,  "Sand yellow")
	makeNPC("Gapaeng Schirak", "Gatekeeper",       cx-165, NZ+102, "Reddish brown")
	makeNPC("Bo Hammer",       "Hero",             cx-165, NZ+119, "Bright orange")
	-- Utara: utility + MAU
	makeNPC("Captured Keeper", "Captured Keeper",  cx-66,  NZ+5,   "Dark stone grey")
	makeNPC("Rockwell",        "Weapon Type B",    cx-79,  NZ+119, "Bright red")
	makeNPC("Tatar",           "Coin Exchange",    cx-66,  NZ+119, "Sand yellow")
	makeNPC("Tosca",           "Rare Tools",       cx-53,  NZ+119, "Sand yellow")
	makeNPC("Ashton Shar",     "MAU",              cx-66,  NZ+170, "Sand blue")
	-- Tengah
	makeNPC("Temple of Honor", "Temple of Honor",  cx-33,  NZ+68,  "White")
	makeNPC("Dark Berserker",  "Dark Ambassador",  cx+20,  NZ+102, "Dark stone grey")
	makeNPC("Emperial Dragon", "Dragon Knight",    cx+46,  NZ+102, "Dark stone grey")
	makeNPC("AW63-33-7148",    "Foreign Vendor",   cx+33,  NZ+119, "Sand green")
	-- Timur: services
	makeNPC("Miscellaneous",   "Battle Dungeon",   cx+99,  NZ+68,  "Medium stone grey")
	makeNPC("PointItemNPC",    "Point Item",       cx+66,  NZ+85,  "Sand yellow")
	makeNPC("CouponMan",       "Premium Manager",  cx+66,  NZ+102, "Bright blue")
	makeNPC("Charlie",         "Potion",           cx+66,  NZ+153, "Bright red")
	makeNPC("Jun",             "Tool",             cx+66,  NZ+170, "Sand yellow")
	makeNPC("Honkey",          "Inspector",        cx+66,  NZ+187, "Bright blue")
	-- Timur: weapon/armor/force
	makeNPC("El Luna",         "Potion",           cx+165, NZ+85,  "Bright red")
	makeNPC("Honakan",         "Force",            cx+178, NZ+85,  "Sand yellow")
	makeNPC("Green Eye",       "Weapon",           cx+185, NZ+51,  "Bright red")
	makeNPC("Monk",            "Armor",            cx+185, NZ+68,  "Medium stone grey")
	-- Selatan: vendor row (pintu masuk Y=31)
	makeNPC("Asehan",          "Shield Type N",    cx-13,  NZ+204, "Medium stone grey")
	makeNPC("Caden",           "Weapon Type A",    cx,     NZ+204, "Bright red")
	makeNPC("Jaden",           "Armor Suit",       cx+13,  NZ+204, "Medium stone grey")
	makeNPC("Accloma",         "Weapon Type N",    cx+33,  NZ+204, "Bright red")
	makeNPC("Draka Bell",      "Weapon Type A",    cx+46,  NZ+204, "Bright red")
	makeNPC("Madison",         "Weapon",           cx+59,  NZ+204, "Bright red")
	makeNPC("Sly",             "Aide",             cx+165, NZ+204, "Sand yellow")
	-- Luar: PAYBOX (timur arc wall)
	makeNPC("Miti",            "Paybox",           cx+220, NZ+17,  "Bright orange")
	task.wait()



	-- ── BENDERA BELLATO ───────────────────────────────────────────
	part(m,"FPole", Vector3.new(2, 35, 2),
		CFrame.new(cx, cy+18, SouthZ-18), "Light grey", Enum.Material.Metal)
	part(m,"BFlag", Vector3.new(24, 14, 2),
		CFrame.new(cx+13, cy+33, SouthZ-18), "Bright blue", Enum.Material.SmoothPlastic)

	-- ── HERO NPC ROTUNDA (Bo Hammer, grid 14,26) ──────────────────
	local HX, HZ = cx - 165, NZ + 119
	part(m,"HPlt",  Vector3.new(66, 4, 66),
		CFrame.new(HX, cy+2, HZ), dkred, Enum.Material.SmoothPlastic)
	part(m,"HPltI", Vector3.new(47, 2, 47),
		CFrame.new(HX, cy+4.5, HZ), beige, Enum.Material.SmoothPlastic)
	part(m,"HPltG", Vector3.new(28, 1, 28),
		CFrame.new(HX, cy+6, HZ), "Bright yellow", Enum.Material.Neon)
	for hci = 0, 5 do
		local ha = hci * (pi*2/6)
		part(m,"HCol"..hci, Vector3.new(6, 15, 6),
			CFrame.new(HX+26*math.sin(ha), cy+10, HZ+26*math.cos(ha)), beige, Enum.Material.SmoothPlastic)
	end
	local hdd = {41,34,25,17,8}
	for hdi, hd in ipairs(hdd) do
		part(m,"HD"..hdi, Vector3.new(hd, 5, hd),
			CFrame.new(HX, cy+17+(hdi-1)*4, HZ), dkred, Enum.Material.SmoothPlastic)
	end
	neonLight(m, Vector3.new(HX, cy+8, HZ), Color3.fromRGB(255, 200, 0), 50, 1)
	task.wait()

	spawnLoc(raceSpawnFolder, "Bellato_Spawn", Vector3.new(cx,cy+2,cz+150), "Bright blue")
end
buildBellatoHQ(); task.wait()

-- ================================================================
-- STEP 5: Accretia HQ
-- ================================================================
print("[MapGen] 5/10 Accretia HQ...")

local function buildAccretiaHQ()
	local m = Instance.new("Model"); m.Name = "AccretiaHQ"; m.Parent = worldFolder
	local cx, cy, cz = 5500, GROUND_Y, 500

	-- Palette berdasarkan referensi RF Classic Accretia HQ:
	-- Interior: dinding krem/beige tebal, panel oval, red neon, blue window bawah
	-- Exterior: dark teal-green, hexagonal platform, tower mekanik dengan orb
	local beige  = "Tan"              -- dinding interior (cream/beige RF Classic)
	local dark   = "Dark stone grey"  -- panel gelap, detail
	local black  = "Really black"     -- trim hitam
	local red    = "Bright red"       -- semua neon merah
	local cyan   = "Cyan"             -- blue window bawah
	local teal   = "Dark teal"        -- exterior struktur
	local grey   = "Medium stone grey"-- lantai

	local N      = 24    -- polygon 24 sisi (lingkaran halus)
	local R      = 580   -- radius dome interior
	local WALL_H = 140   -- tinggi dinding
	local DISC_H = 100   -- tinggi disc dari lantai
	local DISC_R = 420   -- radius disc overhead
	local tw     = 36    -- ketebalan dinding

	-- ── LANTAI ────────────────────────────────────────────────────
	part(m,"Floor", Vector3.new(R*2+tw*2, 4, R*2+tw*2), CFrame.new(cx,cy+2,cz), grey, Enum.Material.SmoothPlastic)
	-- Concentric rings di lantai (khas RF)
	for i = 0, N-1 do
		local am = ((i+0.5)/N)*math.pi*2
		-- Ring luar
		local r1 = R - 40
		part(m,"FRO"..i, Vector3.new(2*r1*math.sin(math.pi/N)+1,2,12),
			CFrame.new(cx+r1*math.sin(am),cy+4,cz+r1*math.cos(am))*CFrame.Angles(0,-am,0), red, Enum.Material.Neon)
		-- Ring dalam
		local r2 = 260
		part(m,"FRI"..i, Vector3.new(2*r2*math.sin(math.pi/N)+1,2,7),
			CFrame.new(cx+r2*math.sin(am),cy+4,cz+r2*math.cos(am))*CFrame.Angles(0,-am,0), red, Enum.Material.Neon)
	end
	-- Center platform hexagonal (terinspirasi RF floor)
	part(m,"FloorCenter", Vector3.new(180,5,180), CFrame.new(cx,cy+4,cz), dark, Enum.Material.Metal)
	part(m,"FloorCenterRim", Vector3.new(200,2,200), CFrame.new(cx,cy+2,cz), black, Enum.Material.Metal)

	-- ── DINDING DOME (N=24 polygon, beige/cream seperti RF interior) ──
	for i = 0, N-1 do
		local am = ((i+0.5)/N)*math.pi*2
		local sl = 2*R*math.sin(math.pi/N) + 2

		-- Dinding utama beige (sama persis RF Classic interior)
		part(m,"Wall"..i, Vector3.new(sl, WALL_H, tw),
			CFrame.new(cx+R*math.sin(am), cy+WALL_H/2, cz+R*math.cos(am))*CFrame.Angles(0,-am,0),
			beige, Enum.Material.SmoothPlastic)

		-- Panel oval gelap di tiap segmen (ciri khas RF - panel oval dengan tanda merah)
		local inR = R - tw/2 - 3
		local pCF = CFrame.new(cx+inR*math.sin(am), cy+WALL_H/2+5, cz+inR*math.cos(am))*CFrame.Angles(0,-am,0)
		part(m,"WPanel"..i, Vector3.new(sl*0.7, WALL_H*0.72, 4), pCF, dark, Enum.Material.SmoothPlastic)

		-- Tanda silang merah di panel (khas Accretia HQ)
		part(m,"WMarkH"..i, Vector3.new(sl*0.42, 6, 5),
			CFrame.new(cx+inR*math.sin(am), cy+WALL_H*0.55, cz+inR*math.cos(am))*CFrame.Angles(0,-am,0),
			red, Enum.Material.Neon)
		part(m,"WMarkV"..i, Vector3.new(6, WALL_H*0.44, 5),
			CFrame.new(cx+inR*math.sin(am), cy+WALL_H*0.55, cz+inR*math.cos(am))*CFrame.Angles(0,-am,0),
			red, Enum.Material.Neon)

		-- Blue window strip bawah (persis RF - cermin biru transparan di kaki dinding)
		part(m,"WWin"..i, Vector3.new(sl-6, 28, 5),
			CFrame.new(cx+inR*math.sin(am), cy+17, cz+inR*math.cos(am))*CFrame.Angles(0,-am,0),
			cyan, Enum.Material.Neon)

		-- Trim hitam vertikal antar panel
		part(m,"WTrim"..i, Vector3.new(8, WALL_H, 5),
			CFrame.new(cx+(inR+1)*math.sin(am), cy+WALL_H/2, cz+(inR+1)*math.cos(am))*CFrame.Angles(0,-am,0),
			black, Enum.Material.SmoothPlastic)
	end

	-- ── LANGIT-LANGIT ─────────────────────────────────────────────
	part(m,"Ceiling", Vector3.new(R*2+tw*2+10, 12, R*2+tw*2+10),
		CFrame.new(cx, cy+WALL_H+6, cz), black, Enum.Material.Metal)

	-- ── KOLOM DALAM (8 pilar silindris) ───────────────────────────
	local COL_R = R - 100
	for i = 0, 7 do
		local a = (i/8)*math.pi*2
		local px, pz = cx+COL_R*math.sin(a), cz+COL_R*math.cos(a)
		-- Pilar utama (dark, industrial)
		part(m,"Col"..i,     Vector3.new(28,DISC_H+14,28), CFrame.new(px,cy+(DISC_H+14)/2,pz), dark,  Enum.Material.Metal)
		-- Ring merah di pilar (khas Accretia)
		part(m,"ColR1_"..i,  Vector3.new(36,8,36),         CFrame.new(px,cy+30,pz),             red,   Enum.Material.Neon)
		part(m,"ColR2_"..i,  Vector3.new(36,8,36),         CFrame.new(px,cy+DISC_H+16,pz),      red,   Enum.Material.Neon)
		part(m,"ColBase"..i, Vector3.new(36,4,36),         CFrame.new(px,cy+3,pz),              dark,  Enum.Material.Metal)
		neonLight(m, Vector3.new(px,cy+DISC_H+24,pz), Color3.fromRGB(220,0,0), 40, 2)
	end

	-- ── OVERHEAD DISC (struktur UFO bertingkat, ciri utama Accretia HQ) ──
	-- Berdasarkan referensi: outer rim gelap, multiple inner red rings, center merah
	-- Ring terluar (body gelap besar)
	for i = 0, N-1 do
		local am = ((i+0.5)/N)*math.pi*2
		-- Rim terluar — body tebal gelap
		local sl = 2*DISC_R*math.sin(math.pi/N) + 2
		part(m,"DR1_"..i, Vector3.new(sl,35,70),
			CFrame.new(cx+DISC_R*math.sin(am),cy+DISC_H,cz+DISC_R*math.cos(am))*CFrame.Angles(0,-am,0),
			dark, Enum.Material.Metal)
		-- Neon merah underside rim luar
		local r2 = DISC_R - 40
		part(m,"DN1_"..i, Vector3.new(2*r2*math.sin(math.pi/N)+1,14,14),
			CFrame.new(cx+r2*math.sin(am),cy+DISC_H-14,cz+r2*math.cos(am))*CFrame.Angles(0,-am,0),
			red, Enum.Material.Neon)
		-- Ring merah ke-2 (lebih dalam)
		local r3 = DISC_R - 95
		part(m,"DN2_"..i, Vector3.new(2*r3*math.sin(math.pi/N)+1,12,18),
			CFrame.new(cx+r3*math.sin(am),cy+DISC_H-20,cz+r3*math.cos(am))*CFrame.Angles(0,-am,0),
			red, Enum.Material.Neon)
		-- Ring merah ke-3 (paling dalam, glowing paling terang)
		local r4 = DISC_R - 150
		part(m,"DN3_"..i, Vector3.new(2*r4*math.sin(math.pi/N)+1,10,12),
			CFrame.new(cx+r4*math.sin(am),cy+DISC_H-24,cz+r4*math.cos(am))*CFrame.Angles(0,-am,0),
			red, Enum.Material.Neon)
	end
	-- Platform atas disc
	part(m,"DiscTop", Vector3.new((DISC_R-20)*2, 14, (DISC_R-20)*2),
		CFrame.new(cx,cy+DISC_H+8,cz), dark, Enum.Material.Metal)
	-- Core bawah disc bertingkat (glowing panas merah)
	part(m,"DCore1", Vector3.new(200,30,200), CFrame.new(cx,cy+DISC_H-5,cz),  dark, Enum.Material.Metal)
	part(m,"DCore2", Vector3.new(140,20,140), CFrame.new(cx,cy+DISC_H-12,cz), red,  Enum.Material.Neon)
	part(m,"DCore3", Vector3.new(80, 14,80),  CFrame.new(cx,cy+DISC_H-18,cz), red,  Enum.Material.Neon)
	part(m,"DCore4", Vector3.new(30, 10,30),  CFrame.new(cx,cy+DISC_H-22,cz), red,  Enum.Material.Neon)
	neonLight(m, Vector3.new(cx,cy+DISC_H,cz), Color3.fromRGB(255,0,0), 320, 4)
	-- Strut ke langit-langit (4 penopang)
	for i = 0, 3 do
		local a  = (i/4)*math.pi*2 + math.pi/4
		local sr = DISC_R - 18
		part(m,"Strut"..i, Vector3.new(14,WALL_H-DISC_H,14),
			CFrame.new(cx+sr*math.sin(a),cy+DISC_H+(WALL_H-DISC_H)/2+8,cz+sr*math.cos(a)), dark, Enum.Material.Metal)
	end

	-- ── EXTERIOR: HEXAGONAL TERMINAL PLATFORM (depan entrance) ────
	-- Berdasarkan referensi: lantai hexagonal grey, struktur teal
	local EX = cx; local EZ = cz + R + 120
	part(m,"ExtPlatBase",  Vector3.new(500,4,300),  CFrame.new(EX,cy+2,EZ+50), grey,  Enum.Material.SmoothPlastic)
	part(m,"ExtPlatTrim",  Vector3.new(510,2,310),  CFrame.new(EX,cy,EZ+50),   black, Enum.Material.Metal)
	-- Hexagonal tiles (rotated squares approximation)
	for ix = -1, 1 do for iz = -1, 1 do
		part(m,"HexTile"..ix..iz, Vector3.new(80,1,80),
			CFrame.new(EX+ix*120,cy+4,EZ+50+iz*90)*CFrame.Angles(0,math.pi/4,0), dark, Enum.Material.Metal)
	end end

	-- ── EXTERIOR: MECHANICAL TOWERS (teal, khas Accretia) ─────────
	-- Tower besar kiri dengan arm melengkung dan orb (persis referensi)
	local function accTower(name, tx, tz, h)
		part(m,name.."Base",  Vector3.new(40,h,40),    CFrame.new(tx,cy+h/2,tz),         teal,  Enum.Material.SmoothPlastic)
		part(m,name.."Cap",   Vector3.new(50,12,50),   CFrame.new(tx,cy+h+6,tz),          black, Enum.Material.Metal)
		part(m,name.."Orb",   Vector3.new(44,44,44),   CFrame.new(tx,cy+h+36,tz),         teal,  Enum.Material.SmoothPlastic)
		part(m,name.."OrbNeon",Vector3.new(20,20,20),  CFrame.new(tx,cy+h+36,tz),         red,   Enum.Material.Neon)
		-- Arm horizontal
		part(m,name.."Arm",   Vector3.new(120,14,14),  CFrame.new(tx+70,cy+h-20,tz),      teal,  Enum.Material.SmoothPlastic)
		part(m,name.."ArmTip",Vector3.new(22,50,22),   CFrame.new(tx+132,cy+h-8,tz),      teal,  Enum.Material.SmoothPlastic)
		-- Blade fins (ciri khas struktur Accretia di referensi)
		part(m,name.."Fin1",  Vector3.new(14,100,8),   CFrame.new(tx-22,cy+h-24,tz),      teal,  Enum.Material.SmoothPlastic)
		part(m,name.."Fin2",  Vector3.new(14,80,8),    CFrame.new(tx+22,cy+h-18,tz),      teal,  Enum.Material.SmoothPlastic)
		neonLight(m, Vector3.new(tx,cy+h+50,tz), Color3.fromRGB(0,200,255), 55, 1.5)
	end
	accTower("TowerL", cx-280, EZ+50, 130)
	accTower("TowerR", cx+280, EZ+50, 110)

	-- ── ENTRANCE TUNNEL (dome → exterior) ─────────────────────────
	part(m,"TunBody", Vector3.new(200,WALL_H,100),
		CFrame.new(cx,cy+WALL_H/2,cz+R+50), beige, Enum.Material.SmoothPlastic)
	part(m,"TunOpen", Vector3.new(100,110,102),
		CFrame.new(cx,cy+57,cz+R+50),       black, Enum.Material.SmoothPlastic)
	part(m,"TunNeon", Vector3.new(104,8,4),
		CFrame.new(cx,cy+114,cz+R),         red,   Enum.Material.Neon)

	-- ── WARP TERMINAL (center dome, hexagonal platform) ───────────
	part(m,"WarpPlat",  Vector3.new(90,6,90),  CFrame.new(cx,cy+5,cz)*CFrame.Angles(0,math.pi/4,0), dark, Enum.Material.Metal)
	part(m,"WarpRim",   Vector3.new(100,3,100), CFrame.new(cx,cy+3,cz)*CFrame.Angles(0,math.pi/4,0), red,  Enum.Material.Neon)
	part(m,"WarpPillar",Vector3.new(18,30,18),  CFrame.new(cx,cy+20,cz),                             dark, Enum.Material.Metal)
	part(m,"WarpCore",  Vector3.new(28,14,28),  CFrame.new(cx,cy+32,cz),                             red,  Enum.Material.Neon)
	neonLight(m, Vector3.new(cx,cy+40,cz), Color3.fromRGB(255,0,0), 110, 5)

	-- ── NPC LAYOUT (RF Classic Accretia HQ — 26 NPCs) ────────────
	local NPC_R  = R - 110   -- ring luar (dekat dinding) = 470
	local NPC_R2 = 300        -- ring dalam

	-- Terminal penting: platform hex + desk + backdrop + screen + pilar
	local function npcTerminal(name, px, pz, rotY, screenCol)
		local bCF = CFrame.new(px, cy, pz) * CFrame.Angles(0, rotY, 0)
		part(m, name.."Plat",   Vector3.new(90,6,90),  bCF*CFrame.Angles(0,math.pi/4,0)*CFrame.new(0,3,0), dark, Enum.Material.Metal)
		part(m, name.."PRim",   Vector3.new(98,2,98),  bCF*CFrame.Angles(0,math.pi/4,0)*CFrame.new(0,1,0), teal, Enum.Material.Neon)
		part(m, name.."Desk",   Vector3.new(82,22,42), bCF*CFrame.new(0,14,0),  dark, Enum.Material.Metal)
		part(m, name.."DTop",   Vector3.new(82,4,42),  bCF*CFrame.new(0,26,0),  teal, Enum.Material.SmoothPlastic)
		part(m, name.."Back",   Vector3.new(90,72,8),  bCF*CFrame.new(0,46,-30), dark, Enum.Material.SmoothPlastic)
		part(m, name.."Scr",    Vector3.new(72,52,5),  bCF*CFrame.new(0,52,-30), screenCol, Enum.Material.Neon)
		part(m, name.."PilL",   Vector3.new(8,80,8),   bCF*CFrame.new(-48,42,-30), dark, Enum.Material.Metal)
		part(m, name.."PilR",   Vector3.new(8,80,8),   bCF*CFrame.new( 48,42,-30), dark, Enum.Material.Metal)
		part(m, name.."CapL",   Vector3.new(12,12,12), bCF*CFrame.new(-48,86,-30), red, Enum.Material.Neon)
		part(m, name.."CapR",   Vector3.new(12,12,12), bCF*CFrame.new( 48,86,-30), red, Enum.Material.Neon)
		part(m, name.."Hdr",    Vector3.new(110,8,10), bCF*CFrame.new(0,86,-30),  red, Enum.Material.Neon)
		neonLight(m, (bCF*CFrame.new(0,90,-20)).Position, Color3.fromRGB(255,50,0), 40, 1.5)
	end

	-- Stall vendor sederhana: counter + sign
	local function npcStall(name, px, pz, rotY, signCol)
		local bCF = CFrame.new(px, cy, pz) * CFrame.Angles(0, rotY, 0)
		part(m, name.."Base", Vector3.new(65,4,52),  bCF*CFrame.new(0,3,0),   dark, Enum.Material.Metal)
		part(m, name.."Desk", Vector3.new(65,16,36), bCF*CFrame.new(0,12,0),  dark, Enum.Material.Metal)
		part(m, name.."Top",  Vector3.new(65,3,36),  bCF*CFrame.new(0,21,0),  teal, Enum.Material.SmoothPlastic)
		part(m, name.."Back", Vector3.new(65,36,5),  bCF*CFrame.new(0,30,-22), dark, Enum.Material.SmoothPlastic)
		part(m, name.."Sign", Vector3.new(50,24,4),  bCF*CFrame.new(0,30,-22), signCol, Enum.Material.Neon)
	end

	-- ── UTARA: NPC Resmi (4 terminal, menghadap selatan = rotY 0) ──
	-- Adjutant 001B (Race Manager), Tribune Rep, Aide, HERO Lothan
	npcTerminal("RaceM",   cx-150, cz-NPC_R,  0, red)
	npcTerminal("Tribune", cx-50,  cz-NPC_R,  0, teal)
	npcTerminal("Aide",    cx+50,  cz-NPC_R,  0, teal)
	npcTerminal("Hero",    cx+150, cz-NPC_R,  0, red)

	-- ── TIMUR: Weapon & Shield vendors (7 stall, menghadap barat) ──
	-- AR12-32-2003, AR33-32-1173, AR24-33-2581, AR14-31-0496, AR11-18-6345, AR23-14-5513, AR31-11-9983
	local EX = cx + NPC_R
	for i, zo in ipairs({-300,-200,-100,0,100,200,300}) do
		npcStall("WepE"..i, EX, cz+zo, -math.pi/2, red)
	end

	-- ── BARAT: Armor & Tool vendors (6 stall, menghadap timur) ─────
	-- NC-5874, AR24-33-2601, NC-110110B, NC-854125, NC-69800, Gem Collector
	local WX = cx - NPC_R
	for i, zo in ipairs({-250,-150,-50,50,150,250}) do
		npcStall("ArmW"..i, WX, cz+zo, math.pi/2, teal)
	end

	-- ── RING DALAM TIMUR: Admin (4 stall, menghadap barat) ─────────
	-- NC-255 Guild Manager, NC-5985 Charger, NC-66333 Charger, AR22-54-5078 Rare Tools
	for i, zo in ipairs({-80, 30, 140, 250}) do
		local sc = (i==1) and teal or red
		npcStall("AdmE"..i, cx+NPC_R2, cz+zo, -math.pi/2, sc)
	end

	-- ── RING DALAM BARAT: Misc vendors (5 stall, menghadap timur) ──
	-- Talic Collector, Golden Pigs, Foreign Vendor (Crea Windom), Paybox (Miti), Captured Keeper
	for i, zo in ipairs({-200,-100,0,100,200}) do
		local sc = (i==3 or i==4) and teal or red
		npcStall("MscW"..i, cx-NPC_R2, cz+zo, math.pi/2, sc)
	end

	-- ── HUMANOID NPC (Accretia HQ, sesuai rf_guide.txt) ─────────
	-- Formula: rx = cx + (gx-17)*33, rz = cz + (gy-71)*17
	-- Referensi RF Classic (17,71) → Roblox center Accretia HQ (5500,500)
	local function makeNPC(npcName, designation, px, pz, shirtCol)
		local nm = Instance.new("Model"); nm.Name = npcName; nm.Parent = m
		local hrp = Instance.new("Part")
		hrp.Name = "HumanoidRootPart"; hrp.Size = Vector3.new(2,2,1)
		hrp.CFrame = CFrame.new(px, cy+3, pz)
		hrp.Anchored = true; hrp.CanCollide = true; hrp.Transparency = 1; hrp.Parent = nm
		local torso = Instance.new("Part")
		torso.Name = "UpperTorso"; torso.Size = Vector3.new(2,2,1)
		torso.CFrame = CFrame.new(px, cy+5, pz)
		torso.Anchored = true; torso.CanCollide = false
		torso.BrickColor = BrickColor.new(shirtCol); torso.Parent = nm
		local head = Instance.new("Part")
		head.Name = "Head"; head.Size = Vector3.new(1.5,1.5,1.5)
		head.CFrame = CFrame.new(px, cy+7, pz)
		head.Anchored = true; head.CanCollide = false
		head.BrickColor = BrickColor.new("Nougat"); head.Parent = nm
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0,180,0,44); bb.StudsOffset = Vector3.new(0,2.5,0)
		bb.AlwaysOnTop = false; bb.Adornee = head; bb.Parent = head
		local nl = Instance.new("TextLabel")
		nl.Size = UDim2.new(1,0,0.55,0); nl.BackgroundTransparency = 1
		nl.TextColor3 = Color3.new(1,1,1); nl.TextScaled = true
		nl.Font = Enum.Font.GothamBold; nl.Text = npcName; nl.Parent = bb
		local rl = Instance.new("TextLabel")
		rl.Size = UDim2.new(1,0,0.45,0); rl.Position = UDim2.new(0,0,0.55,0)
		rl.BackgroundTransparency = 1; rl.TextColor3 = Color3.fromRGB(255,100,100)
		rl.TextScaled = true; rl.Font = Enum.Font.Gotham
		rl.Text = "["..designation.."]"; rl.Parent = bb
		local hum = Instance.new("Humanoid")
		hum.MaxHealth = 100; hum.Health = 100; hum.WalkSpeed = 0; hum.JumpPower = 0
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
		hum.Parent = nm; nm.PrimaryPart = hrp
	end
	local function rf(gx, gy)
		return cx + (gx-17)*33, cz + (gy-71)*17
	end
	local function n(name, desig, gx, gy, col)
		local rx, rz = rf(gx, gy); makeNPC(name, desig, rx, rz, col)
	end
	-- Officials (barat jauh, portal area)
	n("Adjutant 001B",  "Race Manager",     5,  71, "Dark red")
	n("aP0P-CR-1944",   "Tribune Rep",      8,  71, "Dark red")
	-- Weapon / Shield vendors (cluster utara, X=24-27, Y=66-68)
	n("AR12-32-2003",   "Weapon Type A",    27, 68, "Bright red")
	n("AR14-31-0496",   "Weapon Type N",    27, 68, "Bright red")
	n("AR33-32-1173",   "Weapon Type A",    27, 68, "Bright red")
	n("NC-2901",        "Weapon",           27, 68, "Bright red")
	n("AR11-18-6345",   "Shield Type A",    25, 67, "Medium stone grey")
	n("AR14-31-0486",   "Armor Suit",       25, 67, "Medium stone grey")
	n("AR23-14-5513",   "Shield Type N",    25, 67, "Medium stone grey")
	n("NC-5874",        "Armor Suit",       25, 67, "Medium stone grey")
	n("AR24-33-2601",   "Armor Type B",     24, 67, "Medium stone grey")
	n("NC-441100",      "Coin Exchange",    24, 67, "Sand yellow")
	n("NC-5985",        "Charger",          26, 67, "Cyan")
	n("AR31-11-9983",   "Shield Type B",    24, 68, "Medium stone grey")
	-- Inner services (X=22-24, Y=69-72)
	n("AR22-54-5078",   "Rare Tools",       22, 69, "Sand yellow")
	n("Lavendor",       "Talic Collector",  22, 69, "Sand yellow")
	n("AR24-33-2581",   "Weapon Type B",    22, 70, "Bright red")
	n("NC-69800",       "Ore",              22, 70, "Sand yellow")
	n("Stone Master",   "Gem Collector",    22, 70, "Sand yellow")
	n("NC-854125",      "Tool",             28, 69, "Sand yellow")
	n("PointItemNPC",   "Point Item",       24, 70, "Cyan")
	-- Center services
	n("Temple of Honor","Temple of Honor",  20, 71, "White")
	n("Dark Annihilator","Dark Ambassador", 24, 71, "Dark stone grey")
	n("Dark Desolator", "Dark Ambassador",  24, 71, "Dark stone grey")
	n("Dark Warder",    "Dark Ambassador",  24, 71, "Dark stone grey")
	n("Emperial Dragon","Dragon Knight",    24, 71, "Dark stone grey")
	n("CouponMan",      "Premium Manager",  25, 71, "Bright blue")
	n("Crea Windom",    "Foreign Vendor",   25, 71, "Sand green")
	-- Guild / Admin (X=22, Y=72-73)
	n("NC-255",         "Guild Manager",    22, 72, "Bright blue")
	n("Captured Keeper","Captured Keeper",  22, 73, "Dark stone grey")
	n("NC-359804F",     "Gatekeeper",       23, 73, "Reddish brown")
	n("NC-66333",       "Charger",          28, 73, "Cyan")
	n("NC-110110B",     "Armor",            27, 74, "Medium stone grey")
	-- South / Hero area
	n("NC-3589A",       "Battle Dungeon",   26, 75, "Bright orange")
	n("Lothan the 3rd", "Hero",             25, 75, "Bright orange")
	-- Aide (timur laut, dekat entrance)
	n("AS01-R1-1131",   "Aide",             30, 66, "Sand yellow")
	task.wait()

	spawnLoc(raceSpawnFolder, "Accretia_Spawn", Vector3.new(cx,cy+8,cz+200), "Bright red")
end
buildAccretiaHQ(); task.wait()

-- ================================================================
-- STEP 6: Cora HQ
-- ================================================================
print("[MapGen] 6/10 Cora HQ...")

local function buildCoraHQ()
	local m = Instance.new("Model"); m.Name = "CoraHQ"; m.Parent = worldFolder
	local cx, cy, cz = 0, GROUND_Y, 5800

	-- RF Classic Cora: sacred/mystical, white marble, crystal spires, Animus altar
	local white  = "White"
	local stone  = "Light stone grey"
	local cyan   = "Cyan"
	local dark   = "Dark stone grey"

	-- ── PLAZA SACRED (circular ground) ────────────────────────────
	part(m,"Plaza",    Vector3.new(900,4,900),  CFrame.new(cx,cy+2,cz), stone, Enum.Material.SmoothPlastic)
	part(m,"PlazaRim", Vector3.new(910,2,910),  CFrame.new(cx,cy,cz),   dark,  Enum.Material.Metal)
	-- Sacred circles di lantai
	local NF = 16
	for i = 0, NF-1 do
		local a = (i/NF)*math.pi*2
		local r1 = 380
		part(m,"RO"..i, Vector3.new(2*r1*math.sin(math.pi/NF)+1,2,10),
			CFrame.new(cx+r1*math.sin(a),cy+4,cz+r1*math.cos(a))*CFrame.Angles(0,-a,0), cyan, Enum.Material.Neon)
		local r2 = 200
		part(m,"RI"..i, Vector3.new(2*r2*math.sin(math.pi/NF)+1,2,6),
			CFrame.new(cx+r2*math.sin(a),cy+4,cz+r2*math.cos(a))*CFrame.Angles(0,-a,0), cyan, Enum.Material.Neon)
	end

	-- ── TEMBOK LUAR (N=12 polygon, gap di selatan) ────────────────
	local WR = 440
	for i = 0, 10 do   -- 11 dari 12 segmen (1 gap = entrance selatan)
		local a = ((i+0.5)/12)*math.pi*2
		local sl = 2*WR*math.sin(math.pi/12)+2
		part(m,"Wall"..i, Vector3.new(sl,30,18),
			CFrame.new(cx+WR*math.sin(a),cy+17,cz+WR*math.cos(a))*CFrame.Angles(0,-a,0), white, Enum.Material.SmoothPlastic)
		part(m,"WallN"..i,Vector3.new(sl-4,6,8),
			CFrame.new(cx+WR*math.sin(a),cy+34,cz+WR*math.cos(a))*CFrame.Angles(0,-a,0), cyan, Enum.Material.Neon)
	end

	-- ── CRYSTAL SPIRES (8 menara melingkar, alternating height) ───
	for i = 0, 7 do
		local a  = (i/8)*math.pi*2
		local tx = cx + math.cos(a)*WR
		local tz = cz + math.sin(a)*WR
		local h  = (i%2==0) and 110 or 78
		part(m,"SpireBase"..i,  Vector3.new(28,h,28),      CFrame.new(tx,cy+h/2,tz),        white, Enum.Material.SmoothPlastic)
		part(m,"SpireMid"..i,   Vector3.new(18,h*0.7,18),  CFrame.new(tx,cy+h+h*0.35,tz),   cyan,  Enum.Material.Neon)
		part(m,"SpireTip"..i,   Vector3.new(10,h*0.45,10), CFrame.new(tx,cy+h+h*0.88,tz),   cyan,  Enum.Material.Neon)
		neonLight(m, Vector3.new(tx,cy+h*2+5,tz), Color3.fromRGB(0,255,200), 50, 1.5)
	end

	-- ── MAIN TEMPLE (kuil utama bertingkat) ───────────────────────
	local TX, TZ = cx, cz - 80
	part(m,"TPlat1", Vector3.new(280,10,280), CFrame.new(TX,cy+6,TZ),  white, Enum.Material.SmoothPlastic)
	part(m,"TPlat2", Vector3.new(220,10,220), CFrame.new(TX,cy+16,TZ), stone, Enum.Material.SmoothPlastic)
	part(m,"TPlat3", Vector3.new(160,10,160), CFrame.new(TX,cy+26,TZ), white, Enum.Material.SmoothPlastic)
	-- Kolom marble 4 di depan
	for _, ox in ipairs({-65,-22,22,65}) do
		part(m,"TCol"..ox,    Vector3.new(14,70,14), CFrame.new(TX+ox,cy+61,TZ+82),  white, Enum.Material.SmoothPlastic)
		part(m,"TColCap"..ox, Vector3.new(18,8,18),  CFrame.new(TX+ox,cy+98,TZ+82),  cyan,  Enum.Material.Neon)
	end
	-- Body temple
	part(m,"TBody",    Vector3.new(170,60,160), CFrame.new(TX,cy+57,TZ),   white, Enum.Material.SmoothPlastic)
	-- Dome glowing cyan
	part(m,"TDomeRim", Vector3.new(170,10,170), CFrame.new(TX,cy+88,TZ),   white, Enum.Material.SmoothPlastic)
	part(m,"TDome",    Vector3.new(148,72,148), CFrame.new(TX,cy+113,TZ),  cyan,  Enum.Material.Neon)
	-- Menara mini di 4 sudut temple
	for _, c in ipairs({{-80,-80},{80,-80},{-80,80},{80,80}}) do
		part(m,"MT"..c[1], Vector3.new(20,60,20), CFrame.new(TX+c[1],cy+39,TZ+c[2]),  white, Enum.Material.SmoothPlastic)
		part(m,"MC"..c[1], Vector3.new(14,40,14), CFrame.new(TX+c[1],cy+89,TZ+c[2]), cyan,  Enum.Material.Neon)
	end
	neonLight(m, Vector3.new(TX,cy+162,TZ), Color3.fromRGB(0,255,200), 200, 2)

	-- ── ANIMUS ALTAR (floating crystal ring — ciri khas Cora RF) ──
	local AX, AZ = cx, cz + 120
	part(m,"AltarBase", Vector3.new(100,6,100),  CFrame.new(AX,cy+4,AZ),  white, Enum.Material.SmoothPlastic)
	part(m,"AltarRim",  Vector3.new(110,3,110),  CFrame.new(AX,cy+2,AZ),  cyan,  Enum.Material.Neon)
	part(m,"AltarPed",  Vector3.new(28,24,28),   CFrame.new(AX,cy+16,AZ), white, Enum.Material.SmoothPlastic)
	-- Ring melayang (12 segmen)
	local AN = 12; local AR = 55
	for i = 0, AN-1 do
		local a = (i/AN)*math.pi*2
		part(m,"Ani"..i, Vector3.new(2*AR*math.sin(math.pi/AN)+1,8,12),
			CFrame.new(AX+AR*math.sin(a),cy+56,AZ+AR*math.cos(a))*CFrame.Angles(0,-a,0), cyan, Enum.Material.Neon)
	end
	part(m,"AniCore",Vector3.new(28,48,28), CFrame.new(AX,cy+50,AZ),  cyan,  Enum.Material.Neon)
	part(m,"AniGlow",Vector3.new(14,18,14), CFrame.new(AX,cy+67,AZ),  white, Enum.Material.Neon)
	neonLight(m, Vector3.new(AX,cy+82,AZ), Color3.fromRGB(0,255,200), 150, 5)

	-- ── NPC LAYOUT (RF Classic Cora HQ) ──────────────────────────
	-- Stall Cora: white body + cyan sign (sacred/mystical style)
	local function cStall(name, px, pz, rotY, signCol)
		local bCF = CFrame.new(px, cy, pz) * CFrame.Angles(0, rotY, 0)
		part(m, name.."Plat", Vector3.new(68,4,56),  bCF*CFrame.new(0,3,0),   stone, Enum.Material.SmoothPlastic)
		part(m, name.."Desk", Vector3.new(68,16,38), bCF*CFrame.new(0,12,0),  white, Enum.Material.SmoothPlastic)
		part(m, name.."Top",  Vector3.new(68,3,38),  bCF*CFrame.new(0,21,0),  stone, Enum.Material.SmoothPlastic)
		part(m, name.."Back", Vector3.new(68,38,6),  bCF*CFrame.new(0,31,-24), stone, Enum.Material.SmoothPlastic)
		part(m, name.."Sign", Vector3.new(52,26,4),  bCF*CFrame.new(0,31,-24), signCol, Enum.Material.Neon)
	end
	-- Terminal penting Cora (Race Manager, Guild Manager, Archbishop Rep, Hero)
	local function cTerminal(name, px, pz, rotY)
		local bCF = CFrame.new(px, cy, pz) * CFrame.Angles(0, rotY, 0)
		part(m, name.."Plat", Vector3.new(88,6,88),  bCF*CFrame.new(0,3,0),   white, Enum.Material.SmoothPlastic)
		part(m, name.."PRim", Vector3.new(96,2,96),  bCF*CFrame.new(0,1,0),   cyan,  Enum.Material.Neon)
		part(m, name.."Desk", Vector3.new(80,22,40), bCF*CFrame.new(0,14,0),  white, Enum.Material.SmoothPlastic)
		part(m, name.."DTop", Vector3.new(80,4,40),  bCF*CFrame.new(0,26,0),  cyan,  Enum.Material.Neon)
		part(m, name.."Back", Vector3.new(88,70,8),  bCF*CFrame.new(0,45,-30), stone, Enum.Material.SmoothPlastic)
		part(m, name.."Scr",  Vector3.new(70,50,5),  bCF*CFrame.new(0,51,-30), cyan,  Enum.Material.Neon)
		part(m, name.."PilL", Vector3.new(8,78,8),   bCF*CFrame.new(-46,41,-30), stone, Enum.Material.SmoothPlastic)
		part(m, name.."PilR", Vector3.new(8,78,8),   bCF*CFrame.new( 46,41,-30), stone, Enum.Material.SmoothPlastic)
		part(m, name.."Hdr",  Vector3.new(108,6,10), bCF*CFrame.new(0,84,-30), cyan,  Enum.Material.Neon)
		neonLight(m, (bCF*CFrame.new(0,88,-20)).Position, Color3.fromRGB(0,255,200), 40, 1.5)
	end

	-- Timur temple (menghadap barat = rotY -π/2):
	-- Quiane Kahn (Race Manager), Stupor (Archbishop Rep), Aias (Guild Manager), Giz Kadasha (Hero)
	cTerminal("CT_Race",  cx+240, cz-80, -math.pi/2)
	cTerminal("CT_Arch",  cx+240, cz+20, -math.pi/2)
	cTerminal("CT_Guild", cx+240, cz+120, -math.pi/2)
	cTerminal("CT_Hero",  cx+240, cz+220, -math.pi/2)

	-- Barat temple (menghadap timur = rotY π/2):
	-- Weapon vendors (2 tier), Armor vendors (2 tier)
	cStall("CW1", cx-240, cz-100, math.pi/2, cyan)
	cStall("CW2", cx-240, cz,     math.pi/2, cyan)
	cStall("CW3", cx-240, cz+100, math.pi/2, white)
	cStall("CW4", cx-240, cz+200, math.pi/2, white)

	-- Selatan (sepanjang z ≈ cz+280, menghadap utara = rotY π):
	-- Potion vendor, Gem Collector, Ore vendor, Tool vendor, Talic Collector
	for i, px in ipairs({cx-300, cx-180, cx-60, cx+60, cx+180, cx+300}) do
		local sc = (i % 2 == 0) and cyan or white
		cStall("CS"..i, px, cz+290, math.pi, sc)
	end

	-- Baris kedua selatan (cz+370):
	-- Item vendors (Trust / Client quest + misc)
	for i, px in ipairs({cx-240, cx-100, cx+40, cx+200}) do
		cStall("CS2_"..i, px, cz+370, math.pi, (i<=2) and cyan or white)
	end

	-- Maku Luketa (Gatekeeper) — dekat entrance
	cStall("CGate", cx, cz+410, math.pi, cyan)

	-- ── WARP DEVICE ────────────────────────────────────────────────
	part(m,"WarpPlat",  Vector3.new(80,6,80),  CFrame.new(cx,cy+4,cz+380)*CFrame.Angles(0,math.pi/4,0), white, Enum.Material.SmoothPlastic)
	part(m,"WarpRim",   Vector3.new(90,3,90),  CFrame.new(cx,cy+2,cz+380)*CFrame.Angles(0,math.pi/4,0), cyan,  Enum.Material.Neon)
	part(m,"WarpPil",   Vector3.new(14,26,14), CFrame.new(cx,cy+16,cz+380),                              stone, Enum.Material.SmoothPlastic)
	part(m,"WarpCore",  Vector3.new(22,12,22), CFrame.new(cx,cy+28,cz+380),                              cyan,  Enum.Material.Neon)
	neonLight(m, Vector3.new(cx,cy+36,cz+380), Color3.fromRGB(0,255,200), 90, 4)

	-- ── BENDERA ────────────────────────────────────────────────────
	part(m,"FlagPole", Vector3.new(3,70,3),  CFrame.new(TX,cy+37,TZ-145),    "Light grey",  Enum.Material.Metal)
	part(m,"Flag",     Vector3.new(40,26,3), CFrame.new(TX+22,cy+73,TZ-145), "Bright green",Enum.Material.SmoothPlastic)

	-- ── HUMANOID NPC (Cora HQ, sesuai rf_guide.txt) ─────────────
	-- Formula: rx = cx + (gx-87)*33, rz = cz + (gy-57)*17
	-- Referensi RF Classic (87,57) → Roblox center Cora HQ (0,5800)
	local function makeNPC(npcName, designation, px, pz, shirtCol)
		local nm = Instance.new("Model"); nm.Name = npcName; nm.Parent = m
		local hrp = Instance.new("Part")
		hrp.Name = "HumanoidRootPart"; hrp.Size = Vector3.new(2,2,1)
		hrp.CFrame = CFrame.new(px, cy+3, pz)
		hrp.Anchored = true; hrp.CanCollide = true; hrp.Transparency = 1; hrp.Parent = nm
		local torso = Instance.new("Part")
		torso.Name = "UpperTorso"; torso.Size = Vector3.new(2,2,1)
		torso.CFrame = CFrame.new(px, cy+5, pz)
		torso.Anchored = true; torso.CanCollide = false
		torso.BrickColor = BrickColor.new(shirtCol); torso.Parent = nm
		local head = Instance.new("Part")
		head.Name = "Head"; head.Size = Vector3.new(1.5,1.5,1.5)
		head.CFrame = CFrame.new(px, cy+7, pz)
		head.Anchored = true; head.CanCollide = false
		head.BrickColor = BrickColor.new("Nougat"); head.Parent = nm
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0,180,0,44); bb.StudsOffset = Vector3.new(0,2.5,0)
		bb.AlwaysOnTop = false; bb.Adornee = head; bb.Parent = head
		local nl = Instance.new("TextLabel")
		nl.Size = UDim2.new(1,0,0.55,0); nl.BackgroundTransparency = 1
		nl.TextColor3 = Color3.new(1,1,1); nl.TextScaled = true
		nl.Font = Enum.Font.GothamBold; nl.Text = npcName; nl.Parent = bb
		local rl = Instance.new("TextLabel")
		rl.Size = UDim2.new(1,0,0.45,0); rl.Position = UDim2.new(0,0,0.55,0)
		rl.BackgroundTransparency = 1; rl.TextColor3 = Color3.fromRGB(100,255,220)
		rl.TextScaled = true; rl.Font = Enum.Font.Gotham
		rl.Text = "["..designation.."]"; rl.Parent = bb
		local hum = Instance.new("Humanoid")
		hum.MaxHealth = 100; hum.Health = 100; hum.WalkSpeed = 0; hum.JumpPower = 0
		hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
		hum.Parent = nm; nm.PrimaryPart = hrp
	end
	local function rf(gx, gy)
		return cx + (gx-87)*33, cz + (gy-57)*17
	end
	local function n(name, desig, gx, gy, col)
		local rx, rz = rf(gx, gy); makeNPC(name, desig, rx, rz, col)
	end
	-- Vendor baris utara (Y=48, X=78-85)
	n("Casandra",        "Weapon Type A",    78, 48, "Bright red")
	n("Hansen",          "Weapon Type N",    78, 48, "Bright red")
	n("Sara Meser",      "Weapon Type A",    78, 48, "Bright red")
	n("Isillia",         "Armor Vendor",     79, 48, "Medium stone grey")
	n("Noa Del",         "Armor Suit",       79, 48, "Medium stone grey")
	n("Syris",           "Shield Type N",    79, 48, "Medium stone grey")
	n("Beny",            "Shield Type A",    79, 48, "Medium stone grey")
	n("Aias",            "Guild Manager",    85, 48, "Bright blue")
	n("Captured Keeper", "Captured Keeper",  85, 48, "Dark stone grey")
	-- Services row (Y=50, X=76-86)
	n("Methud",          "Force",            76, 50, "Sand yellow")
	n("PA71-02-1316",    "Foreign Vendor",   79, 50, "Sand green")
	n("Fairy",           "Potion",           81, 50, "Bright red")
	n("Zeraf",           "Tool",             81, 50, "Sand yellow")
	n("Elli Ieeda",      "Armour",           86, 50, "Medium stone grey")
	-- Inner cluster (Y=51-52, X=79-83)
	n("CouponMan",       "Premium Manager",  79, 51, "Bright blue")
	n("Maku Luketa",     "Gatekeeper",       79, 52, "Reddish brown")
	n("Dark ArchMagus",  "Dark Ambassador",  80, 51, "Dark stone grey")
	n("Dark Zealot",     "Dark Ambassador",  80, 51, "Dark stone grey")
	n("Dark Redeemer",   "Dark Ambassador",  80, 52, "Dark stone grey")
	n("Emperial Dragon", "Dragon Knight",    80, 52, "Dark stone grey")
	n("PointItemNPC",    "Point Item",       78, 52, "Cyan")
	n("Daesa",           "Armor Type B",     83, 51, "Medium stone grey")
	n("Jamer",           "Coin Exchange",    83, 51, "Sand yellow")
	n("Jewel Master",    "Gem Collector",    83, 51, "Sand yellow")
	n("Louian Cury",     "Shield Type B",    83, 51, "Medium stone grey")
	n("Mether",          "Talic Collector",  83, 51, "Sand yellow")
	n("Minohr",          "Ore",              83, 51, "Sand yellow")
	n("Nora",            "Rare Tools",       83, 51, "Sand yellow")
	n("Railia",          "Weapon Type B",    83, 51, "Bright red")
	n("Gijol Logue",     "Weapon",           89, 52, "Bright red")
	-- Center / south NPCs
	n("Temple of Honor", "Temple of Honor",  82, 54, "White")
	n("Ziz Oadasha",     "Hero",             79, 55, "Bright orange")
	n("Stupor",          "Archbishop Rep",   85, 57, "Bright blue")
	n("Quiane Kahn",     "Race Manager",     86, 58, "Bright blue")
	n("MISCELLANEOUS",   "Battle Dungeon",   79, 58, "Bright orange")
	n("SynPask",         "Potion",           81, 60, "Bright red")
	task.wait()

	spawnLoc(raceSpawnFolder,"Cora_Spawn",Vector3.new(cx,cy+2,cz+330),"Bright green")
end
buildCoraHQ(); task.wait()

-- ================================================================
-- STEP 7: Crag Mine
-- ================================================================
print("[MapGen] 7/10 Crag Mine...")

local function buildCragMine()
	local m = Instance.new("Model"); m.Name = "CragMine"; m.Parent = worldFolder
	local cx, cy, cz = 0, GROUND_Y, -3500
	local rock = "Dark stone grey"

	-- Platform besar
	part(m,"Platform",Vector3.new(1200,6,1200),CFrame.new(cx,cy+3,cz),"Sand grey",Enum.Material.SmoothPlastic)

	-- Tembok per entrance (3 portal ras + lorong mining)
	for i=1,6 do
		local a = (i/6)*math.pi*2
		local wx,wz = cx+math.cos(a)*560, cz+math.sin(a)*560
		if i~=1 and i~=3 and i~=5 then
			part(m,"Wall"..i,Vector3.new(14,30,(2*math.pi*560/6)+2),
				CFrame.new(wx,cy+17,wz)*CFrame.Angles(0,a+math.pi/2,0),
				rock,Enum.Material.SmoothPlastic)
		end
	end

	-- Portal Bellato (barat)
	part(m,"BellatoGateL",Vector3.new(12,36,12),CFrame.new(cx-580,cy+20,cz-50),rock,Enum.Material.SmoothPlastic)
	part(m,"BellatoGateR",Vector3.new(12,36,12),CFrame.new(cx-580,cy+20,cz+50),rock,Enum.Material.SmoothPlastic)
	part(m,"BellatoArch", Vector3.new(110,10,12),CFrame.new(cx-580,cy+38,cz),"Bright blue",Enum.Material.Neon)

	-- Portal Accretia (timur)
	part(m,"AccretiaGateL",Vector3.new(12,36,12),CFrame.new(cx+580,cy+20,cz-50),rock,Enum.Material.SmoothPlastic)
	part(m,"AccretiaGateR",Vector3.new(12,36,12),CFrame.new(cx+580,cy+20,cz+50),rock,Enum.Material.SmoothPlastic)
	part(m,"AccretiaArch", Vector3.new(110,10,12),CFrame.new(cx+580,cy+38,cz),"Bright red",Enum.Material.Neon)

	-- Portal Cora (selatan)
	part(m,"CoraGateL",Vector3.new(12,36,12),CFrame.new(cx-50,cy+20,cz+580),rock,Enum.Material.SmoothPlastic)
	part(m,"CoraGateR",Vector3.new(12,36,12),CFrame.new(cx+50,cy+20,cz+580),rock,Enum.Material.SmoothPlastic)
	part(m,"CoraArch", Vector3.new(110,10,12),CFrame.new(cx,cy+38,cz+580)*CFrame.Angles(0,math.pi/2,0),"Bright green",Enum.Material.Neon)

	-- 6 shaft mining (lubang kecil dengan material khas)
	local shafts = {
		{-280,-200},{280,-200},{-280,200},{280,200},{0,-350},{0,350}
	}
	for i,s in ipairs(shafts) do
		fill(cx+s[1], cz+s[2], 80, 80, Enum.Material.Rock, GROUND_Y, 30)
		part(m,"ShaftTop"..i,Vector3.new(80,4,80),CFrame.new(cx+s[1],cy+2,cz+s[2]),"Dark stone grey",Enum.Material.Metal)
		neonLight(m,Vector3.new(cx+s[1],cy+12,cz+s[2]),Color3.fromRGB(255,200,0),50,1)
	end

	-- Center obelisk (Force Core tower kecil)
	part(m,"Obelisk1",Vector3.new(40,30,40),CFrame.new(cx,cy+17,cz),rock,Enum.Material.SmoothPlastic)
	part(m,"Obelisk2",Vector3.new(30,30,30),CFrame.new(cx,cy+47,cz),rock,Enum.Material.SmoothPlastic)
	part(m,"ObeliskTop",Vector3.new(22,40,22),CFrame.new(cx,cy+82,cz),"Cyan",Enum.Material.Neon)
	neonLight(m,Vector3.new(cx,cy+110,cz),Color3.fromRGB(0,200,255),200,2.5)

	spawnLoc(raceSpawnFolder,"CragMine_Spawn",Vector3.new(cx,cy+2,cz),"Medium stone grey")
end
buildCragMine(); task.wait()

-- ================================================================
-- STEP 8: Platform Ether
-- ================================================================
print("[MapGen] 8/10 Platform Ether...")

local function buildPlatformEther()
	local m = Instance.new("Model"); m.Name = "PlatformEther"; m.Parent = worldFolder
	local cx, cy, cz = 0, ETHER_Y, -4200

	-- Base platform
	part(m,"Base",  Vector3.new(2000,8,1500),CFrame.new(cx,cy+4,cz),"White",Enum.Material.SmoothPlastic)
	-- Tepi / pagar
	part(m,"RailN", Vector3.new(2000,10,6), CFrame.new(cx,cy+13,cz-750),"White",Enum.Material.SmoothPlastic)
	part(m,"RailS", Vector3.new(2000,10,6), CFrame.new(cx,cy+13,cz+750),"White",Enum.Material.SmoothPlastic)
	part(m,"RailW", Vector3.new(6,10,1500), CFrame.new(cx-1000,cy+13,cz),"White",Enum.Material.SmoothPlastic)
	part(m,"RailE", Vector3.new(6,10,1500), CFrame.new(cx+1000,cy+13,cz),"White",Enum.Material.SmoothPlastic)

	-- White Hall (pusat)
	part(m,"WhiteHall",Vector3.new(300,60,250),CFrame.new(cx,cy+38,cz),"White",Enum.Material.SmoothPlastic)
	part(m,"WHDome",   Vector3.new(260,70,210),CFrame.new(cx,cy+95,cz),"Cyan",Enum.Material.Neon)
	neonLight(m,Vector3.new(cx,cy+140,cz),Color3.fromRGB(180,255,255),300,3)

	-- Wharf Bellato (barat)
	part(m,"BWharf",Vector3.new(280,6,200),CFrame.new(cx-700,cy+4,cz+150),"Bright blue",Enum.Material.SmoothPlastic)
	-- Wharf Accretia (timur)
	part(m,"AWharf",Vector3.new(280,6,200),CFrame.new(cx+700,cy+4,cz+150),"Bright red",Enum.Material.SmoothPlastic)
	-- Wharf Cora (selatan)
	part(m,"CWharf",Vector3.new(280,6,200),CFrame.new(cx,cy+4,cz+550),"Bright green",Enum.Material.SmoothPlastic)

	-- Tiang penyangga dari bawah
	for _, pos in ipairs({ {-800,-300},{800,-300},{-800,300},{800,300},{0,0} }) do
		local pillarY = cy/2
		part(m,"Pillar",Vector3.new(20,cy,20),
			CFrame.new(cx+pos[1],pillarY,cz+pos[2]),"Medium stone grey",Enum.Material.SmoothPlastic)
	end

	-- SpawnLocation di ether
	spawnLoc(raceSpawnFolder,"Ether_Spawn",Vector3.new(cx,cy+8,cz),"Cyan")
end
buildPlatformEther(); task.wait()

-- ================================================================
-- STEP 9: Landmark Armory (penanda struktural)
-- ================================================================
print("[MapGen] 9/10 Armory structures...")

local function buildArmoryLandmark(cx, cy, cz, name, flagColor)
	local m = Instance.new("Model"); m.Name = name; m.Parent = worldFolder
	local metal = "Dark stone grey"

	part(m,"Base",   Vector3.new(500,5,400),  CFrame.new(cx,cy+2.5,cz),          "Sand green",Enum.Material.Metal)
	part(m,"WallN",  Vector3.new(500,28,14),  CFrame.new(cx,cy+16,cz-200),        metal,       Enum.Material.Metal)
	part(m,"WallS",  Vector3.new(500,28,14),  CFrame.new(cx,cy+16,cz+200),        metal,       Enum.Material.Metal)
	part(m,"WallE",  Vector3.new(14,28,400),  CFrame.new(cx+250,cy+16,cz),        metal,       Enum.Material.Metal)
	part(m,"WallW",  Vector3.new(14,28,400),  CFrame.new(cx-250,cy+16,cz),        metal,       Enum.Material.Metal)
	part(m,"Hangar", Vector3.new(300,50,200), CFrame.new(cx,cy+27,cz-50),         metal,       Enum.Material.Metal)
	part(m,"HangarT",Vector3.new(260,20,160), CFrame.new(cx,cy+62,cz-50),"Dark orange",        Enum.Material.Neon)
	part(m,"FPole",  Vector3.new(3,55,3),     CFrame.new(cx-220,cy+30,cz-180),    "Light grey",Enum.Material.Metal)
	part(m,"Flag",   Vector3.new(28,18,2),    CFrame.new(cx-205,cy+60,cz-180),    flagColor,   Enum.Material.SmoothPlastic)
	neonLight(m,Vector3.new(cx,cy+75,cz),Color3.fromRGB(255,140,0),100,1.5)
end

buildArmoryLandmark(-2400, GROUND_Y, -3400, "Armory117", "Bright blue")
task.wait()
buildArmoryLandmark(2400, GROUND_Y, -3400, "Armory213", "Bright red")
task.wait()

-- Sette Desert ruins landmark
local function buildSetteRuins()
	local m = Instance.new("Model"); m.Name="SetteRuins"; m.Parent=worldFolder
	local cx,cy,cz = 400,GROUND_Y,-5000
	-- Reruntuhan
	for i,pos in ipairs({ {-80,0,-60},{60,0,-40},{-30,0,60},{80,0,40} }) do
		local h = 20+i*8
		part(m,"Ruin"..i,Vector3.new(22,h,22),
			CFrame.new(cx+pos[1],cy+h/2,cz+pos[2]),"Sand grey",Enum.Material.SmoothPlastic)
	end
	part(m,"RuinCenter",Vector3.new(40,10,40),CFrame.new(cx,cy+5,cz),"Dark stone grey",Enum.Material.SmoothPlastic)
	neonLight(m,Vector3.new(cx,cy+30,cz),Color3.fromRGB(120,80,40),80,1)
end
buildSetteRuins(); task.wait()

-- ================================================================
-- Haram Stockade (CS1 — Cora side neutral, L31-35)
-- ================================================================
local function buildHaramStockade()
	local m = Instance.new("Model"); m.Name="HaramStockade"; m.Parent=worldFolder
	local cx,cy,cz = -1800, GROUND_Y, -800
	local stone = "Medium stone grey"
	local dark  = "Dark stone grey"

	part(m,"Base",    Vector3.new(640,4,520),   CFrame.new(cx,cy+2,cz),         "Warm greige",Enum.Material.Cobblestone)
	part(m,"WallN",   Vector3.new(640,22,12),   CFrame.new(cx,cy+13,cz-260),    stone,Enum.Material.SmoothPlastic)
	part(m,"WallS",   Vector3.new(640,22,12),   CFrame.new(cx,cy+13,cz+260),    stone,Enum.Material.SmoothPlastic)
	part(m,"WallE",   Vector3.new(12,22,520),   CFrame.new(cx+320,cy+13,cz),    stone,Enum.Material.SmoothPlastic)
	part(m,"WallW",   Vector3.new(12,22,520),   CFrame.new(cx-320,cy+13,cz),    stone,Enum.Material.SmoothPlastic)
	for _,c in ipairs({{-320,-260},{320,-260},{-320,260},{320,260}}) do
		part(m,"Tower",Vector3.new(30,38,30),CFrame.new(cx+c[1],cy+21,cz+c[2]),dark,Enum.Material.SmoothPlastic)
	end
	part(m,"GateL",   Vector3.new(12,30,12),    CFrame.new(cx-55,cy+17,cz+260), stone,Enum.Material.SmoothPlastic)
	part(m,"GateR",   Vector3.new(12,30,12),    CFrame.new(cx+55,cy+17,cz+260), stone,Enum.Material.SmoothPlastic)
	part(m,"GateArch",Vector3.new(110,8,12),    CFrame.new(cx,cy+34,cz+260),    dark, Enum.Material.SmoothPlastic)
	part(m,"Hall",    Vector3.new(200,40,150),  CFrame.new(cx,cy+22,cz-20),     stone,Enum.Material.SmoothPlastic)
	part(m,"HallTop", Vector3.new(160,16,110),  CFrame.new(cx,cy+52,cz-20),     dark, Enum.Material.SmoothPlastic)
	-- Bendera penanda
	part(m,"FlagPole",Vector3.new(3,50,3),      CFrame.new(cx,cy+27,cz-140),    "Light grey",Enum.Material.Metal)
	part(m,"Flag",    Vector3.new(26,16,2),     CFrame.new(cx+14,cy+53,cz-140), "Medium stone grey",Enum.Material.SmoothPlastic)
end
buildHaramStockade(); task.wait()

-- ================================================================
-- Numerus Stockade (CS2 — Accretia side neutral, L31-35)
-- ================================================================
local function buildNumerusStockade()
	local m = Instance.new("Model"); m.Name="NumerusStockade"; m.Parent=worldFolder
	local cx,cy,cz = 1800, GROUND_Y, -800
	local stone = "Medium stone grey"
	local dark  = "Dark stone grey"

	part(m,"Base",    Vector3.new(640,4,520),   CFrame.new(cx,cy+2,cz),         "Warm greige",Enum.Material.Cobblestone)
	part(m,"WallN",   Vector3.new(640,22,12),   CFrame.new(cx,cy+13,cz-260),    stone,Enum.Material.SmoothPlastic)
	part(m,"WallS",   Vector3.new(640,22,12),   CFrame.new(cx,cy+13,cz+260),    stone,Enum.Material.SmoothPlastic)
	part(m,"WallE",   Vector3.new(12,22,520),   CFrame.new(cx+320,cy+13,cz),    stone,Enum.Material.SmoothPlastic)
	part(m,"WallW",   Vector3.new(12,22,520),   CFrame.new(cx-320,cy+13,cz),    stone,Enum.Material.SmoothPlastic)
	for _,c in ipairs({{-320,-260},{320,-260},{-320,260},{320,260}}) do
		part(m,"Tower",Vector3.new(30,38,30),CFrame.new(cx+c[1],cy+21,cz+c[2]),dark,Enum.Material.SmoothPlastic)
	end
	part(m,"GateL",   Vector3.new(12,30,12),    CFrame.new(cx-55,cy+17,cz+260), stone,Enum.Material.SmoothPlastic)
	part(m,"GateR",   Vector3.new(12,30,12),    CFrame.new(cx+55,cy+17,cz+260), stone,Enum.Material.SmoothPlastic)
	part(m,"GateArch",Vector3.new(110,8,12),    CFrame.new(cx,cy+34,cz+260),    dark, Enum.Material.SmoothPlastic)
	part(m,"Hall",    Vector3.new(200,40,150),  CFrame.new(cx,cy+22,cz-20),     stone,Enum.Material.SmoothPlastic)
	part(m,"HallTop", Vector3.new(160,16,110),  CFrame.new(cx,cy+52,cz-20),     dark, Enum.Material.SmoothPlastic)
	part(m,"FlagPole",Vector3.new(3,50,3),      CFrame.new(cx,cy+27,cz-140),    "Light grey",Enum.Material.Metal)
	part(m,"Flag",    Vector3.new(26,16,2),     CFrame.new(cx+14,cy+53,cz-140), "Medium stone grey",Enum.Material.SmoothPlastic)
end
buildNumerusStockade(); task.wait()

-- ================================================================
-- Anacaade Settlement (Bellato neutral village, L31-38)
-- ================================================================
local function buildAnacaadeSettlement()
	local m = Instance.new("Model"); m.Name="AnacaadeSettlement"; m.Parent=worldFolder
	local cx,cy,cz = -600, GROUND_Y, -1200
	local stone = "Medium stone grey"
	local brown = "Reddish brown"

	part(m,"Ground",  Vector3.new(520,3,420),   CFrame.new(cx,cy+1.5,cz),       "Sand green",Enum.Material.Cobblestone)
	for _,b in ipairs({{-160,-100},{160,-100},{-160,100},{160,100},{0,-150}}) do
		part(m,"House",Vector3.new(110,34,90),CFrame.new(cx+b[1],cy+19,cz+b[2]),stone,Enum.Material.SmoothPlastic)
		wedge(m,"Roof",Vector3.new(90,20,56),CFrame.new(cx+b[1],cy+46,cz+b[2])*CFrame.Angles(0,math.pi/2,0),brown)
	end
	part(m,"Well",    Vector3.new(22,16,22),    CFrame.new(cx,cy+10,cz+60),     stone,Enum.Material.SmoothPlastic)
	part(m,"WellTop", Vector3.new(26,4,26),     CFrame.new(cx,cy+19,cz+60),     brown,Enum.Material.SmoothPlastic)
	part(m,"FlagPole",Vector3.new(3,48,3),      CFrame.new(cx,cy+26,cz-160),    "Light grey",Enum.Material.Metal)
	part(m,"Flag",    Vector3.new(24,14,2),     CFrame.new(cx+13,cy+50,cz-160), "Bright blue",Enum.Material.SmoothPlastic)
end
buildAnacaadeSettlement(); task.wait()

-- ================================================================
-- Solus Settlement (Accretia neutral village, L31-38)
-- ================================================================
local function buildSolusSettlement()
	local m = Instance.new("Model"); m.Name="SolusSettlement"; m.Parent=worldFolder
	local cx,cy,cz = 600, GROUND_Y, -1200
	local metal  = "Dark stone grey"
	local orange = "Bright orange"

	part(m,"Ground",  Vector3.new(520,3,420),   CFrame.new(cx,cy+1.5,cz),       "Sand green",Enum.Material.Cobblestone)
	for _,b in ipairs({{-160,-100},{160,-100},{-160,100},{160,100},{0,-150}}) do
		part(m,"House",Vector3.new(110,34,90), CFrame.new(cx+b[1],cy+19,cz+b[2]),metal,Enum.Material.Metal)
		part(m,"HTop", Vector3.new(100,14,80), CFrame.new(cx+b[1],cy+48,cz+b[2]),orange,Enum.Material.Neon)
	end
	part(m,"Tower",   Vector3.new(26,54,26),    CFrame.new(cx,cy+29,cz+60),     metal,Enum.Material.Metal)
	part(m,"TowerTop",Vector3.new(34,12,34),    CFrame.new(cx,cy+61,cz+60),     orange,Enum.Material.Neon)
	neonLight(m,Vector3.new(cx,cy+75,cz+60),Color3.fromRGB(255,120,0),80,1.2)
	part(m,"FlagPole",Vector3.new(3,48,3),      CFrame.new(cx,cy+26,cz-160),    "Light grey",Enum.Material.Metal)
	part(m,"Flag",    Vector3.new(24,14,2),     CFrame.new(cx+13,cy+50,cz-160), "Bright red",Enum.Material.SmoothPlastic)
end
buildSolusSettlement(); task.wait()

-- ================================================================
-- Roads Cauldron Volcanic — dari Sette Highland ke Abadon Passage
-- ================================================================
do
	local VC = Zones
	makeRoad(VC.SETTE_HIGHLAND.Center, VC.ABADON_PASSAGE.Center, 20)
	task.wait()
	makeRoad(VC.ABADON_PASSAGE.Center, VC.ABADON_CAVE_NW.Center, 16)
	makeRoad(VC.ABADON_PASSAGE.Center, VC.GENIAL_SPRING.Center,  16)
	task.wait()
	makeRoad(VC.GENIAL_SPRING.Center,  VC.EVIL_HALL.Center,       16)
	makeRoad(VC.ABADON_CAVE_NW.Center, VC.BELPHEGOR_CASTLE.Center,16)
	task.wait()
	makeRoad(VC.EVIL_HALL.Center,      VC.BELPHEGOR_CASTLE.Center,16)
	makeRoad(VC.BELPHEGOR_CASTLE.Center,VC.BAFER_LAKE.Center,     16)
	task.wait()
	makeRoad(VC.BAFER_LAKE.Center,     VC.HWATT_LAND.Center,      14)
	makeRoad(VC.ABADON_PASSAGE.Center, VC.ABADON_CAVE_E.Center,   16)
	makeRoad(VC.ABADON_CAVE_E.Center,  VC.BAFER_LAKE.Center,      14)
	task.wait()
end

-- ================================================================
-- Struktur Belphegor Castle
-- ================================================================
local function buildBelphegorCastle()
	local m = Instance.new("Model"); m.Name = "BelphegorCastle"; m.Parent = worldFolder
	local cx, cy, cz = -400, GROUND_Y, -6850
	local darkRed = "Maroon"
	local darkGrey = "Dark stone grey"
	local blood    = "Bright red"

	-- Platform base
	part(m,"Base",    Vector3.new(700,6,600),   CFrame.new(cx,cy+3,cz),      darkGrey,Enum.Material.SmoothPlastic)

	-- Tembok kastil (gothic)
	part(m,"WallN",   Vector3.new(700,36,16),   CFrame.new(cx,cy+20,cz-300), darkGrey,Enum.Material.SmoothPlastic)
	part(m,"WallS",   Vector3.new(700,36,16),   CFrame.new(cx,cy+20,cz+300), darkGrey,Enum.Material.SmoothPlastic)
	part(m,"WallE",   Vector3.new(16,36,600),   CFrame.new(cx+350,cy+20,cz), darkGrey,Enum.Material.SmoothPlastic)
	part(m,"WallW",   Vector3.new(16,36,600),   CFrame.new(cx-350,cy+20,cz), darkGrey,Enum.Material.SmoothPlastic)

	-- Menara sudut (ramping gothic)
	for _, c in ipairs({ {-350,-300},{350,-300},{-350,300},{350,300} }) do
		part(m,"Tower",   Vector3.new(36,70,36), CFrame.new(cx+c[1],cy+37,cz+c[2]), darkGrey,Enum.Material.SmoothPlastic)
		part(m,"TowerTop",Vector3.new(24,40,24), CFrame.new(cx+c[1],cy+92,cz+c[2]), darkRed, Enum.Material.Neon)
		neonLight(m, Vector3.new(cx+c[1],cy+115,cz+c[2]), Color3.fromRGB(180,0,0), 60, 1.5)
	end

	-- Gerbang utara (arah entry)
	part(m,"GateL",   Vector3.new(14,44,16),    CFrame.new(cx-55,cy+24,cz-300), darkGrey,Enum.Material.SmoothPlastic)
	part(m,"GateR",   Vector3.new(14,44,16),    CFrame.new(cx+55,cy+24,cz-300), darkGrey,Enum.Material.SmoothPlastic)
	part(m,"GateArch",Vector3.new(110,12,16),   CFrame.new(cx,cy+46,cz-300),    darkRed, Enum.Material.Neon)

	-- Gedung utama (keep)
	part(m,"Keep",    Vector3.new(260,55,200),  CFrame.new(cx,cy+30,cz+50),    darkGrey,Enum.Material.SmoothPlastic)
	part(m,"KeepTop", Vector3.new(220,22,160),  CFrame.new(cx,cy+68,cz+50),    darkRed, Enum.Material.Neon)

	-- Belphegor throne (pusat kastil, glowing)
	local throne = part(m,"Throne",Vector3.new(30,24,30),CFrame.new(cx,cy+18,cz+60),blood,Enum.Material.Neon)
	neonLight(m, Vector3.new(cx,cy+50,cz+60), Color3.fromRGB(220,0,0), 200, 3)

	-- Tulang-tulang / dekorasi gothic
	for i=1,6 do
		local ox = (i-3.5)*100
		part(m,"Spike"..i, Vector3.new(8,30,8),
			CFrame.new(cx+ox, cy+48, cz-300), darkGrey, Enum.Material.SmoothPlastic)
	end

	-- Lava moat
	part(m,"MoatN",   Vector3.new(760,4,40),   CFrame.new(cx,cy+1,cz-322),    "Bright orange",Enum.Material.Neon)
	part(m,"MoatS",   Vector3.new(760,4,40),   CFrame.new(cx,cy+1,cz+322),    "Bright orange",Enum.Material.Neon)
	part(m,"MoatE",   Vector3.new(40,4,680),   CFrame.new(cx+372,cy+1,cz),    "Bright orange",Enum.Material.Neon)
	part(m,"MoatW",   Vector3.new(40,4,680),   CFrame.new(cx-372,cy+1,cz),    "Bright orange",Enum.Material.Neon)
	neonLight(m, Vector3.new(cx,cy+10,cz), Color3.fromRGB(255,80,0), 250, 2)

	spawnLoc(raceSpawnFolder, "Cauldron_Spawn", Vector3.new(0,cy+4,-6200), "Dark red")
end
buildBelphegorCastle(); task.wait()

-- ================================================================
-- STEP 10: Monster Spawners
-- ================================================================
print("[MapGen] 10/10 Monster spawners...")

math.randomseed(54321)

for zoneId, spawnList in pairs(MapDefinitions.SpawnConfig) do
	local zone = Zones[zoneId]
	if not zone then continue end
	local zc = zone.Center

	for _, entry in ipairs(spawnList) do
		for i = 1, entry.Count do
			local angle  = math.random() * math.pi * 2
			local radius = math.random() * entry.Spread
			local spawnX = zc.X + math.cos(angle) * radius
			local spawnZ = zc.Z + math.sin(angle) * radius
			local spawnY = zc.Y + GROUND_Y + 1  -- Platform Ether ada di Y=400

			local sp = Instance.new("Part")
			sp.Name         = "Spawner_" .. entry.DefId .. "_" .. zoneId .. "_" .. i
			sp.Size         = Vector3.new(4,1,4)
			sp.CFrame       = CFrame.new(spawnX, spawnY, spawnZ)
			sp.Anchored     = true
			sp.CanCollide   = false
			sp.Transparency = 1
			sp:SetAttribute("MonsterDefId", entry.DefId)
			sp:SetAttribute("ZoneId", zoneId)
			sp.Parent = spawnerFolder
		end
	end
	task.wait()
end

-- Default fallback spawn
if not workspace:FindFirstChildOfClass("SpawnLocation") then
	local s = Instance.new("SpawnLocation")
	s.Size = Vector3.new(8,1,8); s.Neutral = true
	s.CFrame = CFrame.new(0, GROUND_Y+1, 0)
	s.Parent = workspace
end

-- ================================================================
-- SELESAI
-- ================================================================
local marker = Instance.new("BoolValue")
marker.Name = "_MapGenerated"; marker.Value = true; marker.Parent = workspace

local zoneCount    = 0; for _ in pairs(Zones) do zoneCount += 1 end
local spawnerCount = #spawnerFolder:GetChildren()

print("[MapGen] ✓ Peta Aetherion Phase 1 (RF Classic accurate) selesai!")
print(string.format("[MapGen]   Zones: %d | Spawners: %d | Platform Ether Y: %d", zoneCount, spawnerCount, ETHER_Y))
