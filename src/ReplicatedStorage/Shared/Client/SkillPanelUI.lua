-- SkillPanelUI.lua
-- Batch 2.5: UI untuk Skill & Force system.
-- Fitur:
--   - Skill/Force list window (tekan K) dengan tab Melee/Ranged/Force
--   - Tiap skill menampilkan: icon, nama, level, FP cost, cooldown, tier badge
--   - Tier lock indicator (kunci abu-abu jika belum memenuhi PT requirement)
--   - Skill hotbar bawah (S1-S8) yang bisa di-drag dari skill list
--   - Cooldown overlay (sweep animasi seperti RF)
--   - Cast skill: klik hotbar → pilih target → kirim ke server
--
-- Dipanggil dari AetherionGameplayUI (atau standalone dari UILoader)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Definitions = Shared:WaitForChild("Definitions")

local SkillDefinitions = require(Definitions:WaitForChild("SkillDefinitions"))
local ForceDefinitions = require(Definitions:WaitForChild("ForceDefinitions"))

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

local function waitRemote(name, class)
	local r = remotes:WaitForChild(name, 10)
	assert(r and r:IsA(class), "Missing remote: " .. name)
	return r
end

local CastSkillRequest = waitRemote("CastSkillRequest", "RemoteFunction")
local GetSkillDataRequest = waitRemote("GetSkillDataRequest", "RemoteFunction")
local GetSkillCooldownsRequest = waitRemote("GetSkillCooldownsRequest", "RemoteFunction")
local GetPlayerDataRequest = waitRemote("GetPlayerDataRequest", "RemoteFunction")

-- ============================================================
-- State
-- ============================================================

local state = {
	IsOpen = false,
	ActiveTab = "Melee", -- "Melee" | "Ranged" | "Force"
	SkillData = nil, -- dari server: { Skills, SkillPT, ActiveBuffs }
	PlayerData = nil,
	Cooldowns = {}, -- { [skillId] = expiryTick }
	Hotbar = {}, -- [slot 1-8] = skillId | nil
	PendingCast = nil, -- skillId sedang menunggu klik target
	DraggingSkillId = nil,
}

-- ============================================================
-- Theme (same RF_THEME as AetherionGameplayUI)
-- ============================================================

local TH = {
	Window     = Color3.fromRGB(12, 18, 26),
	WindowDark = Color3.fromRGB(7, 10, 15),
	Panel      = Color3.fromRGB(22, 28, 36),
	PanelLight = Color3.fromRGB(34, 42, 52),
	Slot       = Color3.fromRGB(10, 13, 18),
	SlotHover  = Color3.fromRGB(28, 36, 48),
	Border     = Color3.fromRGB(76, 91, 105),
	BorderBright = Color3.fromRGB(145, 169, 190),
	Gold       = Color3.fromRGB(211, 178, 98),
	Blue       = Color3.fromRGB(87, 130, 190),
	Green      = Color3.fromRGB(80, 180, 100),
	Red        = Color3.fromRGB(170, 42, 42),
	Orange     = Color3.fromRGB(200, 130, 40),
	Purple     = Color3.fromRGB(140, 80, 200),
	Text       = Color3.fromRGB(230, 235, 240),
	TextDim    = Color3.fromRGB(150, 165, 180),
}

local TIER_COLOR = {
	Basic  = TH.TextDim,
	Expert = TH.Gold,
	Elite  = TH.Purple,
}

local SCHOOL_COLOR = {
	Holy      = Color3.fromRGB(230, 200, 100),
	Dark      = Color3.fromRGB(160, 80, 220),
	Elemental = Color3.fromRGB(80, 180, 220),
}

local refs = {}

-- ============================================================
-- UI Helpers
-- ============================================================

local function makeFrame(parent, props)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = props.Color or TH.Panel
	f.BorderSizePixel = 0
	f.Size = props.Size or UDim2.new(1, 0, 1, 0)
	f.Position = props.Position or UDim2.new(0, 0, 0, 0)
	f.Parent = parent
	if props.ZIndex then f.ZIndex = props.ZIndex end
	if props.Transparency then f.BackgroundTransparency = props.Transparency end
	if props.Name then f.Name = props.Name end
	if props.ClipsDescendants then f.ClipsDescendants = true end
	return f
end

local function makeLabel(parent, props)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Size = props.Size or UDim2.new(1, 0, 1, 0)
	l.Position = props.Position or UDim2.new(0, 0, 0, 0)
	l.Text = props.Text or ""
	l.TextColor3 = props.Color or TH.Text
	l.Font = props.Font or Enum.Font.GothamMedium
	l.TextSize = props.TextSize or 13
	l.TextXAlignment = props.XAlign or Enum.TextXAlignment.Left
	l.TextYAlignment = props.YAlign or Enum.TextYAlignment.Center
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	if props.ZIndex then l.ZIndex = props.ZIndex end
	if props.Name then l.Name = props.Name end
	return l
end

local function makeButton(parent, props)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = props.Color or TH.PanelLight
	b.BorderSizePixel = 0
	b.Size = props.Size or UDim2.new(1, 0, 1, 0)
	b.Position = props.Position or UDim2.new(0, 0, 0, 0)
	b.Text = props.Text or ""
	b.TextColor3 = props.TextColor or TH.Text
	b.Font = props.Font or Enum.Font.GothamMedium
	b.TextSize = props.TextSize or 13
	b.Parent = parent
	if props.ZIndex then b.ZIndex = props.ZIndex end
	if props.Name then b.Name = props.Name end
	return b
end

local function addBorder(frame, color)
	local ui = Instance.new("UIStroke")
	ui.Color = color or TH.Border
	ui.Thickness = 1
	ui.Parent = frame
	return ui
end

local function addCorner(frame, radius)
	local ui = Instance.new("UICorner")
	ui.CornerRadius = UDim.new(0, radius or 4)
	ui.Parent = frame
	return ui
end

local function addPadding(frame, px)
	local ui = Instance.new("UIPadding")
	ui.PaddingLeft = UDim.new(0, px)
	ui.PaddingRight = UDim.new(0, px)
	ui.PaddingTop = UDim.new(0, px)
	ui.PaddingBottom = UDim.new(0, px)
	ui.Parent = frame
	return ui
end

-- ============================================================
-- Root ScreenGui
-- ============================================================

local function buildRoot()
	local sg = Instance.new("ScreenGui")
	sg.Name = "AetherionSkillUI"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = PlayerGui
	return sg
end

-- ============================================================
-- Skill Hotbar (bawah layar, S1-S8)
-- ============================================================

local HOTBAR_SLOTS = 8
local SLOT_SIZE = 52
local SLOT_GAP = 4

local function buildHotbar(parent)
	local totalW = HOTBAR_SLOTS * SLOT_SIZE + (HOTBAR_SLOTS - 1) * SLOT_GAP
	local barFrame = makeFrame(parent, {
		Name = "SkillHotbar",
		Size = UDim2.new(0, totalW + 16, 0, SLOT_SIZE + 32),
		Position = UDim2.new(0.5, -math.floor(totalW / 2) - 8, 1, -150),
		Color = TH.WindowDark,
	})
	addBorder(barFrame, TH.Border)
	addCorner(barFrame, 6)

	local label = makeLabel(barFrame, {
		Text = "SKILL BAR",
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 0, 2),
		Color = TH.TextDim,
		TextSize = 10,
		XAlign = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBold,
	})

	local slotHolder = makeFrame(barFrame, {
		Name = "SlotHolder",
		Size = UDim2.new(0, totalW, 0, SLOT_SIZE),
		Position = UDim2.new(0, 8, 0, 16),
		Color = Color3.new(0, 0, 0),
		Transparency = 1,
	})

	refs.HotbarSlots = {}
	refs.HotbarCooldownOverlays = {}
	refs.HotbarCDLabels = {}

	for i = 1, HOTBAR_SLOTS do
		local x = (i - 1) * (SLOT_SIZE + SLOT_GAP)

		local slot = makeFrame(slotHolder, {
			Name = "Slot" .. i,
			Size = UDim2.new(0, SLOT_SIZE, 0, SLOT_SIZE),
			Position = UDim2.new(0, x, 0, 0),
			Color = TH.Slot,
		})
		addBorder(slot, TH.Border)
		addCorner(slot, 4)

		-- Key label (S1..S8)
		local keyLabel = makeLabel(slot, {
			Text = "S" .. i,
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.new(0, 0, 0, 0),
			Color = TH.TextDim,
			TextSize = 10,
			XAlign = Enum.TextXAlignment.Center,
		})

		-- Skill name label
		local nameLabel = makeLabel(slot, {
			Name = "SkillName",
			Text = "",
			Size = UDim2.new(1, -2, 0, 12),
			Position = UDim2.new(0, 1, 1, -24),
			Color = TH.Text,
			TextSize = 9,
			XAlign = Enum.TextXAlignment.Center,
		})

		-- Level label
		local lvlLabel = makeLabel(slot, {
			Name = "LvlLabel",
			Text = "",
			Size = UDim2.new(1, -2, 0, 12),
			Position = UDim2.new(0, 1, 1, -13),
			Color = TH.Gold,
			TextSize = 9,
			XAlign = Enum.TextXAlignment.Center,
		})

		-- Cooldown overlay (sweep dari atas, semi-transparent)
		local cdOverlay = makeFrame(slot, {
			Name = "CooldownOverlay",
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Color = Color3.fromRGB(0, 0, 0),
			Transparency = 0.35,
			ZIndex = 5,
		})
		addCorner(cdOverlay, 4)

		-- Cooldown time label
		local cdLabel = makeLabel(slot, {
			Name = "CDLabel",
			Text = "",
			Size = UDim2.new(1, 0, 1, 0),
			Color = Color3.fromRGB(255, 255, 255),
			TextSize = 14,
			XAlign = Enum.TextXAlignment.Center,
			ZIndex = 6,
			Font = Enum.Font.GothamBold,
		})

		-- Click handler
		local btn = makeButton(slot, {
			Text = "",
			Size = UDim2.new(1, 0, 1, 0),
			Color = Color3.new(0, 0, 0),
		})
		btn.BackgroundTransparency = 1

		local slotIdx = i
		btn.MouseButton1Click:Connect(function()
			local skillId = state.Hotbar[slotIdx]

			if not skillId then
				return
			end

			-- Toggle pending cast
			if state.PendingCast == skillId then
				state.PendingCast = nil
			else
				state.PendingCast = skillId
			end
		end)

		slot.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				-- Allow dropping skills onto hotbar
			end
		end)

		refs.HotbarSlots[i] = slot
		refs.HotbarCooldownOverlays[i] = cdOverlay
		refs.HotbarCDLabels[i] = cdLabel
	end

	refs.SkillHotbar = barFrame
	return barFrame
end

-- ============================================================
-- Skill List Window
-- ============================================================

local PANEL_W = 420
local PANEL_H = 520

local function getTierBadgeColor(tier)
	return TIER_COLOR[tier] or TH.TextDim
end

local function buildSkillRow(parent, skillDef, skillEntry, skillPT, yOffset)
	local ROW_H = 56
	local isLocked = false

	-- Cek unlock requirement
	if skillDef.PTTierReq then
		local cat = skillDef.Category or skillDef.School or "Force"
		local ptData = skillPT and skillPT[cat]
		local ptInTier = ptData and ptData[skillDef.PTTierReq] or 0
		isLocked = ptInTier < skillDef.PTReqAmount
	end

	local row = makeFrame(parent, {
		Name = "Row_" .. skillDef.Id,
		Size = UDim2.new(1, -8, 0, ROW_H),
		Position = UDim2.new(0, 4, 0, yOffset),
		Color = isLocked and Color3.fromRGB(14, 16, 20) or TH.Panel,
	})
	addBorder(row, isLocked and TH.Border or TH.BorderBright)
	addCorner(row, 4)

	-- Icon area (left square)
	local iconBox = makeFrame(row, {
		Size = UDim2.new(0, ROW_H - 8, 0, ROW_H - 8),
		Position = UDim2.new(0, 4, 0, 4),
		Color = TH.Slot,
	})
	addBorder(iconBox, TH.Border)
	addCorner(iconBox, 4)

	-- School/element color bar on icon
	if skillDef.School then
		local colorBar = makeFrame(iconBox, {
			Size = UDim2.new(0, 4, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Color = SCHOOL_COLOR[skillDef.School] or TH.Blue,
		})
	end

	-- Tier label on icon
	local tierLabel = makeLabel(iconBox, {
		Text = skillDef.Tier:sub(1, 1), -- B / E / L
		Size = UDim2.new(1, 0, 0, 14),
		Position = UDim2.new(0, 0, 1, -14),
		Color = getTierBadgeColor(skillDef.Tier),
		TextSize = 10,
		XAlign = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBold,
	})

	-- Lock icon
	if isLocked then
		local lockLabel = makeLabel(iconBox, {
			Text = "🔒",
			Size = UDim2.new(1, 0, 1, 0),
			Color = TH.TextDim,
			TextSize = 18,
			XAlign = Enum.TextXAlignment.Center,
		})
	end

	-- Right section
	local infoX = ROW_H + 4

	-- Name
	local nameLabel = makeLabel(row, {
		Text = skillDef.Name,
		Size = UDim2.new(1, -(infoX + 100), 0, 18),
		Position = UDim2.new(0, infoX, 0, 4),
		Color = isLocked and TH.TextDim or TH.Text,
		TextSize = 13,
		Font = Enum.Font.GothamBold,
	})

	-- Tier badge
	local tierBadge = makeLabel(row, {
		Text = skillDef.Tier:upper(),
		Size = UDim2.new(0, 54, 0, 16),
		Position = UDim2.new(1, -60, 0, 4),
		Color = getTierBadgeColor(skillDef.Tier),
		TextSize = 10,
		XAlign = Enum.TextXAlignment.Center,
		Font = Enum.Font.GothamBold,
	})

	-- Level indicator
	local level = (skillEntry and skillEntry.Level) or (isLocked and 0 or 1)
	local levelLabel = makeLabel(row, {
		Text = isLocked and ("Req: " .. skillDef.PTReqAmount .. " PT") or ("Lv." .. level),
		Size = UDim2.new(0, 80, 0, 14),
		Position = UDim2.new(0, infoX, 0, 22),
		Color = isLocked and TH.Red or TH.Gold,
		TextSize = 11,
	})

	-- FP cost
	local fpLabel = makeLabel(row, {
		Text = "FP: " .. (skillDef.FPCost or "—"),
		Size = UDim2.new(0, 70, 0, 14),
		Position = UDim2.new(0, infoX + 90, 0, 22),
		Color = Color3.fromRGB(80, 160, 255),
		TextSize = 11,
	})

	-- Cooldown
	local cdLabel = makeLabel(row, {
		Text = "CD: " .. (skillDef.CastDelay or 0) .. "s",
		Size = UDim2.new(0, 60, 0, 14),
		Position = UDim2.new(0, infoX + 165, 0, 22),
		Color = TH.TextDim,
		TextSize = 11,
	})

	-- Effect description
	local effectLabel = makeLabel(row, {
		Text = skillDef.Effect or "",
		Size = UDim2.new(1, -(infoX + 4), 0, 14),
		Position = UDim2.new(0, infoX, 0, 38),
		Color = TH.TextDim,
		TextSize = 10,
	})

	-- Assign to hotbar button
	local assignBtn = makeButton(row, {
		Text = isLocked and "LOCKED" or "ASSIGN",
		Size = UDim2.new(0, 54, 0, 18),
		Position = UDim2.new(1, -60, 1, -22),
		Color = isLocked and TH.Slot or TH.Blue,
		TextColor = isLocked and TH.TextDim or TH.Text,
		TextSize = 10,
	})
	addCorner(assignBtn, 3)

	if not isLocked then
		assignBtn.MouseButton1Click:Connect(function()
			-- Assign ke slot hotbar pertama yang kosong
			for i = 1, HOTBAR_SLOTS do
				if not state.Hotbar[i] then
					state.Hotbar[i] = skillDef.Id
					refreshHotbarSlot(i)
					break
				end
			end
		end)
	end

	return row, ROW_H + 4
end

-- refreshHotbarSlot adalah forward declaration yang akan diisi nanti
function refreshHotbarSlot(i)
	local slot = refs.HotbarSlots[i]

	if not slot then
		return
	end

	local skillId = state.Hotbar[i]
	local nameLabel = slot:FindFirstChild("SkillName")
	local lvlLabel = slot:FindFirstChild("LvlLabel")

	if skillId then
		local skillDef = SkillDefinitions[skillId] or ForceDefinitions[skillId]
		local skillEntry = state.SkillData and state.SkillData.Skills and state.SkillData.Skills[skillId]
		local level = skillEntry and skillEntry.Level or 1

		if nameLabel then
			nameLabel.Text = skillDef and skillDef.Name or skillId
		end

		if lvlLabel then
			lvlLabel.Text = "Lv." .. level
		end

		-- Tier color border
		local stroke = slot:FindFirstChildOfClass("UIStroke")

		if stroke and skillDef then
			stroke.Color = getTierBadgeColor(skillDef.Tier)
		end
	else
		if nameLabel then nameLabel.Text = "" end
		if lvlLabel then lvlLabel.Text = "" end

		local stroke = slot:FindFirstChildOfClass("UIStroke")
		if stroke then stroke.Color = TH.Border end
	end
end

local function buildSkillListPanel(parent)
	local panel = makeFrame(parent, {
		Name = "SkillPanel",
		Size = UDim2.new(0, PANEL_W, 0, PANEL_H),
		Position = UDim2.new(0.5, -PANEL_W / 2, 0.5, -PANEL_H / 2),
		Color = TH.Window,
	})
	addBorder(panel, TH.BorderBright)
	addCorner(panel, 6)
	panel.Visible = false

	-- Title bar
	local titleBar = makeFrame(panel, {
		Size = UDim2.new(1, 0, 0, 32),
		Color = TH.WindowDark,
	})
	addCorner(titleBar, 6)

	makeLabel(titleBar, {
		Text = "  SKILL & FORCE",
		Size = UDim2.new(1, -40, 1, 0),
		Color = TH.Gold,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
	})

	local closeBtn = makeButton(titleBar, {
		Text = "✕",
		Size = UDim2.new(0, 32, 0, 32),
		Position = UDim2.new(1, -32, 0, 0),
		Color = Color3.new(0, 0, 0),
		TextColor = TH.TextDim,
		TextSize = 14,
	})
	closeBtn.BackgroundTransparency = 1
	closeBtn.MouseButton1Click:Connect(function()
		panel.Visible = false
		state.IsOpen = false
	end)

	-- Tabs
	local TAB_LABELS = { "Melee", "Ranged", "Force" }
	local tabBar = makeFrame(panel, {
		Name = "TabBar",
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0, 32),
		Color = TH.WindowDark,
		Transparency = 0.5,
	})

	refs.TabButtons = {}

	for i, tabName in ipairs(TAB_LABELS) do
		local tabW = PANEL_W / #TAB_LABELS
		local tabBtn = makeButton(tabBar, {
			Name = "Tab_" .. tabName,
			Text = tabName:upper(),
			Size = UDim2.new(0, tabW, 1, 0),
			Position = UDim2.new(0, (i - 1) * tabW, 0, 0),
			Color = TH.Window,
			TextColor = TH.TextDim,
			TextSize = 12,
			Font = Enum.Font.GothamBold,
		})

		local t = tabName
		tabBtn.MouseButton1Click:Connect(function()
			state.ActiveTab = t
			populateSkillList()
			updateTabHighlight()
		end)

		refs.TabButtons[tabName] = tabBtn
	end

	-- Scroll frame for skill rows
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "SkillScroll"
	scrollFrame.Size = UDim2.new(1, 0, 1, -90)
	scrollFrame.Position = UDim2.new(0, 0, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarImageColor3 = TH.Border
	scrollFrame.Parent = panel

	refs.SkillScroll = scrollFrame
	refs.SkillPanel = panel

	return panel
end

function updateTabHighlight()
	for tabName, btn in pairs(refs.TabButtons or {}) do
		if tabName == state.ActiveTab then
			btn.BackgroundColor3 = TH.PanelLight
			btn.TextColor3 = TH.Gold
		else
			btn.BackgroundColor3 = TH.Window
			btn.TextColor3 = TH.TextDim
		end
	end
end

function populateSkillList()
	local scroll = refs.SkillScroll

	if not scroll then return end

	-- Clear existing rows
	for _, child in ipairs(scroll:GetChildren()) do
		child:Destroy()
	end

	local skillData = state.SkillData
	local skillPT = skillData and skillData.SkillPT or {}
	local skills = skillData and skillData.Skills or {}
	local playerFaction = state.PlayerData and state.PlayerData.FactionId

	local defs = {}

	if state.ActiveTab == "Melee" then
		defs = SkillDefinitions.GetByCategory("Melee")
	elseif state.ActiveTab == "Ranged" then
		defs = SkillDefinitions.GetByCategory("Ranged")
	elseif state.ActiveTab == "Force" then
		-- Ambil semua force yang diperbolehkan untuk race ini
		for forceId, def in pairs(ForceDefinitions) do
			if type(def) == "table" then
				if not playerFaction then
					table.insert(defs, def)
				elseif ForceDefinitions.IsAllowedForRace(def, playerFaction) then
					table.insert(defs, def)
				end
			end
		end
	end

	-- Sort: Basic dulu, lalu Expert, lalu Elite
	local TIER_ORDER = { Basic = 1, Expert = 2, Elite = 3 }
	table.sort(defs, function(a, b)
		local ta = TIER_ORDER[a.Tier] or 9
		local tb = TIER_ORDER[b.Tier] or 9
		if ta ~= tb then return ta < tb end
		return a.Name < b.Name
	end)

	local yOffset = 4
	for _, skillDef in ipairs(defs) do
		local skillEntry = skills[skillDef.Id]
		local row, rowH = buildSkillRow(scroll, skillDef, skillEntry, skillPT, yOffset)
		yOffset = yOffset + rowH
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, yOffset + 8)
end

-- ============================================================
-- Cooldown Update Loop
-- ============================================================

local function startCooldownLoop()
	RunService.Heartbeat:Connect(function()
		local now = tick()

		-- Fetch cooldowns from server periodically (atau track lokal)
		-- Untuk performa, track lokal setelah cast

		for i = 1, HOTBAR_SLOTS do
			local skillId = state.Hotbar[i]
			local overlay = refs.HotbarCooldownOverlays[i]
			local cdLabel = refs.HotbarCDLabels[i]

			if skillId and overlay and cdLabel then
				local expiry = state.Cooldowns[skillId] or 0
				local remaining = expiry - now

				if remaining > 0 then
					-- Ambil total CD dari def
					local def = SkillDefinitions[skillId] or ForceDefinitions[skillId]
					local totalCD = (def and def.CastDelay) or 1
					local fraction = math.clamp(remaining / totalCD, 0, 1)

					overlay.Size = UDim2.new(1, 0, fraction, 0)
					overlay.Visible = true
					cdLabel.Text = string.format("%.0f", remaining)
					cdLabel.Visible = true
				else
					overlay.Visible = false
					cdLabel.Text = ""
					cdLabel.Visible = false
				end
			end
		end

		-- Highlight pending cast slot
		for i = 1, HOTBAR_SLOTS do
			local slot = refs.HotbarSlots[i]
			if slot then
				local stroke = slot:FindFirstChildOfClass("UIStroke")
				if stroke then
					local skillId = state.Hotbar[i]
					if skillId and skillId == state.PendingCast then
						stroke.Color = TH.Green
						stroke.Thickness = 2
					else
						local def = SkillDefinitions[skillId or ""] or ForceDefinitions[skillId or ""]
						stroke.Color = def and getTierBadgeColor(def.Tier) or TH.Border
						stroke.Thickness = 1
					end
				end
			end
		end
	end)
end

-- ============================================================
-- Data Fetch
-- ============================================================

local function fetchSkillData()
	local ok, data = pcall(function()
		return GetSkillDataRequest:InvokeServer()
	end)

	if ok and data then
		local success, result = table.unpack(type(data) == "table" and data or { data })

		if success and result then
			state.SkillData = result
		elseif type(data) == "table" and data.Skills then
			state.SkillData = data
		end
	end
end

local function fetchPlayerData()
	local ok, data = pcall(function()
		return GetPlayerDataRequest:InvokeServer()
	end)

	if ok and data then
		state.PlayerData = type(data) == "table" and data or nil
	end
end

local function fetchCooldowns()
	local ok, result = pcall(function()
		return GetSkillCooldownsRequest:InvokeServer()
	end)

	if ok and result then
		local success, cooldownData

		if type(result) == "table" and #result == 2 then
			success, cooldownData = table.unpack(result)
		else
			cooldownData = result
		end

		if cooldownData then
			local now = tick()
			for skillId, remaining in pairs(cooldownData) do
				state.Cooldowns[skillId] = now + remaining
			end
		end
	end
end

-- ============================================================
-- Target Click Handler (untuk PendingCast)
-- ============================================================

local function setupTargetClickHandler()
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 and state.PendingCast then
			local skillId = state.PendingCast
			local def = SkillDefinitions[skillId] or ForceDefinitions[skillId]

			if not def then
				state.PendingCast = nil
				return
			end

			local targetModel = nil

			if def.Target == "Enemy" then
				-- Raycast ke target
				local camera = workspace.CurrentCamera
				local mousePos = UserInputService:GetMouseLocation()
				local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

				local result = workspace:Raycast(
					ray.Origin,
					ray.Direction * 100,
					RaycastParams.new()
				)

				if result and result.Instance then
					local model = result.Instance:FindFirstAncestorOfClass("Model")
					if model and model:FindFirstChildOfClass("Humanoid") then
						targetModel = model
					end
				end

				if not targetModel then
					-- Tidak ada target valid, batalkan cast
					state.PendingCast = nil
					return
				end
			end

			-- Kirim ke server
			state.PendingCast = nil

			local ok, castResult = pcall(function()
				return CastSkillRequest:InvokeServer(skillId, targetModel)
			end)

			if ok and castResult then
				local success, data

				if type(castResult) == "table" and #castResult == 2 then
					success, data = table.unpack(castResult)
				else
					success = castResult
				end

				if success and data then
					-- Set cooldown lokal
					local castDef = SkillDefinitions[skillId] or ForceDefinitions[skillId]
					if castDef then
						state.Cooldowns[skillId] = tick() + castDef.CastDelay
					end

					-- Refresh hotbar
					for i = 1, HOTBAR_SLOTS do
						if state.Hotbar[i] == skillId then
							refreshHotbarSlot(i)
						end
					end

					-- Jika level up, refresh skill list
					if data.LevelUp and state.IsOpen then
						fetchSkillData()
						populateSkillList()
					end
				end
			end
		end

		-- Escape membatalkan pending cast
		if input.KeyCode == Enum.KeyCode.Escape then
			state.PendingCast = nil
		end
	end)
end

-- ============================================================
-- Keybind: K = toggle skill panel
-- ============================================================

local function setupKeybinds()
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		if input.KeyCode == Enum.KeyCode.K then
			state.IsOpen = not state.IsOpen
			refs.SkillPanel.Visible = state.IsOpen

			if state.IsOpen then
				fetchSkillData()
				fetchPlayerData()
				populateSkillList()
				updateTabHighlight()
			end
		end

		-- S1-S8 untuk cast dari hotbar
		local keyToSlot = {
			[Enum.KeyCode.One]   = 1,
			[Enum.KeyCode.Two]   = 2,
			[Enum.KeyCode.Three] = 3,
			[Enum.KeyCode.Four]  = 4,
			[Enum.KeyCode.Five]  = 5,
			[Enum.KeyCode.Six]   = 6,
			[Enum.KeyCode.Seven] = 7,
			[Enum.KeyCode.Eight] = 8,
		}

		-- Gunakan Ctrl+1..8 untuk skill hotbar agar tidak clash dengan movement
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			local slot = keyToSlot[input.KeyCode]

			if slot then
				local skillId = state.Hotbar[slot]

				if skillId then
					if state.PendingCast == skillId then
						state.PendingCast = nil
					else
						state.PendingCast = skillId
					end
				end
			end
		end
	end)
end

-- ============================================================
-- Init
-- ============================================================

local function init()
	local root = buildRoot()

	buildHotbar(root)
	buildSkillListPanel(root)

	setupKeybinds()
	setupTargetClickHandler()
	startCooldownLoop()

	updateTabHighlight()

	-- Fetch awal setelah beberapa detik
	task.delay(2, function()
		fetchSkillData()
		fetchPlayerData()
		fetchCooldowns()
	end)

	-- Refresh data setiap 30 detik
	task.spawn(function()
		while true do
			task.wait(30)
			if state.IsOpen then
				fetchSkillData()
				populateSkillList()
			end
		end
	end)

	return root
end

-- ============================================================
-- Public API (untuk dipanggil dari AetherionGameplayUI / UILoader)
-- ============================================================

local SkillPanelUI = {}

function SkillPanelUI.Init()
	init()
end

function SkillPanelUI.RefreshSkillData()
	fetchSkillData()

	if state.IsOpen then
		populateSkillList()
	end

	for i = 1, HOTBAR_SLOTS do
		refreshHotbarSlot(i)
	end
end

return SkillPanelUI
