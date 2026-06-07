-- CharacterCreationUI.lua
-- RF Classic-style character creation screen.
-- Three distinctly shaped 3D race previews: Bellato (human), Accretia (cyborg), Cora (elf).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CharacterCreationUI = {}

-- ============================================================
-- Palette
-- ============================================================

local BG_COLOR      = Color3.fromRGB(6, 8, 14)
local PANEL_COLOR   = Color3.fromRGB(10, 14, 22)
local TEAL          = Color3.fromRGB(0, 200, 210)
local TEAL_DIM      = Color3.fromRGB(0, 90, 100)
local TEAL_BRIGHT   = Color3.fromRGB(80, 240, 250)
local TEXT_MAIN     = Color3.fromRGB(220, 235, 250)
local TEXT_DIM      = Color3.fromRGB(110, 130, 160)
local SEL_GLOW      = Color3.fromRGB(0, 210, 230)
local GOLD          = Color3.fromRGB(255, 210, 60)

-- ============================================================
-- Race data
-- ============================================================

local RACES = {
	{
		Id          = "MECHA",
		DisplayName = "Bellato Federation",
		SubTitle    = "MECHA  ·  HUMAN",
		Desc        = "Masters of MAU battle mechs.\nBalanced stats. Superior melee\nand mechanical warfare.",
	},
	{
		Id          = "CYBORG",
		DisplayName = "Accretia Empire",
		SubTitle    = "CYBORG  ·  ROBOT",
		Desc        = "Pure war machines. No magic,\nno mercy. Highest armor\nand Launcher class.",
	},
	{
		Id          = "MYSTIC",
		DisplayName = "Cora Alliance",
		SubTitle    = "MYSTIC  ·  ELF",
		Desc        = "Animus spirit summoners\nand Force wielders. Highest FP\nand magical ability.",
	},
}

-- ============================================================
-- Class data
-- ============================================================

local CLASSES = {
	{ Id = "Warrior",     Name = "WARRIOR",      Desc = "Front-line melee fighter.\nHighest HP. Swords and blades.", Role = "MELEE",   RoleColor = Color3.fromRGB(220,70,50),  Locked = {} },
	{ Id = "Ranger",      Name = "RANGER",       Desc = "Ranged attacker and scout.\nHigh stamina. Rifles, bows.",   Role = "RANGED",  RoleColor = Color3.fromRGB(50,150,220), Locked = {} },
	{ Id = "Spiritualist",Name = "SPIRITUALIST", Desc = "Force caster and healer.\nHighest FP. Not for Accretia.",  Role = "MAGIC",   RoleColor = Color3.fromRGB(170,80,230), Locked = { CYBORG = true } },
	{ Id = "Specialist",  Name = "SPECIALIST",   Desc = "Engineer and support.\nCrafting, traps, Blood Ammo.",      Role = "SUPPORT", RoleColor = Color3.fromRGB(50,190,120), Locked = {} },
}

-- ============================================================
-- 3D Model builders  (Y=0 is ground level)
-- ============================================================

-- Shared helpers used by all builders
local function mkPart(parent, name, size, color, cf, mat, trans)
	local p = Instance.new("Part")
	p.Name = name; p.Size = size; p.Color = color
	p.CFrame = cf; p.Anchored = true; p.CanCollide = false
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Transparency = trans or 0
	p.Parent = parent
	return p
end

local function mkSphere(parent, name, size, color, cf, mat)
	local p = mkPart(parent, name, size, color, cf, mat)
	local m = Instance.new("SpecialMesh"); m.MeshType = Enum.MeshType.Sphere; m.Parent = p
	return p
end

-- Cylinder: axis along Y by default (rotate Part if needed)
local function mkCyl(parent, name, size, color, cf, mat)
	local p = mkPart(parent, name, size, color, cf, mat)
	local m = Instance.new("SpecialMesh"); m.MeshType = Enum.MeshType.Cylinder; m.Parent = p
	return p
end

local function mkWedge(parent, name, size, color, cf)
	local p = Instance.new("WedgePart")
	p.Name = name; p.Size = size; p.Color = color
	p.CFrame = cf; p.Anchored = true; p.CanCollide = false
	p.Material = Enum.Material.SmoothPlastic
	p.Parent = parent
	return p
end

-- ── BELLATO — Human warrior ──────────────────────────────────
-- Proportions: standard human, skin on face/hands, silver-blue plate armor
local function buildBellato(parent)
	local SKIN   = Color3.fromRGB(220, 185, 155)
	local ARMOR  = Color3.fromRGB(55, 80, 160)
	local PLATE  = Color3.fromRGB(170, 185, 210)
	local DARK   = Color3.fromRGB(30, 45, 90)
	local GOLD_  = Color3.fromRGB(200, 165, 60)
	local HAIR   = Color3.fromRGB(80, 50, 25)

	-- Ground reference: Y=0
	-- HEAD
	mkSphere(parent, "Head",     Vector3.new(1.7,1.7,1.7), SKIN,  CFrame.new(0,7.05,0))
	-- Eyebrows ridge (dark strip)
	mkPart  (parent, "Brow",     Vector3.new(1.1,0.15,0.2), DARK, CFrame.new(0,7.4,-0.8))
	-- Hair top (piled bun / short hair)
	mkPart  (parent, "HairTop",  Vector3.new(1.6,0.55,1.6), HAIR, CFrame.new(0,7.85,-0.1))
	mkPart  (parent, "HairBack", Vector3.new(1.4,1.0,0.3),  HAIR, CFrame.new(0,7.2,0.7))
	mkPart  (parent, "HairL",    Vector3.new(0.3,1.1,0.7),  HAIR, CFrame.new(-0.8,7.1,0.2))
	mkPart  (parent, "HairR",    Vector3.new(0.3,1.1,0.7),  HAIR, CFrame.new( 0.8,7.1,0.2))

	-- NECK
	mkCyl(parent, "Neck", Vector3.new(0.5,0.6,0.5), SKIN, CFrame.new(0,6.1,0))

	-- TORSO
	mkPart(parent, "Torso",       Vector3.new(1.9,2.3,1.0),  ARMOR, CFrame.new(0,4.9,0))
	-- Chest breast plate
	mkPart(parent, "BreastPlate", Vector3.new(1.6,1.1,0.28), PLATE, CFrame.new(0,5.1,-0.6))
	-- Center ridge on plate
	mkPart(parent, "Ridge",       Vector3.new(0.2,0.9,0.1),  DARK,  CFrame.new(0,5.2,-0.75))
	-- Gold collar rim
	mkPart(parent, "Collar",      Vector3.new(1.8,0.25,1.0), GOLD_, CFrame.new(0,5.9,0))
	-- Belt
	mkPart(parent, "Belt",        Vector3.new(2.0,0.3,1.0),  GOLD_, CFrame.new(0,3.85,0))
	-- Back pack / back plate
	mkPart(parent, "BackPlate",   Vector3.new(1.7,1.5,0.25), PLATE, CFrame.new(0,4.9,0.62))

	-- SHOULDER PAULDRONS
	mkSphere(parent, "PaulL", Vector3.new(0.95,0.75,0.95), PLATE, CFrame.new(-1.25,5.75,0))
	mkSphere(parent, "PaulR", Vector3.new(0.95,0.75,0.95), PLATE, CFrame.new( 1.25,5.75,0))
	mkPart  (parent, "PaulRimL", Vector3.new(0.8,0.18,0.8), GOLD_, CFrame.new(-1.25,5.4,0))
	mkPart  (parent, "PaulRimR", Vector3.new(0.8,0.18,0.8), GOLD_, CFrame.new( 1.25,5.4,0))

	-- UPPER ARMS
	mkCyl(parent, "UArmL", Vector3.new(0.65,1.4,0.65), ARMOR, CFrame.new(-1.55,4.85,0))
	mkCyl(parent, "UArmR", Vector3.new(0.65,1.4,0.65), ARMOR, CFrame.new( 1.55,4.85,0))

	-- FOREARMS (gauntlets — armored)
	mkCyl(parent, "FArmL", Vector3.new(0.6,1.4,0.6),  PLATE, CFrame.new(-1.55,3.4,0))
	mkCyl(parent, "FArmR", Vector3.new(0.6,1.4,0.6),  PLATE, CFrame.new( 1.55,3.4,0))
	mkPart(parent, "GauntL_trim", Vector3.new(0.65,0.2,0.65), GOLD_, CFrame.new(-1.55,2.75,0))
	mkPart(parent, "GauntR_trim", Vector3.new(0.65,0.2,0.65), GOLD_, CFrame.new( 1.55,2.75,0))

	-- HANDS (skin)
	mkSphere(parent, "HandL", Vector3.new(0.55,0.55,0.55), SKIN, CFrame.new(-1.55,2.25,0))
	mkSphere(parent, "HandR", Vector3.new(0.55,0.55,0.55), SKIN, CFrame.new( 1.55,2.25,0))

	-- HIPS / SKIRT plates
	mkPart(parent, "HipL",  Vector3.new(0.7,0.6,0.9), PLATE, CFrame.new(-0.8,3.65,0))
	mkPart(parent, "HipR",  Vector3.new(0.7,0.6,0.9), PLATE, CFrame.new( 0.8,3.65,0))
	mkPart(parent, "HipF",  Vector3.new(0.9,0.6,0.25), DARK, CFrame.new(0,3.65,-0.45))

	-- UPPER LEGS (thighs — armored)
	mkCyl(parent, "ThighL", Vector3.new(0.78,1.7,0.78), ARMOR, CFrame.new(-0.6,2.75,0))
	mkCyl(parent, "ThighR", Vector3.new(0.78,1.7,0.78), ARMOR, CFrame.new( 0.6,2.75,0))

	-- KNEES
	mkSphere(parent, "KneeL", Vector3.new(0.82,0.55,0.82), PLATE, CFrame.new(-0.6,1.95,0))
	mkSphere(parent, "KneeR", Vector3.new(0.82,0.55,0.82), PLATE, CFrame.new( 0.6,1.95,0))

	-- SHINS
	mkCyl(parent, "ShinL", Vector3.new(0.7,1.5,0.7), ARMOR, CFrame.new(-0.6,1.1,0))
	mkCyl(parent, "ShinR", Vector3.new(0.7,1.5,0.7), ARMOR, CFrame.new( 0.6,1.1,0))

	-- BOOTS
	mkPart(parent, "BootL", Vector3.new(0.78,0.52,1.25), DARK, CFrame.new(-0.6,0.27,0.15))
	mkPart(parent, "BootR", Vector3.new(0.78,0.52,1.25), DARK, CFrame.new( 0.6,0.27,0.15))
	mkPart(parent, "BootRimL", Vector3.new(0.8,0.18,1.0), GOLD_, CFrame.new(-0.6,0.55,0.1))
	mkPart(parent, "BootRimR", Vector3.new(0.8,0.18,1.0), GOLD_, CFrame.new( 0.6,0.55,0.1))
end

-- ── ACCRETIA — Cyborg robot ──────────────────────────────────
-- Proportions: bulky, wide shoulders, NO skin, all mechanical
local function buildAccretia(parent)
	local DARK_M  = Color3.fromRGB(22, 25, 32)
	local MID_M   = Color3.fromRGB(42, 48, 60)
	local LIGHT_M = Color3.fromRGB(80, 88, 105)
	local NEON    = Color3.fromRGB(0, 180, 255)
	local NEON2   = Color3.fromRGB(0, 240, 255)
	local PANEL_  = Color3.fromRGB(35, 40, 52)

	-- HEAD: large dome, mechanical, no face visible
	mkSphere(parent, "Head",       Vector3.new(2.4,2.4,2.4), DARK_M, CFrame.new(0,7.2,0))
	-- Visor (wide neon band)
	mkPart  (parent, "Visor",      Vector3.new(1.8,0.5,0.2),  NEON2,  CFrame.new(0,7.3,-1.15), Enum.Material.Neon)
	-- Visor frame
	mkPart  (parent, "VisorFrame", Vector3.new(2.0,0.7,0.18), MID_M,  CFrame.new(0,7.3,-1.1))
	-- Head side fins
	mkPart  (parent, "FinL",       Vector3.new(0.2,1.5,0.5),  MID_M,  CFrame.new(-1.2,7.2,0))
	mkPart  (parent, "FinR",       Vector3.new(0.2,1.5,0.5),  MID_M,  CFrame.new( 1.2,7.2,0))
	-- Top head ridge
	mkPart  (parent, "HeadRidge",  Vector3.new(0.5,0.4,2.4),  MID_M,  CFrame.new(0,8.25,0))
	-- Antenna
	mkPart  (parent, "Antenna",    Vector3.new(0.12,0.8,0.12),NEON,   CFrame.new(0.6,8.7,0),   Enum.Material.Neon)

	-- NO NECK — torso goes directly under head

	-- TORSO: very wide and thick
	mkPart(parent, "Torso",    Vector3.new(3.2,2.8,1.7), DARK_M, CFrame.new(0,5.0,0))
	-- Chest panel inset
	mkPart(parent, "ChestPanel",Vector3.new(2.0,1.6,0.3), PANEL_, CFrame.new(0,5.2,-0.95))
	-- Core reactor (glowing)
	mkSphere(parent,"Core",    Vector3.new(0.6,0.6,0.6), NEON2, CFrame.new(0,5.3,-1.08), Enum.Material.Neon)
	-- Side panels
	mkPart(parent, "SidePanelL", Vector3.new(0.25,1.8,1.5), PANEL_, CFrame.new(-1.72,5.0,0))
	mkPart(parent, "SidePanelR", Vector3.new(0.25,1.8,1.5), PANEL_, CFrame.new( 1.72,5.0,0))
	-- Vent grills (neon slits)
	mkPart(parent, "VentL1", Vector3.new(0.2,0.12,1.2), NEON, CFrame.new(-1.83,5.4,0), Enum.Material.Neon)
	mkPart(parent, "VentL2", Vector3.new(0.2,0.12,1.2), NEON, CFrame.new(-1.83,5.1,0), Enum.Material.Neon)
	mkPart(parent, "VentR1", Vector3.new(0.2,0.12,1.2), NEON, CFrame.new( 1.83,5.4,0), Enum.Material.Neon)
	mkPart(parent, "VentR2", Vector3.new(0.2,0.12,1.2), NEON, CFrame.new( 1.83,5.1,0), Enum.Material.Neon)

	-- MEGA SHOULDER PADS
	mkPart(parent, "ShoulL",      Vector3.new(1.3,1.0,1.4), MID_M,  CFrame.new(-2.55,6.0,0))
	mkPart(parent, "ShoulR",      Vector3.new(1.3,1.0,1.4), MID_M,  CFrame.new( 2.55,6.0,0))
	mkPart(parent, "ShoulTopL",   Vector3.new(1.0,0.35,1.2),LIGHT_M,CFrame.new(-2.55,6.6,0))
	mkPart(parent, "ShoulTopR",   Vector3.new(1.0,0.35,1.2),LIGHT_M,CFrame.new( 2.55,6.6,0))
	mkPart(parent, "ShoulGlowL",  Vector3.new(0.8,0.1,0.8), NEON,   CFrame.new(-2.55,6.85,0), Enum.Material.Neon)
	mkPart(parent, "ShoulGlowR",  Vector3.new(0.8,0.1,0.8), NEON,   CFrame.new( 2.55,6.85,0), Enum.Material.Neon)

	-- UPPER ARMS (thick pipes)
	mkCyl(parent, "UArmL", Vector3.new(1.0,1.8,1.0), MID_M,  CFrame.new(-2.5,5.0,0))
	mkCyl(parent, "UArmR", Vector3.new(1.0,1.8,1.0), MID_M,  CFrame.new( 2.5,5.0,0))
	-- Arm band neon
	mkPart(parent,"ArmBandL", Vector3.new(1.05,0.18,1.05), NEON, CFrame.new(-2.5,4.2,0), Enum.Material.Neon)
	mkPart(parent,"ArmBandR", Vector3.new(1.05,0.18,1.05), NEON, CFrame.new( 2.5,4.2,0), Enum.Material.Neon)

	-- ELBOW JOINTS (sphere)
	mkSphere(parent, "ElbowL", Vector3.new(1.05,1.05,1.05), LIGHT_M, CFrame.new(-2.5,4.0,0))
	mkSphere(parent, "ElbowR", Vector3.new(1.05,1.05,1.05), LIGHT_M, CFrame.new( 2.5,4.0,0))

	-- FOREARMS
	mkCyl(parent, "FArmL", Vector3.new(0.95,1.8,0.95), DARK_M, CFrame.new(-2.5,2.85,0))
	mkCyl(parent, "FArmR", Vector3.new(0.95,1.8,0.95), DARK_M, CFrame.new( 2.5,2.85,0))

	-- GAUNTLETS (boxy mechanical)
	mkPart(parent, "GauntL", Vector3.new(1.1,0.9,1.1), MID_M, CFrame.new(-2.5,1.8,0))
	mkPart(parent, "GauntR", Vector3.new(1.1,0.9,1.1), MID_M, CFrame.new( 2.5,1.8,0))
	-- Claw neon
	mkPart(parent,"ClawL", Vector3.new(0.85,0.2,0.9), NEON, CFrame.new(-2.5,1.3,-0.1), Enum.Material.Neon)
	mkPart(parent,"ClawR", Vector3.new(0.85,0.2,0.9), NEON, CFrame.new( 2.5,1.3,-0.1), Enum.Material.Neon)

	-- WAIST (armored wide belt)
	mkPart(parent, "Waist",    Vector3.new(2.8,0.65,1.6), MID_M,  CFrame.new(0,3.65,0))
	mkPart(parent, "WaistNeon",Vector3.new(2.5,0.12,1.3), NEON,   CFrame.new(0,3.28,0), Enum.Material.Neon)

	-- UPPER LEGS (thick cylinders, wide stance)
	mkCyl(parent, "ThighL", Vector3.new(1.05,2.0,1.05), DARK_M, CFrame.new(-0.9,2.5,0))
	mkCyl(parent, "ThighR", Vector3.new(1.05,2.0,1.05), DARK_M, CFrame.new( 0.9,2.5,0))

	-- KNEE JOINTS
	mkSphere(parent, "KneeL", Vector3.new(1.1,1.1,1.1), LIGHT_M, CFrame.new(-0.9,1.5,0))
	mkSphere(parent, "KneeR", Vector3.new(1.1,1.1,1.1), LIGHT_M, CFrame.new( 0.9,1.5,0))

	-- LOWER LEGS
	mkCyl(parent, "ShinL", Vector3.new(1.0,1.85,1.0), MID_M, CFrame.new(-0.9,0.55,0))
	mkCyl(parent, "ShinR", Vector3.new(1.0,1.85,1.0), MID_M, CFrame.new( 0.9,0.55,0))

	-- FEET (wide, heavy, mechanical)
	mkPart(parent, "FootL", Vector3.new(1.2,0.5,1.9), DARK_M, CFrame.new(-0.9,0.27,0.28))
	mkPart(parent, "FootR", Vector3.new(1.2,0.5,1.9), DARK_M, CFrame.new( 0.9,0.27,0.28))
	-- Thruster heel
	mkCyl(parent, "HeelL", Vector3.new(0.5,0.5,0.6), MID_M, CFrame.new(-0.9,0.35,0.9))
	mkCyl(parent, "HeelR", Vector3.new(0.5,0.5,0.6), MID_M, CFrame.new( 0.9,0.35,0.9))
	mkPart(parent,"HeelNeonL", Vector3.new(0.4,0.12,0.4), NEON, CFrame.new(-0.9,0.1,1.0), Enum.Material.Neon)
	mkPart(parent,"HeelNeonR", Vector3.new(0.4,0.12,0.4), NEON, CFrame.new( 0.9,0.1,1.0), Enum.Material.Neon)
end

-- ── CORA — Elf mage ──────────────────────────────────────────
-- Proportions: slender, pointed ears, flowing robes, long hair
local function buildCora(parent)
	local SKIN   = Color3.fromRGB(255, 230, 210)
	local ROBE   = Color3.fromRGB(130, 70, 190)
	local ROBE2  = Color3.fromRGB(90,  40, 140)
	local ACCENT = Color3.fromRGB(220, 180, 255)
	local GOLD_  = Color3.fromRGB(220, 175, 60)
	local HAIR   = Color3.fromRGB(240, 220, 160)  -- light blonde elf hair
	local EYES   = Color3.fromRGB(120, 220, 255)

	-- HEAD (slightly slender, oval)
	mkSphere(parent, "Head",  Vector3.new(1.55,1.65,1.55), SKIN, CFrame.new(0,7.1,0))
	-- Eyes (glowing teal — elf feature)
	mkPart(parent, "EyeL",  Vector3.new(0.22,0.16,0.1), EYES, CFrame.new(-0.32,7.22,-0.78), Enum.Material.Neon)
	mkPart(parent, "EyeR",  Vector3.new(0.22,0.16,0.1), EYES, CFrame.new( 0.32,7.22,-0.78), Enum.Material.Neon)

	-- POINTED EARS (Wedge parts angled outward + upward)
	-- Left ear
	local earL = mkWedge(parent, "EarL", Vector3.new(0.22,0.75,0.4), SKIN,
		CFrame.new(-0.88,7.15,0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(25)))
	-- Left ear inner
	mkPart(parent,"EarInnerL", Vector3.new(0.05,0.45,0.25), Color3.fromRGB(240,190,185),
		CFrame.new(-0.9,7.12,0))
	-- Right ear
	mkWedge(parent, "EarR", Vector3.new(0.22,0.75,0.4), SKIN,
		CFrame.new( 0.88,7.15,0) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(-25)))
	mkPart(parent,"EarInnerR", Vector3.new(0.05,0.45,0.25), Color3.fromRGB(240,190,185),
		CFrame.new( 0.9,7.12,0))

	-- HAIR (long, flowing — multiple parts down the back)
	mkPart(parent, "HairTop",  Vector3.new(1.45,0.4,1.45), HAIR, CFrame.new(0,7.8,-0.05))
	mkPart(parent, "HairBack1",Vector3.new(1.3,1.6,0.35),  HAIR, CFrame.new(0,7.0,0.72))
	mkPart(parent, "HairBack2",Vector3.new(1.1,1.8,0.3),   HAIR, CFrame.new(0,5.9,0.65) * CFrame.Angles(math.rad(8),0,0))
	mkPart(parent, "HairBack3",Vector3.new(0.9,1.4,0.28),  HAIR, CFrame.new(0,4.8,0.7)  * CFrame.Angles(math.rad(15),0,0))
	mkPart(parent, "HairSideL",Vector3.new(0.28,2.0,0.7),  HAIR, CFrame.new(-0.7,6.5,0.15))
	mkPart(parent, "HairSideR",Vector3.new(0.28,2.0,0.7),  HAIR, CFrame.new( 0.7,6.5,0.15))
	mkPart(parent, "HairFringe",Vector3.new(1.1,0.35,0.2), HAIR, CFrame.new(0,7.6,-0.72))

	-- NECK (slim)
	mkCyl(parent, "Neck", Vector3.new(0.42,0.65,0.42), SKIN, CFrame.new(0,6.2,0))

	-- COLLAR / NECKLACE
	mkPart(parent,"Collar", Vector3.new(1.3,0.22,0.9), GOLD_, CFrame.new(0,5.85,0))
	mkSphere(parent,"Gem", Vector3.new(0.3,0.3,0.3), EYES, CFrame.new(0,5.75,-0.5), Enum.Material.Neon)

	-- TORSO (slender)
	mkPart(parent, "Torso", Vector3.new(1.5,2.2,0.85), ROBE, CFrame.new(0,4.8,0))
	-- Robe bodice detail
	mkPart(parent,"Bodice",  Vector3.new(1.25,1.4,0.28), ROBE2, CFrame.new(0,5.0,-0.55))
	mkPart(parent,"BodiceRim",Vector3.new(1.15,0.18,0.2), GOLD_, CFrame.new(0,4.3,-0.54))

	-- SHOULDERS (narrow, elegant)
	mkSphere(parent, "ShouldL", Vector3.new(0.7,0.55,0.7), ROBE2, CFrame.new(-1.0,5.7,0))
	mkSphere(parent, "ShouldR", Vector3.new(0.7,0.55,0.7), ROBE2, CFrame.new( 1.0,5.7,0))
	-- Shoulder gem accent
	mkSphere(parent,"ShouldGemL",Vector3.new(0.22,0.22,0.22), EYES, CFrame.new(-1.02,5.7,-0.35), Enum.Material.Neon)
	mkSphere(parent,"ShouldGemR",Vector3.new(0.22,0.22,0.22), EYES, CFrame.new( 1.02,5.7,-0.35), Enum.Material.Neon)

	-- UPPER ARMS (slim, bare skin then glove)
	mkCyl(parent,"UArmL", Vector3.new(0.45,1.35,0.45), SKIN,  CFrame.new(-1.2,4.8,0))
	mkCyl(parent,"UArmR", Vector3.new(0.45,1.35,0.45), SKIN,  CFrame.new( 1.2,4.8,0))

	-- FOREARMS (opera gloves — dark purple)
	mkCyl(parent,"FArmL", Vector3.new(0.42,1.3,0.42), ROBE2, CFrame.new(-1.2,3.4,0))
	mkCyl(parent,"FArmR", Vector3.new(0.42,1.3,0.42), ROBE2, CFrame.new( 1.2,3.4,0))
	mkPart(parent,"GloveTrimL", Vector3.new(0.46,0.18,0.46), GOLD_, CFrame.new(-1.2,4.1,0))
	mkPart(parent,"GloveTrimR", Vector3.new(0.46,0.18,0.46), GOLD_, CFrame.new( 1.2,4.1,0))

	-- HANDS (delicate, skin)
	mkSphere(parent,"HandL", Vector3.new(0.42,0.42,0.42), SKIN, CFrame.new(-1.2,2.65,0))
	mkSphere(parent,"HandR", Vector3.new(0.42,0.42,0.42), SKIN, CFrame.new( 1.2,2.65,0))

	-- WAIST SASH
	mkPart(parent,"Sash", Vector3.new(1.6,0.35,0.88), GOLD_, CFrame.new(0,3.75,0))

	-- ROBE SKIRT (layered, flowing — no visible legs)
	-- Inner skirt (narrow top)
	mkPart(parent,"SkirtTop",  Vector3.new(1.65,1.4,0.95), ROBE,  CFrame.new(0,3.15,0))
	-- Mid skirt (wider)
	mkPart(parent,"SkirtMid",  Vector3.new(1.95,1.3,1.1),  ROBE2, CFrame.new(0,2.15,0.04))
	-- Bottom skirt (widest, flared)
	mkPart(parent,"SkirtBot",  Vector3.new(2.3,1.0,1.3),   ROBE,  CFrame.new(0,1.15,0.08))
	mkPart(parent,"SkirtHem",  Vector3.new(2.45,0.22,1.38),GOLD_, CFrame.new(0,0.65,0.1))

	-- Front robe split (decorative line)
	mkPart(parent,"FrontSlit", Vector3.new(0.18,3.6,0.15), GOLD_, CFrame.new(0,2.6,-0.5))

	-- SLIPPERS (below skirt)
	mkPart(parent,"SlipL", Vector3.new(0.5,0.35,1.1), ROBE2, CFrame.new(-0.4,0.2,0.2))
	mkPart(parent,"SlipR", Vector3.new(0.5,0.35,1.1), ROBE2, CFrame.new( 0.4,0.2,0.2))
end

-- Dispatcher
local function buildCharModel(raceId, parent)
	if raceId == "CYBORG" then
		buildAccretia(parent)
	elseif raceId == "MYSTIC" then
		buildCora(parent)
	else
		buildBellato(parent)
	end
end

-- ============================================================
-- UI helpers
-- ============================================================

local function uiFrame(parent, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3       = props.color or Color3.new(0,0,0)
	f.BackgroundTransparency = props.transparency or 0
	f.BorderSizePixel        = 0
	f.AnchorPoint            = props.anchor or Vector2.new(0,0)
	f.Position               = props.pos   or UDim2.new(0,0,0,0)
	f.Size                   = props.size  or UDim2.new(1,0,1,0)
	f.ZIndex                 = props.z     or 1
	f.Name                   = props.name  or "Frame"
	f.ClipsDescendants       = props.clip  or false
	f.Parent                 = parent
	return f
end

local function uiLabel(parent, props)
	local l = Instance.new("TextLabel")
	l.Text                = props.text   or ""
	l.TextSize            = props.size   or 14
	l.Font                = props.bold   and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3          = props.color  or TEXT_MAIN
	l.BackgroundTransparency = 1
	l.AnchorPoint         = props.anchor or Vector2.new(0,0)
	l.Position            = props.pos    or UDim2.new(0,0,0,0)
	l.Size                = props.size2  or UDim2.new(1,0,0,20)
	l.TextXAlignment      = props.alignX or Enum.TextXAlignment.Center
	l.TextYAlignment      = props.alignY or Enum.TextYAlignment.Center
	l.TextWrapped         = true
	l.ZIndex              = props.z      or 2
	l.Name                = props.name   or "Label"
	l.Parent              = parent
	return l
end

local function uiBtn(parent, props)
	local b = Instance.new("TextButton")
	b.Text                = props.text   or ""
	b.TextSize            = props.size   or 14
	b.Font                = props.bold ~= false and Enum.Font.GothamBold or Enum.Font.Gotham
	b.TextColor3          = props.color  or TEXT_MAIN
	b.BackgroundColor3    = props.bg     or PANEL_COLOR
	b.BackgroundTransparency = props.transparency or 0
	b.BorderSizePixel     = 0
	b.AnchorPoint         = props.anchor or Vector2.new(0,0)
	b.Position            = props.pos    or UDim2.new(0,0,0,0)
	b.Size                = props.size2  or UDim2.new(1,0,0,30)
	b.ZIndex              = props.z      or 3
	b.AutoButtonColor     = false
	b.Name                = props.name   or "Button"
	b.Parent              = parent
	return b
end

local function addCorner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 4)
	c.Parent = parent
	return c
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or TEAL; s.Thickness = thickness or 1
	s.Parent = parent; return s
end

local function addGrad(parent, c0, c1, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c0, c1)
	g.Rotation = rot or 90
	g.Parent = parent
end

-- RF-style teal decorative vertical bars on panel sides
local function addDecorations(panel)
	for _, side in ipairs({ {0, Vector2.new(0,0.5)}, {1, Vector2.new(1,0.5)} }) do
		local xPos, anchor = side[1], side[2]
		local bar = uiFrame(panel, {
			color = TEAL, transparency = 0,
			anchor = anchor, pos = UDim2.new(xPos, xPos == 0 and 4 or -7, 0.5, 0),
			size = UDim2.new(0,3,0.82,0), z = 5
		})
		addGrad(bar, Color3.new(0,0,0), TEAL_BRIGHT, 90)
		-- Dot endpoints
		for _, dotAnchor in ipairs({ Vector2.new(0.5,0), Vector2.new(0.5,1) }) do
			local dot = uiFrame(bar, {
				color = TEAL_BRIGHT, anchor = dotAnchor,
				pos = UDim2.new(0.5,0, dotAnchor.Y,0),
				size = UDim2.new(0,7,0,7), z = 6
			})
			addCorner(dot, 99)
		end
	end
	-- Horizontal accent lines
	local top = uiFrame(panel,{color=TEAL,anchor=Vector2.new(0.5,0),pos=UDim2.new(0.5,0,0,10),size=UDim2.new(0.7,0,0,1),z=5})
	addGrad(top,Color3.new(0,0,0),TEAL,0)
	local bot = uiFrame(panel,{color=TEAL,anchor=Vector2.new(0.5,1),pos=UDim2.new(0.5,0,1,-10),size=UDim2.new(0.7,0,0,1),z=5})
	addGrad(bot,Color3.new(0,0,0),TEAL,0)
end

-- ============================================================
-- Show
-- ============================================================

function CharacterCreationUI.Show(onComplete)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CharacterCreationUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	-- Background
	local bg = uiFrame(screenGui, {
		color = BG_COLOR, anchor = Vector2.new(0.5,0.5),
		pos = UDim2.new(0.5,0,0.5,0), size = UDim2.new(1,0,1,0), z = 10
	})
	bg.BackgroundTransparency = 1

	local bgTint = uiFrame(bg, { color = Color3.fromRGB(0,35,45), transparency = 0.88, size = UDim2.new(1,0,1,0), z = 10 })
	addGrad(bgTint, Color3.fromRGB(0,25,35), Color3.fromRGB(0,5,12), 135)

	-- Header
	local header = uiFrame(bg, { color = Color3.fromRGB(4,7,15), size = UDim2.new(1,0,0,58), z = 11 })
	local hLine  = uiFrame(header, { color = TEAL, anchor = Vector2.new(0,1), pos = UDim2.new(0,0,1,0), size = UDim2.new(1,0,0,2), z = 12 })
	addGrad(hLine, Color3.new(0,0,0), TEAL_BRIGHT, 0)

	uiLabel(header, { text = "AETHERION", size = 20, bold = true, color = TEAL_BRIGHT,
		anchor = Vector2.new(0,0.5), pos = UDim2.new(0,20,0.5,0), size2 = UDim2.new(0,180,1,0),
		alignX = Enum.TextXAlignment.Left, z = 12 })

	local titleLbl = uiLabel(header, { text = "CHARACTER CREATION", size = 19, bold = true,
		anchor = Vector2.new(0.5,0.5), pos = UDim2.new(0.5,0,0.5,0), size2 = UDim2.new(0.4,0,1,0), z = 12 })

	local stepLbl = uiLabel(header, { text = "Step 1 — Select your race", size = 12, color = TEXT_DIM,
		anchor = Vector2.new(1,0.5), pos = UDim2.new(1,-20,0.5,0), size2 = UDim2.new(0,220,1,0),
		alignX = Enum.TextXAlignment.Right, z = 12 })

	-- Content area
	local content = uiFrame(bg, {
		color = Color3.new(0,0,0), transparency = 1,
		pos = UDim2.new(0,0,0,58), size = UDim2.new(1,0,1,-58), z = 11
	})

	-- State
	local selectedRace  = nil
	local selectedClass = nil
	local raceCards     = {}
	local classCardsList = {}
	local classPanelGui = nil
	local confirmBtn    = nil
	local statusLbl     = nil

	-- ── Race panels ──────────────────────────────────────────
	local racePanelsHolder = uiFrame(content, {
		color = Color3.new(0,0,0), transparency = 1,
		anchor = Vector2.new(0.5,0.5), pos = UDim2.new(0.5,0,0.44,0),
		size = UDim2.new(0.96,0,0.82,0), z = 11
	})

	local ll = Instance.new("UIListLayout")
	ll.FillDirection = Enum.FillDirection.Horizontal
	ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ll.VerticalAlignment   = Enum.VerticalAlignment.Center
	ll.Padding = UDim.new(0.014,0)
	ll.Parent  = racePanelsHolder

	local function refreshRaceCards()
		for i, rc in ipairs(raceCards) do
			local sel = (selectedRace and rc.Race.Id == selectedRace.Id)
			rc.StrokeObj.Color = sel and SEL_GLOW or TEAL_DIM
			rc.StrokeObj.Thickness = sel and 3 or 1
			rc.NameBar.BackgroundColor3 = sel and Color3.fromRGB(0,75,85) or Color3.fromRGB(8,14,22)
			rc.SelectBtn.BackgroundColor3 = sel and TEAL or PANEL_COLOR
			rc.SelectBtn.TextColor3 = sel and BG_COLOR or TEAL
			rc.SelectBtn.Text = sel and "✔  SELECTED" or "SELECT RACE"
		end
	end

	for _, race in ipairs(RACES) do
		local panel = uiFrame(racePanelsHolder, {
			color = PANEL_COLOR, size = UDim2.new(0.32,0,1,0), z = 12, name = race.Id
		})
		addCorner(panel, 4)
		local pStroke = addStroke(panel, TEAL_DIM, 1)
		addDecorations(panel)

		-- Name bar
		local nameBar = uiFrame(panel, { color = Color3.fromRGB(8,14,22), size = UDim2.new(1,0,0,42), z = 13, name = "NameBar" })
		addCorner(nameBar, 4)
		uiLabel(nameBar, { text = race.DisplayName, size = 14, bold = true,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0,5), size2 = UDim2.new(0.9,0,0,20), z = 14 })
		uiLabel(nameBar, { text = race.SubTitle, size = 10, color = TEAL,
			anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-7), size2 = UDim2.new(0.9,0,0,14), z = 14 })

		-- ViewportFrame
		local vf = Instance.new("ViewportFrame")
		vf.BackgroundColor3 = Color3.fromRGB(3,5,10)
		vf.BackgroundTransparency = 0
		vf.BorderSizePixel = 0
		vf.AnchorPoint = Vector2.new(0.5,0)
		vf.Position    = UDim2.new(0.5,0,0,44)
		vf.Size        = UDim2.new(1,-14,0.62,-52)
		vf.ZIndex      = 13
		vf.LightColor     = Color3.fromRGB(200,230,255)
		vf.LightDirection = Vector3.new(-0.8,-1,-0.5)
		vf.Ambient        = Color3.fromRGB(50,70,100)
		vf.Parent = panel

		-- Fade bottom of viewport
		local vfFade = Instance.new("ImageLabel")
		vfFade.BackgroundTransparency = 1
		vfFade.AnchorPoint = Vector2.new(0,1)
		vfFade.Position    = UDim2.new(0,0,1,0)
		vfFade.Size        = UDim2.new(1,0,0,48)
		vfFade.ZIndex      = 14
		vfFade.Image       = "rbxassetid://1316045217"
		vfFade.ImageColor3 = PANEL_COLOR
		vfFade.ScaleType   = Enum.ScaleType.Stretch
		vfFade.Parent      = vf

		-- Camera
		local cam = Instance.new("Camera")
		cam.Parent = vf
		vf.CurrentCamera = cam
		-- Slight upward-look angle (RF Classic style)
		cam.CFrame = CFrame.new(Vector3.new(0,3.5,11), Vector3.new(0,5.0,0))

		-- WorldModel + character parts
		local wm = Instance.new("WorldModel")
		wm.Parent = vf
		buildCharModel(race.Id, wm)

		-- Gather all parts for rotation
		local allParts = {}
		for _, p in ipairs(wm:GetDescendants()) do
			if p:IsA("BasePart") then
				table.insert(allParts, { part = p, offset = p.CFrame })
			end
		end

		local angle = 0
		local function rotateModel(delta)
			angle = angle + delta
			local rot = CFrame.Angles(0, math.rad(angle), 0)
			for _, pd in ipairs(allParts) do
				pd.part.CFrame = rot * pd.offset
			end
		end
		-- Slight initial angle to show the character at 3/4 view
		rotateModel(-15)

		-- Rotate bar
		local rotBar = uiFrame(panel, {
			color = Color3.fromRGB(4,7,13), pos = UDim2.new(0,7,0.62,-2),
			size = UDim2.new(1,-14,0,30), z = 13
		})
		local rotL = uiBtn(rotBar, {
			text = "◀  Rotate L", size = 11, bold = false, color = TEAL,
			bg = Color3.fromRGB(0,25,30), anchor = Vector2.new(0,0.5),
			pos = UDim2.new(0,0,0.5,0), size2 = UDim2.new(0.48,0,0,22), z = 14
		})
		addCorner(rotL, 3)
		local rotR = uiBtn(rotBar, {
			text = "Rotate R  ▶", size = 11, bold = false, color = TEAL,
			bg = Color3.fromRGB(0,25,30), anchor = Vector2.new(1,0.5),
			pos = UDim2.new(1,0,0.5,0), size2 = UDim2.new(0.48,0,0,22), z = 14
		})
		addCorner(rotR, 3)

		local rotTask = nil
		rotL.MouseButton1Down:Connect(function()
			rotateModel(-14)
			rotTask = task.spawn(function() while true do task.wait(0.04) rotateModel(-9) end end)
		end)
		rotL.MouseButton1Up:Connect(function() if rotTask then task.cancel(rotTask) rotTask = nil end end)
		rotR.MouseButton1Down:Connect(function()
			rotateModel(14)
			rotTask = task.spawn(function() while true do task.wait(0.04) rotateModel(9) end end)
		end)
		rotR.MouseButton1Up:Connect(function() if rotTask then task.cancel(rotTask) rotTask = nil end end)

		-- Description
		uiLabel(panel, {
			text = race.Desc, size = 12, color = TEXT_DIM,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0.62,34),
			size2 = UDim2.new(0.88,0,0,58), z = 13
		})

		-- Select button
		local selBtn = uiBtn(panel, {
			text = "SELECT RACE", size = 12, color = TEAL, bg = PANEL_COLOR,
			anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-11),
			size2 = UDim2.new(0.8,0,0,32), z = 13
		})
		addCorner(selBtn, 4)
		addStroke(selBtn, TEAL, 1)

		-- Click overlay (whole panel clickable)
		local clickOv = uiBtn(panel, { text="", bg=Color3.new(0,0,0), transparency=1, size=UDim2.new(1,0,1,0), z=15 })

		local rc = { Race = race, Panel = panel, StrokeObj = pStroke, NameBar = nameBar, SelectBtn = selBtn }
		table.insert(raceCards, rc)

		local function onSelectRace()
			selectedRace = race
			selectedClass = nil
			refreshRaceCards()
			stepLbl.Text = "Step 2 — Select your class"
			titleLbl.Text = "CLASS SELECTION"
			if classPanelGui then classPanelGui.Visible = true end
			if confirmBtn then confirmBtn.Visible = false end
			-- refresh class locks
			for _, cc in ipairs(classCardsList) do
				local locked = cc.Class.Locked[race.Id]
				cc.LockOverlay.Visible = locked or false
				cc.Btn.Active = not locked
				cc.Panel.BackgroundTransparency = locked and 0.6 or 0
				-- clear selected state
				cc.StrokeObj.Color = locked and Color3.fromRGB(25,25,30) or TEAL_DIM
				cc.StrokeObj.Thickness = 1
				cc.Panel.BackgroundColor3 = locked and Color3.fromRGB(6,6,8) or PANEL_COLOR
				cc.Btn.BackgroundColor3 = locked and Color3.fromRGB(12,12,15) or PANEL_COLOR
				cc.Btn.TextColor3 = locked and Color3.fromRGB(50,50,60) or TEAL
				cc.Btn.Text = locked and "LOCKED" or "SELECT"
			end
		end

		selBtn.MouseButton1Click:Connect(onSelectRace)
		clickOv.MouseButton1Click:Connect(onSelectRace)
	end

	-- ── Class panel ──────────────────────────────────────────
	classPanelGui = uiFrame(content, {
		color = Color3.fromRGB(4,7,14),
		anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,0),
		size = UDim2.new(0.96,0,0,188), z = 20, name = "ClassPanel"
	})
	classPanelGui.Visible = false
	addStroke(classPanelGui, TEAL_DIM, 1)
	addCorner(classPanelGui, 4)
	uiFrame(classPanelGui, { color=TEAL, size=UDim2.new(1,0,0,2), z=21 }) -- top line
	uiLabel(classPanelGui, { text="SELECT CLASS", size=12, bold=true, color=TEAL,
		anchor=Vector2.new(0,0), pos=UDim2.new(0,14,0,8), size2=UDim2.new(0.3,0,0,18),
		alignX=Enum.TextXAlignment.Left, z=21 })

	local classRow = uiFrame(classPanelGui, {
		color=Color3.new(0,0,0), transparency=1,
		anchor=Vector2.new(0.5,1), pos=UDim2.new(0.5,0,1,-10),
		size=UDim2.new(1,-18,0,146), z=21
	})
	local cl = Instance.new("UIListLayout")
	cl.FillDirection = Enum.FillDirection.Horizontal
	cl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	cl.VerticalAlignment   = Enum.VerticalAlignment.Center
	cl.Padding = UDim.new(0.012,0)
	cl.Parent  = classRow

	for _, cls in ipairs(CLASSES) do
		local cp = uiFrame(classRow, { color=PANEL_COLOR, size=UDim2.new(0.24,0,1,0), z=22 })
		addCorner(cp, 4)
		local cStroke = addStroke(cp, TEAL_DIM, 1)

		-- Role color top bar
		uiFrame(cp, { color=cls.RoleColor, transparency=0.35, size=UDim2.new(1,0,0,4), z=23 })

		uiLabel(cp, { text=cls.Name, size=13, bold=true,
			anchor=Vector2.new(0.5,0), pos=UDim2.new(0.5,0,0,9), size2=UDim2.new(0.9,0,0,20), z=23 })

		local roleTag = uiFrame(cp, { color=cls.RoleColor, transparency=0.65,
			anchor=Vector2.new(0.5,0), pos=UDim2.new(0.5,0,0,33), size=UDim2.new(0,62,0,16), z=23 })
		addCorner(roleTag, 3)
		uiLabel(roleTag, { text=cls.Role, size=10, bold=true, size2=UDim2.new(1,0,1,0), z=24 })

		uiLabel(cp, { text=cls.Desc, size=11, color=TEXT_DIM,
			anchor=Vector2.new(0.5,0), pos=UDim2.new(0.5,0,0,55), size2=UDim2.new(0.88,0,0,52), z=23 })

		-- Lock overlay
		local lockOv = uiFrame(cp, { color=Color3.fromRGB(4,4,6), transparency=0.4, size=UDim2.new(1,0,1,0), z=25 })
		addCorner(lockOv, 4)
		uiLabel(lockOv, { text="NOT\nAVAILABLE", size=12, bold=true,
			color=Color3.fromRGB(180,50,50), size2=UDim2.new(1,0,1,0),
			anchor=Vector2.new(0.5,0.5), pos=UDim2.new(0.5,0,0.5,0), z=26 })
		lockOv.Visible = false

		local cBtn = uiBtn(cp, {
			text="SELECT", size=12, color=TEAL, bg=PANEL_COLOR,
			anchor=Vector2.new(0.5,1), pos=UDim2.new(0.5,0,1,-8),
			size2=UDim2.new(0.8,0,0,26), z=23
		})
		addCorner(cBtn, 4)
		addStroke(cBtn, TEAL_DIM, 1)

		local cc = { Class=cls, Panel=cp, StrokeObj=cStroke, LockOverlay=lockOv, Btn=cBtn }
		table.insert(classCardsList, cc)

		cBtn.MouseButton1Click:Connect(function()
			if not selectedRace then return end
			if cls.Locked[selectedRace.Id] then return end
			selectedClass = cls
			-- Update all class cards
			for _, c2 in ipairs(classCardsList) do
				local sel2 = (c2.Class.Id == cls.Id)
				local lk2  = selectedRace and c2.Class.Locked[selectedRace.Id]
				if not lk2 then
					c2.Panel.BackgroundColor3 = sel2 and Color3.fromRGB(0,38,46) or PANEL_COLOR
					c2.StrokeObj.Color        = sel2 and SEL_GLOW or TEAL_DIM
					c2.StrokeObj.Thickness    = sel2 and 2 or 1
					c2.Btn.BackgroundColor3   = sel2 and TEAL or PANEL_COLOR
					c2.Btn.TextColor3         = sel2 and BG_COLOR or TEAL
					c2.Btn.Text               = sel2 and "✔ SELECTED" or "SELECT"
				end
			end
			stepLbl.Text = "Step 3 — Confirm your selection"
			if confirmBtn then confirmBtn.Visible = true end
		end)
	end

	-- ── Confirm ──────────────────────────────────────────────
	confirmBtn = uiBtn(content, {
		text = "CREATE CHARACTER", size = 15,
		color = BG_COLOR, bg = TEAL,
		anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-14),
		size2 = UDim2.new(0,235,0,44), z = 30
	})
	addCorner(confirmBtn, 6)
	addStroke(confirmBtn, TEAL_BRIGHT, 2)
	confirmBtn.Visible = false

	statusLbl = uiLabel(content, {
		text = "", size = 12, color = GOLD,
		anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-64),
		size2 = UDim2.new(0.5,0,0,24), z = 30
	})

	confirmBtn.MouseButton1Click:Connect(function()
		if not selectedRace or not selectedClass then return end
		confirmBtn.Active = false
		confirmBtn.BackgroundColor3 = TEAL_DIM
		confirmBtn.Text = "CREATING..."
		statusLbl.Text  = "Contacting server..."

		local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
		local selectRemote = remotes and remotes:FindFirstChild("SelectRaceAndClassRequest")
		if not selectRemote then
			statusLbl.Text = "Error: remote not found"
			confirmBtn.Active = true; confirmBtn.BackgroundColor3 = TEAL; confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		local ok, result = pcall(function()
			return selectRemote:InvokeServer(selectedRace.Id, selectedClass.Id)
		end)

		if not ok or not result then
			statusLbl.Text = not ok and ("Error: " .. tostring(result)) or "Rejected. Try again."
			confirmBtn.Active = true; confirmBtn.BackgroundColor3 = TEAL; confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		-- Success
		statusLbl.Text  = "Character created! Entering world..."
		confirmBtn.Text = "ENTERING WORLD..."
		titleLbl.Text   = "WELCOME TO AETHERION"
		stepLbl.Text    = selectedRace.DisplayName .. "  ·  " .. selectedClass.Name

		TweenService:Create(bg, TweenInfo.new(1.4), { BackgroundTransparency = 1 }):Play()
		task.wait(1.5)
		screenGui:Destroy()
		if onComplete then onComplete(selectedRace.Id, selectedClass.Id) end
	end)

	-- Fade in
	TweenService:Create(bg, TweenInfo.new(0.9), { BackgroundTransparency = 0 }):Play()
	return screenGui
end

return CharacterCreationUI
