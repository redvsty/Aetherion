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
local GROUND_Y   = MapDefinitions.GROUND_Y
local DEPTH      = MapDefinitions.TERRAIN_DEPTH   -- 30
local MAP_HALF   = MapDefinitions.MAP_HALF         -- 7000

-- ================================================================
-- Helpers
-- ================================================================

local function fill(cx, cz, w, d, mat, yBase, height)
	yBase  = yBase  or GROUND_Y
	height = height or DEPTH
	Terrain:FillBlock(
		CFrame.new(cx, yBase - height / 2, cz),
		Vector3.new(w, height, d),
		mat
	)
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
	ball(h[1], 0, h[2], h[3] or 120, Enum.Material.Rock)
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
	local stone = "Medium stone grey"
	local red   = "Bright red"

	-- Tembok luar
	part(m,"Plaza",   Vector3.new(700,4,700),   CFrame.new(cx,cy+2,cz),     "Warm greige", Enum.Material.SmoothPlastic)
	part(m,"WallN",   Vector3.new(700,26,14),   CFrame.new(cx,cy+15,cz-350), stone, Enum.Material.SmoothPlastic)
	part(m,"WallE",   Vector3.new(14,26,700),   CFrame.new(cx+350,cy+15,cz), stone, Enum.Material.SmoothPlastic)
	part(m,"WallW",   Vector3.new(14,26,700),   CFrame.new(cx-350,cy+15,cz), stone, Enum.Material.SmoothPlastic)
	part(m,"WallSL",  Vector3.new(280,26,14),   CFrame.new(cx-210,cy+15,cz+350), stone, Enum.Material.SmoothPlastic)
	part(m,"WallSR",  Vector3.new(280,26,14),   CFrame.new(cx+210,cy+15,cz+350), stone, Enum.Material.SmoothPlastic)
	-- Menara sudut
	for _, c in ipairs({ {-350,-350},{350,-350},{-350,350},{350,350} }) do
		part(m,"Tower",Vector3.new(34,52,34),CFrame.new(cx+c[1],cy+28,cz+c[2]),stone,Enum.Material.SmoothPlastic)
		part(m,"TTop", Vector3.new(40,16,40),CFrame.new(cx+c[1],cy+60,cz+c[2]),red,  Enum.Material.SmoothPlastic)
	end
	-- Gerbang
	part(m,"GateL",   Vector3.new(13,34,13),  CFrame.new(cx-50,cy+19,cz+350), stone, Enum.Material.SmoothPlastic)
	part(m,"GateR",   Vector3.new(13,34,13),  CFrame.new(cx+50,cy+19,cz+350), stone, Enum.Material.SmoothPlastic)
	part(m,"GateArch",Vector3.new(100,9,14),  CFrame.new(cx,cy+36,cz+350),    stone, Enum.Material.SmoothPlastic)
	-- Barracks
	part(m,"Barracks",Vector3.new(200,42,150),CFrame.new(cx,cy+23,cz-100),    stone, Enum.Material.SmoothPlastic)
	wedge(m,"RoofL",  Vector3.new(150,24,100),CFrame.new(cx-50,cy+56,cz-100)*CFrame.Angles(0,math.pi/2,0),red)
	wedge(m,"RoofR",  Vector3.new(150,24,100),CFrame.new(cx+50,cy+56,cz-100)*CFrame.Angles(0,-math.pi/2,0),red)
	-- Bendera
	part(m,"FlagPole",Vector3.new(3,62,3),    CFrame.new(cx,cy+33,cz-230),    "Light grey", Enum.Material.Metal)
	part(m,"Flag",    Vector3.new(30,20,2),   CFrame.new(cx+16,cy+63,cz-230), "Bright blue",Enum.Material.SmoothPlastic)
	neonLight(m, Vector3.new(cx,cy+70,cz), Color3.fromRGB(100,149,255), 120, 1.2)

	spawnLoc(raceSpawnFolder, "Bellato_Spawn", Vector3.new(cx,cy+2,cz+100), "Bright blue")
end
buildBellatoHQ(); task.wait()

-- ================================================================
-- STEP 5: Accretia HQ
-- ================================================================
print("[MapGen] 5/10 Accretia HQ...")

local function buildAccretiaHQ()
	local m = Instance.new("Model"); m.Name = "AccretiaHQ"; m.Parent = worldFolder
	local cx, cy, cz = 5500, GROUND_Y, 500
	local metal = "Dark stone grey"
	local orange= "Bright orange"

	part(m,"Plaza",  Vector3.new(700,4,700),  CFrame.new(cx,cy+2,cz),     "Sand green", Enum.Material.Metal)
	-- Grid lines
	for i=-2,2 do
		part(m,"GX"..i,Vector3.new(700,1,5),CFrame.new(cx,cy+5,cz+i*120),metal,Enum.Material.Metal)
		part(m,"GZ"..i,Vector3.new(5,1,700),CFrame.new(cx+i*120,cy+5,cz),metal,Enum.Material.Metal)
	end
	-- Tembok
	part(m,"WallN",  Vector3.new(700,32,18), CFrame.new(cx,cy+18,cz-350),  metal, Enum.Material.Metal)
	part(m,"WallE",  Vector3.new(18,32,700), CFrame.new(cx+350,cy+18,cz),  metal, Enum.Material.Metal)
	part(m,"WallW",  Vector3.new(18,32,700), CFrame.new(cx-350,cy+18,cz),  metal, Enum.Material.Metal)
	part(m,"WallSL", Vector3.new(280,32,18), CFrame.new(cx-210,cy+18,cz+350),metal,Enum.Material.Metal)
	part(m,"WallSR", Vector3.new(280,32,18), CFrame.new(cx+210,cy+18,cz+350),metal,Enum.Material.Metal)
	-- Menara
	for _, c in ipairs({ {-350,-350},{350,-350},{-350,350},{350,350} }) do
		part(m,"TBase",Vector3.new(44,44,44),CFrame.new(cx+c[1],cy+24,cz+c[2]),metal, Enum.Material.Metal)
		part(m,"TTop", Vector3.new(32,26,32),CFrame.new(cx+c[1],cy+57,cz+c[2]),orange,Enum.Material.Neon)
	end
	-- Gerbang
	part(m,"GateL",  Vector3.new(16,42,16), CFrame.new(cx-65,cy+23,cz+350), metal, Enum.Material.Metal)
	part(m,"GateR",  Vector3.new(16,42,16), CFrame.new(cx+65,cy+23,cz+350), metal, Enum.Material.Metal)
	part(m,"GateTop",Vector3.new(130,10,18),CFrame.new(cx,cy+44,cz+350),    metal, Enum.Material.Metal)
	-- Command center
	part(m,"CmdBase",Vector3.new(240,52,170),CFrame.new(cx,cy+28,cz-100),   metal, Enum.Material.Metal)
	part(m,"CmdTop", Vector3.new(200,22,130),CFrame.new(cx,cy+63,cz-100),   orange,Enum.Material.Neon)
	part(m,"Antenna",Vector3.new(4,55,4),   CFrame.new(cx,cy+85,cz-100),    "Sand green",Enum.Material.Metal)
	part(m,"AntTop", Vector3.new(22,4,22),  CFrame.new(cx,cy+113,cz-100),   orange,Enum.Material.Neon)
	-- Bendera
	part(m,"FlagPole",Vector3.new(3,62,3),  CFrame.new(cx,cy+33,cz-270),    "Light grey",Enum.Material.Metal)
	part(m,"Flag",   Vector3.new(30,20,2),  CFrame.new(cx+16,cy+63,cz-270), "Bright red",Enum.Material.SmoothPlastic)
	neonLight(m, Vector3.new(cx,cy+80,cz), Color3.fromRGB(255,100,50), 120, 1.2)

	spawnLoc(raceSpawnFolder, "Accretia_Spawn", Vector3.new(cx,cy+2,cz+100), "Bright red")
end
buildAccretiaHQ(); task.wait()

-- ================================================================
-- STEP 6: Cora HQ
-- ================================================================
print("[MapGen] 6/10 Cora HQ...")

local function buildCoraHQ()
	local m = Instance.new("Model"); m.Name = "CoraHQ"; m.Parent = worldFolder
	local cx, cy, cz = 0, GROUND_Y, 5800
	local white = "White"
	local cyan  = "Cyan"

	part(m,"Plaza",Vector3.new(700,4,700), CFrame.new(cx,cy+2,cz), "White", Enum.Material.SmoothPlastic)
	-- Tembok melingkar 8 segmen
	local wr = 340; local seg = 8
	for i=1,seg do
		local a = (i/seg)*math.pi*2
		local nx,nz = cx+math.cos(a)*wr, cz+math.sin(a)*wr
		if i~=7 then -- gap di selatan (arah Novus)
			part(m,"Wall"..i,Vector3.new(14,24,(2*math.pi*wr/seg)+2),
				CFrame.new(nx,cy+14,nz)*CFrame.Angles(0,a+math.pi/2,0),
				white,Enum.Material.SmoothPlastic)
		end
	end
	-- Menara kristal
	for i=1,4 do
		local a = ((i-1)/4)*math.pi*2+math.pi/4
		local tx,tz = cx+math.cos(a)*355,cz+math.sin(a)*355
		part(m,"Tower"..i,Vector3.new(24,58,24),CFrame.new(tx,cy+31,tz),white,Enum.Material.SmoothPlastic)
		part(m,"Crystal"..i,Vector3.new(16,32,16),CFrame.new(tx,cy+76,tz),cyan,Enum.Material.Neon)
		neonLight(m,Vector3.new(tx,cy+90,tz),Color3.fromRGB(0,255,220),60,1.5)
	end
	-- Kuil
	part(m,"Temple",Vector3.new(170,52,170),CFrame.new(cx,cy+28,cz-70),white,Enum.Material.SmoothPlastic)
	part(m,"Dome",  Vector3.new(150,64,150),CFrame.new(cx,cy+84,cz-70),cyan, Enum.Material.Neon)
	for _,dx in ipairs({-65,-22,22,65}) do
		part(m,"Col"..dx,Vector3.new(11,56,11),CFrame.new(cx+dx,cy+30,cz+16),white,Enum.Material.SmoothPlastic)
	end
	part(m,"FlagPole",Vector3.new(3,62,3),CFrame.new(cx,cy+33,cz-205),"Light grey",Enum.Material.Metal)
	part(m,"Flag",Vector3.new(30,20,2),CFrame.new(cx+16,cy+63,cz-205),"Bright green",Enum.Material.SmoothPlastic)
	neonLight(m,Vector3.new(cx,cy+80,cz),Color3.fromRGB(0,255,180),130,1.2)

	spawnLoc(raceSpawnFolder,"Cora_Spawn",Vector3.new(cx,cy+2,cz-100),"Bright green")
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
