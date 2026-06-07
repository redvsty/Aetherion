-- CharacterCreationUI.lua
-- RF Classic-style character creation: dark sci-fi aesthetic, 3D character preview per race,
-- Rotate L/R buttons, teal/cyan accent panels.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CharacterCreationUI = {}

-- ============================================================
-- Constants
-- ============================================================

local BG_COLOR        = Color3.fromRGB(6, 8, 14)
local PANEL_COLOR     = Color3.fromRGB(10, 14, 22)
local TEAL            = Color3.fromRGB(0, 200, 210)
local TEAL_DIM        = Color3.fromRGB(0, 100, 110)
local TEAL_BRIGHT     = Color3.fromRGB(80, 240, 250)
local TEXT_MAIN       = Color3.fromRGB(220, 235, 250)
local TEXT_DIM        = Color3.fromRGB(120, 140, 170)
local SELECTED_GLOW   = Color3.fromRGB(0, 210, 230)
local GOLD            = Color3.fromRGB(255, 210, 60)

-- ============================================================
-- Race data
-- ============================================================

local RACES = {
	{
		Id          = "MECHA",
		DisplayName = "Bellato Federation",
		SubTitle    = "MECHA",
		Desc        = "Masters of MAU battle mechs.\nBalanced stats. Superior melee\nand mechanical warfare.",
		-- 3D model colors
		BodyColor   = Color3.fromRGB(60, 100, 180),
		ArmorColor  = Color3.fromRGB(40, 70, 140),
		AccentColor = Color3.fromRGB(100, 180, 255),
		SkinColor   = Color3.fromRGB(220, 185, 155),
	},
	{
		Id          = "CYBORG",
		DisplayName = "Accretia Empire",
		SubTitle    = "CYBORG",
		Desc        = "Pure war machines. No magic,\nno mercy. Highest armor\nand Launcher class.",
		BodyColor   = Color3.fromRGB(40, 45, 55),
		ArmorColor  = Color3.fromRGB(25, 28, 38),
		AccentColor = Color3.fromRGB(0, 160, 220),
		SkinColor   = Color3.fromRGB(60, 65, 80),
	},
	{
		Id          = "MYSTIC",
		DisplayName = "Cora Alliance",
		SubTitle    = "MYSTIC",
		Desc        = "Animus spirit summoners\nand Force wielders. Highest FP\nand magical ability.",
		BodyColor   = Color3.fromRGB(200, 160, 220),
		ArmorColor  = Color3.fromRGB(140, 100, 180),
		AccentColor = Color3.fromRGB(240, 200, 255),
		SkinColor   = Color3.fromRGB(255, 220, 200),
	},
}

-- ============================================================
-- Class data
-- ============================================================

local CLASSES = {
	{
		Id    = "Warrior",
		Name  = "WARRIOR",
		Desc  = "Front-line melee fighter.\nHighest HP. Swords and blades.",
		Role  = "MELEE",
		RoleColor = Color3.fromRGB(220, 70, 50),
		Locked = {},
	},
	{
		Id    = "Ranger",
		Name  = "RANGER",
		Desc  = "Ranged attacker and scout.\nHigh stamina. Rifles and bows.",
		Role  = "RANGED",
		RoleColor = Color3.fromRGB(50, 150, 220),
		Locked = {},
	},
	{
		Id    = "Spiritualist",
		Name  = "SPIRITUALIST",
		Desc  = "Force caster and healer.\nHighest FP. Not for Accretia.",
		Role  = "MAGIC",
		RoleColor = Color3.fromRGB(170, 80, 230),
		Locked = { CYBORG = true },
	},
	{
		Id    = "Specialist",
		Name  = "SPECIALIST",
		Desc  = "Engineer and support.\nCrafting, traps, Blood Ammo.",
		Role  = "SUPPORT",
		RoleColor = Color3.fromRGB(50, 190, 120),
		Locked = {},
	},
}

-- ============================================================
-- UI helpers
-- ============================================================

local function frame(parent, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3    = props.color or Color3.new(0,0,0)
	f.BackgroundTransparency = props.transparency or 0
	f.BorderSizePixel     = 0
	f.AnchorPoint         = props.anchor or Vector2.new(0,0)
	f.Position            = props.pos   or UDim2.new(0,0,0,0)
	f.Size                = props.size  or UDim2.new(1,0,1,0)
	f.ZIndex              = props.z     or 1
	f.Name                = props.name  or "Frame"
	f.ClipsDescendants    = props.clip  or false
	f.Parent              = parent
	return f
end

local function label(parent, props)
	local l = Instance.new("TextLabel")
	l.Text                = props.text  or ""
	l.TextSize            = props.size  or 14
	l.Font                = props.bold  and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3          = props.color or TEXT_MAIN
	l.BackgroundTransparency = 1
	l.AnchorPoint         = props.anchor or Vector2.new(0,0)
	l.Position            = props.pos   or UDim2.new(0,0,0,0)
	l.Size                = props.size2 or UDim2.new(1,0,0,20)
	l.TextXAlignment      = props.alignX or Enum.TextXAlignment.Center
	l.TextYAlignment      = props.alignY or Enum.TextYAlignment.Center
	l.TextWrapped         = true
	l.ZIndex              = props.z     or 2
	l.Name                = props.name  or "Label"
	l.Parent              = parent
	return l
end

local function btn(parent, props)
	local b = Instance.new("TextButton")
	b.Text                = props.text  or ""
	b.TextSize            = props.size  or 14
	b.Font                = props.bold ~= false and Enum.Font.GothamBold or Enum.Font.Gotham
	b.TextColor3          = props.color or TEXT_MAIN
	b.BackgroundColor3    = props.bg    or PANEL_COLOR
	b.BackgroundTransparency = props.transparency or 0
	b.BorderSizePixel     = 0
	b.AnchorPoint         = props.anchor or Vector2.new(0,0)
	b.Position            = props.pos   or UDim2.new(0,0,0,0)
	b.Size                = props.size2 or UDim2.new(1,0,0,30)
	b.ZIndex              = props.z     or 3
	b.AutoButtonColor     = false
	b.Name                = props.name  or "Button"
	b.Parent              = parent
	return b
end

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
end

local function stroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color     = color     or TEAL
	s.Thickness = thickness or 1
	s.Parent    = parent
	return s
end

local function gradient(parent, c0, c1, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c0, c1)
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

-- ============================================================
-- 3D character model builder for ViewportFrame
-- ============================================================

local function buildCharModel(race)
	local model = Instance.new("Model")
	model.Name = race.Id

	local bc   = race.BodyColor
	local ac   = race.ArmorColor
	local acc  = race.AccentColor
	local skin = race.SkinColor

	local isCyborg = (race.Id == "CYBORG")

	local function part(name, size, color, cframe, mat)
		local p = Instance.new("Part")
		p.Name     = name
		p.Size     = size
		p.Color    = color
		p.CFrame   = cframe
		p.Anchored = true
		p.CanCollide = false
		p.Material = mat or Enum.Material.SmoothPlastic
		p.Parent   = model
		return p
	end

	local function sp(name, size, color, cframe)
		local p = Instance.new("SpecialMesh")
		p.MeshType = Enum.MeshType.Sphere
		p.Scale = Vector3.one
		local par = part(name, size, color, cframe)
		p.Parent = par
		return par
	end

	if isCyborg then
		-- Accretia: blocky robot, wider shoulders, no visible head/neck
		-- Torso
		part("Torso",   Vector3.new(2.6,2.8,1.2), ac,  CFrame.new(0,3.4,0))
		-- Chest plate
		part("Chest",   Vector3.new(2.4,1.2,0.5), acc, CFrame.new(0,4.0,-0.55), Enum.Material.Neon)
		-- Shoulder pads (big)
		part("LShoulder",Vector3.new(1.0,0.8,1.0), ac, CFrame.new(-1.9,4.6,0))
		part("RShoulder",Vector3.new(1.0,0.8,1.0), ac, CFrame.new( 1.9,4.6,0))
		-- Head (helmet-like box)
		part("Head",    Vector3.new(1.8,1.8,1.8), ac,  CFrame.new(0,6.1,0))
		-- Visor (neon)
		part("Visor",   Vector3.new(1.4,0.4,0.2), acc, CFrame.new(0,6.2,-0.9), Enum.Material.Neon)
		-- Upper arms
		part("LUpperArm",Vector3.new(0.7,1.6,0.7), ac, CFrame.new(-2.05,3.8,0))
		part("RUpperArm",Vector3.new(0.7,1.6,0.7), ac, CFrame.new( 2.05,3.8,0))
		-- Lower arms
		part("LLowerArm",Vector3.new(0.65,1.4,0.65), bc, CFrame.new(-2.1,2.3,0))
		part("RLowerArm",Vector3.new(0.65,1.4,0.65), bc, CFrame.new( 2.1,2.3,0))
		-- Hands
		part("LHand",   Vector3.new(0.7,0.6,0.7), ac,  CFrame.new(-2.1,1.4,0))
		part("RHand",   Vector3.new(0.7,0.6,0.7), ac,  CFrame.new( 2.1,1.4,0))
		-- Hips/waist
		part("Waist",   Vector3.new(2.2,0.5,1.0), ac,  CFrame.new(0,2.0,0))
		-- Upper legs
		part("LULeg",   Vector3.new(0.9,1.8,0.9), ac,  CFrame.new(-0.7,0.9,0))
		part("RULeg",   Vector3.new(0.9,1.8,0.9), ac,  CFrame.new( 0.7,0.9,0))
		-- Lower legs
		part("LLLeg",   Vector3.new(0.85,1.8,0.85), bc, CFrame.new(-0.7,-1.1,0.1))
		part("RLLeg",   Vector3.new(0.85,1.8,0.85), bc, CFrame.new( 0.7,-1.1,0.1))
		-- Feet
		part("LFoot",   Vector3.new(0.9,0.4,1.3), ac,  CFrame.new(-0.7,-2.1,0.2))
		part("RFoot",   Vector3.new(0.9,0.4,1.3), ac,  CFrame.new( 0.7,-2.1,0.2))
		-- Core energy dot
		part("Core",    Vector3.new(0.5,0.5,0.1), acc, CFrame.new(0,3.6,-0.65), Enum.Material.Neon)
	else
		-- Humanoid: Bellato/Cora
		-- Head
		sp("Head",      Vector3.new(1.8,1.8,1.8), skin, CFrame.new(0,6.1,0))
		-- Hair (simple block)
		part("Hair",    Vector3.new(1.9,0.8,1.9), bc,   CFrame.new(0,6.8,0.1))
		-- Neck
		part("Neck",    Vector3.new(0.5,0.4,0.5), skin, CFrame.new(0,5.1,0))
		-- Torso
		part("Torso",   Vector3.new(2.0,2.4,1.0), bc,   CFrame.new(0,3.7,0))
		-- Chest armor
		part("ChestArmor",Vector3.new(1.8,1.0,0.3), ac, CFrame.new(0,4.1,-0.55))
		-- Belt
		part("Belt",    Vector3.new(2.1,0.3,1.0), ac,   CFrame.new(0,2.6,0))
		-- Shoulder pads
		part("LShoulder",Vector3.new(0.7,0.5,0.7), ac,  CFrame.new(-1.3,4.7,0))
		part("RShoulder",Vector3.new(0.7,0.5,0.7), ac,  CFrame.new( 1.3,4.7,0))
		-- Upper arms
		part("LUpperArm",Vector3.new(0.65,1.4,0.65), skin, CFrame.new(-1.5,3.7,0))
		part("RUpperArm",Vector3.new(0.65,1.4,0.65), skin, CFrame.new( 1.5,3.7,0))
		-- Lower arms
		part("LLowerArm",Vector3.new(0.6,1.3,0.6), bc,  CFrame.new(-1.55,2.3,0))
		part("RLowerArm",Vector3.new(0.6,1.3,0.6), bc,  CFrame.new( 1.55,2.3,0))
		-- Hands
		sp("LHand",     Vector3.new(0.6,0.6,0.6), skin, CFrame.new(-1.55,1.5,0))
		sp("RHand",     Vector3.new(0.6,0.6,0.6), skin, CFrame.new( 1.55,1.5,0))
		-- Hips
		part("Hips",    Vector3.new(2.0,0.4,1.0), bc,   CFrame.new(0,2.4,0))
		-- Upper legs
		part("LULeg",   Vector3.new(0.8,1.8,0.8), bc,   CFrame.new(-0.6,1.3,0))
		part("RULeg",   Vector3.new(0.8,1.8,0.8), bc,   CFrame.new( 0.6,1.3,0))
		-- Knee guards
		part("LKnee",   Vector3.new(0.85,0.4,0.85), ac, CFrame.new(-0.6,0.4,0))
		part("RKnee",   Vector3.new(0.85,0.4,0.85), ac, CFrame.new( 0.6,0.4,0))
		-- Lower legs
		part("LLLeg",   Vector3.new(0.75,1.6,0.75), bc, CFrame.new(-0.6,-0.8,0))
		part("RLLeg",   Vector3.new(0.75,1.6,0.75), bc, CFrame.new( 0.6,-0.8,0))
		-- Boots
		part("LBoot",   Vector3.new(0.85,0.5,1.2), ac,  CFrame.new(-0.6,-1.9,0.15))
		part("RBoot",   Vector3.new(0.85,0.5,1.2), ac,  CFrame.new( 0.6,-1.9,0.15))
	end

	return model
end

-- ============================================================
-- Teal decorative side bars (matching RF Classic UI)
-- ============================================================

local function addRFDecorations(panel)
	-- Left vertical bar
	local leftBar = frame(panel, {
		color = TEAL, transparency = 0,
		anchor = Vector2.new(0,0.5), pos = UDim2.new(0,4,0.5,0),
		size = UDim2.new(0,3,0.85,0), z = 5
	})
	gradient(leftBar,
		Color3.fromRGB(0,0,0), TEAL_BRIGHT, 90)

	-- Left bar accent dot top
	local lt = frame(leftBar, {
		color = TEAL_BRIGHT, anchor = Vector2.new(0.5,0),
		pos = UDim2.new(0.5,0,0,0), size = UDim2.new(0,7,0,7), z = 6
	})
	corner(lt, 99)

	-- Left bar accent dot bottom
	local lb = frame(leftBar, {
		color = TEAL_BRIGHT, anchor = Vector2.new(0.5,1),
		pos = UDim2.new(0.5,0,1,0), size = UDim2.new(0,7,0,7), z = 6
	})
	corner(lb, 99)

	-- Right vertical bar
	local rightBar = frame(panel, {
		color = TEAL, transparency = 0,
		anchor = Vector2.new(1,0.5), pos = UDim2.new(1,-7,0.5,0),
		size = UDim2.new(0,3,0.85,0), z = 5
	})
	gradient(rightBar, Color3.fromRGB(0,0,0), TEAL_BRIGHT, 90)

	local rt = frame(rightBar, {
		color = TEAL_BRIGHT, anchor = Vector2.new(0.5,0),
		pos = UDim2.new(0.5,0,0,0), size = UDim2.new(0,7,0,7), z = 6
	})
	corner(rt, 99)

	local rb = frame(rightBar, {
		color = TEAL_BRIGHT, anchor = Vector2.new(0.5,1),
		pos = UDim2.new(0.5,0,1,0), size = UDim2.new(0,7,0,7), z = 6
	})
	corner(rb, 99)

	-- Horizontal top accent line
	local topLine = frame(panel, {
		color = TEAL, anchor = Vector2.new(0.5,0),
		pos = UDim2.new(0.5,0,0,12), size = UDim2.new(0.7,0,0,1), z = 5
	})
	gradient(topLine, Color3.fromRGB(0,0,0), TEAL, 0)

	-- Horizontal bottom accent line
	local botLine = frame(panel, {
		color = TEAL, anchor = Vector2.new(0.5,1),
		pos = UDim2.new(0.5,0,1,-12), size = UDim2.new(0.7,0,0,1), z = 5
	})
	gradient(botLine, Color3.fromRGB(0,0,0), TEAL, 0)
end

-- ============================================================
-- Build UI
-- ============================================================

function CharacterCreationUI.Show(onComplete)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CharacterCreationUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	-- ── Background ──────────────────────────────────────────
	local bg = frame(screenGui, {
		color = BG_COLOR, anchor = Vector2.new(0.5,0.5),
		pos = UDim2.new(0.5,0,0.5,0), size = UDim2.new(1,0,1,0), z = 10
	})
	bg.BackgroundTransparency = 1

	-- Subtle diagonal gradient overlay
	local bgGrad = frame(bg, {
		color = Color3.fromRGB(0,40,50), transparency = 0.85,
		size = UDim2.new(1,0,1,0), z = 10
	})
	gradient(bgGrad, Color3.fromRGB(0,30,40), Color3.fromRGB(0,8,14), 135)

	-- ── Header bar ──────────────────────────────────────────
	local header = frame(bg, {
		color = Color3.fromRGB(4, 8, 16), transparency = 0,
		size = UDim2.new(1,0,0,64), z = 11
	})
	-- Bottom teal line
	local headerLine = frame(header, {
		color = TEAL, anchor = Vector2.new(0,1),
		pos = UDim2.new(0,0,1,0), size = UDim2.new(1,0,0,2), z = 12
	})
	gradient(headerLine, Color3.fromRGB(0,0,0), TEAL_BRIGHT, 0)

	-- Logo/title left side
	label(header, {
		text = "AETHERION", size = 22, bold = true, color = TEAL_BRIGHT,
		anchor = Vector2.new(0,0.5), pos = UDim2.new(0,24,0.5,0),
		size2 = UDim2.new(0,200,0,40), alignX = Enum.TextXAlignment.Left, z = 12
	})

	local titleLbl = label(header, {
		text = "CHARACTER CREATION", size = 20, bold = true, color = TEXT_MAIN,
		anchor = Vector2.new(0.5,0.5), pos = UDim2.new(0.5,0,0.5,0),
		size2 = UDim2.new(0.4,0,0,40), z = 12
	})

	local stepLbl = label(header, {
		text = "Step 1 — Select your race", size = 13, color = TEXT_DIM,
		anchor = Vector2.new(1,0.5), pos = UDim2.new(1,-24,0.5,0),
		size2 = UDim2.new(0,220,0,40), alignX = Enum.TextXAlignment.Right, z = 12
	})

	-- ── Content area ────────────────────────────────────────
	local content = frame(bg, {
		color = Color3.new(0,0,0), transparency = 1,
		anchor = Vector2.new(0,0), pos = UDim2.new(0,0,0,64),
		size = UDim2.new(1,0,1,-64), z = 11
	})

	-- ── State ───────────────────────────────────────────────
	local selectedRace  = nil
	local selectedClass = nil
	local raceCards     = {}
	local classPanelGui = nil
	local rotConnections = {}
	local modelAngles   = { 0, 0, 0 }

	-- ── Race panels row ─────────────────────────────────────
	local racePanelsHolder = frame(content, {
		color = Color3.new(0,0,0), transparency = 1,
		anchor = Vector2.new(0.5,0.5),
		pos = UDim2.new(0.5,0,0.45,0),
		size = UDim2.new(0.94,0,0.82,0), z = 11
	})

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.Padding = UDim.new(0.015, 0)
	listLayout.Parent = racePanelsHolder

	local function setRaceSelected(idx)
		for i, rc in ipairs(raceCards) do
			local sel = (i == idx)
			-- Border glow
			if rc.StrokeObj then
				rc.StrokeObj.Color = sel and SELECTED_GLOW or TEAL_DIM
				rc.StrokeObj.Thickness = sel and 3 or 1
			end
			-- Header bg
			rc.NameBar.BackgroundColor3 = sel
				and Color3.fromRGB(0, 80, 90)
				or  Color3.fromRGB(8, 16, 24)
			-- SELECT button
			rc.SelectBtn.BackgroundColor3 = sel and TEAL or PANEL_COLOR
			rc.SelectBtn.TextColor3 = sel and BG_COLOR or TEAL
			rc.SelectBtn.Text = sel and "✔  SELECTED" or "SELECT RACE"
		end
	end

	for i, race in ipairs(RACES) do
		-- Outer panel
		local panel = frame(racePanelsHolder, {
			color = PANEL_COLOR, transparency = 0,
			size = UDim2.new(0.318, 0, 1, 0), z = 12, name = race.Id .. "Panel"
		})
		local panelStroke = stroke(panel, TEAL_DIM, 1)
		corner(panel, 4)
		addRFDecorations(panel)

		-- Name bar (top)
		local nameBar = frame(panel, {
			color = Color3.fromRGB(8,16,24), transparency = 0,
			size = UDim2.new(1,0,0,44), z = 13, name = "NameBar"
		})
		corner(nameBar, 4)
		label(nameBar, {
			text = race.DisplayName, size = 15, bold = true, color = TEXT_MAIN,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0,4),
			size2 = UDim2.new(0.9,0,0,22), z = 14
		})
		local subLbl = label(nameBar, {
			text = race.SubTitle, size = 11, color = TEAL,
			anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-6),
			size2 = UDim2.new(0.9,0,0,16), z = 14
		})

		-- ViewportFrame for 3D character
		local vf = Instance.new("ViewportFrame")
		vf.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
		vf.BackgroundTransparency = 0
		vf.BorderSizePixel = 0
		vf.AnchorPoint = Vector2.new(0.5, 0)
		vf.Position = UDim2.new(0.5, 0, 0, 46)
		vf.Size = UDim2.new(1, -16, 0.62, -50)
		vf.ZIndex = 13
		vf.LightColor = Color3.fromRGB(180, 220, 255)
		vf.LightDirection = Vector3.new(-1, -1, -1)
		vf.Ambient = Color3.fromRGB(60, 80, 110)
		vf.Parent = panel

		-- Vf bottom gradient to fade into panel
		local vfGrad = Instance.new("ImageLabel")
		vfGrad.BackgroundTransparency = 1
		vfGrad.AnchorPoint = Vector2.new(0,1)
		vfGrad.Position = UDim2.new(0,0,1,0)
		vfGrad.Size = UDim2.new(1,0,0,40)
		vfGrad.ZIndex = 14
		vfGrad.Image = "rbxassetid://1316045217"
		vfGrad.ImageColor3 = PANEL_COLOR
		vfGrad.ScaleType = Enum.ScaleType.Stretch
		vfGrad.Parent = vf

		-- Camera
		local cam = Instance.new("Camera")
		cam.Parent = vf
		vf.CurrentCamera = cam
		cam.CFrame = CFrame.new(Vector3.new(0, 3.5, 9), Vector3.new(0, 3.5, 0))

		-- WorldModel + character
		local wm = Instance.new("WorldModel")
		wm.Parent = vf
		local charModel = buildCharModel(race)
		charModel.Parent = wm

		-- Scan all parts for rotation pivot
		local allParts = {}
		for _, p in ipairs(charModel:GetDescendants()) do
			if p:IsA("BasePart") then
				table.insert(allParts, { part = p, offset = p.CFrame })
			end
		end

		-- Rotation logic
		local angle = 0

		local function rotateModel(delta)
			angle = angle + delta
			local rot = CFrame.Angles(0, math.rad(angle), 0)
			for _, pd in ipairs(allParts) do
				pd.part.CFrame = rot * pd.offset
			end
		end

		-- Rotate L / R buttons bar
		local rotBar = frame(panel, {
			color = Color3.fromRGB(4, 8, 14), transparency = 0,
			anchor = Vector2.new(0.5, 0), pos = UDim2.new(0.5, 0, 0.62, -2),
			size = UDim2.new(1, 0, 0, 32), z = 13
		})

		local rotL = btn(rotBar, {
			text = "◀  Rotate L", size = 12, bold = false,
			color = TEAL, bg = Color3.fromRGB(0,30,35), transparency = 0,
			anchor = Vector2.new(0,0.5), pos = UDim2.new(0,8,0.5,0),
			size2 = UDim2.new(0.44,0,0,24), z = 14, name = "RotL"
		})
		corner(rotL, 4)

		local rotR = btn(rotBar, {
			text = "Rotate R  ▶", size = 12, bold = false,
			color = TEAL, bg = Color3.fromRGB(0,30,35), transparency = 0,
			anchor = Vector2.new(1,0.5), pos = UDim2.new(1,-8,0.5,0),
			size2 = UDim2.new(0.44,0,0,24), z = 14, name = "RotR"
		})
		corner(rotR, 4)

		local rotInterval = nil
		rotL.MouseButton1Down:Connect(function()
			rotateModel(-12)
			rotInterval = task.spawn(function()
				while true do task.wait(0.05) rotateModel(-8) end
			end)
		end)
		rotL.MouseButton1Up:Connect(function()
			if rotInterval then task.cancel(rotInterval) rotInterval = nil end
		end)
		rotR.MouseButton1Down:Connect(function()
			rotateModel(12)
			rotInterval = task.spawn(function()
				while true do task.wait(0.05) rotateModel(8) end
			end)
		end)
		rotR.MouseButton1Up:Connect(function()
			if rotInterval then task.cancel(rotInterval) rotInterval = nil end
		end)

		-- Description
		label(panel, {
			text = race.Desc, size = 13, color = TEXT_DIM,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0.62,34),
			size2 = UDim2.new(0.9,0,0,58), z = 13, alignX = Enum.TextXAlignment.Center
		})

		-- Select race button
		local selBtn = btn(panel, {
			text = "SELECT RACE", size = 13,
			color = TEAL, bg = PANEL_COLOR, transparency = 0,
			anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-12),
			size2 = UDim2.new(0.82,0,0,34), z = 13, name = "SelectBtn"
		})
		corner(selBtn, 4)
		stroke(selBtn, TEAL, 1)

		local rc = {
			Race = race, Panel = panel, StrokeObj = panelStroke,
			NameBar = nameBar, SelectBtn = selBtn
		}
		raceCards[i] = rc

		-- Click anywhere on panel selects race
		local clickOverlay = btn(panel, {
			text = "", bg = Color3.new(0,0,0), transparency = 1,
			size = UDim2.new(1,0,1,0), z = 15, name = "ClickOverlay"
		})

		local function onRaceSelect()
			selectedRace = race
			selectedClass = nil
			setRaceSelected(i)
			stepLbl.Text = "Step 2 — Select your class"
			titleLbl.Text = "CLASS SELECTION"

			-- Show class panel
			if classPanelGui then
				classPanelGui.Visible = true
			end
		end

		selBtn.MouseButton1Click:Connect(onRaceSelect)
		clickOverlay.MouseButton1Click:Connect(onRaceSelect)
	end

	-- ── Class selection overlay ──────────────────────────────
	classPanelGui = frame(content, {
		color = Color3.fromRGB(4, 8, 14), transparency = 0,
		anchor = Vector2.new(0.5, 1), pos = UDim2.new(0.5, 0, 1, 0),
		size = UDim2.new(0.94, 0, 0, 190), z = 20, name = "ClassPanel"
	})
	classPanelGui.Visible = false
	stroke(classPanelGui, TEAL_DIM, 1)
	corner(classPanelGui, 4)

	-- Top teal accent line
	frame(classPanelGui, {
		color = TEAL, anchor = Vector2.new(0,0),
		pos = UDim2.new(0,0,0,0), size = UDim2.new(1,0,0,2), z = 21
	})

	label(classPanelGui, {
		text = "SELECT CLASS", size = 13, bold = true, color = TEAL,
		anchor = Vector2.new(0,0), pos = UDim2.new(0,16,0,8),
		size2 = UDim2.new(0.3,0,0,20), alignX = Enum.TextXAlignment.Left, z = 21
	})

	-- 4 class cards in a row
	local classRow = frame(classPanelGui, {
		color = Color3.new(0,0,0), transparency = 1,
		anchor = Vector2.new(0.5, 1), pos = UDim2.new(0.5,0,1,-10),
		size = UDim2.new(1,-20,0,148), z = 21
	})

	local classLayout = Instance.new("UIListLayout")
	classLayout.FillDirection = Enum.FillDirection.Horizontal
	classLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	classLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	classLayout.Padding = UDim.new(0.012, 0)
	classLayout.Parent = classRow

	local classCards = {}

	local function updateClassCards()
		for _, cc in ipairs(classCards) do
			local isSelected = selectedClass and cc.Class.Id == selectedClass.Id
			local isLocked   = selectedRace and cc.Class.Locked[selectedRace.Id]

			cc.Panel.BackgroundColor3 = isLocked and Color3.fromRGB(6,6,8)
				or isSelected and Color3.fromRGB(0,40,48)
				or PANEL_COLOR

			if cc.StrokeObj then
				cc.StrokeObj.Color = isLocked and Color3.fromRGB(30,30,35)
					or isSelected and SELECTED_GLOW
					or TEAL_DIM
				cc.StrokeObj.Thickness = isSelected and 2 or 1
			end

			cc.LockOverlay.Visible = isLocked or false
			cc.SelectBtn.Active  = not isLocked
			cc.SelectBtn.BackgroundColor3 = isLocked and Color3.fromRGB(15,15,18)
				or isSelected and TEAL
				or PANEL_COLOR
			cc.SelectBtn.TextColor3 = isLocked and Color3.fromRGB(60,60,70)
				or isSelected and BG_COLOR
				or TEAL
			cc.SelectBtn.Text = isLocked and "LOCKED"
				or isSelected and "✔ SELECTED"
				or "SELECT"
		end
	end

	for _, cls in ipairs(CLASSES) do
		local cp = frame(classRow, {
			color = PANEL_COLOR, transparency = 0,
			size = UDim2.new(0.24,0,1,0), z = 22, name = cls.Id .. "Card"
		})
		corner(cp, 4)
		local cStroke = stroke(cp, TEAL_DIM, 1)

		-- Role color bar (top)
		local roleBar = frame(cp, {
			color = cls.RoleColor, transparency = 0.3,
			size = UDim2.new(1,0,0,4), z = 23
		})

		label(cp, {
			text = cls.Name, size = 14, bold = true, color = TEXT_MAIN,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0,10),
			size2 = UDim2.new(0.9,0,0,20), z = 23
		})

		-- Role tag
		local roleTag = frame(cp, {
			color = cls.RoleColor, transparency = 0.7,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0,34),
			size = UDim2.new(0,64,0,16), z = 23
		})
		corner(roleTag, 3)
		label(roleTag, {
			text = cls.Role, size = 10, bold = true, color = Color3.new(1,1,1),
			size2 = UDim2.new(1,0,1,0), z = 24
		})

		label(cp, {
			text = cls.Desc, size = 11, color = TEXT_DIM,
			anchor = Vector2.new(0.5,0), pos = UDim2.new(0.5,0,0,56),
			size2 = UDim2.new(0.9,0,0,52), z = 23
		})

		-- Locked overlay
		local lockOverlay = frame(cp, {
			color = Color3.fromRGB(5,5,8), transparency = 0.4,
			size = UDim2.new(1,0,1,0), z = 25
		})
		corner(lockOverlay, 4)
		label(lockOverlay, {
			text = "NOT\nAVAILABLE", size = 13, bold = true,
			color = Color3.fromRGB(180,50,50), size2 = UDim2.new(1,0,1,0),
			anchor = Vector2.new(0.5,0.5), pos = UDim2.new(0.5,0,0.5,0), z = 26
		})
		lockOverlay.Visible = false

		local cSelBtn = btn(cp, {
			text = "SELECT", size = 12,
			color = TEAL, bg = PANEL_COLOR, transparency = 0,
			anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-8),
			size2 = UDim2.new(0.82,0,0,26), z = 23
		})
		corner(cSelBtn, 4)
		stroke(cSelBtn, TEAL_DIM, 1)

		local cc = {
			Class = cls, Panel = cp, StrokeObj = cStroke,
			LockOverlay = lockOverlay, SelectBtn = cSelBtn
		}
		table.insert(classCards, cc)

		cSelBtn.MouseButton1Click:Connect(function()
			if not selectedRace then return end
			if cls.Locked[selectedRace.Id] then return end
			selectedClass = cls
			updateClassCards()
			stepLbl.Text = "Step 3 — Confirm your selection"
			if confirmBtn then confirmBtn.Visible = true end
		end)
	end

	-- ── Confirm button ───────────────────────────────────────
	local confirmBtn = btn(content, {
		text = "CREATE CHARACTER", size = 16,
		color = BG_COLOR, bg = TEAL, transparency = 0,
		anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-14),
		size2 = UDim2.new(0,240,0,46), z = 30, name = "ConfirmBtn"
	})
	corner(confirmBtn, 6)
	stroke(confirmBtn, TEAL_BRIGHT, 2)
	confirmBtn.Visible = false

	local statusLbl = label(content, {
		text = "", size = 13, color = GOLD,
		anchor = Vector2.new(0.5,1), pos = UDim2.new(0.5,0,1,-66),
		size2 = UDim2.new(0.5,0,0,26), z = 30
	})

	confirmBtn.MouseButton1Click:Connect(function()
		if not selectedRace or not selectedClass then return end

		confirmBtn.Active = false
		confirmBtn.BackgroundColor3 = TEAL_DIM
		confirmBtn.Text = "CREATING..."
		statusLbl.Text = "Contacting server..."

		local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
		if not remotes then
			statusLbl.Text = "Error: Remotes not found"
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = TEAL
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		local selectRemote = remotes:FindFirstChild("SelectRaceAndClassRequest")
		if not selectRemote then
			statusLbl.Text = "Error: Remote not found"
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = TEAL
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		local ok, result = pcall(function()
			return selectRemote:InvokeServer(selectedRace.Id, selectedClass.Id)
		end)

		if not ok then
			statusLbl.Text = "Error: " .. tostring(result)
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = TEAL
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		if not result then
			statusLbl.Text = "Selection rejected by server. Try again."
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = TEAL
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		-- Success
		statusLbl.Text = "Character created! Entering world..."
		confirmBtn.Text = "ENTERING WORLD..."
		titleLbl.Text = "WELCOME TO AETHERION"
		stepLbl.Text = selectedRace.DisplayName .. "  ·  " .. selectedClass.Name

		TweenService:Create(bg, TweenInfo.new(1.4), { BackgroundTransparency = 1 }):Play()
		task.wait(1.5)
		screenGui:Destroy()

		if onComplete then
			onComplete(selectedRace.Id, selectedClass.Id)
		end
	end)

	-- Fade in
	TweenService:Create(bg, TweenInfo.new(0.9), { BackgroundTransparency = 0 }):Play()

	return screenGui
end

return CharacterCreationUI
