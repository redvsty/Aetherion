-- CharacterCreationUI.lua
-- Full-screen race + class selection screen for new players.
-- Shown by AetherionUILoader when FactionId == nil.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CharacterCreationUI = {}

-- ============================================================
-- Data
-- ============================================================

local RACES = {
	{
		Id = "MECHA",
		DisplayName = "Bellato Federation",
		SubTitle = "MECHA",
		Desc = "Masters of MAU battle mechs. Balanced stats with superior melee and mechanical warfare.",
		Color = Color3.fromRGB(60, 120, 220),
		AccentColor = Color3.fromRGB(100, 160, 255),
		TextColor = Color3.fromRGB(200, 225, 255),
	},
	{
		Id = "CYBORG",
		DisplayName = "Accretia Empire",
		SubTitle = "CYBORG",
		Desc = "Pure war machines. No magic, no mercy. Highest base armor and Launcher class.",
		Color = Color3.fromRGB(180, 50, 50),
		AccentColor = Color3.fromRGB(230, 80, 80),
		TextColor = Color3.fromRGB(255, 200, 200),
	},
	{
		Id = "MYSTIC",
		DisplayName = "Cora Alliance",
		SubTitle = "MYSTIC",
		Desc = "Animus spirit summoners and Force wielders. Highest FP and magical ability.",
		Color = Color3.fromRGB(60, 160, 90),
		AccentColor = Color3.fromRGB(80, 210, 120),
		TextColor = Color3.fromRGB(190, 255, 210),
	},
}

local CLASSES = {
	{
		Id = "Warrior",
		DisplayName = "Warrior",
		Desc = "Front-line melee fighter with highest HP. Uses swords and blades.",
		Role = "Melee",
		AvailableFor = { MECHA = true, CYBORG = true, MYSTIC = true },
	},
	{
		Id = "Ranger",
		DisplayName = "Ranger",
		Desc = "Ranged attacker and scout. Uses rifles, launchers, and bows.",
		Role = "Ranged",
		AvailableFor = { MECHA = true, CYBORG = true, MYSTIC = true },
	},
	{
		Id = "Spiritualist",
		DisplayName = "Spiritualist",
		Desc = "Force caster and healer. Not available to Accretia (no magic).",
		Role = "Magic",
		AvailableFor = { MECHA = true, CYBORG = false, MYSTIC = true },
	},
	{
		Id = "Specialist",
		DisplayName = "Specialist",
		Desc = "Engineer and support. Crafting, traps, and Blood Ammo healing.",
		Role = "Support",
		AvailableFor = { MECHA = true, CYBORG = true, MYSTIC = true },
	},
}

-- ============================================================
-- Helpers
-- ============================================================

local function makeLabel(parent, text, size, color, bold, anchorX, anchorY, posX, posY, sizeX, sizeY)
	local lbl = Instance.new("TextLabel")
	lbl.Text = text
	lbl.TextSize = size
	lbl.TextColor3 = color or Color3.new(1, 1, 1)
	lbl.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.AnchorPoint = Vector2.new(anchorX or 0, anchorY or 0)
	lbl.Position = UDim2.new(posX or 0, 0, posY or 0, 0)
	lbl.Size = UDim2.new(sizeX or 1, 0, sizeY or 0, size + 6)
	lbl.TextWrapped = true
	lbl.Parent = parent
	return lbl
end

local function makeFrame(parent, color, transparency, anchorX, anchorY, posX, posXO, posY, posYO, sizeX, sizeXO, sizeY, sizeYO)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = color or Color3.new(0, 0, 0)
	f.BackgroundTransparency = transparency or 0
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(anchorX or 0, anchorY or 0)
	f.Position = UDim2.new(posX or 0, posXO or 0, posY or 0, posYO or 0)
	f.Size = UDim2.new(sizeX or 1, sizeXO or 0, sizeY or 0, sizeYO or 0)
	f.Parent = parent
	return f
end

local function addCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
end

local function addStroke(parent, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(1, 1, 1)
	s.Thickness = thickness or 2
	s.Parent = parent
end

-- ============================================================
-- Build UI
-- ============================================================

function CharacterCreationUI.Show(onComplete)
	-- onComplete(factionId, classId) called after successful creation

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CharacterCreationUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	-- Dark overlay background
	local bg = makeFrame(screenGui, Color3.fromRGB(8, 10, 16), 0, 0.5, 0.5, 0.5, 0, 0.5, 0, 1, 0, 1, 0)
	bg.ZIndex = 10

	-- Gradient overlay
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 10, 20)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 35)),
	})
	grad.Rotation = 135
	grad.Parent = bg

	-- Title bar
	local titleBar = makeFrame(bg, Color3.fromRGB(15, 20, 35), 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 70)
	titleBar.ZIndex = 11

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Text = "CHOOSE YOUR RACE"
	titleLabel.TextSize = 26
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.BackgroundTransparency = 1
	titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
	titleLabel.ZIndex = 12
	titleLabel.Parent = titleBar

	local subTitle = Instance.new("TextLabel")
	subTitle.Text = "AETHERION — Character Creation"
	subTitle.TextSize = 14
	subTitle.Font = Enum.Font.Gotham
	subTitle.TextColor3 = Color3.fromRGB(140, 160, 190)
	subTitle.BackgroundTransparency = 1
	subTitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subTitle.Position = UDim2.new(0.5, 0, 0.5, 26)
	subTitle.Size = UDim2.new(0.6, 0, 0, 20)
	subTitle.ZIndex = 12
	subTitle.Parent = titleBar

	-- Main content area
	local content = makeFrame(bg, Color3.new(0, 0, 0), 1, 0, 0, 0, 0, 0, 70, 1, 0, 1, -70)
	content.ZIndex = 11

	-- ========================
	-- State
	-- ========================
	local selectedRace = nil
	local selectedClass = nil
	local raceCards = {}
	local classCards = {}
	local classPanel = nil
	local confirmBtn = nil
	local stepLabel = nil

	-- ========================
	-- Step label
	-- ========================
	stepLabel = Instance.new("TextLabel")
	stepLabel.Text = "Step 1: Select your race"
	stepLabel.TextSize = 16
	stepLabel.Font = Enum.Font.GothamBold
	stepLabel.TextColor3 = Color3.fromRGB(180, 200, 230)
	stepLabel.BackgroundTransparency = 1
	stepLabel.AnchorPoint = Vector2.new(0.5, 0)
	stepLabel.Position = UDim2.new(0.5, 0, 0, 16)
	stepLabel.Size = UDim2.new(0.8, 0, 0, 28)
	stepLabel.ZIndex = 12
	stepLabel.Parent = content

	-- ========================
	-- Race cards row
	-- ========================
	local raceRow = makeFrame(content, Color3.new(0, 0, 0), 1, 0.5, 0, 0.5, 0, 0, 60, 0.9, 0, 0, 220)
	raceRow.ZIndex = 11

	local raceList = Instance.new("UIListLayout")
	raceList.FillDirection = Enum.FillDirection.Horizontal
	raceList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	raceList.VerticalAlignment = Enum.VerticalAlignment.Center
	raceList.Padding = UDim.new(0, 20)
	raceList.Parent = raceRow

	local function updateRaceSelection()
		for _, rc in ipairs(raceCards) do
			local isSelected = rc.RaceId == (selectedRace and selectedRace.Id)
			local race = rc.Race
			rc.Frame.BackgroundColor3 = isSelected and race.Color or Color3.fromRGB(18, 22, 32)
			rc.Frame.BackgroundTransparency = isSelected and 0.1 or 0.3
			if rc.Stroke then
				rc.Stroke.Color = isSelected and race.AccentColor or Color3.fromRGB(60, 70, 90)
				rc.Stroke.Thickness = isSelected and 3 or 1
			end
		end
	end

	for _, race in ipairs(RACES) do
		local card = makeFrame(raceRow, Color3.fromRGB(18, 22, 32), 0.3, 0, 0, 0, 0, 0, 0, 0, 220, 0, 200)
		card.ZIndex = 12
		addCorner(card, 12)
		local stroke = addStroke(card, Color3.fromRGB(60, 70, 90), 1)

		-- Race name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = race.DisplayName
		nameLabel.TextSize = 18
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextColor3 = race.TextColor
		nameLabel.BackgroundTransparency = 1
		nameLabel.AnchorPoint = Vector2.new(0.5, 0)
		nameLabel.Position = UDim2.new(0.5, 0, 0, 16)
		nameLabel.Size = UDim2.new(0.9, 0, 0, 24)
		nameLabel.ZIndex = 13
		nameLabel.Parent = card

		-- Subtitle badge
		local badge = makeFrame(card, race.Color, 0.2, 0.5, 0, 0.5, 0, 0, 50, 0, 70, 0, 24)
		badge.ZIndex = 13
		addCorner(badge, 4)
		local badgeLabel = Instance.new("TextLabel")
		badgeLabel.Text = race.SubTitle
		badgeLabel.TextSize = 12
		badgeLabel.Font = Enum.Font.GothamBold
		badgeLabel.TextColor3 = race.AccentColor
		badgeLabel.BackgroundTransparency = 1
		badgeLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		badgeLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		badgeLabel.Size = UDim2.new(1, 0, 1, 0)
		badgeLabel.ZIndex = 14
		badgeLabel.Parent = badge

		-- Separator
		local sep = makeFrame(card, race.Color, 0.5, 0, 0, 0.05, 0, 0, 82, 0.9, 0, 0, 1)
		sep.ZIndex = 13

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Text = race.Desc
		descLabel.TextSize = 13
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
		descLabel.BackgroundTransparency = 1
		descLabel.AnchorPoint = Vector2.new(0.5, 0)
		descLabel.Position = UDim2.new(0.5, 0, 0, 96)
		descLabel.Size = UDim2.new(0.88, 0, 0, 80)
		descLabel.ZIndex = 13
		descLabel.TextWrapped = true
		descLabel.TextXAlignment = Enum.TextXAlignment.Center
		descLabel.Parent = card

		-- Clickable button overlay
		local btn = Instance.new("TextButton")
		btn.Text = ""
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.ZIndex = 15
		btn.Parent = card

		local raceCard = { RaceId = race.Id, Race = race, Frame = card, Stroke = stroke }
		table.insert(raceCards, raceCard)

		btn.MouseButton1Click:Connect(function()
			selectedRace = race
			selectedClass = nil
			updateRaceSelection()

			-- Update step label
			stepLabel.Text = "Step 2: Select your class  ·  Race: " .. race.DisplayName
			titleLabel.Text = "CHOOSE YOUR CLASS"

			-- Show class panel
			if classPanel then
				classPanel.Visible = true
			end
			if confirmBtn then
				confirmBtn.Visible = false
			end

			-- Reset class cards
			for _, cc in ipairs(classCards) do
				local available = race.Id ~= "CYBORG" or cc.ClassId ~= "Spiritualist"
				local classDef = nil
				for _, c in ipairs(CLASSES) do
					if c.Id == cc.ClassId then classDef = c break end
				end

				cc.Frame.BackgroundTransparency = available and 0.3 or 0.7
				cc.Frame.BackgroundColor3 = available and Color3.fromRGB(18, 22, 32) or Color3.fromRGB(12, 12, 15)
				if cc.Stroke then
					cc.Stroke.Color = Color3.fromRGB(60, 70, 90)
					cc.Stroke.Thickness = 1
				end
				cc.LockedLabel.Visible = not available
				cc.Btn.Active = available
			end
		end)
	end

	-- ========================
	-- Class panel
	-- ========================
	classPanel = makeFrame(content, Color3.new(0, 0, 0), 1, 0.5, 0, 0.5, 0, 0, 290, 0.9, 0, 0, 210)
	classPanel.ZIndex = 11
	classPanel.Visible = false

	local classList = Instance.new("UIListLayout")
	classList.FillDirection = Enum.FillDirection.Horizontal
	classList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	classList.VerticalAlignment = Enum.VerticalAlignment.Center
	classList.Padding = UDim.new(0, 16)
	classList.Parent = classPanel

	local function updateClassSelection()
		for _, cc in ipairs(classCards) do
			local isSelected = selectedClass and cc.ClassId == selectedClass.Id
			local available = selectedRace and (selectedRace.Id ~= "CYBORG" or cc.ClassId ~= "Spiritualist")
			if isSelected and available then
				cc.Frame.BackgroundColor3 = Color3.fromRGB(40, 80, 50)
				cc.Frame.BackgroundTransparency = 0.1
				if cc.Stroke then
					cc.Stroke.Color = Color3.fromRGB(80, 220, 120)
					cc.Stroke.Thickness = 3
				end
			elseif available then
				cc.Frame.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
				cc.Frame.BackgroundTransparency = 0.3
				if cc.Stroke then
					cc.Stroke.Color = Color3.fromRGB(60, 70, 90)
					cc.Stroke.Thickness = 1
				end
			end
		end
	end

	for _, cls in ipairs(CLASSES) do
		local card = makeFrame(classPanel, Color3.fromRGB(18, 22, 32), 0.3, 0, 0, 0, 0, 0, 0, 0, 180, 0, 190)
		card.ZIndex = 12
		addCorner(card, 12)
		local stroke = addStroke(card, Color3.fromRGB(60, 70, 90), 1)

		-- Class name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Text = cls.DisplayName
		nameLabel.TextSize = 16
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.BackgroundTransparency = 1
		nameLabel.AnchorPoint = Vector2.new(0.5, 0)
		nameLabel.Position = UDim2.new(0.5, 0, 0, 14)
		nameLabel.Size = UDim2.new(0.9, 0, 0, 22)
		nameLabel.ZIndex = 13
		nameLabel.Parent = card

		-- Role badge
		local roleColors = {
			Melee = Color3.fromRGB(200, 80, 60),
			Ranged = Color3.fromRGB(60, 140, 200),
			Magic = Color3.fromRGB(160, 80, 220),
			Support = Color3.fromRGB(60, 180, 130),
		}
		local roleBadge = makeFrame(card, roleColors[cls.Role] or Color3.fromRGB(80, 80, 80), 0.3, 0.5, 0, 0.5, 0, 0, 44, 0, 80, 0, 20)
		roleBadge.ZIndex = 13
		addCorner(roleBadge, 4)
		local roleLabel = Instance.new("TextLabel")
		roleLabel.Text = cls.Role
		roleLabel.TextSize = 11
		roleLabel.Font = Enum.Font.GothamBold
		roleLabel.TextColor3 = Color3.new(1, 1, 1)
		roleLabel.BackgroundTransparency = 1
		roleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		roleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		roleLabel.Size = UDim2.new(1, 0, 1, 0)
		roleLabel.ZIndex = 14
		roleLabel.Parent = roleBadge

		-- Separator
		makeFrame(card, Color3.fromRGB(60, 70, 90), 0.5, 0, 0, 0.05, 0, 0, 72, 0.9, 0, 0, 1).ZIndex = 13

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Text = cls.Desc
		descLabel.TextSize = 12
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextColor3 = Color3.fromRGB(170, 180, 200)
		descLabel.BackgroundTransparency = 1
		descLabel.AnchorPoint = Vector2.new(0.5, 0)
		descLabel.Position = UDim2.new(0.5, 0, 0, 82)
		descLabel.Size = UDim2.new(0.88, 0, 0, 90)
		descLabel.ZIndex = 13
		descLabel.TextWrapped = true
		descLabel.TextXAlignment = Enum.TextXAlignment.Center
		descLabel.Parent = card

		-- Locked overlay for Spiritualist+CYBORG
		local lockedLabel = Instance.new("TextLabel")
		lockedLabel.Text = "Not available\nfor Accretia"
		lockedLabel.TextSize = 13
		lockedLabel.Font = Enum.Font.GothamBold
		lockedLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
		lockedLabel.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
		lockedLabel.BackgroundTransparency = 0.3
		lockedLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		lockedLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		lockedLabel.Size = UDim2.new(1, 0, 1, 0)
		lockedLabel.ZIndex = 16
		lockedLabel.TextWrapped = true
		lockedLabel.TextXAlignment = Enum.TextXAlignment.Center
		lockedLabel.Visible = false
		lockedLabel.Parent = card
		addCorner(lockedLabel, 12)

		-- Button
		local btn = Instance.new("TextButton")
		btn.Text = ""
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.ZIndex = 15
		btn.Parent = card

		local classCard = { ClassId = cls.Id, Class = cls, Frame = card, Stroke = stroke, LockedLabel = lockedLabel, Btn = btn }
		table.insert(classCards, classCard)

		btn.MouseButton1Click:Connect(function()
			if not selectedRace then return end
			-- Block Spiritualist for Accretia
			if selectedRace.Id == "CYBORG" and cls.Id == "Spiritualist" then return end

			selectedClass = cls
			updateClassSelection()

			stepLabel.Text = "Step 3: Confirm your selection"
			if confirmBtn then
				confirmBtn.Visible = true
			end
		end)
	end

	-- ========================
	-- Confirm button
	-- ========================
	confirmBtn = Instance.new("TextButton")
	confirmBtn.Text = "CREATE CHARACTER"
	confirmBtn.TextSize = 18
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.TextColor3 = Color3.new(1, 1, 1)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
	confirmBtn.AnchorPoint = Vector2.new(0.5, 1)
	confirmBtn.Position = UDim2.new(0.5, 0, 1, -30)
	confirmBtn.Size = UDim2.new(0, 260, 0, 52)
	confirmBtn.ZIndex = 20
	confirmBtn.Visible = false
	confirmBtn.Parent = content
	addCorner(confirmBtn, 10)
	addStroke(confirmBtn, Color3.fromRGB(80, 220, 120), 2)

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Text = ""
	statusLabel.TextSize = 14
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
	statusLabel.BackgroundTransparency = 1
	statusLabel.AnchorPoint = Vector2.new(0.5, 1)
	statusLabel.Position = UDim2.new(0.5, 0, 1, -92)
	statusLabel.Size = UDim2.new(0.7, 0, 0, 28)
	statusLabel.ZIndex = 20
	statusLabel.Parent = content

	confirmBtn.MouseButton1Click:Connect(function()
		if not selectedRace or not selectedClass then return end

		confirmBtn.Active = false
		confirmBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 50)
		confirmBtn.Text = "Creating..."
		statusLabel.Text = "Contacting server..."

		local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
		if not remotes then
			statusLabel.Text = "Error: Remotes not found"
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		local selectRemote = remotes:FindFirstChild("SelectRaceAndClassRequest")
		if not selectRemote then
			statusLabel.Text = "Error: Remote not found"
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		local ok, result = pcall(function()
			return selectRemote:InvokeServer(selectedRace.Id, selectedClass.Id)
		end)

		if not ok then
			statusLabel.Text = "Error: " .. tostring(result)
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		-- result is (success, message/items)
		if not result then
			statusLabel.Text = "Server rejected selection. Try again."
			confirmBtn.Active = true
			confirmBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
			confirmBtn.Text = "CREATE CHARACTER"
			return
		end

		-- Success — fade out and notify caller
		statusLabel.Text = "Character created! Entering world..."
		confirmBtn.Text = "ENTERING WORLD..."

		TweenService:Create(bg, TweenInfo.new(1.2), { BackgroundTransparency = 1 }):Play()
		task.wait(1.3)
		screenGui:Destroy()

		if onComplete then
			onComplete(selectedRace.Id, selectedClass.Id)
		end
	end)

	-- Fade in
	bg.BackgroundTransparency = 1
	TweenService:Create(bg, TweenInfo.new(0.8), { BackgroundTransparency = 0 }):Play()

	return screenGui
end

return CharacterCreationUI
