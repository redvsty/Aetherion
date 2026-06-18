-- HQBuilder.server.lua
-- Membangun struktur fisik HQ ketiga ras sesudah terrain selesai.
-- Bellato: fortress batu abad pertengahan, gerbang menghadap timur (ke tengah)
-- Accretia: industri metal, gerbang menghadap barat
-- Cora: organik/elven, gerbang menghadap utara (-Z, ke tengah)

local workspace = game:GetService("Workspace")
local M = Enum.Material

-- Tunggu terrain selesai
workspace:WaitForChild("_MapGenerated", 300)
local worldFolder = workspace:WaitForChild("World")

if workspace:FindFirstChild("_HQBuilt") then
	print("[HQBuilder] Already built, skipping.")
	return
end

local GROUND_Y = 0

-- ================================================================
-- Helpers
-- ================================================================

-- Buat Part. cy = Y lantai (bawah part), ukuran naik ke atas.
local function makePart(parent, name, cx, cy, cz, sx, sy, sz, colorName, mat)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = Vector3.new(sx, sy, sz)
	p.CFrame = CFrame.new(cx, cy + sy / 2, cz)
	p.Anchored = true
	p.CanCollide = true
	p.BrickColor = BrickColor.new(colorName)
	p.Material = mat or M.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CastShadow = true
	p.Parent = parent
	return p
end

-- Dinding axis-aligned. Naik dari GROUND_Y.
local function makeWall(parent, cx, cz, sx, sz, height, colorName, mat)
	return makePart(parent, "Wall", cx, GROUND_Y, cz, sx, height, sz, colorName, mat)
end

-- Segmentasi dinding timur/barat dengan bukaan gerbang (sepanjang sumbu Z).
-- Gerbang berada di tengah dinding (cz = pusat dinding), lebar GW, tinggi GH.
local function makeWallWithGateZ(parent, wx, cz, wallThick, halfDepth, wallH, gateW, gateH, colorName, mat)
	local sideLen = halfDepth - gateW / 2
	-- Segmen utara
	makeWall(parent, wx, cz - halfDepth + sideLen / 2, wallThick, sideLen, wallH, colorName, mat)
	-- Segmen selatan
	makeWall(parent, wx, cz + halfDepth - sideLen / 2, wallThick, sideLen, wallH, colorName, mat)
	-- Lintel di atas gerbang
	local lintel = Instance.new("Part")
	lintel.Name = "GateLintel"
	lintel.Size = Vector3.new(wallThick, wallH - gateH, gateW)
	lintel.CFrame = CFrame.new(wx, gateH + (wallH - gateH) / 2, cz)
	lintel.Anchored = true
	lintel.BrickColor = BrickColor.new(colorName)
	lintel.Material = mat or M.SmoothPlastic
	lintel.TopSurface = Enum.SurfaceType.Smooth
	lintel.BottomSurface = Enum.SurfaceType.Smooth
	lintel.Parent = parent
end

-- Segmentasi dinding utara/selatan dengan bukaan gerbang (sepanjang sumbu X).
local function makeWallWithGateX(parent, cz, cx, wallThick, halfWidth, wallH, gateW, gateH, colorName, mat)
	local sideLen = halfWidth - gateW / 2
	makeWall(parent, cx - halfWidth + sideLen / 2, cz, sideLen, wallThick, wallH, colorName, mat)
	makeWall(parent, cx + halfWidth - sideLen / 2, cz, sideLen, wallThick, wallH, colorName, mat)
	local lintel = Instance.new("Part")
	lintel.Name = "GateLintel"
	lintel.Size = Vector3.new(gateW, wallH - gateH, wallThick)
	lintel.CFrame = CFrame.new(cx, gateH + (wallH - gateH) / 2, cz)
	lintel.Anchored = true
	lintel.BrickColor = BrickColor.new(colorName)
	lintel.Material = mat or M.SmoothPlastic
	lintel.TopSurface = Enum.SurfaceType.Smooth
	lintel.BottomSurface = Enum.SurfaceType.Smooth
	lintel.Parent = parent
end

-- Pillar di pojok-pojok compound
local function makeCornerTowers(parent, cx, cz, hw, hd, tSize, tHeight, capH, bodyColor, capColor, mat)
	local corners = {
		{cx - hw, cz - hd},
		{cx + hw, cz - hd},
		{cx - hw, cz + hd},
		{cx + hw, cz + hd},
	}
	for _, c in ipairs(corners) do
		makePart(parent, "Tower", c[1], GROUND_Y, c[2], tSize, tHeight, tSize, bodyColor, mat)
		makePart(parent, "TowerCap", c[1], tHeight, c[2], tSize + 4, capH, tSize + 4, capColor, mat)
	end
end

-- ================================================================
-- BELLATO HQ  (-5500, 0, 500)
-- Batu abad pertengahan, gerbang menghadap timur (+X, ke neutral zone)
-- ================================================================
print("[HQBuilder] Building Bellato HQ structures...")

do
	local m = Instance.new("Model")
	m.Name = "BellatoHQ_Buildings"
	m.Parent = worldFolder

	local cx, cz = -5500, 500
	local HW, HD = 155, 130   -- half-width (X), half-depth (Z) — compound ±HW, ±HD
	local WH, WT = 18, 4      -- wall height, wall thickness
	local GW, GH = 30, 14     -- gate width, gate height

	local stone   = "Medium stone grey"
	local stoneM  = M.StonePlastic
	local darkSt  = "Dark stone grey"
	local blue    = "Bright blue"

	-- Lantai compound (batu paving tipis, sedikit di atas tanah)
	makePart(m, "CompoundFloor", cx, GROUND_Y - 0.4, cz, HW * 2, 0.8, HD * 2, "Light stone grey", M.StonePlastic)

	-- Dinding perimeter
	makeWall(m, cx, cz - HD, HW * 2, WT, WH, stone, stoneM)    -- utara
	makeWall(m, cx, cz + HD, HW * 2, WT, WH, stone, stoneM)    -- selatan
	makeWall(m, cx - HW, cz, WT, HD * 2, WH, stone, stoneM)    -- barat (belakang)
	makeWallWithGateZ(m, cx + HW, cz, WT, HD, WH, GW, GH, stone, stoneM)  -- timur (gerbang)

	-- Pillar gerbang
	makePart(m, "GatePillarN", cx + HW - 2, GROUND_Y, cz - GW / 2, 8, GH + 3, 8, darkSt, stoneM)
	makePart(m, "GatePillarS", cx + HW - 2, GROUND_Y, cz + GW / 2, 8, GH + 3, 8, darkSt, stoneM)
	-- Arch cap di atas pillar
	makePart(m, "GateCapN", cx + HW - 2, GH + 3, cz - GW / 2, 10, 2, 10, blue, M.SmoothPlastic)
	makePart(m, "GateCapS", cx + HW - 2, GH + 3, cz + GW / 2, 10, 2, 10, blue, M.SmoothPlastic)

	-- Corner towers
	makeCornerTowers(m, cx, cz, HW, HD, 13, 22, 3, darkSt, blue, stoneM)

	-- Gedung utama / main hall (barat-tengah compound)
	-- Hall 90×60, 16 tinggi, pintu di sisi timur
	local hx = cx - 25
	makePart(m, "HallFloor", hx, GROUND_Y, cz, 90, 1, 60, "Light stone grey", stoneM)
	makeWall(m, hx, cz - 30, 90, WT, 16, stone, stoneM)    -- utara
	makeWall(m, hx, cz + 30, 90, WT, 16, stone, stoneM)    -- selatan
	makeWall(m, hx - 45, cz, WT, 60, 16, stone, stoneM)    -- barat
	-- Timur hall: dua segmen + bukaan 24 lebar
	makeWall(m, hx + 45, cz - 18, WT, 24, 16, stone, stoneM)
	makeWall(m, hx + 45, cz + 18, WT, 24, 16, stone, stoneM)
	local hallLintel = Instance.new("Part")
	hallLintel.Name = "HallDoorLintel"
	hallLintel.Size = Vector3.new(WT, 4, 24)
	hallLintel.CFrame = CFrame.new(hx + 45, 14 + 2, cz)
	hallLintel.Anchored = true
	hallLintel.BrickColor = BrickColor.new(stone)
	hallLintel.Material = stoneM
	hallLintel.Parent = m
	-- Atap hall
	makePart(m, "HallRoof", hx, 16, cz, 92, 3, 62, blue, M.SmoothPlastic)
	-- Dekorasi atap: ridge line
	makePart(m, "HallRidge", hx, 19, cz, 94, 2, 4, darkSt, stoneM)

	-- Area pasar (barat-timur: cx+70 ke cx+130, utara-selatan: cz-60 ke cz+60)
	-- 5 lapak berjejer arah utara-selatan
	for i = 1, 5 do
		local stZ = cz - 50 + (i - 1) * 25
		makePart(m, "Stall_" .. i, cx + 95, GROUND_Y, stZ, 20, 4, 16, "Sand yellow", M.Wood)
		makePart(m, "StallCanopy_" .. i, cx + 95, 4, stZ, 22, 1, 18, stone, stoneM)
		-- Meja NPC (sedikit lebih kecil di depan)
		makePart(m, "StallCounter_" .. i, cx + 105, GROUND_Y, stZ, 4, 4, 14, darkSt, stoneM)
	end

	-- Tiang bendera (di sebelah utara, depan gedung utama)
	makePart(m, "FlagpoleBase", cx, GROUND_Y, cz - HD + 10, 5, 2, 5, darkSt, stoneM)
	makePart(m, "Flagpole",     cx, 2, cz - HD + 10, 1.5, 32, 1.5, darkSt, M.Metal)
	makePart(m, "Flag",         cx + 8, 28, cz - HD + 10, 14, 7, 1, blue, M.SmoothPlastic)
end

task.wait()

-- ================================================================
-- ACCRETIA HQ  (5500, 0, 500)
-- Industrial metal, gerbang menghadap barat (-X, ke neutral zone)
-- ================================================================
print("[HQBuilder] Building Accretia HQ structures...")

do
	local m = Instance.new("Model")
	m.Name = "AccretiaHQ_Buildings"
	m.Parent = worldFolder

	local cx, cz = 5500, 500
	local HW, HD = 155, 130
	local WH, WT = 20, 5
	local GW, GH = 32, 15

	local metal  = "Dark stone grey"
	local metalM = M.Metal
	local red    = "Bright red"
	local black  = "Really black"

	-- Lantai (plat besi gelap)
	makePart(m, "CompoundFloor", cx, GROUND_Y - 0.4, cz, HW * 2, 0.8, HD * 2, "Dark stone grey", metalM)

	-- Perimeter
	makeWall(m, cx, cz - HD, HW * 2, WT, WH, metal, metalM)    -- utara
	makeWall(m, cx, cz + HD, HW * 2, WT, WH, metal, metalM)    -- selatan
	makeWall(m, cx + HW, cz, WT, HD * 2, WH, metal, metalM)    -- timur (belakang)
	makeWallWithGateZ(m, cx - HW, cz, WT, HD, WH, GW, GH, metal, metalM)  -- barat (gerbang)

	-- Pillar gerbang (industrial rectangular)
	makePart(m, "GatePillarN", cx - HW + 3, GROUND_Y, cz - GW / 2, 9, GH + 4, 9, black, metalM)
	makePart(m, "GatePillarS", cx - HW + 3, GROUND_Y, cz + GW / 2, 9, GH + 4, 9, black, metalM)
	-- Neon strip di pillar
	makePart(m, "PillarGlowN", cx - HW + 3, GH / 2, cz - GW / 2 - 4.6, 2, GH, 1, red, M.Neon)
	makePart(m, "PillarGlowS", cx - HW + 3, GH / 2, cz + GW / 2 + 4.6, 2, GH, 1, red, M.Neon)

	-- Corner blocks (industrial)
	makeCornerTowers(m, cx, cz, HW, HD, 15, 25, 3, black, red, metalM)
	-- Neon top di setiap corner
	local corners = {
		{cx - HW, cz - HD}, {cx + HW, cz - HD},
		{cx - HW, cz + HD}, {cx + HW, cz + HD},
	}
	for _, c in ipairs(corners) do
		makePart(m, "CornerNeon", c[1], 28, c[2], 17, 1, 17, red, M.Neon)
	end

	-- Command center (bangunan utama, timur-tengah compound)
	local hx = cx + 20
	makePart(m, "HallFloor", hx, GROUND_Y, cz, 90, 1, 60, "Dark stone grey", metalM)
	makeWall(m, hx, cz - 30, 90, WT, 20, metal, metalM)
	makeWall(m, hx, cz + 30, 90, WT, 20, metal, metalM)
	makeWall(m, hx + 45, cz, WT, 60, 20, metal, metalM)
	makeWall(m, hx - 45, cz - 18, WT, 24, 20, metal, metalM)
	makeWall(m, hx - 45, cz + 18, WT, 24, 20, metal, metalM)
	local hallLintel = Instance.new("Part")
	hallLintel.Name = "HallDoorLintel"
	hallLintel.Size = Vector3.new(WT, 6, 24)
	hallLintel.CFrame = CFrame.new(hx - 45, 15 + 3, cz)
	hallLintel.Anchored = true
	hallLintel.BrickColor = BrickColor.new(metal)
	hallLintel.Material = metalM
	hallLintel.Parent = m
	-- Atap (plat datar gelap dengan neon border)
	makePart(m, "HallRoof", hx, 20, cz, 92, 3, 62, black, metalM)
	makePart(m, "RoofNeonN", hx, 23, cz - 31, 94, 1, 2, red, M.Neon)
	makePart(m, "RoofNeonS", hx, 23, cz + 31, 94, 1, 2, red, M.Neon)

	-- Terminal pasar (barat compound, berjejer arah utara-selatan)
	for i = 1, 5 do
		local stZ = cz - 50 + (i - 1) * 25
		makePart(m, "Terminal_" .. i, cx - 90, GROUND_Y, stZ, 20, 6, 14, black, metalM)
		-- Layar terminal (neon merah)
		makePart(m, "Screen_" .. i, cx - 90, 6, stZ - 7, 18, 9, 1, red, M.Neon)
		-- Counter
		makePart(m, "Counter_" .. i, cx - 100, GROUND_Y, stZ, 4, 5, 12, metal, metalM)
	end

	-- Antena / menara sinyal di belakang HQ
	makePart(m, "AntennaTower", cx + HW - 25, GROUND_Y, cz - 60, 6, 40, 6, metal, metalM)
	makePart(m, "AntennaCross1", cx + HW - 25, 35, cz - 60, 30, 2, 3, red, M.Neon)
	makePart(m, "AntennaCross2", cx + HW - 25, 28, cz - 60, 3, 2, 30, red, M.Neon)
end

task.wait()

-- ================================================================
-- CORA HQ  (0, 0, 5800)
-- Organik/elven, gerbang menghadap utara (-Z, ke neutral zone)
-- ================================================================
print("[HQBuilder] Building Cora HQ structures...")

do
	local m = Instance.new("Model")
	m.Name = "CoraHQ_Buildings"
	m.Parent = worldFolder

	local cx, cz = 0, 5800
	local HW, HD = 145, 135
	local WH, WT = 14, 5
	local GW, GH = 32, 12

	local wood   = "Sand green"
	local woodM  = M.Wood
	local green  = "Bright green"
	local leafM  = M.Grass
	local darkG  = "Dark green"
	local teal   = "Cyan"

	-- Lantai compound (tanah hijau tebal)
	makePart(m, "CompoundFloor", cx, GROUND_Y - 0.4, cz, HW * 2, 0.8, HD * 2, "Medium green", leafM)

	-- Perimeter (dinding kayu/batu organik)
	makeWall(m, cx + HW, cz, WT, HD * 2, WH, wood, woodM)    -- timur
	makeWall(m, cx - HW, cz, WT, HD * 2, WH, wood, woodM)    -- barat
	makeWall(m, cx, cz + HD, HW * 2, WT, WH, wood, woodM)    -- selatan (belakang)
	makeWallWithGateX(m, cz - HD, cx, WT, HW, WH, GW, GH, wood, woodM)  -- utara (gerbang)

	-- Pohon gerbang (pillar organik)
	makePart(m, "GateTreeW", cx - GW / 2, GROUND_Y, cz - HD, 7, GH + 5, 7, darkG, leafM)
	makePart(m, "GateTreeE", cx + GW / 2, GROUND_Y, cz - HD, 7, GH + 5, 7, darkG, leafM)
	-- Dedaunan di atas pohon gerbang
	makePart(m, "FoliageW", cx - GW / 2, GH + 5, cz - HD, 16, 9, 16, green, leafM)
	makePart(m, "FoliageE", cx + GW / 2, GH + 5, cz - HD, 16, 9, 16, green, leafM)

	-- Corner trees
	local corners = {
		{cx - HW, cz - HD}, {cx + HW, cz - HD},
		{cx - HW, cz + HD}, {cx + HW, cz + HD},
	}
	for _, c in ipairs(corners) do
		makePart(m, "CornerTree",    c[1], GROUND_Y, c[2], 9, 22, 9, darkG, leafM)
		makePart(m, "CornerFoliage", c[1], 22, c[2], 22, 12, 22, green, leafM)
	end

	-- Kuil tengah (temple melingkar)
	-- Lantai kuil
	makePart(m, "TempleFloor", cx, GROUND_Y, cz, 70, 1, 70, "Bright green", leafM)
	-- Pillar melingkar (8 tiang di radius 38)
	local pillarRadius = 38
	local pillarCount  = 8
	for i = 1, pillarCount do
		local angle = (i - 1) * (math.pi * 2 / pillarCount)
		local px = cx + math.cos(angle) * pillarRadius
		local pz = cz + math.sin(angle) * pillarRadius
		makePart(m, "TemplePillar_" .. i, px, GROUND_Y, pz, 7, 22, 7, wood, woodM)
		makePart(m, "PillarCap_" .. i, px, 22, pz, 10, 3, 10, teal, M.SmoothPlastic)
	end
	-- Atap kuil
	makePart(m, "TempleRoof", cx, 22, cz, 78, 4, 78, teal, M.SmoothPlastic)
	-- Dedaunan di atap
	makePart(m, "RoofFoliage", cx, 26, cz, 82, 7, 82, green, leafM)
	-- Altar tengah
	makePart(m, "Altar", cx, GROUND_Y, cz, 20, 3, 20, "Light stone grey", M.StonePlastic)
	makePart(m, "AltarTop", cx, 3, cz, 18, 2, 18, teal, M.SmoothPlastic)

	-- Area pasar (arah barat-timur, selatan kuil)
	for i = 1, 4 do
		local stX = cx - 55 + (i - 1) * 38
		makePart(m, "Stall_" .. i, stX, GROUND_Y, cz + 90, 18, 4, 14, wood, woodM)
		makePart(m, "StallCanopy_" .. i, stX, 4, cz + 90, 22, 1, 18, green, leafM)
		makePart(m, "StallCounter_" .. i, stX + 9, GROUND_Y, cz + 90, 4, 4, 12, darkG, woodM)
	end

	-- Pohon dekorasi dalam compound (mengisi ruang)
	local decoTrees = {
		{cx - 90, cz - 60}, {cx + 90, cz - 60},
		{cx - 90, cz + 60}, {cx + 90, cz + 60},
		{cx - 100, cz}, {cx + 100, cz},
	}
	for _, t in ipairs(decoTrees) do
		makePart(m, "DecoTree", t[1], GROUND_Y, t[2], 6, 16, 6, darkG, leafM)
		makePart(m, "DecoFoliage", t[1], 16, t[2], 18, 8, 18, green, leafM)
	end
end

task.wait()

-- Marker agar tidak rebuild
local marker = Instance.new("BoolValue")
marker.Name = "_HQBuilt"
marker.Value = true
marker.Parent = workspace

print("[HQBuilder] Semua HQ berhasil dibangun!")
print("  Bellato  (-5500, 0, 500) — fortress batu, gerbang timur")
print("  Accretia (5500, 0, 500)  — kompleks industri, gerbang barat")
print("  Cora     (0, 0, 5800)    — kuil organik, gerbang utara")
