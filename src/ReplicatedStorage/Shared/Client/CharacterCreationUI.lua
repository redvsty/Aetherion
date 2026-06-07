-- CharacterCreationUI.lua
-- Clean card-based race + class selection. No 3D models.
-- Step 1: 3 wide horizontal race cards with stat bars.
-- Step 2: 4 class cards slide in after race is picked.

local Players       = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService  = game:GetService("TweenService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CharacterCreationUI = {}

-- ============================================================
-- Palette
-- ============================================================
local BG      = Color3.fromRGB(6, 8, 14)
local PANEL   = Color3.fromRGB(12, 16, 26)
local PANEL2  = Color3.fromRGB(18, 23, 36)
local TEAL    = Color3.fromRGB(0, 200, 210)
local TEAL_DIM= Color3.fromRGB(0, 80, 90)
local TEAL_BR = Color3.fromRGB(80, 240, 250)
local TEXT    = Color3.fromRGB(220, 235, 250)
local TEXT_DIM= Color3.fromRGB(110, 130, 160)
local GOLD    = Color3.fromRGB(255, 210, 60)
local SEL_GL  = Color3.fromRGB(0, 220, 235)

-- ============================================================
-- Race data  (no stat bars — stats shown per class)
-- ============================================================
local RACES = {
	{
		Id       = "MECHA",
		Name     = "BELLATO FEDERATION",
		Tag      = "MECHA  ·  HUMAN",
		Desc     = "Masters of MAU battle mechs. Balanced warriors with access to powerful battle suits. Strong in both melee and ranged combat.",
		Color    = Color3.fromRGB(50, 110, 220),
		ColorDim = Color3.fromRGB(20, 45, 100),
		TagColor = Color3.fromRGB(100, 160, 255),
		Traits   = { "Can pilot MAU battle suits", "Holy force element", "All 4 classes available" },
	},
	{
		Id       = "CYBORG",
		Name     = "ACCRETIA EMPIRE",
		Tag      = "CYBORG  ·  ROBOT",
		Desc     = "Pure war machines engineered for maximum destruction. No magic capability, compensated by superior armor and the exclusive Launcher class.",
		Color    = Color3.fromRGB(200, 60, 50),
		ColorDim = Color3.fromRGB(90, 22, 18),
		TagColor = Color3.fromRGB(255, 110, 100),
		Traits   = { "No Spiritualist (no magic)", "Exclusive Launcher weapon", "Highest base armor" },
	},
	{
		Id       = "MYSTIC",
		Name     = "CORA ALLIANCE",
		Tag      = "MYSTIC  ·  ELF",
		Desc     = "Ancient elven summoners bonded with Animus spirits. Fragile in direct combat but unmatched in Force power and spirit manipulation.",
		Color    = Color3.fromRGB(110, 55, 190),
		ColorDim = Color3.fromRGB(45, 20, 85),
		TagColor = Color3.fromRGB(200, 150, 255),
		Traits   = { "Animus spirit summoning", "Exclusive Cora magic school", "All 4 classes available" },
	},
}

-- ============================================================
-- Class data  — stats dari ClassDefinitions RF Classic
-- Warrior     : BaseHP=200 HPLv=25 | BaseFP=80  FPLv=4  | BaseSP=200 SPLv=8
-- Ranger      : BaseHP=160 HPLv=18 | BaseFP=80  FPLv=4  | BaseSP=220 SPLv=10
-- Spiritualist: BaseHP=130 HPLv=12 | BaseFP=160 FPLv=20 | BaseSP=180 SPLv=5
-- Specialist  : BaseHP=150 HPLv=15 | BaseFP=100 FPLv=8  | BaseSP=220 SPLv=10
-- Pip scale 1-5 dihitung relatif terhadap range antar class:
--   HP: max=200 min=130 → Warrior=5,Ranger=3,Spiritualist=1,Specialist=2
--   FP: max=160 min=80  → Warrior=1,Ranger=1,Spiritualist=5,Specialist=2
--   SP: max=220 min=180 → Warrior=3,Ranger=5,Spiritualist=1,Specialist=5
-- ============================================================
local CLASSES = {
	{
		Id        = "Warrior",
		Name      = "WARRIOR",
		Role      = "MELEE",
		Desc      = "Front-line fighter with highest HP. Masters swords and blades. Advances to Guardian or Templar at Lv30.",
		RoleColor = Color3.fromRGB(220, 70, 50),
		Stats     = { HP=5, FP=1, SP=3 },
		Locked    = {},
	},
	{
		Id        = "Ranger",
		Name      = "RANGER",
		Role      = "RANGED",
		Desc      = "Agile ranged attacker with the highest stamina. Uses rifles, launchers, and bows. Advances to Scout at Lv30.",
		RoleColor = Color3.fromRGB(50, 150, 220),
		Stats     = { HP=3, FP=1, SP=5 },
		Locked    = {},
	},
	{
		Id        = "Spiritualist",
		Name      = "SPIRITUALIST",
		Role      = "MAGIC",
		Desc      = "Force caster with the highest FP. Fragile but powerful healer and nuker. Not available to Accretia.",
		RoleColor = Color3.fromRGB(170, 80, 230),
		Stats     = { HP=1, FP=5, SP=2 },
		Locked    = { CYBORG = true },
	},
	{
		Id        = "Specialist",
		Name      = "SPECIALIST",
		Role      = "SUPPORT",
		Desc      = "Engineer and support with high stamina. Crafting, traps, and Blood Ammo healing (Accretia only).",
		RoleColor = Color3.fromRGB(50, 190, 120),
		Stats     = { HP=2, FP=2, SP=5 },
		Locked    = {},
	},
}

-- ============================================================
-- UI micro-helpers
-- ============================================================
local function F(parent, bg, tr, anchor, pos, size, z, name)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = bg or Color3.new(0,0,0)
	f.BackgroundTransparency = tr or 0
	f.BorderSizePixel = 0
	f.AnchorPoint = anchor or Vector2.new(0,0)
	f.Position = pos or UDim2.new(0,0,0,0)
	f.Size = size or UDim2.new(1,0,1,0)
	f.ZIndex = z or 1
	f.Name = name or "Frame"
	f.Parent = parent
	return f
end
local function L(parent, txt, tsz, color, bold, anchor, pos, size, ax, z)
	local l = Instance.new("TextLabel")
	l.Text = txt; l.TextSize = tsz or 14
	l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	l.TextColor3 = color or TEXT
	l.BackgroundTransparency = 1; l.BorderSizePixel = 0
	l.AnchorPoint = anchor or Vector2.new(0,0)
	l.Position = pos or UDim2.new(0,0,0,0)
	l.Size = size or UDim2.new(1,0,0,20)
	l.TextXAlignment = ax or Enum.TextXAlignment.Left
	l.TextWrapped = true; l.ZIndex = z or 2
	l.Parent = parent; return l
end
local function B(parent, txt, tsz, tc, bg, tr, anchor, pos, size, z, name)
	local b = Instance.new("TextButton")
	b.Text = txt; b.TextSize = tsz or 14
	b.Font = Enum.Font.GothamBold; b.TextColor3 = tc or TEXT
	b.BackgroundColor3 = bg or PANEL; b.BackgroundTransparency = tr or 0
	b.BorderSizePixel = 0; b.AutoButtonColor = false
	b.AnchorPoint = anchor or Vector2.new(0,0)
	b.Position = pos or UDim2.new(0,0,0,0)
	b.Size = size or UDim2.new(1,0,0,30)
	b.ZIndex = z or 3; b.Name = name or "Btn"
	b.Parent = parent; return b
end
local function corner(p, r)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = p
end
local function stroke(p, c, t)
	local s = Instance.new("UIStroke"); s.Color = c or TEAL; s.Thickness = t or 1; s.Parent = p; return s
end
local function grad(p, c0, c1, rot)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(c0, c1); g.Rotation = rot or 0; g.Parent = p
end

-- Stat bar (HP / FP / SP) — 5 pips
local function statBar(parent, label, pips, color, posY)
	local row = F(parent, Color3.new(0,0,0), 1, Vector2.new(0,0),
		UDim2.new(0,0,0,posY), UDim2.new(1,0,0,18), 5)

	L(row, label, 11, TEXT_DIM, true,
		Vector2.new(0,0.5), UDim2.new(0,0,0.5,0), UDim2.new(0,28,1,0),
		Enum.TextXAlignment.Left, 6)

	for i = 1, 5 do
		local filled = i <= pips
		local pip = F(row,
			filled and color or Color3.fromRGB(20,25,35),
			0,
			Vector2.new(0,0.5),
			UDim2.new(0, 30 + (i-1)*18, 0.5, 0),
			UDim2.new(0,14,0,10),
			6)
		corner(pip, 2)
		if filled then
			-- inner glow
			local glow = F(pip, color, 0.5, Vector2.new(0.5,0.5),
				UDim2.new(0.5,0,0.5,0), UDim2.new(0.6,0,0.6,0), 7)
			corner(glow, 2)
		end
	end
end

-- ============================================================
-- Show
-- ============================================================
function CharacterCreationUI.Show(onComplete)
	local sg = Instance.new("ScreenGui")
	sg.Name = "CharacterCreationUI"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 200  -- tampil di atas semua HUD/belt/hotbar
	sg.Parent = playerGui

	-- Root background
	local bg = F(sg, BG, 0, Vector2.new(.5,.5), UDim2.new(.5,0,.5,0), UDim2.new(1,0,1,0), 10, "Root")
	bg.BackgroundTransparency = 1
	local bgTint = F(bg, Color3.fromRGB(0,30,42), 0.88, nil, nil, UDim2.new(1,0,1,0), 10)
	grad(bgTint, Color3.fromRGB(0,20,32), Color3.fromRGB(5,5,12), 130)

	-- ── Header ────────────────────────────────────────────────
	local hdr = F(bg, Color3.fromRGB(4,7,15), 0, nil, nil, UDim2.new(1,0,0,56), 11, "Header")
	local hline = F(hdr, TEAL, 0, Vector2.new(0,1), UDim2.new(0,0,1,0), UDim2.new(1,0,0,2), 12)
	grad(hline, Color3.new(0,0,0), TEAL_BR, 0)

	L(hdr,"AETHERION",20,TEAL_BR,true,
		Vector2.new(0,.5),UDim2.new(0,22,.5,0),UDim2.new(0,170,1,0),Enum.TextXAlignment.Left,12)

	local titleL = L(hdr,"CHARACTER CREATION",19,TEXT,true,
		Vector2.new(.5,.5),UDim2.new(.5,0,.5,0),UDim2.new(.4,0,1,0),Enum.TextXAlignment.Center,12)

	local stepL = L(hdr,"Step 1 — Choose your race",12,TEXT_DIM,false,
		Vector2.new(1,.5),UDim2.new(1,-22,.5,0),UDim2.new(0,220,1,0),Enum.TextXAlignment.Right,12)

	-- ── Content ───────────────────────────────────────────────
	local content = F(bg, Color3.new(0,0,0), 1, nil, UDim2.new(0,0,0,56), UDim2.new(1,0,1,-56), 11, "Content")

	-- ── State ─────────────────────────────────────────────────
	local selectedRace  = nil
	local selectedClass = nil
	local raceCards     = {}
	local classCards    = {}
	local classSection  = nil
	local confirmBtn    = nil
	local statusLbl     = nil

	-- ── Race card list ─────────────────────────────────────────
	-- Left column: race cards; right column: class selection
	local leftCol = F(content, Color3.new(0,0,0), 1, nil,
		UDim2.new(0,0,0,0), UDim2.new(.52,0,1,0), 11, "LeftCol")

	local raceList = Instance.new("UIListLayout")
	raceList.FillDirection = Enum.FillDirection.Vertical
	raceList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	raceList.VerticalAlignment = Enum.VerticalAlignment.Center
	raceList.Padding = UDim.new(0, 10)
	raceList.Parent = leftCol

	local listPad = Instance.new("UIPadding")
	listPad.PaddingTop    = UDim.new(0, 14)
	listPad.PaddingBottom = UDim.new(0, 14)
	listPad.PaddingLeft   = UDim.new(0, 20)
	listPad.PaddingRight  = UDim.new(0, 10)
	listPad.Parent = leftCol

	local function refreshRaceCards()
		for _, rc in ipairs(raceCards) do
			local sel = selectedRace and rc.Race.Id == selectedRace.Id
			local race = rc.Race

			-- Stroke glow
			rc.St.Color = sel and race.Color or TEAL_DIM
			rc.St.Thickness = sel and 2.5 or 1

			-- Left accent bar
			rc.AccentBar.BackgroundColor3 = sel and race.Color or Color3.fromRGB(30,35,48)

			-- Card bg
			rc.Card.BackgroundColor3 = sel and race.ColorDim or Color3.fromRGB(10,13,20)

			-- Select button
			rc.SelBtn.BackgroundColor3 = sel and race.Color or PANEL2
			rc.SelBtn.TextColor3       = sel and Color3.new(1,1,1) or race.TagColor
			rc.SelBtn.Text             = sel and "✔  SELECTED" or "SELECT"
		end
	end

	for _, race in ipairs(RACES) do
		-- Card container
		local card = F(leftCol, Color3.fromRGB(10,13,20), 0, nil,
			UDim2.new(0,0,0,0), UDim2.new(1,0,0,108), 12, race.Id.."Card")
		corner(card, 8)
		local st = stroke(card, TEAL_DIM, 1)

		-- Left color accent bar
		local accent = F(card, Color3.fromRGB(30,35,48), 0, nil,
			UDim2.new(0,0,0,0), UDim2.new(0,5,1,0), 13, "AccentBar")
		corner(accent, 4)

		-- Inner content (offset from accent bar)
		local inner = F(card, Color3.new(0,0,0), 1, nil,
			UDim2.new(0,16,0,12), UDim2.new(1,-20,1,-12), 13, "Inner")

		-- Race name
		L(inner, race.Name, 17, TEXT, true,
			nil, UDim2.new(0,0,0,0), UDim2.new(.73,0,0,22),
			Enum.TextXAlignment.Left, 14)

		-- Race tag badge
		local tagBg = F(inner, race.ColorDim, 0, nil,
			UDim2.new(.74,0,0,2), UDim2.new(.26,-4,0,18), 13)
		corner(tagBg, 4)
		L(tagBg, race.Tag, 10, race.TagColor, true,
			Vector2.new(.5,.5), UDim2.new(.5,0,.5,0), UDim2.new(1,-4,1,0),
			Enum.TextXAlignment.Center, 14)

		-- Thin separator
		local sep = F(inner, race.Color, 0.6, nil,
			UDim2.new(0,0,0,26), UDim2.new(1,0,0,1), 14)
		grad(sep, race.Color, Color3.fromRGB(0,0,0), 0)

		-- Traits list (no stat bars — stats are per class)
		for i, trait in ipairs(race.Traits) do
			L(inner, "· " .. trait, 11, TEXT_DIM, false,
				nil, UDim2.new(0,0,0,32+(i-1)*20), UDim2.new(.72,0,0,18),
				Enum.TextXAlignment.Left, 14)
		end

		-- SELECT button
		local selBtn = B(inner, "SELECT", 11, race.TagColor, PANEL2, 0,
			Vector2.new(1,1), UDim2.new(1,-84,1,0), UDim2.new(0,80,0,26), 14)
		corner(selBtn, 4)
		stroke(selBtn, race.Color, 1)

		-- Click overlay (whole card)
		local ov = B(card,"",12,TEXT,Color3.new(0,0,0),1,nil,nil,UDim2.new(1,0,1,0),15,"Overlay")

		local rc = { Race=race, Card=card, St=st, AccentBar=accent, SelBtn=selBtn }
		table.insert(raceCards, rc)

		local function onPick()
			selectedRace = race
			selectedClass = nil
			refreshRaceCards()
			stepL.Text = "Step 2 — Choose your class"
			titleL.Text = "CLASS SELECTION"
			-- Refresh class lock state
			for _, cc in ipairs(classCards) do
				local locked = cc.Cls.Locked[race.Id]
				cc.Locked = locked or false
				cc.Lo.Visible = locked or false
				cc.Card.BackgroundTransparency = locked and 0.55 or 0
				cc.SelBtn.BackgroundColor3 = locked and Color3.fromRGB(12,12,16) or PANEL2
				cc.SelBtn.TextColor3 = locked and Color3.fromRGB(50,50,60) or TEXT_DIM
				cc.SelBtn.Text = locked and "LOCKED" or "SELECT"
				cc.St.Color = locked and Color3.fromRGB(22,22,28) or TEAL_DIM
				cc.St.Thickness = 1
				cc.Card.BackgroundColor3 = locked and Color3.fromRGB(8,8,10) or PANEL
			end
			if classSection then
				classSection.Visible = true
				TweenService:Create(classSection, TweenInfo.new(.35), { Position = UDim2.new(.52,0,0,0) }):Play()
			end
			if confirmBtn then confirmBtn.Visible = false end
		end

		selBtn.MouseButton1Click:Connect(onPick)
		ov.MouseButton1Click:Connect(onPick)
	end

	-- ── Class section (right column) ─────────────────────────
	classSection = F(content, Color3.new(0,0,0), 1,
		nil, UDim2.new(1.1,0,0,0), UDim2.new(.48,0,1,0), 11, "ClassSection")
	classSection.Visible = false
	classSection.ClipsDescendants = false

	local classPad = Instance.new("UIPadding")
	classPad.PaddingTop   = UDim.new(0,14)
	classPad.PaddingBottom= UDim.new(0,60)
	classPad.PaddingRight = UDim.new(0,20)
	classPad.PaddingLeft  = UDim.new(0,10)
	classPad.Parent = classSection

	-- Class section header
	local csHdr = F(classSection, Color3.fromRGB(8,12,20), 0, nil,
		UDim2.new(0,0,0,0), UDim2.new(1,0,0,36), 12)
	corner(csHdr, 6)
	stroke(csHdr, TEAL_DIM, 1)
	L(csHdr,"SELECT CLASS",13,TEAL,true,
		Vector2.new(0,.5),UDim2.new(0,14,.5,0),UDim2.new(.5,0,1,0),Enum.TextXAlignment.Left,13)
	local raceTagL = L(csHdr,"",12,TEXT_DIM,false,
		Vector2.new(1,.5),UDim2.new(1,-12,.5,0),UDim2.new(.45,0,1,0),Enum.TextXAlignment.Right,13)

	-- Class list
	local classList = Instance.new("UIListLayout")
	classList.FillDirection = Enum.FillDirection.Vertical
	classList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	classList.VerticalAlignment = Enum.VerticalAlignment.Top
	classList.Padding = UDim.new(0,8)
	classList.SortOrder = Enum.SortOrder.LayoutOrder
	classList.Parent = classSection

	local function refreshClassCards()
		for _, cc in ipairs(classCards) do
			local sel = selectedClass and cc.Cls.Id == selectedClass.Id
			if not cc.Locked then
				cc.Card.BackgroundColor3 = sel and Color3.fromRGB(0,40,50) or PANEL
				cc.St.Color = sel and SEL_GL or TEAL_DIM
				cc.St.Thickness = sel and 2 or 1
				cc.SelBtn.BackgroundColor3 = sel and TEAL or PANEL2
				cc.SelBtn.TextColor3 = sel and BG or TEXT_DIM
				cc.SelBtn.Text = sel and "✔  SELECTED" or "SELECT"
			end
		end
	end

	for i, cls in ipairs(CLASSES) do
		local ccard = F(classSection, PANEL, 0, nil,
			UDim2.new(0,0,0,0), UDim2.new(1,0,0,74), 12, cls.Id.."Card")
		ccard.LayoutOrder = i
		corner(ccard, 6)
		local cSt = stroke(ccard, TEAL_DIM, 1)

		-- Role color bar (left)
		local roleBar = F(ccard, cls.RoleColor, 0, nil,
			UDim2.new(0,0,0,0), UDim2.new(0,4,1,0), 13)
		corner(roleBar, 4)

		-- Inner
		local cInner = F(ccard, Color3.new(0,0,0), 1, nil,
			UDim2.new(0,14,0,10), UDim2.new(1,-18,1,-10), 13)

		-- Class name + role badge
		L(cInner, cls.Name, 14, TEXT, true,
			nil, UDim2.new(0,0,0,0), UDim2.new(.55,0,0,20),
			Enum.TextXAlignment.Left, 14)

		local roleF = F(cInner, cls.RoleColor, 0.55, nil,
			UDim2.new(.56,0,0,2), UDim2.new(.25,0,0,17), 14)
		corner(roleF, 3)
		L(roleF, cls.Role, 10, Color3.new(1,1,1), true,
			Vector2.new(.5,.5), UDim2.new(.5,0,.5,0), UDim2.new(1,-4,1,0),
			Enum.TextXAlignment.Center, 15)

		-- Description (kiri, lebih sempit karena ada stat bars kanan)
		L(cInner, cls.Desc, 10, TEXT_DIM, false,
			nil, UDim2.new(0,0,0,24), UDim2.new(.52,0,1,-4),
			Enum.TextXAlignment.Left, 14)

		-- Stat bars kanan (HP/FP/SP dari ClassDefinitions RF Classic)
		local statFrame = F(cInner, Color3.new(0,0,0), 1, nil,
			UDim2.new(0.54,0,0,22), UDim2.new(0.46,0,1,-4), 14)
		statBar(statFrame, "HP", cls.Stats.HP, cls.RoleColor, 0)
		statBar(statFrame, "FP", cls.Stats.FP, cls.RoleColor, 18)
		statBar(statFrame, "SP", cls.Stats.SP, cls.RoleColor, 36)

		-- Select button
		local cSelBtn = B(cInner, "SELECT", 11, TEXT_DIM, PANEL2, 0,
			Vector2.new(1,1), UDim2.new(1,-72,1,0), UDim2.new(0,68,0,24), 14)
		corner(cSelBtn, 4)
		stroke(cSelBtn, TEAL_DIM, 1)

		-- Locked overlay
		local lo = F(ccard, Color3.fromRGB(4,4,6), 0.45, nil,
			nil, UDim2.new(1,0,1,0), 16)
		corner(lo, 6)
		lo.Visible = false
		L(lo, "NOT AVAILABLE FOR ACCRETIA", 11, Color3.fromRGB(200,60,60), true,
			Vector2.new(.5,.5), UDim2.new(.5,0,.5,0), UDim2.new(.9,0,1,0),
			Enum.TextXAlignment.Center, 17)

		local cc = { Cls=cls, Card=ccard, St=cSt, SelBtn=cSelBtn, Lo=lo, Locked=false }
		table.insert(classCards, cc)

		cSelBtn.MouseButton1Click:Connect(function()
			if cc.Locked then return end
			selectedClass = cls
			refreshClassCards()
			stepL.Text = "Step 3 — Confirm your selection"
			if confirmBtn then confirmBtn.Visible = true end
			if statusLbl then statusLbl.Text = "" end
		end)
	end

	-- Spacer so classList doesn't start from Y=0 (below header)
	local spacer = F(classSection, Color3.new(0,0,0), 1, nil,
		UDim2.new(0,0,0,0), UDim2.new(1,0,0,44), 11, "Spacer")
	spacer.LayoutOrder = 0

	-- ── Confirm button (bottom center) ────────────────────────
	confirmBtn = B(content, "CREATE CHARACTER", 15, BG, TEAL, 0,
		Vector2.new(.5,1), UDim2.new(.5,0,1,-14), UDim2.new(0,240,0,46), 30, "ConfirmBtn")
	corner(confirmBtn, 8)
	stroke(confirmBtn, TEAL_BR, 2)
	confirmBtn.Visible = false

	statusLbl = L(content, "", 12, GOLD, false,
		Vector2.new(.5,1), UDim2.new(.5,0,1,-66), UDim2.new(.5,0,0,24),
		Enum.TextXAlignment.Center, 30)

	-- Summary strip (shows selected race + class above confirm)
	local summaryL = L(content, "", 13, TEXT_DIM, false,
		Vector2.new(.5,1), UDim2.new(.5,0,1,-72), UDim2.new(.6,0,0,22),
		Enum.TextXAlignment.Center, 30)

	local function updateSummary()
		if selectedRace and selectedClass then
			summaryL.Text = selectedRace.Name .. "  ›  " .. selectedClass.Name
		else
			summaryL.Text = ""
		end
	end

	-- Wire class selection to update summary
	for _, cc in ipairs(classCards) do
		cc.SelBtn.MouseButton1Click:Connect(function()
			task.defer(updateSummary)
		end)
	end
	for _, rc in ipairs(raceCards) do
		rc.SelBtn.MouseButton1Click:Connect(function()
			task.defer(updateSummary)
		end)
		-- wire overlay too
		rc.Card:FindFirstChildWhichIsA("TextButton").MouseButton1Click:Connect(function()
			task.defer(updateSummary)
		end)
	end

	-- ── Confirm handler ───────────────────────────────────────
	confirmBtn.MouseButton1Click:Connect(function()
		if not selectedRace or not selectedClass then return end
		confirmBtn.Active = false
		confirmBtn.BackgroundColor3 = TEAL_DIM
		confirmBtn.Text = "CREATING..."
		statusLbl.Text = "Contacting server..."

		local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
		local rem = remotes and remotes:FindFirstChild("SelectRaceAndClassRequest")
		if not rem then
			statusLbl.Text = "Error: remote not found"
			confirmBtn.Active = true; confirmBtn.BackgroundColor3 = TEAL; confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		local ok, res = pcall(function() return rem:InvokeServer(selectedRace.Id, selectedClass.Id) end)
		if not ok or not res then
			statusLbl.Text = not ok and ("Error: " .. tostring(res)) or "Selection rejected. Try again."
			confirmBtn.Active = true; confirmBtn.BackgroundColor3 = TEAL; confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		statusLbl.Text = "Character created! Entering world..."
		confirmBtn.Text = "ENTERING WORLD..."
		titleL.Text = "WELCOME TO AETHERION"
		stepL.Text = selectedRace.Name .. "  ·  " .. selectedClass.Name

		TweenService:Create(bg, TweenInfo.new(1.3), { BackgroundTransparency = 1 }):Play()
		task.wait(1.4)
		sg:Destroy()
		if onComplete then onComplete(selectedRace.Id, selectedClass.Id) end
	end)

	-- Fade in
	TweenService:Create(bg, TweenInfo.new(0.8), { BackgroundTransparency = 0 }):Play()
	return sg
end

return CharacterCreationUI
