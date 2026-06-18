-- MapGenerator.server.lua
-- Terrain generation (alam saja: gunung, laut, rawa, es, lava, dll) + NPC placement.

local MapDefinitions = require(game.ReplicatedStorage.Shared.Definitions.MapDefinitions)

print("[MapGen] Starting world generation...")

if workspace:FindFirstChild("_MapGenerated") then
	print("[MapGen] Already generated, skipping.")
	return
end

-- Hapus Baseplate default Roblox yang menutupi terrain
for _, name in ipairs({"Baseplate", "Base", "BasePlate"}) do
	local bp = workspace:FindFirstChild(name)
	if bp and bp:IsA("BasePart") then bp:Destroy() end
end

local GROUND_Y = MapDefinitions.GROUND_Y   -- 0
local ETHER_Y  = 400                        -- Platform Ether elevation
local Terrain  = workspace.Terrain
local M        = Enum.Material
local HD       = 20  -- half-depth for terrain fills (total 40 studs underground)

-- ================================================================
-- Terrain Helpers
-- ================================================================

-- Fill rectangular terrain slab, auto-tiled (Roblox FillBlock max ~2048/axis).
-- yBase = TOP surface Y (default GROUND_Y). height = slab height (default HD*2).
-- Fills from (yBase - height) to yBase.
local TILE = 1500
local function fill(cx, cz, w, d, mat, yBase, height)
	yBase  = yBase  or GROUND_Y
	height = height or (HD * 2)
	local halfH = height / 2
	local x0, z0 = cx - w/2, cz - d/2
	local xi = x0
	while xi < x0 + w do
		local tw = math.min(TILE, x0 + w - xi)
		local zi = z0
		while zi < z0 + d do
			local td = math.min(TILE, z0 + d - zi)
			Terrain:FillBlock(
				CFrame.new(xi + tw/2, yBase - halfH, zi + td/2),
				Vector3.new(tw, height, td),
				mat
			)
			zi = zi + TILE
		end
		xi = xi + TILE
		task.wait()
	end
end

-- Fill a sphere. cy=0 → perfect hemisphere above ground (recommended for hills).
local function ball(cx, cy, cz, r, mat)
	Terrain:FillBall(Vector3.new(cx, cy, cz), r, mat)
end

-- ================================================================
-- Folders
-- ================================================================
local worldFolder = Instance.new("Folder")
worldFolder.Name = "World"; worldFolder.Parent = workspace
local raceSpawnFolder = Instance.new("Folder")
raceSpawnFolder.Name = "RaceSpawns"; raceSpawnFolder.Parent = workspace

-- ================================================================
-- PHASE 1 — Base Terrain Fills (large regions, layer by layer)
-- ================================================================
print("[MapGen] Phase 1: Base terrain...")

-- 1a. Whole map: Grass base
fill(0, 0, 14000, 14000, M.Grass)
task.wait()

-- 1b. Accretia territory (timur, X positif): arid/desert sandy
-- X from ~2000 to 7000, Z from -2500 to 4000
fill(4500, 750, 5000, 6500, M.Sand)
task.wait()

-- 1c. Neutral center strip: Ground/Dirt (transitional zone)
-- X from -2200 to 2200, Z from -3800 to 2500
fill(0, -650, 4400, 6300, M.Ground)
task.wait()

-- 1d. Crag Mine Field: Rocky plateau
fill(0, -3500, 1800, 1800, M.Rock)
task.wait()

-- 1e. Armory 117 (barat laut): industrial rock terrain
fill(-2700, -3300, 2400, 1800, M.Rock)
-- Armory 213 (timur laut): mirror
fill(2700, -3300, 2400, 1800, M.Rock)
task.wait()

-- 1f. Sette Desert: full sandy desert
fill(0, -5200, 4400, 2200, M.Sand)
task.wait()

-- 1g. Cauldron Volcanic Area: lava crust
fill(0, -6700, 3200, 2800, M.CrackedLava)
task.wait()

-- 1h. Platform Ether: snowy floating island (Y=400)
fill(0, -4200, 2400, 2400, M.Snow, ETHER_Y)
task.wait()

-- 1i. Mud patches: marshes dan rawa
fill(-1600, -400, 800, 900, M.Mud)   -- Silence Marsh (Haram area)
fill(1200, 2800, 700, 700, M.Mud)    -- Fog Marsh (Cora)
fill(-3200, -3200, 700, 700, M.Mud)  -- Somora Moor (Armory 117)
fill(1600, -3200, 700, 700, M.Mud)   -- Cruel Moor (Armory 213)
fill(-1800, 3600, 600, 600, M.Mud)   -- Dark Plain (Cora, rawa gelap)
task.wait()

-- 1j. Hutan lebat (pakai Grass agar universal di semua Roblox version)
fill(0, 5200, 2200, 2200, M.Grass)       -- hutan selatan (Cora HQ area)
fill(-1200, -1600, 800, 800, M.Grass)    -- Shadow Forest (Haram)
fill(2200, -1600, 800, 800, M.Grass)     -- Holy Forest (Numerus)
fill(600, 3200, 600, 600, M.Grass)       -- Spire Forest (Cora)
fill(1000, -3000, 600, 600, M.Grass)     -- Crawler Forest
task.wait()

-- 1k. Sand patches di dalam Accretia territory untuk variasi
fill(4500, -800, 900, 900, M.Rock)  -- Crater Desert formation (rock rim)
task.wait()

-- ================================================================
-- PHASE 2 — Border Walls + Hills & Mountains
-- ================================================================
print("[MapGen] Phase 2: Mountains and hills...")

-- Border walls (solid fill, same approach as old code).
-- fill(cx, cz, w, d, mat, yBase, height): yBase = top Y of wall, height = wall height.
-- Wall goes from (yBase-height) to yBase.
local BH = MapDefinitions.MAP_HALF  -- 7000
local bh = 140
fill(0,   -BH, BH*2, 600, M.Rock, GROUND_Y + bh/2, bh)  -- utara
fill(0,    BH, BH*2, 600, M.Rock, GROUND_Y + bh/2, bh)  -- selatan
fill(-BH,   0, 600, BH*2, M.Rock, GROUND_Y + bh/2, bh)  -- barat
fill( BH,   0, 600, BH*2, M.Rock, GROUND_Y + bh/2, bh)  -- timur
task.wait()

-- Hills (cy=0 → perfect hemisphere, half underground / half above ground).
-- radius = height above ground.

-- BELLATO territory: bukit di dekat HQ agar langsung terlihat dari spawn
local hills = {
	-- Dekat Bellato HQ (spawn di -5500, 500)
	{-4200, 0,  1800, 160, M.Rock},  -- bukit besar Bellato canyon
	{-3500, 0,  2200, 130, M.Rock},  -- canyon 2
	{-4800, 0,  -300, 140, M.Rock},  -- Wind Cliff
	{-5200, 0,  -600, 110, M.Rock},  -- Wind Cliff barat
	-- Dekat Accretia HQ (spawn di 5500, 500)
	{4200,  0,   800, 160, M.Rock},  -- bukit besar Accretia
	{3600,  0,  1400, 140, M.Rock},  -- crater rim
	{4800,  0,  -500, 120, M.Rock},  -- arid cliffs
	-- Dekat Cora HQ (spawn di 0, 5800)
	{-800,  0,  4200, 150, M.Rock},  -- Spire Forest hills
	{ 600,  0,  4000, 130, M.Rock},  -- Cora hills timur
	-- Neutral center (Arayan Mountain Range) — major landmark
	{ 200,  0, -2400, 200, M.Rock},  -- puncak utama
	{-200,  0, -2600, 170, M.Rock},  -- puncak kedua
	{ 500,  0, -2200, 150, M.Rock},  -- puncak ketiga
	{-500,  0, -2800, 140, M.Rock},  -- puncak keempat
	-- Thunder Cliff + Rocky area
	{-400,  0, -3000, 130, M.Rock},
	{   0,  0, -3000, 120, M.Rock},
	{-2000, 0, -2400, 110, M.Rock},  -- Haram rocky cavern
	{ 2000, 0, -2600, 110, M.Rock},  -- Numerus highland
}
for _, h in ipairs(hills) do
	ball(h[1], h[2], h[3], h[4], h[5] or M.Rock)
	task.wait()
end

-- CAULDRON volcanic mountains
local cauldronHills = {
	{-400, 0, -6300, 130, M.Rock},   -- utara Belphegor
	{ 400, 0, -6300, 120, M.Rock},
	{-750, 0, -6600, 140, M.Rock},
	{ 750, 0, -6600, 140, M.Rock},
	{   0, 0, -7300, 150, M.Rock},   -- selatan jauh
	{-400, 0, -6850, 110, M.CrackedLava},  -- Belphegor lava spires
	{ 300, 0, -6800,  90, M.CrackedLava},
}
for _, h in ipairs(cauldronHills) do
	ball(h[1], h[2], h[3], h[4], h[5])
	task.wait()
end

-- SETTE HIGHLAND: mesa pasir dengan tebing batu
ball(800,  0, -5600, 100, M.Rock)
ball(600,  0, -5400,  80, M.Rock)
ball(1050, 0, -5750,  90, M.Rock)
task.wait()

-- Crater floor depression (Accretia)
Terrain:FillBall(Vector3.new(4500, -30, -850), 110, M.Sand)
task.wait()

-- ================================================================
-- PHASE 3 — Water Bodies
-- ================================================================
print("[MapGen] Phase 3: Water bodies...")

-- Surface air di Y≈8 (slightly above ground). Formula: cy = -(r - 8).
-- Red Beach (Cora territory): pantai dengan laut
local function lake(x, z, r, mat, surfaceY)
	surfaceY = surfaceY or 8
	Terrain:FillBall(Vector3.new(x, -(r - surfaceY), z), r, mat)
end

lake(-2500, 2750, 240, M.Water)
lake(-2200, 3100, 180, M.Water)
task.wait()

-- Crimson Coast (Haram area): pantai batu merah
lake(-800,  -2100, 260, M.Water)
lake(-600,  -2400, 200, M.Water)
task.wait()

-- Kolam & danau kecil
lake(-3800, 3120, 95, M.Water)   -- Lode Falls (Bellato)
lake( 1200, -2000, 80, M.Water)  -- Drizzle Veil (Numerus)
lake(-1600, -420, 110, M.Water)  -- Silence Marsh
lake( 1100, 2680, 65, M.Water)   -- Fog Marsh 1
lake( 1380, 2960, 55, M.Water)   -- Fog Marsh 2
task.wait()

-- Lava pools (Cauldron): center harus jauh di bawah karena bukan water
lake(   0, -7100, 130, M.CrackedLava, 5)  -- Bafer Lake
lake( 200, -6500,  60, M.CrackedLava, 5)  -- Genial Spring 1
lake(-100, -6600,  45, M.CrackedLava, 5)  -- Genial Spring 2
task.wait()

-- ================================================================
-- PHASE 4 — Platform Ether (Floating Ice Island at Y=400)
-- ================================================================
print("[MapGen] Phase 4: Ether platform...")

-- Snow hills di atas pulau
ball( 200, ETHER_Y + 45, -4000, 55, M.Snow)
ball(-280, ETHER_Y + 40, -4400, 50, M.Snow)
ball( 420, ETHER_Y + 38, -4200, 48, M.Snow)
ball(   0, ETHER_Y + 42, -4600, 52, M.Snow)
ball(-500, ETHER_Y + 35, -3900, 45, M.Snow)
-- Glacier outcroppings
ball(-620, ETHER_Y + 20, -4100, 42, M.Glacier)
ball( 700, ETHER_Y + 20, -4300, 38, M.Glacier)
ball( 150, ETHER_Y + 18, -4800, 40, M.Glacier)
-- Tepi pulau agak turun (cliff effect bawah)
Terrain:FillBall(Vector3.new(-1050, ETHER_Y - 30, -4200), 55, M.Glacier)
Terrain:FillBall(Vector3.new( 1050, ETHER_Y - 30, -4200), 55, M.Glacier)
Terrain:FillBall(Vector3.new(0,     ETHER_Y - 30, -3100), 55, M.Glacier)
Terrain:FillBall(Vector3.new(0,     ETHER_Y - 30, -5250), 55, M.Glacier)
task.wait()

-- ================================================================
-- PHASE 5 — SpawnLocations
-- ================================================================
local function spawnLoc(parent, name, pos, color)
	local s = Instance.new("SpawnLocation")
	s.Name = name; s.Size = Vector3.new(8,1,8)
	s.CFrame = CFrame.new(pos); s.Neutral = true
	s.BrickColor = BrickColor.new(color)
	s.Material = Enum.Material.Neon; s.Parent = parent
end

-- ================================================================
-- PHASE 6 — NPC Placement Helper
-- ================================================================
local function makeNPC(parent, npcName, designation, px, py, pz, shirtCol, labelColor)
	local nm = Instance.new("Model"); nm.Name = npcName; nm.Parent = parent
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"; hrp.Size = Vector3.new(2,2,1)
	hrp.CFrame = CFrame.new(px, py+3, pz)
	hrp.Anchored = true; hrp.CanCollide = true; hrp.Transparency = 1; hrp.Parent = nm
	local torso = Instance.new("Part")
	torso.Name = "UpperTorso"; torso.Size = Vector3.new(2,2,1)
	torso.CFrame = CFrame.new(px, py+5, pz)
	torso.Anchored = true; torso.CanCollide = false
	torso.BrickColor = BrickColor.new(shirtCol); torso.Parent = nm
	local head = Instance.new("Part")
	head.Name = "Head"; head.Size = Vector3.new(1.5,1.5,1.5)
	head.CFrame = CFrame.new(px, py+7, pz)
	head.Anchored = true; head.CanCollide = false
	head.BrickColor = BrickColor.new("Nougat"); head.Parent = nm
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0,180,0,44); bb.StudsOffset = Vector3.new(0,2.5,0)
	bb.AlwaysOnTop = false; bb.Adornee = head; bb.Parent = head
	local nl = Instance.new("TextLabel")
	nl.Size = UDim2.new(1,0,0.55,0); nl.BackgroundTransparency = 1
	nl.TextColor3 = Color3.new(1,1,1); nl.TextScaled = true
	nl.Font = Enum.Font.BuilderSansBold; nl.Text = npcName; nl.Parent = bb
	local rl = Instance.new("TextLabel")
	rl.Size = UDim2.new(1,0,0.45,0); rl.Position = UDim2.new(0,0,0.55,0)
	rl.BackgroundTransparency = 1; rl.TextColor3 = labelColor
	rl.TextScaled = true; rl.Font = Enum.Font.BuilderSans
	rl.Text = "["..designation.."]"; rl.Parent = bb
	local hum = Instance.new("Humanoid")
	hum.MaxHealth = 100; hum.Health = 100; hum.WalkSpeed = 0; hum.JumpPower = 0
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.HealthDisplayType  = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.Parent = nm; nm.PrimaryPart = hrp
end

-- ================================================================
-- BELLATO HQ NPCs
-- ================================================================
print("[MapGen] Placing Bellato NPCs...")

do
	local m = Instance.new("Model"); m.Name = "BellatoHQ_NPCs"; m.Parent = worldFolder
	local cx, cy, cz = -5500, GROUND_Y, 500
	local NZ = cz - 170
	local lc = Color3.fromRGB(255, 220, 60)

	local function n(name, desig, px, pz, col)
		makeNPC(m, name, desig, px, cy, pz, col, lc)
	end

	n("Eldon Carter",    "Race Manager",     cx-185, NZ+17,  "Bright blue")
	n("Jhan Chrisdoff",  "Committee",        cx-165, NZ+34,  "Bright blue")
	n("Rezzo Gihon",     "Guild Manager",    cx-99,  NZ+5,   "Bright blue")
	n("Gem Master",      "Gem Collector",    cx-165, NZ+68,  "Sand yellow")
	n("Nosta Bell",      "Armor Type B",     cx-152, NZ+68,  "Medium stone grey")
	n("Reel Mars",       "Shield Type B",    cx-165, NZ+85,  "Medium stone grey")
	n("T-310",           "Talic Collector",  cx-152, NZ+85,  "Sand yellow")
	n("Durba",           "Ore",              cx-139, NZ+85,  "Sand yellow")
	n("Gapaeng Schirak", "Gatekeeper",       cx-165, NZ+102, "Reddish brown")
	n("Bo Hammer",       "Hero",             cx-165, NZ+119, "Bright orange")
	n("Captured Keeper", "Captured Keeper",  cx-66,  NZ+5,   "Dark stone grey")
	n("Rockwell",        "Weapon Type B",    cx-79,  NZ+119, "Bright red")
	n("Tatar",           "Coin Exchange",    cx-66,  NZ+119, "Sand yellow")
	n("Tosca",           "Rare Tools",       cx-53,  NZ+119, "Sand yellow")
	n("Ashton Shar",     "MAU",              cx-66,  NZ+170, "Sand blue")
	n("Temple of Honor", "Temple of Honor",  cx-33,  NZ+68,  "White")
	n("Dark Berserker",  "Dark Ambassador",  cx+20,  NZ+102, "Dark stone grey")
	n("Emperial Dragon", "Dragon Knight",    cx+46,  NZ+102, "Dark stone grey")
	n("AW63-33-7148",    "Foreign Vendor",   cx+33,  NZ+119, "Sand green")
	n("Miscellaneous",   "Battle Dungeon",   cx+99,  NZ+68,  "Medium stone grey")
	n("PointItemNPC",    "Point Item",       cx+66,  NZ+85,  "Sand yellow")
	n("CouponMan",       "Premium Manager",  cx+66,  NZ+102, "Bright blue")
	n("Charlie",         "Potion",           cx+66,  NZ+153, "Bright red")
	n("Jun",             "Tool",             cx+66,  NZ+170, "Sand yellow")
	n("Honkey",          "Inspector",        cx+66,  NZ+187, "Bright blue")
	n("El Luna",         "Potion",           cx+165, NZ+85,  "Bright red")
	n("Honakan",         "Force",            cx+178, NZ+85,  "Sand yellow")
	n("Green Eye",       "Weapon",           cx+185, NZ+51,  "Bright red")
	n("Monk",            "Armor",            cx+185, NZ+68,  "Medium stone grey")
	n("Asehan",          "Shield Type N",    cx-13,  NZ+204, "Medium stone grey")
	n("Caden",           "Weapon Type A",    cx,     NZ+204, "Bright red")
	n("Jaden",           "Armor Suit",       cx+13,  NZ+204, "Medium stone grey")
	n("Accloma",         "Weapon Type N",    cx+33,  NZ+204, "Bright red")
	n("Draka Bell",      "Weapon Type A",    cx+46,  NZ+204, "Bright red")
	n("Madison",         "Weapon",           cx+59,  NZ+204, "Bright red")
	n("Sly",             "Aide",             cx+165, NZ+204, "Sand yellow")
	n("Miti",            "Paybox",           cx+220, NZ+17,  "Bright orange")

	spawnLoc(raceSpawnFolder, "Bellato_Spawn", Vector3.new(cx, cy+2, cz+150), "Bright blue")
end
task.wait()

-- ================================================================
-- ACCRETIA HQ NPCs
-- ================================================================
print("[MapGen] Placing Accretia NPCs...")

do
	local m = Instance.new("Model"); m.Name = "AccretiaHQ_NPCs"; m.Parent = worldFolder
	local cx, cy, cz = 5500, GROUND_Y, 500
	local lc = Color3.fromRGB(255, 100, 100)

	local function rf(gx, gy)
		return cx + (gx-17)*33, cz + (gy-71)*17
	end
	local function n(name, desig, gx, gy, col)
		local rx, rz = rf(gx, gy)
		makeNPC(m, name, desig, rx, cy, rz, col, lc)
	end

	n("Adjutant 001B",  "Race Manager",     5,  71, "Dark red")
	n("aP0P-CR-1944",   "Tribune Rep",      8,  71, "Dark red")
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
	n("AR22-54-5078",   "Rare Tools",       22, 69, "Sand yellow")
	n("Lavendor",       "Talic Collector",  22, 69, "Sand yellow")
	n("AR24-33-2581",   "Weapon Type B",    22, 70, "Bright red")
	n("NC-69800",       "Ore",              22, 70, "Sand yellow")
	n("Stone Master",   "Gem Collector",    22, 70, "Sand yellow")
	n("NC-854125",      "Tool",             28, 69, "Sand yellow")
	n("PointItemNPC",   "Point Item",       24, 70, "Cyan")
	n("Temple of Honor","Temple of Honor",  20, 71, "White")
	n("Dark Annihilator","Dark Ambassador", 24, 71, "Dark stone grey")
	n("Dark Desolator", "Dark Ambassador",  24, 71, "Dark stone grey")
	n("Dark Warder",    "Dark Ambassador",  24, 71, "Dark stone grey")
	n("Emperial Dragon","Dragon Knight",    24, 71, "Dark stone grey")
	n("CouponMan",      "Premium Manager",  25, 71, "Bright blue")
	n("Crea Windom",    "Foreign Vendor",   25, 71, "Sand green")
	n("NC-255",         "Guild Manager",    22, 72, "Bright blue")
	n("Captured Keeper","Captured Keeper",  22, 73, "Dark stone grey")
	n("NC-359804F",     "Gatekeeper",       23, 73, "Reddish brown")
	n("NC-66333",       "Charger",          28, 73, "Cyan")
	n("NC-110110B",     "Armor",            27, 74, "Medium stone grey")
	n("NC-3589A",       "Battle Dungeon",   26, 75, "Bright orange")
	n("Lothan the 3rd", "Hero",             25, 75, "Bright orange")
	n("AS01-R1-1131",   "Aide",             30, 66, "Sand yellow")

	spawnLoc(raceSpawnFolder, "Accretia_Spawn", Vector3.new(cx, cy+2, cz+200), "Bright red")
end
task.wait()

-- ================================================================
-- CORA HQ NPCs
-- ================================================================
print("[MapGen] Placing Cora NPCs...")

do
	local m = Instance.new("Model"); m.Name = "CoraHQ_NPCs"; m.Parent = worldFolder
	local cx, cy, cz = 0, GROUND_Y, 5800
	local lc = Color3.fromRGB(100, 255, 220)

	local function rf(gx, gy)
		return cx + (gx-87)*33, cz + (gy-57)*17
	end
	local function n(name, desig, gx, gy, col)
		local rx, rz = rf(gx, gy)
		makeNPC(m, name, desig, rx, cy, rz, col, lc)
	end

	n("Casandra",        "Weapon Type A",    78, 48, "Bright red")
	n("Hansen",          "Weapon Type N",    78, 48, "Bright red")
	n("Sara Meser",      "Weapon Type A",    78, 48, "Bright red")
	n("Isillia",         "Armor Vendor",     79, 48, "Medium stone grey")
	n("Noa Del",         "Armor Suit",       79, 48, "Medium stone grey")
	n("Syris",           "Shield Type N",    79, 48, "Medium stone grey")
	n("Beny",            "Shield Type A",    79, 48, "Medium stone grey")
	n("Aias",            "Guild Manager",    85, 48, "Bright blue")
	n("Captured Keeper", "Captured Keeper",  85, 48, "Dark stone grey")
	n("Methud",          "Force",            76, 50, "Sand yellow")
	n("PA71-02-1316",    "Foreign Vendor",   79, 50, "Sand green")
	n("Fairy",           "Potion",           81, 50, "Bright red")
	n("Zeraf",           "Tool",             81, 50, "Sand yellow")
	n("Elli Ieeda",      "Armour",           86, 50, "Medium stone grey")
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
	n("Temple of Honor", "Temple of Honor",  82, 54, "White")
	n("Ziz Oadasha",     "Hero",             79, 55, "Bright orange")
	n("Stupor",          "Archbishop Rep",   85, 57, "Bright blue")
	n("Quiane Kahn",     "Race Manager",     86, 58, "Bright blue")
	n("MISCELLANEOUS",   "Battle Dungeon",   79, 58, "Bright orange")
	n("SynPask",         "Potion",           81, 60, "Bright red")

	spawnLoc(raceSpawnFolder, "Cora_Spawn", Vector3.new(cx, cy+2, cz+330), "Bright green")
end
task.wait()

-- ================================================================
-- SELESAI
-- ================================================================
local marker = Instance.new("BoolValue")
marker.Name = "_MapGenerated"; marker.Value = true; marker.Parent = workspace

print("[MapGen] World generation selesai!")
print("  Bellato  (-5500, 0, 500) → Grass hills, cliffs, canyon")
print("  Accretia (5500, 0, 500)  → Sand desert, crater formation")
print("  Cora     (0, 0, 5800)    → Lush forest, marsh, beach")
print("  Ether    (0, 400, -4200) → Floating snow island")
print("  Cauldron (0, 0, -6700)   → Volcanic lava zone")
