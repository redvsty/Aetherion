-- PortalSystem.server.lua
-- Portal fisik untuk teleport antar zona yang tidak bisa dicapai dengan jalan kaki.
-- Platform Ether di Y=400 adalah satu-satunya zona yang WAJIB pakai portal.
--
-- Layout portal Ether:
--   Bellato  → portal di dekat Armory 117 settlement (barat laut) → Bellato Wharf
--   Accretia → portal di dekat Armory 213 settlement (timur laut) → Accretia Wharf
--   Cora     → portal di tengah Sette Desert / Nadir Plain        → Cora Wharf
--   Return   → di setiap Wharf → kembali ke portal asal (ground level)

local Players = game:GetService("Players")

workspace:WaitForChild("_MapGenerated", 300)
local worldFolder = workspace:WaitForChild("World")

if workspace:FindFirstChild("_PortalsBuilt") then
	print("[PortalSystem] Already built, skipping.")
	return
end

local GROUND_Y = 0

-- ================================================================
-- Portal Definition
-- ================================================================

-- { id, label, color, fromPos, toPos, groundPortal(bool) }
-- groundPortal = true  → di darat, neon solid (portal naik ke Ether)
-- groundPortal = false → di Ether, neon transparan (portal turun ke darat)

local portalDefs = {

	-- ── ETHER PORTALS (naik ke Y=400) ───────────────────────────

	{
		id    = "portal_bellato_to_ether",
		label = "Bellato Wharf ↑",
		desc  = "Platform Ether",
		color = Color3.fromRGB(60, 140, 255),     -- biru Bellato
		ring  = Color3.fromRGB(150, 200, 255),
		from  = Vector3.new(-2600, GROUND_Y, -3900),  -- dekat Armory 117 settlement
		to    = Vector3.new(-600, 400, -4400),         -- Bellato Wharf di Ether
		up    = true,
	},
	{
		id    = "portal_accretia_to_ether",
		label = "Accretia Wharf ↑",
		desc  = "Platform Ether",
		color = Color3.fromRGB(255, 60, 60),      -- merah Accretia
		ring  = Color3.fromRGB(255, 160, 160),
		from  = Vector3.new(2600, GROUND_Y, -3900),   -- dekat Armory 213 settlement
		to    = Vector3.new(600, 400, -4400),           -- Accretia Wharf di Ether
		up    = true,
	},
	{
		id    = "portal_cora_to_ether",
		label = "Cora Wharf ↑",
		desc  = "Platform Ether",
		color = Color3.fromRGB(60, 220, 180),     -- teal Cora
		ring  = Color3.fromRGB(150, 255, 220),
		from  = Vector3.new(-200, GROUND_Y, -5200),    -- tengah Sette Desert (Nadir Plain)
		to    = Vector3.new(0, 400, -4600),             -- Cora Wharf di Ether
		up    = true,
	},

	-- ── RETURN PORTALS (turun dari Ether ke ground) ─────────────

	{
		id    = "portal_ether_bellato_return",
		label = "Kembali ↓",
		desc  = "Armory 117",
		color = Color3.fromRGB(60, 140, 255),
		ring  = Color3.fromRGB(150, 200, 255),
		from  = Vector3.new(-600, 400, -4350),          -- dekat portal Bellato di Ether
		to    = Vector3.new(-2600, GROUND_Y + 3, -3900), -- kembali ke darat
		up    = false,
	},
	{
		id    = "portal_ether_accretia_return",
		label = "Kembali ↓",
		desc  = "Armory 213",
		color = Color3.fromRGB(255, 60, 60),
		ring  = Color3.fromRGB(255, 160, 160),
		from  = Vector3.new(600, 400, -4350),
		to    = Vector3.new(2600, GROUND_Y + 3, -3900),
		up    = false,
	},
	{
		id    = "portal_ether_cora_return",
		label = "Kembali ↓",
		desc  = "Sette Desert",
		color = Color3.fromRGB(60, 220, 180),
		ring  = Color3.fromRGB(150, 255, 220),
		from  = Vector3.new(0, 400, -4550),
		to    = Vector3.new(-200, GROUND_Y + 3, -5200),
		up    = false,
	},

}

-- ================================================================
-- Portal Builder
-- ================================================================

local portalFolder = Instance.new("Folder")
portalFolder.Name = "Portals"
portalFolder.Parent = worldFolder

local function buildPortal(def)
	local pf = Instance.new("Model")
	pf.Name = def.id
	pf.Parent = portalFolder

	local px, py, pz = def.from.X, def.from.Y, def.from.Z
	local baseY = py  -- Y lantai portal

	-- Disc (flat cylinder) — visual utama portal
	local disc = Instance.new("Part")
	disc.Name = "Disc"
	disc.Shape = Enum.PartType.Cylinder
	disc.Size = Vector3.new(1, 24, 24)    -- tipis, lebar 12 radius
	disc.CFrame = CFrame.new(px, baseY + 0.5, pz) * CFrame.Angles(0, 0, math.pi / 2)
	disc.Anchored = true
	disc.CanCollide = false
	disc.CastShadow = false
	disc.Color = def.color
	disc.Material = Enum.Material.Neon
	disc.Transparency = def.up and 0.3 or 0.5
	disc.Parent = pf

	-- Outer ring (slightly larger, different tone)
	local ring = Instance.new("Part")
	ring.Name = "Ring"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.6, 30, 30)
	ring.CFrame = CFrame.new(px, baseY + 0.3, pz) * CFrame.Angles(0, 0, math.pi / 2)
	ring.Anchored = true
	ring.CanCollide = false
	ring.CastShadow = false
	ring.Color = def.ring
	ring.Material = Enum.Material.Neon
	ring.Transparency = 0.6
	ring.Parent = pf

	-- Pillar beam efek (vertikal, dekoratif)
	if def.up then
		local beam = Instance.new("Part")
		beam.Name = "Beam"
		beam.Size = Vector3.new(3, 30, 3)
		beam.CFrame = CFrame.new(px, baseY + 16, pz)
		beam.Anchored = true
		beam.CanCollide = false
		beam.CastShadow = false
		beam.Color = def.color
		beam.Material = Enum.Material.Neon
		beam.Transparency = 0.7
		beam.Parent = pf
	end

	-- PointLight untuk efek cahaya
	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 20
	light.Color = def.color
	light.Parent = disc

	-- Collision trigger (invisible, player step pada)
	local trigger = Instance.new("Part")
	trigger.Name = "Trigger"
	trigger.Size = Vector3.new(24, 6, 24)
	trigger.CFrame = CFrame.new(px, baseY + 3, pz)
	trigger.Anchored = true
	trigger.CanCollide = false
	trigger.Transparency = 1
	trigger.CastShadow = false
	trigger.Parent = pf

	-- BillboardGui label
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 160, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 10, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = disc

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0.55, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.BuilderSansBold
	titleLabel.Text = def.label
	titleLabel.Parent = billboard

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0.45, 0)
	descLabel.Position = UDim2.new(0, 0, 0.55, 0)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextScaled = true
	descLabel.Font = Enum.Font.BuilderSans
	descLabel.Text = "→ " .. def.desc
	descLabel.Parent = billboard

	-- ProximityPrompt untuk aktivasi
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Enter"
	prompt.ObjectText = def.label
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 1.5    -- hold 1.5 detik untuk masuk portal
	prompt.MaxActivationDistance = 14
	prompt.Parent = trigger

	-- Cooldown per player agar tidak spam teleport
	local cooldowns = {}

	prompt.Triggered:Connect(function(player)
		local userId = player.UserId
		local now = tick()

		if cooldowns[userId] and now - cooldowns[userId] < 3 then return end
		cooldowns[userId] = now

		local character = player.Character
		if not character then return end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		-- Teleport ke tujuan dengan spread kecil agar tidak stack
		local dest = def.to
		local spread = Vector3.new(math.random(-6, 6), 0, math.random(-6, 6))
		hrp.CFrame = CFrame.new(dest + spread + Vector3.new(0, 2, 0))

		print(string.format("[Portal] %s → %s (%s)", player.Name, def.id, def.desc))
	end)

	-- Animasi pulse (opsional: modifikasi transparency saat idle)
	task.spawn(function()
		local t = 0
		while pf.Parent do
			task.wait(0.05)
			t = t + 0.05
			local pulse = 0.2 + math.sin(t * 2) * 0.15
			disc.Transparency = pulse
		end
	end)
end

-- ================================================================
-- Build semua portals
-- ================================================================

print("[PortalSystem] Building portals...")

for _, def in ipairs(portalDefs) do
	buildPortal(def)
	task.wait()
end

-- Marker
local marker = Instance.new("BoolValue")
marker.Name = "_PortalsBuilt"
marker.Value = true
marker.Parent = workspace

print(string.format("[PortalSystem] %d portals berhasil dibangun.", #portalDefs))
print("  Ether portal: Bellato (Armory 117), Accretia (Armory 213), Cora (Sette Desert)")
print("  Cauldron: akses jalan kaki dari Sette Desert (terrain nyambung)")
