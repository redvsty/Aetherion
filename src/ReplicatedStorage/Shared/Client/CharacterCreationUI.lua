-- CharacterCreationUI.lua
-- RF Classic-style character creation.
-- Accretia = white/silver robot + orange gems (matching RF Classic color scheme)
-- Bellato  = human female, skin visible, blue-silver armor
-- Cora     = elf female, slender, pointed ears, flowing robes

local Players       = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService  = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CharacterCreationUI = {}

-- ============================================================
-- Palette
-- ============================================================
local BG_COLOR    = Color3.fromRGB(6, 8, 14)
local PANEL_COLOR = Color3.fromRGB(10, 14, 22)
local TEAL        = Color3.fromRGB(0, 200, 210)
local TEAL_DIM    = Color3.fromRGB(0, 90, 100)
local TEAL_BRIGHT = Color3.fromRGB(80, 240, 250)
local TEXT_MAIN   = Color3.fromRGB(220, 235, 250)
local TEXT_DIM    = Color3.fromRGB(110, 130, 160)
local SEL_GLOW    = Color3.fromRGB(0, 210, 230)
local GOLD        = Color3.fromRGB(255, 210, 60)

-- ============================================================
-- Race + Class data
-- ============================================================
local RACES = {
	{ Id="MECHA",  DisplayName="Bellato Federation", SubTitle="MECHA  ·  HUMAN",
	  Desc="Masters of MAU battle mechs.\nBalanced stats. Superior melee\nand mechanical warfare." },
	{ Id="CYBORG", DisplayName="Accretia Empire",    SubTitle="CYBORG  ·  ROBOT",
	  Desc="Pure war machines. No magic,\nno mercy. Highest armor\nand Launcher class." },
	{ Id="MYSTIC", DisplayName="Cora Alliance",      SubTitle="MYSTIC  ·  ELF",
	  Desc="Animus spirit summoners\nand Force wielders. Highest FP\nand magical ability." },
}
local CLASSES = {
	{ Id="Warrior",      Name="WARRIOR",      Desc="Front-line melee.\nHighest HP. Swords.",       Role="MELEE",   RoleColor=Color3.fromRGB(220,70,50),  Locked={} },
	{ Id="Ranger",       Name="RANGER",       Desc="Ranged attacker.\nHigh stamina. Rifles.",       Role="RANGED",  RoleColor=Color3.fromRGB(50,150,220), Locked={} },
	{ Id="Spiritualist", Name="SPIRITUALIST", Desc="Force caster.\nHighest FP. Not Accretia.",      Role="MAGIC",   RoleColor=Color3.fromRGB(170,80,230), Locked={CYBORG=true} },
	{ Id="Specialist",   Name="SPECIALIST",   Desc="Engineer support.\nCrafting, traps, heal.",     Role="SUPPORT", RoleColor=Color3.fromRGB(50,190,120), Locked={} },
}

-- ============================================================
-- 3D character builders  (Y=0 is ground)
-- ============================================================

local function P(parent, name, size, color, cf, mat, trans)
	local p = Instance.new("Part")
	p.Name=name; p.Size=size; p.Color=color; p.CFrame=cf
	p.Anchored=true; p.CanCollide=false
	p.Material = mat or Enum.Material.SmoothPlastic
	p.Transparency = trans or 0
	p.Parent = parent
	return p
end
local function Sph(parent, name, size, color, cf, mat)
	local p = P(parent, name, size, color, cf, mat)
	local m = Instance.new("SpecialMesh"); m.MeshType=Enum.MeshType.Sphere; m.Parent=p
	return p
end
local function Cyl(parent, name, size, color, cf, mat)
	local p = P(parent, name, size, color, cf, mat)
	local m = Instance.new("SpecialMesh"); m.MeshType=Enum.MeshType.Cylinder; m.Parent=p
	return p
end
local function Wdg(parent, name, size, color, cf)
	local w = Instance.new("WedgePart")
	w.Name=name; w.Size=size; w.Color=color; w.CFrame=cf
	w.Anchored=true; w.CanCollide=false; w.Material=Enum.Material.SmoothPlastic
	w.Parent=parent; return w
end

-- ── ACCRETIA — white/silver robot, matching RF Classic color scheme ──────────
local function buildAccretia(parent)
	local WH  = Color3.fromRGB(200, 210, 218)   -- main silver-white
	local WH2 = Color3.fromRGB(165, 175, 188)   -- secondary plate
	local DK  = Color3.fromRGB(35,  40,  50)    -- dark joints
	local MID = Color3.fromRGB(85,  92, 108)    -- mid-grey mechanical
	local GEM = Color3.fromRGB(255, 138, 20)    -- orange gem (Neon)
	local VIS = Color3.fromRGB(60,  170, 255)   -- blue visor (Neon)

	-- HEAD: large dome, white/silver, blue visor
	Sph(parent,"Head",        Vector3.new(2.3,2.3,2.3),  WH,  CFrame.new(0,7.15,0))
	P  (parent,"VisorFrame",  Vector3.new(2.0,0.65,0.15),DK,  CFrame.new(0,7.25,-1.05))
	P  (parent,"Visor",       Vector3.new(1.7,0.42,0.12),VIS, CFrame.new(0,7.28,-1.1), Enum.Material.Neon)
	P  (parent,"HeadTopRidge",Vector3.new(0.45,0.22,2.2),WH2, CFrame.new(0,8.2,0))
	P  (parent,"HeadFinL",    Vector3.new(0.16,1.5,0.45),WH2, CFrame.new(-1.12,7.15,0))
	P  (parent,"HeadFinR",    Vector3.new(0.16,1.5,0.45),WH2, CFrame.new( 1.12,7.15,0))

	-- TORSO: wide, hexagonal front plate
	P  (parent,"TorsoCore",   Vector3.new(3.1,2.9,1.65), DK,  CFrame.new(0,4.9,0))
	P  (parent,"ChestPlate",  Vector3.new(2.65,2.3,0.28),WH,  CFrame.new(0,5.1,-0.97))
	-- Hexagonal inset lines
	P  (parent,"HexLineL",    Vector3.new(0.1,2.0,0.12), MID, CFrame.new(-0.75,5.1,-1.08)*CFrame.Angles(0,0,math.rad(28)))
	P  (parent,"HexLineR",    Vector3.new(0.1,2.0,0.12), MID, CFrame.new( 0.75,5.1,-1.08)*CFrame.Angles(0,0,math.rad(-28)))
	P  (parent,"HexTop",      Vector3.new(1.0,0.1,0.12), MID, CFrame.new(0,6.1,-1.08))
	-- 3 orange gem nodes (triangle formation) matching RF Classic
	Sph(parent,"GemTop",      Vector3.new(0.38,0.38,0.38),GEM, CFrame.new(0,   5.8,-1.12), Enum.Material.Neon)
	Sph(parent,"GemBL",       Vector3.new(0.38,0.38,0.38),GEM, CFrame.new(-0.5,5.15,-1.12),Enum.Material.Neon)
	Sph(parent,"GemBR",       Vector3.new(0.38,0.38,0.38),GEM, CFrame.new( 0.5,5.15,-1.12),Enum.Material.Neon)
	-- Back plate
	P  (parent,"BackPlate",   Vector3.new(2.9,2.5,0.28), WH2, CFrame.new(0,5.0,0.97))
	-- Side vents
	P  (parent,"VentL",       Vector3.new(0.22,1.6,1.5), MID, CFrame.new(-1.72,4.9,0))
	P  (parent,"VentR",       Vector3.new(0.22,1.6,1.5), MID, CFrame.new( 1.72,4.9,0))

	-- MEGA SHOULDER PADS: curved upward shape (WedgePart gives the swept look)
	P  (parent,"ShoulBodyL",  Vector3.new(1.25,1.1,1.35), WH,  CFrame.new(-2.45,5.85,0))
	Wdg(parent,"ShoulCurveL", Vector3.new(1.25,0.75,1.35),WH2, CFrame.new(-2.45,6.6,0)*CFrame.Angles(0,math.rad(180),0))
	Sph(parent,"ShoulGemL",   Vector3.new(0.32,0.32,0.32),GEM, CFrame.new(-2.45,5.85,-0.55),Enum.Material.Neon)
	P  (parent,"ShoulBodyR",  Vector3.new(1.25,1.1,1.35), WH,  CFrame.new( 2.45,5.85,0))
	Wdg(parent,"ShoulCurveR", Vector3.new(1.25,0.75,1.35),WH2, CFrame.new( 2.45,6.6,0))
	Sph(parent,"ShoulGemR",   Vector3.new(0.32,0.32,0.32),GEM, CFrame.new( 2.45,5.85,-0.55),Enum.Material.Neon)

	-- UPPER ARMS
	Cyl(parent,"UArmL",       Vector3.new(0.92,1.75,0.92),DK,  CFrame.new(-2.35,4.6,0))
	Cyl(parent,"UArmR",       Vector3.new(0.92,1.75,0.92),DK,  CFrame.new( 2.35,4.6,0))
	-- Elbow joints (sphere)
	Sph(parent,"ElbowL",      Vector3.new(1.0,1.0,1.0),   WH2, CFrame.new(-2.35,3.65,0))
	Sph(parent,"ElbowR",      Vector3.new(1.0,1.0,1.0),   WH2, CFrame.new( 2.35,3.65,0))
	-- Forearms
	Cyl(parent,"FArmL",       Vector3.new(0.88,1.75,0.88), WH, CFrame.new(-2.35,2.55,0))
	Cyl(parent,"FArmR",       Vector3.new(0.88,1.75,0.88), WH, CFrame.new( 2.35,2.55,0))
	-- Gauntlets
	P  (parent,"GauntL",      Vector3.new(1.05,0.85,1.05), DK, CFrame.new(-2.35,1.5,0))
	P  (parent,"GauntR",      Vector3.new(1.05,0.85,1.05), DK, CFrame.new( 2.35,1.5,0))
	P  (parent,"ClawNeonL",   Vector3.new(0.85,0.14,0.85), VIS,CFrame.new(-2.35,1.05,-0.1),Enum.Material.Neon)
	P  (parent,"ClawNeonR",   Vector3.new(0.85,0.14,0.85), VIS,CFrame.new( 2.35,1.05,-0.1),Enum.Material.Neon)

	-- WAIST
	P  (parent,"Waist",       Vector3.new(2.6,0.62,1.6),  DK,  CFrame.new(0,3.55,0))
	P  (parent,"WaistFront",  Vector3.new(2.1,0.42,0.2),  WH2, CFrame.new(0,3.55,-0.98))

	-- UPPER LEGS (thick, dark)
	Cyl(parent,"ThighL",      Vector3.new(1.08,2.05,1.08), DK, CFrame.new(-0.88,2.4,0))
	Cyl(parent,"ThighR",      Vector3.new(1.08,2.05,1.08), DK, CFrame.new( 0.88,2.4,0))
	-- Knee joints with orange gems
	Sph(parent,"KneeL",       Vector3.new(1.12,1.12,1.12), WH2,CFrame.new(-0.88,1.35,0))
	Sph(parent,"KneeR",       Vector3.new(1.12,1.12,1.12), WH2,CFrame.new( 0.88,1.35,0))
	Sph(parent,"KneeGemL",    Vector3.new(0.3,0.3,0.3),    GEM,CFrame.new(-0.88,1.35,-0.55),Enum.Material.Neon)
	Sph(parent,"KneeGemR",    Vector3.new(0.3,0.3,0.3),    GEM,CFrame.new( 0.88,1.35,-0.55),Enum.Material.Neon)
	-- Shins (white)
	Cyl(parent,"ShinL",       Vector3.new(0.95,1.8,0.95),  WH, CFrame.new(-0.88,0.38,0))
	Cyl(parent,"ShinR",       Vector3.new(0.95,1.8,0.95),  WH, CFrame.new( 0.88,0.38,0))
	-- Feet (wide, mechanical)
	P  (parent,"FootL",       Vector3.new(1.1,0.48,1.8),   DK, CFrame.new(-0.88,0.24,0.28))
	P  (parent,"FootR",       Vector3.new(1.1,0.48,1.8),   DK, CFrame.new( 0.88,0.24,0.28))
	P  (parent,"ToeL",        Vector3.new(0.85,0.28,0.55), WH, CFrame.new(-0.88,0.14,-0.9))
	P  (parent,"ToeR",        Vector3.new(0.85,0.28,0.55), WH, CFrame.new( 0.88,0.14,-0.9))
end

-- ── BELLATO — human female, blue-silver armor, skin visible ─────────────────
local function buildBellato(parent)
	local SKIN  = Color3.fromRGB(220, 185, 155)
	local SKIN2 = Color3.fromRGB(205, 170, 140)
	local ARMOR = Color3.fromRGB(55, 80, 162)
	local PLATE = Color3.fromRGB(175, 188, 215)
	local DARK  = Color3.fromRGB(28, 40, 85)
	local GOLD_ = Color3.fromRGB(210, 170, 55)
	local HAIR  = Color3.fromRGB(55, 38, 20)
	local WHITE = Color3.fromRGB(235, 240, 245)

	-- HEAD
	Sph(parent,"Head",       Vector3.new(1.65,1.7,1.65),  SKIN, CFrame.new(0,7.05,0))
	-- Face detail
	P  (parent,"Nose",       Vector3.new(0.12,0.15,0.1),  SKIN2,CFrame.new(0,6.95,-0.83))
	P  (parent,"Brow",       Vector3.new(1.0,0.12,0.14),  Color3.fromRGB(80,55,30),CFrame.new(0,7.4,-0.78))

	-- HAIR (dark, short female style with two side pieces)
	P  (parent,"HairTop",   Vector3.new(1.55,0.5,1.6),   HAIR, CFrame.new(0,7.82,-0.06))
	P  (parent,"HairBack",  Vector3.new(1.4,0.9,0.32),   HAIR, CFrame.new(0,7.15,0.68))
	P  (parent,"HairFringe",Vector3.new(1.2,0.35,0.18),  HAIR, CFrame.new(0,7.58,-0.72))
	P  (parent,"HairSideL", Vector3.new(0.28,1.1,0.72),  HAIR, CFrame.new(-0.78,7.1,0.18))
	P  (parent,"HairSideR", Vector3.new(0.28,1.1,0.72),  HAIR, CFrame.new( 0.78,7.1,0.18))

	-- NECK (skin)
	Cyl(parent,"Neck",       Vector3.new(0.44,0.62,0.44), SKIN, CFrame.new(0,6.16,0))

	-- TORSO — blue armor
	P  (parent,"Torso",      Vector3.new(1.9,2.25,0.95),  ARMOR,CFrame.new(0,4.85,0))
	-- Chest breast plate (silver)
	P  (parent,"BreastPlate",Vector3.new(1.65,1.05,0.28), PLATE,CFrame.new(0,5.05,-0.62))
	P  (parent,"BPRidge",    Vector3.new(0.18,0.88,0.1),  DARK, CFrame.new(0,5.12,-0.78))
	-- Collar
	P  (parent,"Collar",     Vector3.new(1.82,0.22,0.95), GOLD_,CFrame.new(0,5.88,0))
	-- Belt
	P  (parent,"Belt",       Vector3.new(2.0,0.28,0.95),  GOLD_,CFrame.new(0,3.82,0))
	-- Back plate (white)
	P  (parent,"BackPlate",  Vector3.new(1.7,1.5,0.22),   PLATE,CFrame.new(0,4.85,0.6))
	-- Midriff skin (between top and bottom, RF Classic shows midriff)
	P  (parent,"Midriff",    Vector3.new(1.5,0.5,0.88),   SKIN, CFrame.new(0,3.62,0))

	-- SHOULDER PAULDRONS
	Sph(parent,"PaulL",      Vector3.new(0.9,0.72,0.9),   PLATE,CFrame.new(-1.22,5.72,0))
	Sph(parent,"PaulR",      Vector3.new(0.9,0.72,0.9),   PLATE,CFrame.new( 1.22,5.72,0))
	P  (parent,"PaulRimL",   Vector3.new(0.78,0.16,0.78), GOLD_,CFrame.new(-1.22,5.38,0))
	P  (parent,"PaulRimR",   Vector3.new(0.78,0.16,0.78), GOLD_,CFrame.new( 1.22,5.38,0))

	-- UPPER ARMS (skin)
	Cyl(parent,"UArmL",      Vector3.new(0.58,1.35,0.58), SKIN, CFrame.new(-1.52,4.82,0))
	Cyl(parent,"UArmR",      Vector3.new(0.58,1.35,0.58), SKIN, CFrame.new( 1.52,4.82,0))

	-- FOREARMS (armored)
	Cyl(parent,"FArmL",      Vector3.new(0.55,1.35,0.55), PLATE,CFrame.new(-1.52,3.38,0))
	Cyl(parent,"FArmR",      Vector3.new(0.55,1.35,0.55), PLATE,CFrame.new( 1.52,3.38,0))
	P  (parent,"GauntTrimL", Vector3.new(0.6,0.16,0.6),   GOLD_,CFrame.new(-1.52,2.72,0))
	P  (parent,"GauntTrimR", Vector3.new(0.6,0.16,0.6),   GOLD_,CFrame.new( 1.52,2.72,0))

	-- HANDS (skin)
	Sph(parent,"HandL",      Vector3.new(0.52,0.52,0.52), SKIN, CFrame.new(-1.52,2.22,0))
	Sph(parent,"HandR",      Vector3.new(0.52,0.52,0.52), SKIN, CFrame.new( 1.52,2.22,0))

	-- HIPS
	P  (parent,"HipL",       Vector3.new(0.68,0.55,0.9),  PLATE,CFrame.new(-0.78,3.6,0))
	P  (parent,"HipR",       Vector3.new(0.68,0.55,0.9),  PLATE,CFrame.new( 0.78,3.6,0))

	-- THIGHS (skin — short skirt/shorts showing thighs like RF Bellato)
	Cyl(parent,"ThighL",     Vector3.new(0.72,1.65,0.72), SKIN, CFrame.new(-0.58,2.7,0))
	Cyl(parent,"ThighR",     Vector3.new(0.72,1.65,0.72), SKIN, CFrame.new( 0.58,2.7,0))

	-- KNEES
	Sph(parent,"KneeL",      Vector3.new(0.75,0.52,0.75), PLATE,CFrame.new(-0.58,1.9,0))
	Sph(parent,"KneeR",      Vector3.new(0.75,0.52,0.75), PLATE,CFrame.new( 0.58,1.9,0))

	-- BOOTS (thigh-high white, RF Classic Bellato style)
	Cyl(parent,"ShinL",      Vector3.new(0.68,1.55,0.68), WHITE,CFrame.new(-0.58,1.1,0))
	Cyl(parent,"ShinR",      Vector3.new(0.68,1.55,0.68), WHITE,CFrame.new( 0.58,1.1,0))
	P  (parent,"BootTopL",   Vector3.new(0.72,0.2,0.72),  DARK, CFrame.new(-0.58,1.9,0))
	P  (parent,"BootTopR",   Vector3.new(0.72,0.2,0.72),  DARK, CFrame.new( 0.58,1.9,0))
	P  (parent,"BootL",      Vector3.new(0.75,0.5,1.2),   DARK, CFrame.new(-0.58,0.28,0.12))
	P  (parent,"BootR",      Vector3.new(0.75,0.5,1.2),   DARK, CFrame.new( 0.58,0.28,0.12))
end

-- ── CORA — elf female, slender, pointed ears, flowing robes ─────────────────
local function buildCora(parent)
	local SKIN  = Color3.fromRGB(252, 230, 210)
	local SKIN2 = Color3.fromRGB(240, 200, 185)
	local ROBE  = Color3.fromRGB(138, 72, 195)
	local ROBE2 = Color3.fromRGB(95,  44, 148)
	local ACC   = Color3.fromRGB(220, 185, 255)
	local GOLD_ = Color3.fromRGB(220, 178, 58)
	local HAIR  = Color3.fromRGB(238, 218, 140)  -- blonde
	local EYES  = Color3.fromRGB(80,  220, 255)  -- glowing teal elf eyes
	local DARK  = Color3.fromRGB(55,  28, 90)

	-- HEAD (slightly taller = elf look)
	Sph(parent,"Head",       Vector3.new(1.55,1.68,1.55), SKIN, CFrame.new(0,7.12,0))
	-- Glowing eyes
	P  (parent,"EyeL",       Vector3.new(0.24,0.16,0.1),  EYES, CFrame.new(-0.3,7.24,-0.76),Enum.Material.Neon)
	P  (parent,"EyeR",       Vector3.new(0.24,0.16,0.1),  EYES, CFrame.new( 0.3,7.24,-0.76),Enum.Material.Neon)

	-- POINTED ELF EARS (Wedge angled outward + upward)
	Wdg(parent,"EarL",       Vector3.new(0.2,0.78,0.38), SKIN, CFrame.new(-0.88,7.12,0)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(22)))
	Wdg(parent,"EarR",       Vector3.new(0.2,0.78,0.38), SKIN, CFrame.new( 0.88,7.12,0)*CFrame.Angles(math.rad(0),math.rad(0),math.rad(-22)))
	P  (parent,"EarInnerL",  Vector3.new(0.05,0.45,0.22),SKIN2,CFrame.new(-0.91,7.1,0))
	P  (parent,"EarInnerR",  Vector3.new(0.05,0.45,0.22),SKIN2,CFrame.new( 0.91,7.1,0))

	-- HAIR (long blonde, multiple flowing layers)
	P  (parent,"HairTop",    Vector3.new(1.45,0.42,1.48), HAIR, CFrame.new(0,7.82,-0.04))
	P  (parent,"HairFringe", Vector3.new(1.2,0.32,0.18),  HAIR, CFrame.new(0,7.6,-0.74))
	P  (parent,"HairBack1",  Vector3.new(1.32,1.65,0.32), HAIR, CFrame.new(0,7.05,0.7))
	P  (parent,"HairBack2",  Vector3.new(1.15,1.75,0.28), HAIR, CFrame.new(0,5.95,0.64)*CFrame.Angles(math.rad(6),0,0))
	P  (parent,"HairBack3",  Vector3.new(0.95,1.45,0.25), HAIR, CFrame.new(0,4.88,0.7)*CFrame.Angles(math.rad(12),0,0))
	P  (parent,"HairSideL",  Vector3.new(0.26,1.95,0.68), HAIR, CFrame.new(-0.72,6.55,0.14))
	P  (parent,"HairSideR",  Vector3.new(0.26,1.95,0.68), HAIR, CFrame.new( 0.72,6.55,0.14))

	-- NECK (slim elf)
	Cyl(parent,"Neck",       Vector3.new(0.4,0.65,0.4),   SKIN, CFrame.new(0,6.22,0))

	-- COLLAR / necklace gem
	P  (parent,"Collar",     Vector3.new(1.28,0.2,0.88),  GOLD_,CFrame.new(0,5.88,0))
	Sph(parent,"Gem",        Vector3.new(0.28,0.28,0.28), EYES, CFrame.new(0,5.78,-0.5),Enum.Material.Neon)

	-- TORSO (slender)
	P  (parent,"Torso",      Vector3.new(1.48,2.2,0.84),  ROBE, CFrame.new(0,4.78,0))
	P  (parent,"Bodice",     Vector3.new(1.25,1.35,0.26), ROBE2,CFrame.new(0,4.98,-0.55))
	P  (parent,"BodiceRim",  Vector3.new(1.15,0.16,0.18), GOLD_,CFrame.new(0,4.28,-0.54))

	-- SHOULDERS (narrow, gem accent)
	Sph(parent,"ShouldL",    Vector3.new(0.68,0.52,0.68), ROBE2,CFrame.new(-1.0,5.72,0))
	Sph(parent,"ShouldR",    Vector3.new(0.68,0.52,0.68), ROBE2,CFrame.new( 1.0,5.72,0))
	Sph(parent,"SGemL",      Vector3.new(0.2,0.2,0.2),    EYES, CFrame.new(-1.02,5.72,-0.34),Enum.Material.Neon)
	Sph(parent,"SGemR",      Vector3.new(0.2,0.2,0.2),    EYES, CFrame.new( 1.02,5.72,-0.34),Enum.Material.Neon)

	-- UPPER ARMS (bare skin)
	Cyl(parent,"UArmL",      Vector3.new(0.44,1.32,0.44), SKIN, CFrame.new(-1.18,4.78,0))
	Cyl(parent,"UArmR",      Vector3.new(0.44,1.32,0.44), SKIN, CFrame.new( 1.18,4.78,0))

	-- FOREARMS (opera gloves, dark purple)
	Cyl(parent,"FArmL",      Vector3.new(0.4,1.28,0.4),   ROBE2,CFrame.new(-1.18,3.38,0))
	Cyl(parent,"FArmR",      Vector3.new(0.4,1.28,0.4),   ROBE2,CFrame.new( 1.18,3.38,0))
	P  (parent,"GloveTrimL", Vector3.new(0.45,0.16,0.45), GOLD_,CFrame.new(-1.18,4.08,0))
	P  (parent,"GloveTrimR", Vector3.new(0.45,0.16,0.45), GOLD_,CFrame.new( 1.18,4.08,0))

	-- HANDS
	Sph(parent,"HandL",      Vector3.new(0.4,0.4,0.4),    SKIN, CFrame.new(-1.18,2.65,0))
	Sph(parent,"HandR",      Vector3.new(0.4,0.4,0.4),    SKIN, CFrame.new( 1.18,2.65,0))

	-- WAIST SASH
	P  (parent,"Sash",       Vector3.new(1.58,0.32,0.86), GOLD_,CFrame.new(0,3.72,0))

	-- ROBE SKIRT (layered, progressively wider — no legs visible)
	P  (parent,"SkirtTop",   Vector3.new(1.62,1.38,0.92), ROBE, CFrame.new(0,3.12,0))
	P  (parent,"SkirtMid",   Vector3.new(1.95,1.28,1.08), ROBE2,CFrame.new(0,2.12,0.04))
	P  (parent,"SkirtBot",   Vector3.new(2.28,0.98,1.28), ROBE, CFrame.new(0,1.12,0.08))
	P  (parent,"SkirtHem",   Vector3.new(2.42,0.2,1.36),  GOLD_,CFrame.new(0,0.62,0.1))
	-- Front center split detail
	P  (parent,"FrontSplit", Vector3.new(0.16,3.52,0.14), GOLD_,CFrame.new(0,2.58,-0.48))

	-- SLIPPERS
	P  (parent,"SlipL",      Vector3.new(0.48,0.34,1.08), DARK, CFrame.new(-0.38,0.2,0.2))
	P  (parent,"SlipR",      Vector3.new(0.48,0.34,1.08), DARK, CFrame.new( 0.38,0.2,0.2))
end

local function buildCharModel(raceId, parent)
	if     raceId == "CYBORG" then buildAccretia(parent)
	elseif raceId == "MYSTIC" then buildCora(parent)
	else                           buildBellato(parent)
	end
end

-- ============================================================
-- UI helpers
-- ============================================================
local function F(parent, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3       = props.color or Color3.new(0,0,0)
	f.BackgroundTransparency = props.tr    or 0
	f.BorderSizePixel = 0
	f.AnchorPoint     = props.anchor or Vector2.new(0,0)
	f.Position        = props.pos    or UDim2.new(0,0,0,0)
	f.Size            = props.size   or UDim2.new(1,0,1,0)
	f.ZIndex          = props.z      or 1
	f.Name            = props.name   or "Frame"
	f.ClipsDescendants = props.clip  or false
	f.Parent          = parent
	return f
end
local function L(parent, props)
	local l = Instance.new("TextLabel")
	l.Text      = props.text  or ""
	l.TextSize  = props.tsize or 14
	l.Font      = props.bold  and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3 = props.color or TEXT_MAIN
	l.BackgroundTransparency = 1
	l.AnchorPoint  = props.anchor or Vector2.new(0,0)
	l.Position     = props.pos    or UDim2.new(0,0,0,0)
	l.Size         = props.size   or UDim2.new(1,0,0,20)
	l.TextXAlignment = props.ax   or Enum.TextXAlignment.Center
	l.TextWrapped  = true
	l.ZIndex       = props.z      or 2
	l.Name         = props.name   or "Label"
	l.Parent       = parent
	return l
end
local function B(parent, props)
	local b = Instance.new("TextButton")
	b.Text      = props.text  or ""
	b.TextSize  = props.tsize or 14
	b.Font      = props.bold ~= false and Enum.Font.GothamBold or Enum.Font.Gotham
	b.TextColor3 = props.color or TEXT_MAIN
	b.BackgroundColor3    = props.bg  or PANEL_COLOR
	b.BackgroundTransparency = props.tr or 0
	b.BorderSizePixel = 0
	b.AnchorPoint = props.anchor or Vector2.new(0,0)
	b.Position    = props.pos    or UDim2.new(0,0,0,0)
	b.Size        = props.size   or UDim2.new(1,0,0,30)
	b.ZIndex      = props.z      or 3
	b.AutoButtonColor = false
	b.Name        = props.name   or "Btn"
	b.Parent      = parent
	return b
end
local function corner(p,r) local c=Instance.new("UICorner");c.CornerRadius=UDim.new(0,r or 4);c.Parent=p end
local function stroke(p,c,t) local s=Instance.new("UIStroke");s.Color=c or TEAL;s.Thickness=t or 1;s.Parent=p;return s end
local function grad(p,c0,c1,r) local g=Instance.new("UIGradient");g.Color=ColorSequence.new(c0,c1);g.Rotation=r or 90;g.Parent=p end

local function addRFDecos(panel)
	for _,side in ipairs({{0,Vector2.new(0,.5)},{1,Vector2.new(1,.5)}}) do
		local xp,an=side[1],side[2]
		local bar=F(panel,{color=TEAL,anchor=an,pos=UDim2.new(xp,xp==0 and 4 or -7,.5,0),size=UDim2.new(0,3,.82,0),z=5})
		grad(bar,Color3.new(0,0,0),TEAL_BRIGHT,90)
		for _,da in ipairs({Vector2.new(.5,0),Vector2.new(.5,1)}) do
			local d=F(bar,{color=TEAL_BRIGHT,anchor=da,pos=UDim2.new(.5,0,da.Y,0),size=UDim2.new(0,7,0,7),z=6})
			corner(d,99)
		end
	end
	local t=F(panel,{color=TEAL,anchor=Vector2.new(.5,0),pos=UDim2.new(.5,0,0,10),size=UDim2.new(.7,0,0,1),z=5})
	grad(t,Color3.new(0,0,0),TEAL,0)
	local b=F(panel,{color=TEAL,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-10),size=UDim2.new(.7,0,0,1),z=5})
	grad(b,Color3.new(0,0,0),TEAL,0)
end

-- ============================================================
-- Show
-- ============================================================
function CharacterCreationUI.Show(onComplete)
	local sg = Instance.new("ScreenGui")
	sg.Name="CharacterCreationUI"; sg.ResetOnSpawn=false
	sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.IgnoreGuiInset=true; sg.Parent=playerGui

	local bg=F(sg,{color=BG_COLOR,anchor=Vector2.new(.5,.5),pos=UDim2.new(.5,0,.5,0),size=UDim2.new(1,0,1,0),z=10})
	bg.BackgroundTransparency=1
	local bgT=F(bg,{color=Color3.fromRGB(0,35,45),tr=0.88,size=UDim2.new(1,0,1,0),z=10})
	grad(bgT,Color3.fromRGB(0,25,35),Color3.fromRGB(0,5,12),135)

	-- Header
	local hdr=F(bg,{color=Color3.fromRGB(4,7,15),size=UDim2.new(1,0,0,58),z=11})
	local hl=F(hdr,{color=TEAL,anchor=Vector2.new(0,1),pos=UDim2.new(0,0,1,0),size=UDim2.new(1,0,0,2),z=12})
	grad(hl,Color3.new(0,0,0),TEAL_BRIGHT,0)
	L(hdr,{text="AETHERION",tsize=20,bold=true,color=TEAL_BRIGHT,anchor=Vector2.new(0,.5),pos=UDim2.new(0,20,.5,0),size=UDim2.new(0,180,1,0),ax=Enum.TextXAlignment.Left,z=12})
	local titleL=L(hdr,{text="CHARACTER CREATION",tsize=19,bold=true,anchor=Vector2.new(.5,.5),pos=UDim2.new(.5,0,.5,0),size=UDim2.new(.4,0,1,0),z=12})
	local stepL=L(hdr,{text="Step 1 — Select your race",tsize=12,color=TEXT_DIM,anchor=Vector2.new(1,.5),pos=UDim2.new(1,-20,.5,0),size=UDim2.new(0,220,1,0),ax=Enum.TextXAlignment.Right,z=12})

	local content=F(bg,{color=Color3.new(0,0,0),tr=1,pos=UDim2.new(0,0,0,58),size=UDim2.new(1,0,1,-58),z=11})

	local selectedRace=nil; local selectedClass=nil
	local raceCards={}; local classCards={}
	local classPanel=nil; local confirmBtn=nil; local statusL=nil

	-- Race panels
	local holder=F(content,{color=Color3.new(0,0,0),tr=1,anchor=Vector2.new(.5,.5),pos=UDim2.new(.5,0,.44,0),size=UDim2.new(.96,0,.82,0),z=11})
	local ll=Instance.new("UIListLayout");ll.FillDirection=Enum.FillDirection.Horizontal
	ll.HorizontalAlignment=Enum.HorizontalAlignment.Center;ll.VerticalAlignment=Enum.VerticalAlignment.Center
	ll.Padding=UDim.new(0.014,0);ll.Parent=holder

	local function refreshRace()
		for _,rc in ipairs(raceCards) do
			local sel=selectedRace and rc.Race.Id==selectedRace.Id
			rc.St.Color=sel and SEL_GLOW or TEAL_DIM; rc.St.Thickness=sel and 3 or 1
			rc.NBar.BackgroundColor3=sel and Color3.fromRGB(0,75,85) or Color3.fromRGB(8,14,22)
			rc.Btn.BackgroundColor3=sel and TEAL or PANEL_COLOR
			rc.Btn.TextColor3=sel and BG_COLOR or TEAL
			rc.Btn.Text=sel and "✔  SELECTED" or "SELECT RACE"
		end
	end

	for _,race in ipairs(RACES) do
		local panel=F(holder,{color=PANEL_COLOR,size=UDim2.new(.32,0,1,0),z=12,name=race.Id})
		corner(panel,4); local pSt=stroke(panel,TEAL_DIM,1); addRFDecos(panel)

		local nb=F(panel,{color=Color3.fromRGB(8,14,22),size=UDim2.new(1,0,0,42),z=13,name="NBar"})
		corner(nb,4)
		L(nb,{text=race.DisplayName,tsize=14,bold=true,anchor=Vector2.new(.5,0),pos=UDim2.new(.5,0,0,5),size=UDim2.new(.9,0,0,20),z=14})
		L(nb,{text=race.SubTitle,tsize=10,color=TEAL,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-7),size=UDim2.new(.9,0,0,14),z=14})

		-- ViewportFrame
		local vf=Instance.new("ViewportFrame")
		vf.BackgroundColor3=Color3.fromRGB(3,5,10); vf.BackgroundTransparency=0; vf.BorderSizePixel=0
		vf.AnchorPoint=Vector2.new(.5,0); vf.Position=UDim2.new(.5,0,0,44); vf.Size=UDim2.new(1,-14,.62,-52)
		vf.ZIndex=13; vf.LightColor=Color3.fromRGB(210,230,255); vf.LightDirection=Vector3.new(-0.7,-1,-0.5)
		vf.Ambient=Color3.fromRGB(55,75,110); vf.Parent=panel

		-- Bottom fade
		local fade=Instance.new("ImageLabel"); fade.BackgroundTransparency=1
		fade.AnchorPoint=Vector2.new(0,1); fade.Position=UDim2.new(0,0,1,0); fade.Size=UDim2.new(1,0,0,52)
		fade.ZIndex=14; fade.Image="rbxassetid://1316045217"; fade.ImageColor3=PANEL_COLOR
		fade.ScaleType=Enum.ScaleType.Stretch; fade.Parent=vf

		-- Camera: slight upward look angle (RF Classic style)
		local cam=Instance.new("Camera"); cam.Parent=vf; vf.CurrentCamera=cam
		cam.FieldOfView=58
		cam.CFrame=CFrame.new(Vector3.new(0,3.2,9.5),Vector3.new(0,5.2,0))

		-- Build model
		local wm=Instance.new("WorldModel"); wm.Parent=vf
		buildCharModel(race.Id, wm)

		-- Collect parts for rotation
		local parts={}
		for _,p in ipairs(wm:GetDescendants()) do
			if p:IsA("BasePart") then table.insert(parts,{p=p,cf=p.CFrame}) end
		end

		local angle=0
		local function rotate(d)
			angle=angle+d
			local R=CFrame.Angles(0,math.rad(angle),0)
			for _,pd in ipairs(parts) do pd.p.CFrame=R*pd.cf end
		end
		rotate(-18) -- initial 3/4 view

		-- Rotate bar
		local rb=F(panel,{color=Color3.fromRGB(4,7,13),pos=UDim2.new(0,7,.62,-2),size=UDim2.new(1,-14,0,30),z=13})
		local rl=B(rb,{text="◀  Rotate L",tsize=11,bold=false,color=TEAL,bg=Color3.fromRGB(0,25,30),anchor=Vector2.new(0,.5),pos=UDim2.new(0,0,.5,0),size=UDim2.new(.48,0,0,22),z=14})
		corner(rl,3)
		local rr=B(rb,{text="Rotate R  ▶",tsize=11,bold=false,color=TEAL,bg=Color3.fromRGB(0,25,30),anchor=Vector2.new(1,.5),pos=UDim2.new(1,0,.5,0),size=UDim2.new(.48,0,0,22),z=14})
		corner(rr,3)
		local rt=nil
		rl.MouseButton1Down:Connect(function() rotate(-14); rt=task.spawn(function() while true do task.wait(.04);rotate(-9) end end) end)
		rl.MouseButton1Up:Connect(function() if rt then task.cancel(rt);rt=nil end end)
		rr.MouseButton1Down:Connect(function() rotate(14); rt=task.spawn(function() while true do task.wait(.04);rotate(9) end end) end)
		rr.MouseButton1Up:Connect(function() if rt then task.cancel(rt);rt=nil end end)

		L(panel,{text=race.Desc,tsize=12,color=TEXT_DIM,anchor=Vector2.new(.5,0),pos=UDim2.new(.5,0,.62,34),size=UDim2.new(.88,0,0,58),z=13})

		local sb=B(panel,{text="SELECT RACE",tsize=12,color=TEAL,bg=PANEL_COLOR,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-11),size=UDim2.new(.8,0,0,32),z=13})
		corner(sb,4); stroke(sb,TEAL,1)
		local ov=B(panel,{text="",bg=Color3.new(0,0,0),tr=1,size=UDim2.new(1,0,1,0),z=15})

		local rc={Race=race,Panel=panel,St=pSt,NBar=nb,Btn=sb}
		table.insert(raceCards,rc)

		local function onSel()
			selectedRace=race; selectedClass=nil; refreshRace()
			stepL.Text="Step 2 — Select your class"; titleL.Text="CLASS SELECTION"
			if classPanel then classPanel.Visible=true end
			if confirmBtn then confirmBtn.Visible=false end
			for _,cc in ipairs(classCards) do
				local lk=cc.C.Locked[race.Id]
				cc.Lo.Visible=lk or false; cc.Btn.Active=not lk
				cc.Panel.BackgroundColor3=lk and Color3.fromRGB(6,6,8) or PANEL_COLOR
				cc.St.Color=lk and Color3.fromRGB(22,22,28) or TEAL_DIM; cc.St.Thickness=1
				cc.Btn.BackgroundColor3=lk and Color3.fromRGB(12,12,15) or PANEL_COLOR
				cc.Btn.TextColor3=lk and Color3.fromRGB(45,45,55) or TEAL
				cc.Btn.Text=lk and "LOCKED" or "SELECT"
			end
		end
		sb.MouseButton1Click:Connect(onSel); ov.MouseButton1Click:Connect(onSel)
	end

	-- Class panel
	classPanel=F(content,{color=Color3.fromRGB(4,7,14),anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,0),size=UDim2.new(.96,0,0,188),z=20,name="ClassPanel"})
	classPanel.Visible=false; stroke(classPanel,TEAL_DIM,1); corner(classPanel,4)
	F(classPanel,{color=TEAL,size=UDim2.new(1,0,0,2),z=21})
	L(classPanel,{text="SELECT CLASS",tsize=12,bold=true,color=TEAL,anchor=Vector2.new(0,0),pos=UDim2.new(0,14,0,8),size=UDim2.new(.3,0,0,18),ax=Enum.TextXAlignment.Left,z=21})

	local crow=F(classPanel,{color=Color3.new(0,0,0),tr=1,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-10),size=UDim2.new(1,-18,0,146),z=21})
	local cl=Instance.new("UIListLayout");cl.FillDirection=Enum.FillDirection.Horizontal
	cl.HorizontalAlignment=Enum.HorizontalAlignment.Center;cl.VerticalAlignment=Enum.VerticalAlignment.Center
	cl.Padding=UDim.new(.012,0);cl.Parent=crow

	for _,cls in ipairs(CLASSES) do
		local cp=F(crow,{color=PANEL_COLOR,size=UDim2.new(.24,0,1,0),z=22})
		corner(cp,4); local cSt=stroke(cp,TEAL_DIM,1)
		F(cp,{color=cls.RoleColor,tr=0.35,size=UDim2.new(1,0,0,4),z=23})
		L(cp,{text=cls.Name,tsize=13,bold=true,anchor=Vector2.new(.5,0),pos=UDim2.new(.5,0,0,9),size=UDim2.new(.9,0,0,20),z=23})
		local rt2=F(cp,{color=cls.RoleColor,tr=0.65,anchor=Vector2.new(.5,0),pos=UDim2.new(.5,0,0,33),size=UDim2.new(0,62,0,16),z=23});corner(rt2,3)
		L(rt2,{text=cls.Role,tsize=10,bold=true,size=UDim2.new(1,0,1,0),z=24})
		L(cp,{text=cls.Desc,tsize=11,color=TEXT_DIM,anchor=Vector2.new(.5,0),pos=UDim2.new(.5,0,0,55),size=UDim2.new(.88,0,0,52),z=23})
		local lo=F(cp,{color=Color3.fromRGB(4,4,6),tr=0.4,size=UDim2.new(1,0,1,0),z=25});corner(lo,4);lo.Visible=false
		L(lo,{text="NOT\nAVAILABLE",tsize=12,bold=true,color=Color3.fromRGB(180,50,50),size=UDim2.new(1,0,1,0),anchor=Vector2.new(.5,.5),pos=UDim2.new(.5,0,.5,0),z=26})
		local cb=B(cp,{text="SELECT",tsize=12,color=TEAL,bg=PANEL_COLOR,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-8),size=UDim2.new(.8,0,0,26),z=23});corner(cb,4);stroke(cb,TEAL_DIM,1)
		local cc={C=cls,Panel=cp,St=cSt,Lo=lo,Btn=cb};table.insert(classCards,cc)
		cb.MouseButton1Click:Connect(function()
			if not selectedRace or cls.Locked[selectedRace.Id] then return end
			selectedClass=cls
			for _,c2 in ipairs(classCards) do
				local sel2=c2.C.Id==cls.Id; local lk2=selectedRace and c2.C.Locked[selectedRace.Id]
				if not lk2 then
					c2.Panel.BackgroundColor3=sel2 and Color3.fromRGB(0,38,46) or PANEL_COLOR
					c2.St.Color=sel2 and SEL_GLOW or TEAL_DIM; c2.St.Thickness=sel2 and 2 or 1
					c2.Btn.BackgroundColor3=sel2 and TEAL or PANEL_COLOR
					c2.Btn.TextColor3=sel2 and BG_COLOR or TEAL
					c2.Btn.Text=sel2 and "✔ SELECTED" or "SELECT"
				end
			end
			stepL.Text="Step 3 — Confirm your selection"
			if confirmBtn then confirmBtn.Visible=true end
		end)
	end

	-- Confirm
	confirmBtn=B(content,{text="CREATE CHARACTER",tsize=15,color=BG_COLOR,bg=TEAL,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-14),size=UDim2.new(0,235,0,44),z=30})
	corner(confirmBtn,6); stroke(confirmBtn,TEAL_BRIGHT,2); confirmBtn.Visible=false
	statusL=L(content,{text="",tsize=12,color=GOLD,anchor=Vector2.new(.5,1),pos=UDim2.new(.5,0,1,-64),size=UDim2.new(.5,0,0,24),z=30})

	confirmBtn.MouseButton1Click:Connect(function()
		if not selectedRace or not selectedClass then return end
		confirmBtn.Active=false; confirmBtn.BackgroundColor3=TEAL_DIM; confirmBtn.Text="CREATING..."
		statusL.Text="Contacting server..."
		local remotes=ReplicatedStorage:WaitForChild("Remotes",10)
		local rem=remotes and remotes:FindFirstChild("SelectRaceAndClassRequest")
		if not rem then statusL.Text="Error: remote not found"; confirmBtn.Active=true; confirmBtn.BackgroundColor3=TEAL; confirmBtn.Text="CREATE CHARACTER"; return end
		local ok,res=pcall(function() return rem:InvokeServer(selectedRace.Id,selectedClass.Id) end)
		if not ok or not res then
			statusL.Text=not ok and ("Error: "..tostring(res)) or "Rejected. Try again."
			confirmBtn.Active=true; confirmBtn.BackgroundColor3=TEAL; confirmBtn.Text="CREATE CHARACTER"; return
		end
		statusL.Text="Character created! Entering world..."; confirmBtn.Text="ENTERING WORLD..."
		titleL.Text="WELCOME TO AETHERION"; stepL.Text=selectedRace.DisplayName.."  ·  "..selectedClass.Name
		TweenService:Create(bg,TweenInfo.new(1.4),{BackgroundTransparency=1}):Play()
		task.wait(1.5); sg:Destroy()
		if onComplete then onComplete(selectedRace.Id,selectedClass.Id) end
	end)

	TweenService:Create(bg,TweenInfo.new(0.9),{BackgroundTransparency=0}):Play()
	return sg
end

return CharacterCreationUI
