-- MapGenerator.server.lua
-- Generate terrain, struktur HQ, Chip Mine Core, dan monster spawner.
-- Dijalankan SEKALI saat server start. Kalau sudah ada marker _MapGenerated di workspace, skip.
--
-- Layout:
--   Bellato HQ  (-3000, -2500)    Accretia HQ  (3000, -2500)
--   Elan West   (-2000, -1400)    Elan East    (2000, -1400)
--   Novus NW    (-1400,  -600)    Novus NE     (1400,  -600)
--              Novus Center (0, 0)
--              Novus South  (0, 800)
--              Elan South   (0, 1800)
--              Cora HQ      (0, 3500)
--   Chip Mine Approach (0, -1000)
--   Chip Mine Core     (0, -2200)

local MapDefinitions = require(game.ReplicatedStorage.Shared.Definitions.MapDefinitions)

-- ── skip jika sudah generate ──────────────────────────────────
if workspace:FindFirstChild("_MapGenerated") then
	print("[MapGen] Sudah generate, skip.")
	return
end

local Terrain = workspace:FindFirstChildOfClass("Terrain") or workspace.Terrain
local Zones = MapDefinitions.Zones

local GROUND_Y    = MapDefinitions.GROUND_Y    -- 0
local DEPTH       = MapDefinitions.TERRAIN_DEPTH -- 30
local MAP_HALF    = MapDefinitions.MAP_HALF       -- 4000

-- ============================================================
-- Helper: buat Part sederhana
-- ============================================================
local function makePart(parent, name, size, cframe, color, material, anchored)
	local p = Instance.new("Part")
	p.Name       = name
	p.Size       = size
	p.CFrame     = cframe
	p.BrickColor = BrickColor.new(color)
	p.Material   = material or Enum.Material.SmoothPlastic
	p.Anchored   = anchored ~= false
	p.CanCollide = true
	p.Parent     = parent
	return p
end

local function makeWedge(parent, name, size, cframe, color, material)
	local p = Instance.new("WedgePart")
	p.Name       = name
	p.Size       = size
	p.CFrame     = cframe
	p.BrickColor = BrickColor.new(color)
	p.Material   = material or Enum.Material.SmoothPlastic
	p.Anchored   = true
	p.CanCollide = true
	p.Parent     = parent
	return p
end

-- ============================================================
-- STEP 1: Base Terrain
-- ============================================================
print("[MapGen] Step 1: Base terrain...")

-- Tanah luas (grass), surface di Y=0
Terrain:FillBlock(
	CFrame.new(0, GROUND_Y - DEPTH / 2, 0),
	Vector3.new(MAP_HALF * 2, DEPTH, MAP_HALF * 2),
	Enum.Material.Grass
)
task.wait()

-- ── Area Chip Mine: ganti material jadi Rock di utara ────────
-- Dari Z = -600 sampai Z = -3000
Terrain:FillBlock(
	CFrame.new(0, GROUND_Y - DEPTH / 2, -1800),
	Vector3.new(2000, DEPTH, 2400),
	Enum.Material.Rock
)
task.wait()

-- ── Area HQ Accretia: Concrete/Metal feel ────────────────────
Terrain:FillBlock(
	CFrame.new(3000, GROUND_Y - DEPTH / 2, -2500),
	Vector3.new(1000, DEPTH, 1000),
	Enum.Material.Concrete
)
task.wait()

-- ── Laut di luar batas peta ──────────────────────────────────
-- Buat ocean tipis di sekeliling untuk batas visual
local oceanMat = Enum.Material.Water
local oceanDepth = 80
local oceanThick = 1200
-- Utara
Terrain:FillBlock(
	CFrame.new(0, GROUND_Y - oceanDepth / 2, -(MAP_HALF + oceanThick / 2)),
	Vector3.new(MAP_HALF * 2 + oceanThick * 2, oceanDepth, oceanThick),
	oceanMat
)
-- Selatan
Terrain:FillBlock(
	CFrame.new(0, GROUND_Y - oceanDepth / 2, MAP_HALF + oceanThick / 2),
	Vector3.new(MAP_HALF * 2 + oceanThick * 2, oceanDepth, oceanThick),
	oceanMat
)
-- Barat
Terrain:FillBlock(
	CFrame.new(-(MAP_HALF + oceanThick / 2), GROUND_Y - oceanDepth / 2, 0),
	Vector3.new(oceanThick, oceanDepth, MAP_HALF * 2),
	oceanMat
)
-- Timur
Terrain:FillBlock(
	CFrame.new(MAP_HALF + oceanThick / 2, GROUND_Y - oceanDepth / 2, 0),
	Vector3.new(oceanThick, oceanDepth, MAP_HALF * 2),
	oceanMat
)
task.wait()

-- ── Pegunungan batas (mencegah keluar peta) ───────────────────
local borderY   = GROUND_Y + 50   -- center bukit
local borderH   = 120
local borderW   = 300
print("[MapGen] Step 1b: Pegunungan batas...")

Terrain:FillBlock( -- Utara
	CFrame.new(0, borderY, -MAP_HALF),
	Vector3.new(MAP_HALF * 2, borderH, borderW),
	Enum.Material.Rock
)
Terrain:FillBlock( -- Selatan
	CFrame.new(0, borderY, MAP_HALF),
	Vector3.new(MAP_HALF * 2, borderH, borderW),
	Enum.Material.Rock
)
Terrain:FillBlock( -- Barat
	CFrame.new(-MAP_HALF, borderY, 0),
	Vector3.new(borderW, borderH, MAP_HALF * 2),
	Enum.Material.Rock
)
Terrain:FillBlock( -- Timur
	CFrame.new(MAP_HALF, borderY, 0),
	Vector3.new(borderW, borderH, MAP_HALF * 2),
	Enum.Material.Rock
)
task.wait()

-- ── Hills kecil di beberapa zona untuk variasi ───────────────
local hills = {
	Vector3.new(-2600, 0, -1800), -- antara Bellato dan Elan West
	Vector3.new(2600, 0, -1800),  -- antara Accretia dan Elan East
	Vector3.new(-1800, 0, -1100), -- Elan West menuju Novus NW
	Vector3.new(1800, 0, -1100),  -- Elan East menuju Novus NE
	Vector3.new(-500, 0, -1500),  -- sisi Chip Mine Approach barat
	Vector3.new(500, 0, -1500),   -- sisi Chip Mine Approach timur
}
for _, pos in ipairs(hills) do
	Terrain:FillBall(pos, 120, Enum.Material.Rock)
	task.wait()
end

-- ============================================================
-- STEP 2: Jalan / Roads
-- ============================================================
print("[MapGen] Step 2: Roads...")

local ROAD_WIDTH = 28  -- lebar jalan studs
local ROAD_DEPTH = 8   -- ketebalan jalan (surface sampai bawah)

local function makeRoad(fromZoneId, toZoneId, width)
	width = width or ROAD_WIDTH
	local from = Zones[fromZoneId].Center
	local to   = Zones[toZoneId].Center
	local dir  = (to - from)
	local dist = dir.Magnitude
	local mid  = Vector3.new((from.X + to.X) / 2, GROUND_Y - ROAD_DEPTH / 2, (from.Z + to.Z) / 2)
	local angle = math.atan2(dir.X, dir.Z)

	Terrain:FillBlock(
		CFrame.new(mid.X, mid.Y, mid.Z) * CFrame.Angles(0, angle, 0),
		Vector3.new(width, ROAD_DEPTH, dist),
		Enum.Material.Cobblestone
	)
end

for _, road in ipairs(MapDefinitions.Roads) do
	makeRoad(road[1], road[2])
	task.wait()
end

-- ============================================================
-- STEP 3: Folder untuk Model dan Spawner
-- ============================================================
print("[MapGen] Step 3: Setup folders...")

local worldFolder = workspace:FindFirstChild("World") or Instance.new("Folder")
worldFolder.Name = "World"
worldFolder.Parent = workspace

local spawnerFolder = workspace:FindFirstChild("MonsterSpawners") or Instance.new("Folder")
spawnerFolder.Name = "MonsterSpawners"
spawnerFolder.Parent = workspace

local raceSpawnFolder = workspace:FindFirstChild("RaceSpawns") or Instance.new("Folder")
raceSpawnFolder.Name = "RaceSpawns"
raceSpawnFolder.Parent = workspace

-- ============================================================
-- STEP 4: Struktur Bellato HQ
-- ============================================================
print("[MapGen] Step 4: Bellato HQ...")

local function buildBellatoHQ()
	local hq = Instance.new("Model")
	hq.Name = "BellatoHQ"
	hq.Parent = worldFolder

	local cx, cy, cz = -3000, GROUND_Y, -2500
	local stoneColor = "Medium stone grey"
	local wallMat = Enum.Material.SmoothPlastic

	-- Lantai plaza
	makePart(hq, "Plaza", Vector3.new(600, 4, 600),
		CFrame.new(cx, cy + 2, cz), "Warm greige", Enum.Material.SmoothPlastic)

	-- Tembok keliling (4 sisi, dengan gap di selatan sebagai gerbang)
	-- Utara
	makePart(hq, "WallN", Vector3.new(600, 24, 14),
		CFrame.new(cx, cy + 14, cz - 300), stoneColor, wallMat)
	-- Timur
	makePart(hq, "WallE", Vector3.new(14, 24, 600),
		CFrame.new(cx + 300, cy + 14, cz), stoneColor, wallMat)
	-- Barat
	makePart(hq, "WallW", Vector3.new(14, 24, 600),
		CFrame.new(cx - 300, cy + 14, cz), stoneColor, wallMat)
	-- Selatan kiri (ada gap 80 studs untuk gerbang)
	makePart(hq, "WallSL", Vector3.new(250, 24, 14),
		CFrame.new(cx - 175, cy + 14, cz + 300), stoneColor, wallMat)
	-- Selatan kanan
	makePart(hq, "WallSR", Vector3.new(250, 24, 14),
		CFrame.new(cx + 175, cy + 14, cz + 300), stoneColor, wallMat)

	-- Menara di empat sudut
	for _, corner in ipairs({
		Vector3.new(cx - 300, cy, cz - 300),
		Vector3.new(cx + 300, cy, cz - 300),
		Vector3.new(cx - 300, cy, cz + 300),
		Vector3.new(cx + 300, cy, cz + 300),
	}) do
		makePart(hq, "Tower", Vector3.new(30, 50, 30),
			CFrame.new(corner.X, cy + 25, corner.Z), stoneColor, wallMat)
		-- Atap menara
		makePart(hq, "TowerTop", Vector3.new(36, 14, 36),
			CFrame.new(corner.X, cy + 57, corner.Z), "Dark red", Enum.Material.SmoothPlastic)
	end

	-- Tiang gerbang
	makePart(hq, "GateL", Vector3.new(12, 32, 12),
		CFrame.new(cx - 46, cy + 18, cz + 300), stoneColor, wallMat)
	makePart(hq, "GateR", Vector3.new(12, 32, 12),
		CFrame.new(cx + 46, cy + 18, cz + 300), stoneColor, wallMat)
	-- Arch atas gerbang
	makePart(hq, "GateArch", Vector3.new(92, 8, 14),
		CFrame.new(cx, cy + 32, cz + 300), stoneColor, wallMat)

	-- Gedung utama (Barracks)
	makePart(hq, "MainHall", Vector3.new(180, 40, 140),
		CFrame.new(cx, cy + 22, cz - 100), "Medium stone grey", Enum.Material.SmoothPlastic)
	-- Atap
	makeWedge(hq, "RoofL", Vector3.new(140, 22, 90),
		CFrame.new(cx - 45, cy + 53, cz - 100) * CFrame.Angles(0, math.pi / 2, 0),
		"Dark red", Enum.Material.SmoothPlastic)
	makeWedge(hq, "RoofR", Vector3.new(140, 22, 90),
		CFrame.new(cx + 45, cy + 53, cz - 100) * CFrame.Angles(0, -math.pi / 2, 0),
		"Dark red", Enum.Material.SmoothPlastic)

	-- Bendera Bellato (tiang + flag)
	makePart(hq, "FlagPole", Vector3.new(3, 60, 3),
		CFrame.new(cx, cy + 32, cz - 180), "Light grey", Enum.Material.Metal)
	makePart(hq, "Flag", Vector3.new(28, 18, 2),
		CFrame.new(cx + 15, cy + 61, cz - 180), "Bright blue", Enum.Material.SmoothPlastic)

	-- SpawnLocation
	local spawnLoc = Instance.new("SpawnLocation")
	spawnLoc.Name = "Bellato_Spawn"
	spawnLoc.Size = Vector3.new(8, 1, 8)
	spawnLoc.CFrame = CFrame.new(cx, cy + 3, cz + 80)
	spawnLoc.Neutral = true
	spawnLoc.BrickColor = BrickColor.new("Bright blue")
	spawnLoc.Material = Enum.Material.Neon
	spawnLoc.Parent = raceSpawnFolder

	hq.PrimaryPart = hq:FindFirstChildOfClass("Part")
end

buildBellatoHQ()
task.wait()

-- ============================================================
-- STEP 5: Struktur Cora HQ
-- ============================================================
print("[MapGen] Step 5: Cora HQ...")

local function buildCoraHQ()
	local hq = Instance.new("Model")
	hq.Name = "CoraHQ"
	hq.Parent = worldFolder

	local cx, cy, cz = 0, GROUND_Y, 3500
	local whiteColor = "White"
	local crystalMat = Enum.Material.SmoothPlastic

	-- Lantai kuil (putih)
	makePart(hq, "Plaza", Vector3.new(600, 4, 600),
		CFrame.new(cx, cy + 2, cz), "White", Enum.Material.SmoothPlastic)

	-- Tembok keliling melingkar — kita pakai 8 segmen
	local wallRadius = 300
	local segCount   = 8
	for i = 1, segCount do
		local angle  = (i / segCount) * math.pi * 2
		local nx     = cx + math.cos(angle) * wallRadius
		local nz     = cz + math.sin(angle) * wallRadius
		local wallAngle = angle + math.pi / 2
		local isGate    = (i == 7) -- gap di sisi selatan (menuju Novus)
		if not isGate then
			local seg = makePart(hq, "Wall"..i, Vector3.new(14, 22, (2 * math.pi * wallRadius) / segCount + 2),
				CFrame.new(nx, cy + 13, nz) * CFrame.Angles(0, wallAngle, 0),
				whiteColor, crystalMat)
		end
	end

	-- Menara sudut (lebih tipis, ramping)
	for i = 1, 4 do
		local angle = ((i - 1) / 4) * math.pi * 2 + math.pi / 4
		local tx    = cx + math.cos(angle) * 310
		local tz    = cz + math.sin(angle) * 310
		makePart(hq, "Tower"..i, Vector3.new(22, 55, 22),
			CFrame.new(tx, cy + 28, tz), "White", crystalMat)
		-- Kristal di atas menara
		makePart(hq, "Crystal"..i, Vector3.new(14, 30, 14),
			CFrame.new(tx, cy + 72, tz), "Cyan", Enum.Material.Neon)
	end

	-- Kuil utama (bangunan octagonal / bulat)
	makePart(hq, "Temple", Vector3.new(160, 50, 160),
		CFrame.new(cx, cy + 27, cz - 60), "White", crystalMat)
	-- Kubah
	makePart(hq, "Dome", Vector3.new(140, 60, 140),
		CFrame.new(cx, cy + 82, cz - 60), "Light cyan", Enum.Material.Neon)
	-- Kolom depan
	for _, dx in ipairs({ -60, -20, 20, 60 }) do
		makePart(hq, "Column"..dx, Vector3.new(10, 55, 10),
			CFrame.new(cx + dx, cy + 30, cz + 22), "White", crystalMat)
	end

	-- Bendera Cora
	makePart(hq, "FlagPole", Vector3.new(3, 60, 3),
		CFrame.new(cx, cy + 32, cz - 190), "Light grey", Enum.Material.Metal)
	makePart(hq, "Flag", Vector3.new(28, 18, 2),
		CFrame.new(cx + 15, cy + 61, cz - 190), "Bright green", Enum.Material.SmoothPlastic)

	-- SpawnLocation
	local spawnLoc = Instance.new("SpawnLocation")
	spawnLoc.Name = "Cora_Spawn"
	spawnLoc.Size = Vector3.new(8, 1, 8)
	spawnLoc.CFrame = CFrame.new(cx, cy + 3, cz - 100)
	spawnLoc.Neutral = true
	spawnLoc.BrickColor = BrickColor.new("Bright green")
	spawnLoc.Material = Enum.Material.Neon
	spawnLoc.Parent = raceSpawnFolder

	hq.PrimaryPart = hq:FindFirstChildOfClass("Part")
end

buildCoraHQ()
task.wait()

-- ============================================================
-- STEP 6: Struktur Accretia HQ
-- ============================================================
print("[MapGen] Step 6: Accretia HQ...")

local function buildAccretiaHQ()
	local hq = Instance.new("Model")
	hq.Name = "AccretiaHQ"
	hq.Parent = worldFolder

	local cx, cy, cz = 3000, GROUND_Y, -2500
	local metalColor = "Dark stone grey"
	local metalMat   = Enum.Material.Metal

	-- Lantai industrial (logam)
	makePart(hq, "Plaza", Vector3.new(640, 4, 640),
		CFrame.new(cx, cy + 2, cz), "Sand green", metalMat)
	-- Grid lines di lantai
	for i = -2, 2 do
		makePart(hq, "GridX"..i, Vector3.new(640, 1, 6),
			CFrame.new(cx, cy + 5, cz + i * 110), "Dark stone grey", metalMat)
		makePart(hq, "GridZ"..i, Vector3.new(6, 1, 640),
			CFrame.new(cx + i * 110, cy + 5, cz), "Dark stone grey", metalMat)
	end

	-- Tembok persegi panjang (lebih tebal, industrial)
	makePart(hq, "WallN", Vector3.new(640, 30, 18),
		CFrame.new(cx, cy + 17, cz - 320), metalColor, metalMat)
	makePart(hq, "WallE", Vector3.new(18, 30, 640),
		CFrame.new(cx + 320, cy + 17, cz), metalColor, metalMat)
	makePart(hq, "WallW", Vector3.new(18, 30, 640),
		CFrame.new(cx - 320, cy + 17, cz), metalColor, metalMat)
	-- Selatan: gerbang besar
	makePart(hq, "WallSL", Vector3.new(260, 30, 18),
		CFrame.new(cx - 190, cy + 17, cz + 320), metalColor, metalMat)
	makePart(hq, "WallSR", Vector3.new(260, 30, 18),
		CFrame.new(cx + 190, cy + 17, cz + 320), metalColor, metalMat)

	-- Menara (lebih besar, silinder di atas box)
	for _, corner in ipairs({
		Vector3.new(cx - 320, cy, cz - 320),
		Vector3.new(cx + 320, cy, cz - 320),
		Vector3.new(cx - 320, cy, cz + 320),
		Vector3.new(cx + 320, cy, cz + 320),
	}) do
		makePart(hq, "TowerBase", Vector3.new(40, 40, 40),
			CFrame.new(corner.X, cy + 22, corner.Z), metalColor, metalMat)
		makePart(hq, "TowerTop", Vector3.new(30, 24, 30),
			CFrame.new(corner.X, cy + 54, corner.Z), "Dark orange", Enum.Material.Neon)
	end

	-- Gerbang Accretia: dua tiang besar + radar dish
	makePart(hq, "GateL", Vector3.new(16, 40, 16),
		CFrame.new(cx - 60, cy + 22, cz + 320), metalColor, metalMat)
	makePart(hq, "GateR", Vector3.new(16, 40, 16),
		CFrame.new(cx + 60, cy + 22, cz + 320), metalColor, metalMat)
	makePart(hq, "GateArch", Vector3.new(120, 10, 18),
		CFrame.new(cx, cy + 42, cz + 320), metalColor, metalMat)
	-- Radar dish
	makePart(hq, "RadarDish", Vector3.new(40, 6, 40),
		CFrame.new(cx, cy + 52, cz + 320), "Dark stone grey", metalMat)

	-- Command Center (gedung utama kotak besar)
	makePart(hq, "CommandBase", Vector3.new(220, 50, 160),
		CFrame.new(cx, cy + 27, cz - 100), metalColor, metalMat)
	makePart(hq, "CommandTop", Vector3.new(180, 20, 120),
		CFrame.new(cx, cy + 62, cz - 100), "Dark orange", Enum.Material.Neon)
	-- Antena di atas
	makePart(hq, "Antenna", Vector3.new(4, 50, 4),
		CFrame.new(cx, cy + 82, cz - 100), "Sand green", metalMat)
	makePart(hq, "AntennaTop", Vector3.new(20, 4, 20),
		CFrame.new(cx, cy + 108, cz - 100), "Bright orange", Enum.Material.Neon)

	-- Bendera Accretia
	makePart(hq, "FlagPole", Vector3.new(3, 60, 3),
		CFrame.new(cx, cy + 32, cz - 260), "Light grey", metalMat)
	makePart(hq, "Flag", Vector3.new(28, 18, 2),
		CFrame.new(cx + 15, cy + 61, cz - 260), "Bright red", Enum.Material.SmoothPlastic)

	-- SpawnLocation
	local spawnLoc = Instance.new("SpawnLocation")
	spawnLoc.Name = "Accretia_Spawn"
	spawnLoc.Size = Vector3.new(8, 1, 8)
	spawnLoc.CFrame = CFrame.new(cx, cy + 3, cz + 100)
	spawnLoc.Neutral = true
	spawnLoc.BrickColor = BrickColor.new("Bright red")
	spawnLoc.Material = Enum.Material.Neon
	spawnLoc.Parent = raceSpawnFolder

	hq.PrimaryPart = hq:FindFirstChildOfClass("Part")
end

buildAccretiaHQ()
task.wait()

-- ============================================================
-- STEP 7: Chip Mine Core — Struktur ikonik RF Classic
-- ============================================================
print("[MapGen] Step 7: Chip Mine Core...")

local function buildChipMineTower()
	local mine = Instance.new("Model")
	mine.Name = "ChipMineCore"
	mine.Parent = worldFolder

	local cx, cy, cz = 0, GROUND_Y, -2200
	local rockColor  = "Dark stone grey"

	-- Platform base besar
	makePart(mine, "BasePlatform", Vector3.new(500, 8, 500),
		CFrame.new(cx, cy + 4, cz), "Sand grey", Enum.Material.SmoothPlastic)

	-- Tembok keliling chip mine (8 segmen)
	local wallR = 230
	for i = 1, 8 do
		local a   = (i / 8) * math.pi * 2
		local nx  = cx + math.cos(a) * wallR
		local nz  = cz + math.sin(a) * wallR
		local wa  = a + math.pi / 2
		local seg = (2 * math.pi * wallR) / 8 + 2
		-- Empat gap (tiap 2 segmen ada satu gap) untuk entrance dari tiap arah
		if i ~= 2 and i ~= 4 and i ~= 6 and i ~= 8 then
			makePart(mine, "Wall"..i, Vector3.new(14, 28, seg),
				CFrame.new(nx, cy + 16, nz) * CFrame.Angles(0, wa, 0),
				rockColor, Enum.Material.SmoothPlastic)
		end
	end

	-- Menara penjaga di sudut (4 buah)
	for i = 1, 4 do
		local a  = ((i - 1) / 4) * math.pi * 2 + math.pi / 4
		local tx = cx + math.cos(a) * 240
		local tz = cz + math.sin(a) * 240
		makePart(mine, "GuardTower"..i, Vector3.new(28, 50, 28),
			CFrame.new(tx, cy + 27, tz), rockColor, Enum.Material.SmoothPlastic)
		makePart(mine, "GuardLight"..i, Vector3.new(20, 16, 20),
			CFrame.new(tx, cy + 58, tz), "Bright orange", Enum.Material.Neon)
	end

	-- Tiga Chip Capture Points (segitiga sama sisi mengelilingi tower utama)
	-- RF Classic: tiga titik capture yang diperebutkan tiga ras
	local chipRadius = 120
	local chipColors = { "Bright blue", "Bright green", "Bright red" }
	for i = 1, 3 do
		local a   = ((i - 1) / 3) * math.pi * 2 - math.pi / 2
		local cpx = cx + math.cos(a) * chipRadius
		local cpz = cz + math.sin(a) * chipRadius

		-- Platform chip
		makePart(mine, "ChipBase"..i, Vector3.new(40, 6, 40),
			CFrame.new(cpx, cy + 11, cpz), "Sand grey", Enum.Material.SmoothPlastic)
		-- Chip node (glowing)
		local chipPart = makePart(mine, "ChipNode"..i, Vector3.new(20, 20, 20),
			CFrame.new(cpx, cy + 24, cpz), chipColors[i], Enum.Material.Neon)
		-- Tag untuk sistem Chip War nanti
		local tag = Instance.new("StringValue")
		tag.Name  = "ChipId"
		tag.Value = "Chip"..i
		tag.Parent = chipPart

		-- PointLight di chip node
		local light = Instance.new("PointLight")
		light.Range       = 50
		light.Brightness  = 2
		light.Color       = chipPart.Color
		light.Parent = chipPart
	end

	-- ── Tower utama (Force Core) ────────────────────────────
	-- Base cylinder (dibuat dari Part + special look)
	makePart(mine, "TowerBase1", Vector3.new(52, 30, 52),
		CFrame.new(cx, cy + 17, cz), rockColor, Enum.Material.SmoothPlastic)
	makePart(mine, "TowerBase2", Vector3.new(44, 30, 44),
		CFrame.new(cx, cy + 47, cz), "Dark stone grey", Enum.Material.SmoothPlastic)
	makePart(mine, "TowerMid",   Vector3.new(36, 30, 36),
		CFrame.new(cx, cy + 77, cz), "Dark stone grey", Enum.Material.SmoothPlastic)
	makePart(mine, "TowerTop",   Vector3.new(28, 30, 28),
		CFrame.new(cx, cy + 107, cz), "Dark stone grey", Enum.Material.SmoothPlastic)

	-- Force Core crystal di puncak (glow utama)
	local forceCore = makePart(mine, "ForceCore", Vector3.new(22, 40, 22),
		CFrame.new(cx, cy + 142, cz), "Cyan", Enum.Material.Neon)
	local coreLight = Instance.new("PointLight")
	coreLight.Range      = 300
	coreLight.Brightness = 3
	coreLight.Color      = Color3.fromRGB(0, 220, 255)
	coreLight.Parent = forceCore

	-- Ring di tengah tower
	makePart(mine, "Ring1", Vector3.new(70, 8, 70),
		CFrame.new(cx, cy + 62, cz), "Bright orange", Enum.Material.Neon)
	makePart(mine, "RingInner1", Vector3.new(52, 9, 52),
		CFrame.new(cx, cy + 62, cz), rockColor, Enum.Material.SmoothPlastic)

	mine.PrimaryPart = mine:FindFirstChildOfClass("Part")
end

buildChipMineTower()
task.wait()

-- ============================================================
-- STEP 8: Landmark ringan di Novus Center
-- ============================================================
print("[MapGen] Step 8: Novus Center landmark...")

local function buildNovusCenter()
	local nm = Instance.new("Model")
	nm.Name = "NovusCenter"
	nm.Parent = worldFolder

	-- Lingkaran batu tengah (meeting point tiga ras)
	makePart(nm, "StoneRing", Vector3.new(100, 4, 100),
		CFrame.new(0, GROUND_Y + 2, 0), "Medium stone grey", Enum.Material.SmoothPlastic)
	makePart(nm, "StoneInner", Vector3.new(70, 5, 70),
		CFrame.new(0, GROUND_Y + 2, 0), "Sand grey", Enum.Material.SmoothPlastic)
	-- Empat tiang di sudut
	for _, pos in ipairs({
		Vector3.new(-42, 0, -42), Vector3.new(42, 0, -42),
		Vector3.new(-42, 0, 42),  Vector3.new(42, 0, 42),
	}) do
		makePart(nm, "Pillar", Vector3.new(8, 30, 8),
			CFrame.new(pos.X, GROUND_Y + 17, pos.Z), "Medium stone grey", Enum.Material.SmoothPlastic)
	end
	-- Torches di atas tiang
	for _, pos in ipairs({
		Vector3.new(-42, 32, -42), Vector3.new(42, 32, -42),
		Vector3.new(-42, 32, 42),  Vector3.new(42, 32, 42),
	}) do
		local torch = makePart(nm, "Torch", Vector3.new(6, 6, 6),
			CFrame.new(pos.X, GROUND_Y + pos.Y, pos.Z), "Bright orange", Enum.Material.Neon)
		local fl = Instance.new("PointLight")
		fl.Range = 40; fl.Brightness = 1.5
		fl.Color = Color3.fromRGB(255, 150, 0)
		fl.Parent = torch
	end
end

buildNovusCenter()
task.wait()

-- ============================================================
-- STEP 9: Monster Spawners
-- ============================================================
print("[MapGen] Step 9: Monster spawners...")

math.randomseed(12345)  -- seed tetap agar posisi konsisten tiap restart

for zoneId, spawnList in pairs(MapDefinitions.SpawnConfig) do
	local zone = Zones[zoneId]
	if not zone then continue end

	local zoneCenter = zone.Center

	for _, entry in ipairs(spawnList) do
		for i = 1, entry.Count do
			-- Posisi acak dalam radius sebaran
			local angle  = math.random() * math.pi * 2
			local radius = math.random() * entry.Spread
			local spawnX = zoneCenter.X + math.cos(angle) * radius
			local spawnZ = zoneCenter.Z + math.sin(angle) * radius

			local spawner = Instance.new("Part")
			spawner.Name        = "Spawner_" .. entry.DefId .. "_" .. i
			spawner.Size        = Vector3.new(4, 1, 4)
			spawner.CFrame      = CFrame.new(spawnX, GROUND_Y + 1, spawnZ)
			spawner.Anchored    = true
			spawner.CanCollide  = false
			spawner.Transparency = 1   -- invisible saat runtime
			spawner:SetAttribute("MonsterDefId", entry.DefId)
			spawner:SetAttribute("ZoneId", zoneId)
			spawner.Parent = spawnerFolder
		end
	end
	task.wait()
end

-- ============================================================
-- STEP 10: Spawn Default (fallback, neutral)
-- ============================================================
print("[MapGen] Step 10: Default spawn...")

local defaultSpawn = workspace:FindFirstChildOfClass("SpawnLocation")
if not defaultSpawn then
	defaultSpawn = Instance.new("SpawnLocation")
	defaultSpawn.Size = Vector3.new(8, 1, 8)
	defaultSpawn.CFrame = CFrame.new(0, GROUND_Y + 1, 0)
	defaultSpawn.Neutral = true
	defaultSpawn.BrickColor = BrickColor.new("Medium stone grey")
	defaultSpawn.Parent = workspace
end

-- ============================================================
-- SELESAI
-- ============================================================
local marker = Instance.new("BoolValue")
marker.Name   = "_MapGenerated"
marker.Value  = true
marker.Parent = workspace

print("[MapGen] ✓ Peta Aetherion Phase 1 berhasil di-generate!")
print("[MapGen]   Zones: " .. #(function()
	local t = {} for k in pairs(Zones) do t[#t+1] = k end return t
end)())
print("[MapGen]   Spawners: " .. #spawnerFolder:GetChildren())
