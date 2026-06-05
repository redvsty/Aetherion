local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local player = Players.LocalPlayer

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Definitions = Shared:WaitForChild("Definitions")
local Database = Shared:WaitForChild("Database")
local WeaponsFolder = Database:WaitForChild("Weapons")
local ClientFolder = Shared:WaitForChild("Client")

local ItemDefinitions = require(Definitions:WaitForChild("ItemDefinitions"))
local Weapons = require(WeaponsFolder:WaitForChild("Weapons"))

local AetherionGameplayUI = {}

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

if not remotes then
	error("ReplicatedStorage.Remotes not found")
end

local function waitRemoteFunction(name)
	local remote = remotes:WaitForChild(name, 10)

	if not remote then
		error("Missing RemoteFunction: " .. name)
	end

	if not remote:IsA("RemoteFunction") then
		error(name .. " is not RemoteFunction")
	end

	return remote
end

local function waitRemoteEvent(name)
	local remote = remotes:WaitForChild(name, 10)

	if not remote then
		error("Missing RemoteEvent: " .. name)
	end

	if not remote:IsA("RemoteEvent") then
		error(name .. " is not RemoteEvent")
	end

	return remote
end

local GetPlayerDataRequest = waitRemoteFunction("GetPlayerDataRequest")
local GetPlayerStatsRequest = waitRemoteFunction("GetPlayerStatsRequest")
local EquipItemRequest = waitRemoteFunction("EquipItemRequest")
local UpgradeItemRequest = waitRemoteFunction("UpgradeItemRequest")
local GetPartyDataRequest = waitRemoteFunction("GetPartyDataRequest")
local PartyInviteRequest = waitRemoteFunction("PartyInviteRequest")
local PartyInviteResponseRequest = waitRemoteFunction("PartyInviteResponseRequest")
local PartyLeaveRequest = waitRemoteFunction("PartyLeaveRequest")
local PartyToggleLockRequest = waitRemoteFunction("PartyToggleLockRequest")
local PartyInviteReceived = waitRemoteEvent("PartyInviteReceived")
local ToggleRunWalkRequest = waitRemoteEvent("ToggleRunWalkRequest")
local RunWalkStateChanged = waitRemoteEvent("RunWalkStateChanged")
local GetMacrosRequest = waitRemoteFunction("GetMacrosRequest")
local ExecuteMacroRequest = waitRemoteFunction("ExecuteMacroRequest")
local CastSkillRequest = waitRemoteFunction("CastSkillRequest")
local ClearMacroRequest = waitRemoteFunction("ClearMacroRequest")
local UseItemRequest = waitRemoteFunction("UseItemRequest")
local PartyChatReceived = waitRemoteEvent("PartyChatReceived")
local BattleModeNotify  = waitRemoteEvent("BattleModeNotify")
local SPUpdateEvent     = waitRemoteEvent("SPUpdateEvent")

local BAG_COUNT = 5
local BAG_SIZE = 20
local HOTBAR_SIZE = 10
local EQUIPMENT_PANEL_SLOTS = {
	{ Key = "Helmet", Label = "Head", X = 69, Y = 0 },
	{ Key = "Weapon", Label = "Weapon", X = 0, Y = 58 },
	{ Key = "Shield", Label = "Shield", X = 138, Y = 58 },
	{ Key = "Upper", Label = "Upper", X = 69, Y = 58 },
	{ Key = "Gloves", Label = "Gloves", X = 0, Y = 116 },
	{ Key = "Lower", Label = "Lower", X = 69, Y = 116 },
	{ Key = "Boots", Label = "Boots", X = 138, Y = 116 },
	{ Key = "Cloak", Label = "Cloak", X = 69, Y = 174 },
	{ Key = "Ring1",   Label = "Ring 1",   X = 0,   Y = 232 },
	{ Key = "Ring2",   Label = "Ring 2",   X = 138, Y = 232 },
	{ Key = "Amulet1", Label = "Amulet 1", X = 0,   Y = 290 },
	{ Key = "Amulet2", Label = "Amulet 2", X = 138, Y = 290 },
}

local EQUIPMENT_STAT_ROWS = {
	{ Key = "Attack", Label = "ATK", Format = "number" },
	{ Key = "ForceAttack", Label = "FORCE", Format = "number" },
	{ Key = "Defense", Label = "DEF", Format = "number" },
	{ Key = "Accuracy", Label = "ACC", Format = "number" },
	{ Key = "Dodge", Label = "DODGE", Format = "number" },
	{ Key = "CritChance", Label = "CRIT", Format = "percent" },
	{ Key = "BlockChance", Label = "BLOCK", Format = "percent" },
	{ Key = "LifeStealPercent", Label = "DRAIN", Format = "percent" },
}

local uiState = {
	CurrentBag = 1,
	InventoryOpen = false,
	UpgradeOpen = false,
	PartyOpen = false,
	MacroOpen = false,
	CharacterOpen = false,
	BattleMode = false,
	LastBattleTick = 0,

	PlayerData = nil,
	PlayerStats = nil,
	SelectedPartyTarget = nil,
	PendingPartyInvite = nil,
	MacroData = nil,

	-- Item belt: 5 set × 10 slot (RF style)
	BeltSet = 1,
	BeltAssignments = { {}, {}, {}, {}, {} },

	UpgradeSlots = {
		Equipment = nil,
		Talic1 = nil,
		Talic2 = nil,
		Talic3 = nil,
		Talic4 = nil,
		Catalyst = nil,
	},

	DraggedItem = nil,
	DraggedSource = nil,
	DragVisual = nil,

	HoveredTooltipItem = nil,
	StatusMessage = "Ready.",
}

local RF_THEME = {
	Window = Color3.fromRGB(12, 18, 26),
	WindowDark = Color3.fromRGB(7, 10, 15),
	Panel = Color3.fromRGB(22, 28, 36),
	PanelLight = Color3.fromRGB(34, 42, 52),
	Slot = Color3.fromRGB(10, 13, 18),
	SlotHover = Color3.fromRGB(28, 36, 48),
	Border = Color3.fromRGB(76, 91, 105),
	BorderBright = Color3.fromRGB(145, 169, 190),
	Gold = Color3.fromRGB(211, 178, 98),
	Blue = Color3.fromRGB(87, 130, 190),
	Text = Color3.fromRGB(230, 235, 240),
	TextDim = Color3.fromRGB(150, 165, 180),
	Red = Color3.fromRGB(170, 42, 42),
}

local guiRefs = {}
local slotRegistry = {}
local runtimeConnections = {}
local lastInventoryToggleAt = 0
local walkRunIsRunning = true

local function currentBelt()
	return uiState.BeltAssignments[uiState.BeltSet]
end
local INVENTORY_ACTION_PRIORITY = 10000
local PARTY_ACTION_PRIORITY = INVENTORY_ACTION_PRIORITY + 1
local activeDragWindow = nil

local function invokeRemote(remote, ...)
	local ok, a, b = pcall(function(...)
		return remote:InvokeServer(...)
	end, ...)

	if not ok then
		warn("[AetherionGameplayUI] Remote invoke error:", a)
		return false, a
	end

	return true, a, b
end

local function getDefinition(itemId)
	return Weapons[itemId] or ItemDefinitions[itemId]
end

local function isUpgraderItem(item)
	if not item then
		return false
	end

	if item.ItemId == "upgrader" then
		return true
	end

	local def = getDefinition(item.ItemId)

	if not def then
		return false
	end

	return def.SpecialAction == "OpenUpgradeUI"
end

local function isTalicItem(item)
	local def = item and ItemDefinitions[item.ItemId]
	return def and (def.Type == "Talic" or def.UpgradeRole == "Talic")
end

local function isCatalystItem(item)
	local def = item and ItemDefinitions[item.ItemId]
	return def and (def.Type == "UpgradeCatalyst" or def.UpgradeRole == "Catalyst")
end

local function isUpgradeableItem(item)
	local def = item and getDefinition(item.ItemId)
	return def and def.MaxUpgrade ~= nil
end

local function talicAppliesToEquipment(talicItem, equipmentItem)
	local talicDef = talicItem and ItemDefinitions[talicItem.ItemId]
	local equipmentDef = equipmentItem and getDefinition(equipmentItem.ItemId)

	if not talicDef or not equipmentDef then
		return false
	end

	if not talicDef.AppliesTo then
		return true
	end

	local targetGroup = talicDef.AppliesTo
	local groups = {
		Weapon = { Weapon = true },
		Helmet = { Helmet = true },
		Upper = { Upper = true },
		Lower = { Lower = true },
		Gloves = { Gloves = true },
		Boots = { Boots = true },
		Shield = { Shield = true },
		Cloak = { Cloak = true },
		WeaponOrCloak = { Weapon = true, Cloak = true },
		UpperLowerShieldJetpackMelee = { Upper = true, Lower = true, Shield = true, Cloak = true, Weapon = true },
		AllArmor = {
			Helmet = true,
			Upper = true,
			Lower = true,
			Gloves = true,
			Boots = true,
			Shield = true,
			Cloak = true,
		},
		All = {
			Weapon = true,
			Helmet = true,
			Upper = true,
			Lower = true,
			Gloves = true,
			Boots = true,
			Shield = true,
			Cloak = true,
			Ring1 = true, Ring2 = true,
			Amulet1 = true, Amulet2 = true,
		},
	}

	local equipSlot = equipmentDef.EquipSlot or equipmentDef.Slot
	local group = groups[targetGroup]

	if group and group[equipSlot] then
		return true
	end

	return targetGroup == equipmentDef.Category
end

local function getUpgradeSlotLimit(item)
	if not item then
		return 4
	end

	local def = getDefinition(item.ItemId)
	if not def then
		return 4
	end

	return item.Slots or def.SlotMax or 4
end

local function getAssignedTalicCount()
	local count = 0

	for _, key in ipairs({ "Talic1", "Talic2", "Talic3", "Talic4" }) do
		if uiState.UpgradeSlots[key] then
			count += 1
		end
	end

	return count
end

local function clearUpgradeSlotReferences(uid, exceptSlotKey)
	for key, assigned in pairs(uiState.UpgradeSlots) do
		if key ~= exceptSlotKey and assigned and assigned.Uid == uid then
			uiState.UpgradeSlots[key] = nil
		end
	end
end

local function getGradeColor(def)
	if not def then
		return Color3.fromRGB(110, 110, 110)
	end

	local grade = def.Grade

	if grade == "A" then
		return Color3.fromRGB(159, 126, 255)
	elseif grade == "B" then
		return Color3.fromRGB(255, 245, 120)
	elseif grade == "C" then
		return Color3.fromRGB(80, 220, 255)
	elseif grade == "D" then
		return Color3.fromRGB(255, 120, 120)
	elseif grade == "Leon" then
		return Color3.fromRGB(255, 170, 60)
	elseif grade == "Relic" then
		return Color3.fromRGB(255, 90, 90)
	end

	return Color3.fromRGB(180, 180, 180)
end

local function getDisplayName(item)
	if not item then
		return ""
	end

	local def = getDefinition(item.ItemId)
	if def and def.Name then
		return def.Name
	end

	return item.ItemId
end

local function getShortLabel(item)
	local name = getDisplayName(item)
	if #name > 10 then
		return string.sub(name, 1, 10)
	end
	return name
end

local function getItemByUid(uid)
	if not uiState.PlayerData or not uiState.PlayerData.Inventory then
		return nil
	end

	for _, item in ipairs(uiState.PlayerData.Inventory) do
		if item.Uid == uid then
			return item
		end
	end

	return nil
end

local function getEquippedItem(slotKey)
	if not uiState.PlayerData or not uiState.PlayerData.Equipment then
		return nil
	end

	local uid = uiState.PlayerData.Equipment[slotKey]
	if not uid and slotKey == "Upper" then
		uid = uiState.PlayerData.Equipment.Armor
	end

	if not uid then
		return nil
	end

	return getItemByUid(uid)
end

local function getInventoryItemsForCurrentBag()
	local result = {}
	local inventory = uiState.PlayerData and uiState.PlayerData.Inventory or {}
	local startIndex = ((uiState.CurrentBag - 1) * BAG_SIZE) + 1
	local endIndex = startIndex + BAG_SIZE - 1

	for index = startIndex, endIndex do
		table.insert(result, inventory[index])
	end

	return result
end

local function setStatus(message)
	uiState.StatusMessage = tostring(message)

	if guiRefs.StatusLabel then
		guiRefs.StatusLabel.Text = "Status: " .. uiState.StatusMessage
	end
end

local function refreshPlayerData()
	local ok, data = invokeRemote(GetPlayerDataRequest)
	if ok and type(data) == "table" then
		uiState.PlayerData = data
		return true
	end

	setStatus("Failed to get player data")
	return false
end

local function refreshPlayerStats()
	local ok, successFlag, stats = invokeRemote(GetPlayerStatsRequest)
	if ok and successFlag and type(stats) == "table" then
		uiState.PlayerStats = stats
		return true
	end

	setStatus("Failed to get player stats")
	return false
end

local function refreshPartyData()
	local ok, successFlag, partyData = invokeRemote(GetPartyDataRequest)

	if ok and successFlag then
		uiState.PlayerData = uiState.PlayerData or {}
		uiState.PlayerData.Party = partyData
		return true
	end

	return false
end

local function getSelectedPartyTargetName()
	local target = uiState.SelectedPartyTarget

	if target and target.Parent then
		return target.Name
	end

	return "No target"
end

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

local function createStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(80, 80, 90)
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0.62
	stroke.Parent = parent
	return stroke
end

local function makeFrame(parent, name, size, position, color, backgroundTransparency)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = color or RF_THEME.Window
	frame.BackgroundTransparency = backgroundTransparency or 0.08
	frame.BorderSizePixel = 0
	frame.Parent = parent

	createCorner(frame, 2)
	createStroke(frame, RF_THEME.Border, 1)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 39, 48)),
		ColorSequenceKeypoint.new(0.45, color or RF_THEME.Window),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 8, 12)),
	})
	gradient.Rotation = 90
	gradient.Parent = frame

	return frame
end

local function getViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end

	return Vector2.new(1280, 720)
end

local function getAbsolutePanelSize(frame)
	return frame.AbsoluteSize
end

local function clampFrameToViewport(frame, position)
	local viewport = getViewportSize()
	local panelSize = getAbsolutePanelSize(frame)
	local minX = 8
	local minY = 8
	local maxX = math.max(minX, viewport.X - panelSize.X - 8)
	local maxY = math.max(minY, viewport.Y - panelSize.Y - 8)
	local x = math.clamp(position.X.Offset, minX, maxX)
	local y = math.clamp(position.Y.Offset, minY, maxY)

	return UDim2.new(0, x, 0, y)
end

local function makeDraggable(frame, handle)
	handle.Active = true
	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		activeDragWindow = {
			Frame = frame,
			StartMouse = UserInputService:GetMouseLocation(),
			StartPosition = frame.Position,
		}
	end)

	handle.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			and activeDragWindow
			and activeDragWindow.Frame == frame
		then
			activeDragWindow = nil
		end
	end)
end

local function createDragHandle(frame, name, height)
	local handle = Instance.new("TextButton")
	handle.Name = name or "DragHandle"
	handle.Size = UDim2.new(1, -42, 0, height or 34)
	handle.Position = UDim2.new(0, 8, 0, 4)
	handle.BackgroundTransparency = 1
	handle.Text = ""
	handle.AutoButtonColor = false
	handle.ZIndex = 1
	handle.Parent = frame

	makeDraggable(frame, handle)
	return handle
end

local function applyResponsiveScale(frame, minScale, maxScale)
	local scaleObject = frame:FindFirstChild("ResponsiveScale")
	if not scaleObject then
		scaleObject = Instance.new("UIScale")
		scaleObject.Name = "ResponsiveScale"
		scaleObject.Parent = frame
	end

	local viewport = getViewportSize()
	local widthScale = (viewport.X * 0.86) / frame.Size.X.Offset
	local heightScale = (viewport.Y * 0.78) / frame.Size.Y.Offset
	scaleObject.Scale = math.clamp(math.min(widthScale, heightScale, maxScale or 1), minScale or 0.72, maxScale or 1)

	frame.Position = clampFrameToViewport(frame, frame.Position)
	return scaleObject.Scale
end

local function makeLabel(parent, text, size, position, textSize, bold)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = size
	label.Position = position
	label.Text = text or ""
	label.TextColor3 = Color3.fromRGB(230, 230, 230)
	label.TextSize = textSize or 14
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local function makeButton(parent, text, size, position)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.Text = text
	button.TextColor3 = RF_THEME.Text
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.BackgroundColor3 = RF_THEME.PanelLight
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Parent = parent

	createCorner(button, 2)
	createStroke(button, RF_THEME.Border, 1)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(62, 73, 86)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 27, 34)),
	})
	gradient.Rotation = 90
	gradient.Parent = button

	return button
end

local function makeTextBox(parent, placeholder, size, position)
	local box = Instance.new("TextBox")
	box.Size = size
	box.Position = position
	box.PlaceholderText = placeholder
	box.Text = ""
	box.ClearTextOnFocus = false
	box.TextColor3 = Color3.fromRGB(240, 240, 240)
	box.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	box.TextSize = 13
	box.Font = Enum.Font.Gotham
	box.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	box.BorderSizePixel = 0
	box.Parent = parent
	createCorner(box, 6)
	createStroke(box, Color3.fromRGB(80, 80, 90), 1)
	return box
end

local function createBar(parent, title, position, barColor)
	local container = Instance.new("Frame")
	container.BackgroundTransparency = 1
	container.Size = UDim2.new(0, 250, 0, 25)
	container.Position = position
	container.Parent = parent

	local titleLabel = makeLabel(container, title, UDim2.new(0, 38, 0, 18), UDim2.new(0, 0, 0, 0), 12, true)
	titleLabel.TextColor3 = RF_THEME.TextDim

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(0, 190, 0, 10)
	bg.Position = UDim2.new(0, 46, 0, 4)
	bg.BackgroundColor3 = Color3.fromRGB(5, 6, 8)
	bg.BorderSizePixel = 0
	bg.Parent = container
	createCorner(bg, 1)
	createStroke(bg, Color3.fromRGB(80, 80, 85), 1)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = barColor
	fill.BorderSizePixel = 0
	fill.Parent = bg
	createCorner(fill, 1)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, barColor),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.45),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Rotation = 90
	gradient.Parent = fill

	local valueLabel = makeLabel(container, "0 / 0", UDim2.new(0, 190, 0, 16), UDim2.new(0, 46, 0, 12), 10, false)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Center
	valueLabel.TextColor3 = RF_THEME.Text

	return {
		Container = container,
		Title = titleLabel,
		Background = bg,
		Fill = fill,
		Value = valueLabel,
	}
end

local function getTooltipText(item)
	if not item then
		return ""
	end

	local def = getDefinition(item.ItemId)
	if not def then
		return item.ItemId
	end

	local lines = {}

	table.insert(lines, tostring(def.Name or item.ItemId))

	if def.Grade then
		table.insert(lines, "Grade: " .. tostring(def.Grade))
	end

	if def.GradeDisplayName then
		table.insert(lines, "Grade Name: " .. tostring(def.GradeDisplayName))
	end

	if def.WeaponType then
		table.insert(lines, "Type: " .. tostring(def.WeaponType))
	end

	if def.RequiredLevel then
		table.insert(lines, "Required Level: " .. tostring(def.RequiredLevel))
	end

	if def.FactionId then
		table.insert(lines, "Race: " .. tostring(def.FactionId))
	end

	if def.RequiredPT and def.RequiredPT.Type then
		table.insert(
			lines,
			"Required Skill: " .. tostring(def.RequiredPT.Type) .. " " .. tostring(def.RequiredPT.Level)
		)
	end

	if def.AttackMin or def.AttackMax then
		table.insert(lines, "Attack: " .. tostring(def.AttackMin or 0) .. " - " .. tostring(def.AttackMax or 0))
	end

	if def.ForceAttackMin or def.ForceAttackMax then
		table.insert(
			lines,
			"Force Attack: " .. tostring(def.ForceAttackMin or 0) .. " - " .. tostring(def.ForceAttackMax or 0)
		)
	end

	if def.Defense then
		table.insert(lines, "Defense: " .. tostring(def.Defense))
	end

	if def.Element then
		table.insert(lines, "Element: " .. tostring(def.Element))
	end

	if def.SpecialEffectText and def.SpecialEffectText ~= "" then
		table.insert(lines, "Special Effects: " .. tostring(def.SpecialEffectText))
	end

	if def.AbilityId then
		table.insert(lines, "Ability: " .. tostring(def.AbilityId))
	end

	if def.SlotMax then
		table.insert(lines, "Upgrade Slots: " .. tostring(def.SlotMax))
	end

	if item.UpgradeLevel then
		table.insert(lines, "Current Upgrade: +" .. tostring(item.UpgradeLevel))
	end

	if item.InstalledTalics and #item.InstalledTalics > 0 then
		table.insert(lines, "Installed Talics:")

		for _, installed in ipairs(item.InstalledTalics) do
			table.insert(lines, "- " .. tostring(installed.TalicId or "Talic"))
		end
	end

	return table.concat(lines, "\n")
end

local function ensureTooltip()
	if guiRefs.TooltipFrame then
		return
	end

	local tooltipFrame = makeFrame(
		guiRefs.ScreenGui,
		"TooltipFrame",
		UDim2.new(0, 260, 0, 220),
		UDim2.new(0, 0, 0, 0),
		Color3.fromRGB(8, 12, 24)
	)
	tooltipFrame.Visible = false
	tooltipFrame.ZIndex = 50

	local tooltipText = Instance.new("TextLabel")
	tooltipText.Name = "TooltipText"
	tooltipText.Size = UDim2.new(1, -12, 1, -12)
	tooltipText.Position = UDim2.new(0, 6, 0, 6)
	tooltipText.BackgroundTransparency = 1
	tooltipText.TextColor3 = Color3.fromRGB(240, 240, 240)
	tooltipText.TextXAlignment = Enum.TextXAlignment.Left
	tooltipText.TextYAlignment = Enum.TextYAlignment.Top
	tooltipText.TextWrapped = true
	tooltipText.Font = Enum.Font.Code
	tooltipText.TextSize = 13
	tooltipText.Text = ""
	tooltipText.Parent = tooltipFrame
	tooltipText.ZIndex = 51

	guiRefs.TooltipFrame = tooltipFrame
	guiRefs.TooltipText = tooltipText
end

local function showTooltip(item)
	ensureTooltip()

	if not item then
		guiRefs.TooltipFrame.Visible = false
		return
	end

	guiRefs.TooltipText.Text = getTooltipText(item)
	guiRefs.TooltipFrame.Visible = true
	uiState.HoveredTooltipItem = item
end

local function hideTooltip()
	if guiRefs.TooltipFrame then
		guiRefs.TooltipFrame.Visible = false
	end
	uiState.HoveredTooltipItem = nil
end

local function createSlot(parent, slotName, size, position)
	local button = Instance.new("TextButton")
	button.Name = slotName
	button.Size = size
	button.Position = position
	button.Text = ""
	button.AutoButtonColor = false
	button.BackgroundColor3 = RF_THEME.Slot
	button.BackgroundTransparency = 0.18
	button.BorderSizePixel = 0
	button.Parent = parent

	createCorner(button, 1)
	local outerStroke = createStroke(button, RF_THEME.Border, 1)
	outerStroke.Transparency = 0.78

	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.new(1, -6, 1, -6)
	inner.Position = UDim2.new(0, 3, 0, 3)
	inner.BackgroundColor3 = Color3.fromRGB(17, 21, 28)
	inner.BackgroundTransparency = 0.22
	inner.BorderSizePixel = 0
	inner.Parent = button

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.fromRGB(35, 43, 55)
	innerStroke.Thickness = 1
	innerStroke.Transparency = 0.82
	innerStroke.Parent = inner

	local icon = Instance.new("TextLabel")
	icon.Name = "ItemName"
	icon.Size = UDim2.new(1, -8, 1, -18)
	icon.Position = UDim2.new(0, 4, 0, 4)
	icon.BackgroundTransparency = 1
	icon.Text = ""
	icon.TextWrapped = true
	icon.TextScaled = false
	icon.TextSize = 9
	icon.Font = Enum.Font.GothamBold
	icon.TextColor3 = RF_THEME.Text
	icon.Parent = button

	local qty = Instance.new("TextLabel")
	qty.Name = "BottomText"
	qty.Size = UDim2.new(1, -6, 0, 12)
	qty.Position = UDim2.new(0, 3, 1, -14)
	qty.BackgroundTransparency = 1
	qty.Text = ""
	qty.TextScaled = false
	qty.TextSize = 10
	qty.Font = Enum.Font.Gotham
	qty.TextColor3 = RF_THEME.Gold
	qty.TextXAlignment = Enum.TextXAlignment.Right
	qty.Parent = button

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = RF_THEME.SlotHover
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = RF_THEME.Slot
	end)

	return button
end

local function beginDrag(sourceMeta, item)
	if not item then
		return
	end

	if uiState.DragVisual then
		uiState.DragVisual:Destroy()
		uiState.DragVisual = nil
	end

	uiState.DraggedItem = item
	uiState.DraggedSource = sourceMeta

	local dragVisual = makeFrame(
		guiRefs.ScreenGui,
		"DragVisual",
		UDim2.new(0, 70, 0, 70),
		UDim2.new(0, 0, 0, 0),
		Color3.fromRGB(35, 35, 40)
	)
	dragVisual.BackgroundTransparency = 0.15
	dragVisual.ZIndex = 100

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -6, 1, -6)
	textLabel.Position = UDim2.new(0, 3, 0, 3)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = getShortLabel(item)
	textLabel.TextWrapped = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 11
	textLabel.ZIndex = 101
	textLabel.Parent = dragVisual

	uiState.DragVisual = dragVisual
end

local function registerSlot(button, meta)
	slotRegistry[button] = meta

	button.MouseEnter:Connect(function()
		local item = meta.GetItem and meta.GetItem() or nil
		if item then
			showTooltip(item)
		end
	end)

	button.MouseLeave:Connect(function()
		hideTooltip()
	end)

	button.MouseButton2Click:Connect(function()
		local item = meta.GetItem and meta.GetItem() or nil
		if not item then
			return
		end

		if meta.Kind == "Inventory" then
			if isUpgraderItem(item) then
				uiState.UpgradeOpen = true

				if guiRefs.UpgradeFrame then
					guiRefs.UpgradeFrame.Visible = true
				end

				setStatus("Upgrader opened")
				AetherionGameplayUI.Render()
				return
			end

			local ok, successFlag, result = invokeRemote(EquipItemRequest, item.Uid)
			if ok and successFlag then
				setStatus("Equipped " .. getDisplayName(item))
				refreshPlayerData()
				refreshPlayerStats()
				AetherionGameplayUI.Render()
			else
				setStatus(result or "Equip failed")
			end
		elseif meta.Kind == "Upgrade" then
			uiState.UpgradeSlots[meta.SlotKey] = nil
			AetherionGameplayUI.Render()
		elseif meta.Kind == "Hotbar" then
			currentBelt()[meta.Index] = nil
			AetherionGameplayUI.Render()
		end
	end)

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local item = meta.GetItem and meta.GetItem() or nil
			if item then
				beginDrag(meta, item)
			end
		end
	end)
end

local function resolveDropTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local objects = player.PlayerGui:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)

	for _, object in ipairs(objects) do
		if slotRegistry[object] then
			return slotRegistry[object]
		end
	end

	return nil
end

local function slotAcceptsItem(slotKey, item)
	local def = getDefinition(item.ItemId)
	if not def then
		return false
	end

	local equipSlot = def.EquipSlot or def.Slot

	-- Ring1/Ring2: terima item dengan EquipSlot = slotKey spesifik ATAU generic "Ring"
	if slotKey == "Ring1" or slotKey == "Ring2" then
		return equipSlot == slotKey or equipSlot == "Ring"
	end

	-- Amulet1/Amulet2: terima item dengan EquipSlot = slotKey spesifik ATAU generic "Amulet"
	if slotKey == "Amulet1" or slotKey == "Amulet2" then
		return equipSlot == slotKey or equipSlot == "Amulet"
	end

	return equipSlot == slotKey
end

local function upgradeSlotAcceptsItem(slotKey, item)
	if slotKey == "Equipment" then
		return isUpgradeableItem(item), "Only upgradeable equipment can be placed here"
	end

	if slotKey == "Catalyst" then
		return isCatalystItem(item), "Only catalyst items can be placed here"
	end

	if string.sub(slotKey, 1, 5) == "Talic" then
		if not isTalicItem(item) then
			return false, "Only talic items can be placed here"
		end

		local equipment = uiState.UpgradeSlots.Equipment

		if not equipment then
			return false, "Place equipment first"
		end

		if not talicAppliesToEquipment(item, equipment) then
			return false, "Talic cannot be used on this item"
		end

		local slotLimit = getUpgradeSlotLimit(equipment)
		local currentTalics = getAssignedTalicCount()

		if not uiState.UpgradeSlots[slotKey] then
			currentTalics += 1
		end

		if currentTalics > slotLimit then
			return false, "Equipment only has " .. tostring(slotLimit) .. " upgrade slots"
		end

		return true
	end

	return false, "Unknown upgrade slot"
end

local function handleDrop(sourceMeta, targetMeta)
	local item = uiState.DraggedItem
	if not item then
		return
	end

	if not targetMeta then
		return
	end

	if targetMeta.Kind == "Equipment" then
		if not slotAcceptsItem(targetMeta.SlotKey, item) then
			setStatus("Item cannot be equipped in " .. targetMeta.SlotKey)
			return
		end

		local ok, successFlag, result = invokeRemote(EquipItemRequest, item.Uid)

		if ok and successFlag then
			setStatus("Equipped " .. getDisplayName(item))
			refreshPlayerData()
			refreshPlayerStats()
			AetherionGameplayUI.Render()
		else
			setStatus(result or "Equip failed")
		end

		return
	end

	if targetMeta.Kind == "Hotbar" then
		currentBelt()[targetMeta.Index] = {
			Uid = item.Uid,
			ItemId = item.ItemId,
		}
		setStatus("Belt " .. uiState.BeltSet .. " slot " .. tostring(targetMeta.Index) .. " assigned")
		AetherionGameplayUI.Render()
		return
	end

	if targetMeta.Kind == "Upgrade" then
		local accepts, reason = upgradeSlotAcceptsItem(targetMeta.SlotKey, item)

		if not accepts then
			setStatus(reason)
			return
		end

		if targetMeta.SlotKey == "Equipment" then
			for _, key in ipairs({ "Talic1", "Talic2", "Talic3", "Talic4" }) do
				uiState.UpgradeSlots[key] = nil
			end
		elseif targetMeta.SlotKey == "Catalyst" then
			clearUpgradeSlotReferences(item.Uid, targetMeta.SlotKey)
		end

		uiState.UpgradeSlots[targetMeta.SlotKey] = {
			Uid = item.Uid,
			ItemId = item.ItemId,
		}
		setStatus("Placed " .. getDisplayName(item) .. " into upgrade slot")
		AetherionGameplayUI.Render()
		return
	end
end

local function endDrag()
	if uiState.DragVisual then
		uiState.DragVisual:Destroy()
		uiState.DragVisual = nil
	end

	if uiState.DraggedItem then
		local targetMeta = resolveDropTarget()
		handleDrop(uiState.DraggedSource, targetMeta)
	end

	uiState.DraggedItem = nil
	uiState.DraggedSource = nil
end

local function clearChildren(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
end

local function renderSlotVisual(button, item, placeholderText)
	local icon = button:FindFirstChild("ItemName")
	local bottomText = button:FindFirstChild("BottomText")
	local stroke = button:FindFirstChildOfClass("UIStroke")

	if not item then
		icon.Text = placeholderText or ""
		icon.TextColor3 = Color3.fromRGB(120, 120, 130)
		bottomText.Text = ""
		stroke.Color = Color3.fromRGB(85, 85, 95)
		stroke.Transparency = 0.82
		return
	end

	local def = getDefinition(item.ItemId)

	icon.Text = getShortLabel(item)
	icon.TextColor3 = Color3.fromRGB(240, 240, 240)

	if item.UpgradeLevel and item.UpgradeLevel > 0 then
		bottomText.Text = "+" .. tostring(item.UpgradeLevel)
	elseif item.Quantity and item.Quantity > 1 then
		bottomText.Text = "x" .. tostring(item.Quantity)
	else
		bottomText.Text = ""
	end

	stroke.Color = getGradeColor(def)
	stroke.Transparency = 0.48
end

local function buildHUD()
	local hud = guiRefs.HUDFrame
	local data = uiState.PlayerData or {}
	local stats = uiState.PlayerStats or {}

	guiRefs.LevelLabel.Text = tostring(data.Level or 1)

	local baseMaxHP = (data.Stats and data.Stats.MaxHP) or 150
	local baseMaxFP = (data.Stats and data.Stats.MaxFP) or 100
	local maxHP = baseMaxHP + (stats.MaxHP or 0)
	local maxFP = baseMaxFP + (stats.MaxFP or 0)
	local currentHP = math.min((data.Stats and data.Stats.HP) or maxHP, maxHP)
	local currentFP = math.min((data.Stats and data.Stats.FP) or maxFP, maxFP)
	local currentSP = (data.Stats and data.Stats.SP) or 100
	local maxSP = (data.Stats and data.Stats.MaxSP) or 100

	local function applyBar(barRef, current, max)
		local ratio = 0
		if max > 0 then
			ratio = math.clamp(current / max, 0, 1)
		end

		barRef.Fill.Size = UDim2.new(ratio, 0, 1, 0)
		barRef.Value.Text = tostring(math.floor(current)) .. " / " .. tostring(math.floor(max))
	end

	applyBar(guiRefs.HPBar, currentHP, maxHP)
	applyBar(guiRefs.FPBar, currentFP, maxFP)
	applyBar(guiRefs.SPBar, currentSP, maxSP)

	local pvpStats = data.Pvp or {}
	guiRefs.KillLabel.Text = "Kill " .. tostring(pvpStats.Kill or 0)
	guiRefs.DeathLabel.Text = "Death " .. tostring(pvpStats.Death or 0)
	guiRefs.TempPvpLabel.Text = "PvP Sementara " .. tostring(pvpStats.TempPoints or 0)
	guiRefs.CertainPvpLabel.Text = "Point Tertentu " .. tostring(pvpStats.CertainPoints or 0)
	guiRefs.GoldPointLabel.Text = "Point Emas " .. tostring(pvpStats.GoldPoints or 0)

	local currencies = data.Currencies or {}
	guiRefs.MoneyLabel.Text = "CP " .. tostring(currencies.CP or 0) .. "   Gold " .. tostring(currencies.Gold or 0)

	-- Battle Mode: aktif jika terakhir diserang/menyerang < 15 detik
	if guiRefs.BattleModeLabel then
		local now = tick()
		local inBattle = (now - uiState.LastBattleTick) < 15
		uiState.BattleMode = inBattle
		if inBattle then
			guiRefs.BattleModeLabel.Text = "COMBAT"
			guiRefs.BattleModeLabel.TextColor3 = Color3.fromRGB(220, 60, 60)
		else
			guiRefs.BattleModeLabel.Text = "PEACE"
			guiRefs.BattleModeLabel.TextColor3 = Color3.fromRGB(100, 200, 100)
		end
	end

end

local function getPartyMembers()
	local data = uiState.PlayerData or {}
	local party = data.Party
	local members = {}

	if type(party) == "table" and type(party.Members) == "table" then
		for _, member in ipairs(party.Members) do
			table.insert(members, member)
		end
	end

	if #members == 0 then
		table.insert(members, {
			Name = data.Name or player.Name,
			Level = data.Level or 1,
			Role = data.StartingClassId or "Leader",
			IsLeader = true,
			HP = (data.Stats and data.Stats.HP) or 150,
			MaxHP = (data.Stats and data.Stats.MaxHP) or 150,
			FP = (data.Stats and data.Stats.FP) or 100,
			MaxFP = (data.Stats and data.Stats.MaxFP) or 100,
		})
	end

	return members
end

local function buildPartyUI()
	local frame = guiRefs.PartyFrame
	frame.Visible = uiState.PartyOpen

	if not frame.Visible then
		return
	end

	clearChildren(guiRefs.PartyContent)

	local members = getPartyMembers()
	local capacity = 8
	local party = (uiState.PlayerData and uiState.PlayerData.Party) or {}

	guiRefs.PartyTitle.Text = "Party " .. tostring(#members) .. "/" .. tostring(capacity)

	if guiRefs.PartyTargetLabel then
		guiRefs.PartyTargetLabel.Text = "Target: " .. getSelectedPartyTargetName()
	end

	if guiRefs.PartyLockButton then
		guiRefs.PartyLockButton.Text = party.Locked and "Locked" or "Lock"
	end

	for index = 1, capacity do
		local member = members[index]
		local row = Instance.new("Frame")
		row.Name = "MemberRow" .. tostring(index)
		row.Size = UDim2.new(1, -12, 0, 28)
		row.Position = UDim2.new(0, 6, 0, (index - 1) * 31)
		row.BackgroundColor3 = member and Color3.fromRGB(18, 22, 28) or Color3.fromRGB(12, 15, 19)
		row.BorderSizePixel = 0
		row.Parent = guiRefs.PartyContent
		createCorner(row, 2)
		createStroke(row, member and Color3.fromRGB(124, 139, 154) or Color3.fromRGB(66, 73, 82), 1)

		if member then
			local nameLabel = makeLabel(
				row,
				tostring(member.Name or "Unknown") .. "  Lv" .. tostring(member.Level or 1),
				UDim2.new(1, -14, 0, 12),
				UDim2.new(0, 8, 0, 3),
				11,
				true
			)
			nameLabel.TextColor3 = Color3.fromRGB(236, 241, 246)

			local roleLabel = makeLabel(
				row,
				tostring(member.Role or "Member"),
				UDim2.new(0, 95, 0, 11),
				UDim2.new(1, -103, 0, 3),
				9,
				false
			)
			roleLabel.TextXAlignment = Enum.TextXAlignment.Right
			roleLabel.TextColor3 = Color3.fromRGB(183, 170, 255)

			local hpRatio = 0
			local fpRatio = 0

			if member.MaxHP and member.MaxHP > 0 then
				hpRatio = math.clamp((member.HP or member.MaxHP) / member.MaxHP, 0, 1)
			end

			if member.MaxFP and member.MaxFP > 0 then
				fpRatio = math.clamp((member.FP or member.MaxFP) / member.MaxFP, 0, 1)
			end

			local hpBar = Instance.new("Frame")
			hpBar.Size = UDim2.new(0, 72, 0, 4)
			hpBar.Position = UDim2.new(0, 8, 1, -10)
			hpBar.BackgroundColor3 = Color3.fromRGB(55, 18, 18)
			hpBar.BorderSizePixel = 0
			hpBar.Parent = row
			createCorner(hpBar, 1)

			local hpFill = Instance.new("Frame")
			hpFill.Size = UDim2.new(hpRatio, 0, 1, 0)
			hpFill.BackgroundColor3 = Color3.fromRGB(210, 63, 63)
			hpFill.BorderSizePixel = 0
			hpFill.Parent = hpBar
			createCorner(hpFill, 1)

			local fpBar = Instance.new("Frame")
			fpBar.Size = UDim2.new(0, 72, 0, 4)
			fpBar.Position = UDim2.new(0, 8, 1, -4)
			fpBar.BackgroundColor3 = Color3.fromRGB(17, 28, 55)
			fpBar.BorderSizePixel = 0
			fpBar.Parent = row
			createCorner(fpBar, 1)

			local fpFill = Instance.new("Frame")
			fpFill.Size = UDim2.new(fpRatio, 0, 1, 0)
			fpFill.BackgroundColor3 = Color3.fromRGB(79, 124, 223)
			fpFill.BorderSizePixel = 0
			fpFill.Parent = fpBar
			createCorner(fpFill, 1)
		else
			local emptyLabel = makeLabel(row, "Empty Slot", UDim2.new(1, -14, 1, 0), UDim2.new(0, 8, 0, 0), 11, false)
			emptyLabel.TextColor3 = Color3.fromRGB(108, 116, 124)
		end
	end
end

local function formatEquipmentStat(value, formatKind)
	value = tonumber(value or 0) or 0

	if formatKind == "percent" then
		return tostring(math.floor(value * 100 + 0.5)) .. "%"
	end

	return tostring(math.floor(value))
end

local function buildEquipmentStats(parent)
	local stats = uiState.PlayerStats or {}

	local statFrame = Instance.new("Frame")
	statFrame.Name = "EquipmentStats"
	statFrame.Size = UDim2.new(0, 202, 0, 82)
	statFrame.Position = UDim2.new(0, 0, 0, 352)
	statFrame.BackgroundColor3 = Color3.fromRGB(11, 15, 20)
	statFrame.BorderSizePixel = 0
	statFrame.Parent = parent
	createCorner(statFrame, 2)
	createStroke(statFrame, Color3.fromRGB(68, 82, 96), 1)

	local title = makeLabel(statFrame, "COMBAT", UDim2.new(1, -12, 0, 16), UDim2.new(0, 6, 0, 4), 10, true)
	title.TextColor3 = RF_THEME.Gold
	title.TextXAlignment = Enum.TextXAlignment.Center

	for index, rowInfo in ipairs(EQUIPMENT_STAT_ROWS) do
		local column = (index - 1) % 2
		local row = math.floor((index - 1) / 2)
		local rowFrame = Instance.new("Frame")
		rowFrame.Name = rowInfo.Key .. "Row"
		rowFrame.Size = UDim2.new(0, 92, 0, 13)
		rowFrame.Position = UDim2.new(0, 7 + (column * 96), 0, 23 + (row * 14))
		rowFrame.BackgroundTransparency = 1
		rowFrame.Parent = statFrame

		local label = makeLabel(rowFrame, rowInfo.Label, UDim2.new(0, 42, 1, 0), UDim2.new(0, 0, 0, 0), 9, false)
		label.TextColor3 = RF_THEME.TextDim

		local valueLabel = makeLabel(
			rowFrame,
			formatEquipmentStat(stats[rowInfo.Key], rowInfo.Format),
			UDim2.new(0, 46, 1, 0),
			UDim2.new(1, -46, 0, 0),
			9,
			true
		)
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.TextColor3 = RF_THEME.Text
	end
end

local function buildInventory()
	local inventoryFrame = guiRefs.InventoryFrame
	inventoryFrame.Visible = uiState.InventoryOpen

	if not inventoryFrame.Visible then
		return
	end

	clearChildren(guiRefs.InventoryGrid)
	clearChildren(guiRefs.EquipmentGrid)
	slotRegistry = {}

	local bagItems = getInventoryItemsForCurrentBag()

	for slotIndex = 1, BAG_SIZE do
		local row = math.floor((slotIndex - 1) / 4)
		local col = (slotIndex - 1) % 4

		local slotButton = createSlot(
			guiRefs.InventoryGrid,
			"InvSlot" .. tostring(slotIndex),
			UDim2.new(0, 54, 0, 54),
			UDim2.new(0, col * 58, 0, row * 58)
		)

		local item = bagItems[slotIndex]
		renderSlotVisual(slotButton, item, "")
		registerSlot(slotButton, {
			Kind = "Inventory",
			Index = slotIndex,
			GetItem = function()
				return item
			end,
		})
	end

	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "EquipmentSilhouette"
	avatarFrame.Size = UDim2.new(0, 64, 0, 108)
	avatarFrame.Position = UDim2.new(0, 69, 0, 184)
	avatarFrame.BackgroundColor3 = Color3.fromRGB(14, 18, 24)
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = guiRefs.EquipmentGrid
	createCorner(avatarFrame, 2)
	createStroke(avatarFrame, Color3.fromRGB(58, 70, 82), 1)

	local avatarName = makeLabel(avatarFrame, "GEAR", UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 0, 8), 10, true)
	avatarName.TextColor3 = Color3.fromRGB(122, 153, 188)
	avatarName.TextXAlignment = Enum.TextXAlignment.Center

	local factionText = tostring((uiState.PlayerData and uiState.PlayerData.FactionId) or "-")
	local factionLabel = makeLabel(avatarFrame, factionText, UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 0, 36), 9, false)
	factionLabel.TextColor3 = RF_THEME.TextDim
	factionLabel.TextXAlignment = Enum.TextXAlignment.Center

	for _, slotInfo in ipairs(EQUIPMENT_PANEL_SLOTS) do
		local slotButton = createSlot(
			guiRefs.EquipmentGrid,
			slotInfo.Key,
			UDim2.new(0, 54, 0, 54),
			UDim2.new(0, slotInfo.X, 0, slotInfo.Y)
		)

		local equippedItem = getEquippedItem(slotInfo.Key)
		renderSlotVisual(slotButton, equippedItem, slotInfo.Label)

		registerSlot(slotButton, {
			Kind = "Equipment",
			SlotKey = slotInfo.Key,
			GetItem = function()
				return getEquippedItem(slotInfo.Key)
			end,
		})
	end

	buildEquipmentStats(guiRefs.EquipmentGrid)

	for index, button in ipairs(guiRefs.BagButtons) do
		if index == uiState.CurrentBag then
			button.BackgroundColor3 = Color3.fromRGB(80, 110, 180)
		else
			button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		end
	end
end

local function buildUpgradeUI()
	local frame = guiRefs.UpgradeFrame
	frame.Visible = uiState.UpgradeOpen

	if not frame.Visible then
		return
	end

	clearChildren(guiRefs.UpgradeSlotContainer)
	slotRegistry = slotRegistry or {}

	local slotLayout = {
		{ Key = "Equipment", Label = "Equipment", X = 70, Y = 60, Size = 64 },
		{ Key = "Talic1", Label = "Talic 1", X = 16, Y = 22, Size = 44 },
		{ Key = "Talic2", Label = "Talic 2", X = 176, Y = 22, Size = 44 },
		{ Key = "Talic3", Label = "Talic 3", X = 16, Y = 138, Size = 44 },
		{ Key = "Talic4", Label = "Talic 4", X = 176, Y = 138, Size = 44 },
		{ Key = "Catalyst", Label = "Catalyst", X = 176, Y = 80, Size = 44 },
	}

	for _, slotInfo in ipairs(slotLayout) do
		local slotButton = createSlot(
			guiRefs.UpgradeSlotContainer,
			slotInfo.Key,
			UDim2.new(0, slotInfo.Size, 0, slotInfo.Size),
			UDim2.new(0, slotInfo.X, 0, slotInfo.Y)
		)

		local assigned = uiState.UpgradeSlots[slotInfo.Key]
		renderSlotVisual(slotButton, assigned, slotInfo.Label)

		registerSlot(slotButton, {
			Kind = "Upgrade",
			SlotKey = slotInfo.Key,
			GetItem = function()
				return uiState.UpgradeSlots[slotInfo.Key]
			end,
		})
	end
end

local function buildHotbar()
	clearChildren(guiRefs.HotbarSlots)
	slotRegistry = slotRegistry or {}

	-- Update belt set indicator
	if guiRefs.BeltSetLabel then
		guiRefs.BeltSetLabel.Text = uiState.BeltSet .. "/5"
	end

	for index = 1, HOTBAR_SIZE do
		local slotButton = createSlot(
			guiRefs.HotbarSlots,
			"Hotbar" .. tostring(index),
			UDim2.new(0, 38, 0, 38),
			UDim2.new(0, (index - 1) * 42, 0, 0)
		)
		slotButton.BackgroundTransparency = 0.32

		local inner = slotButton:FindFirstChild("Inner")
		if inner then
			inner.BackgroundTransparency = 0.36
		end

		local stroke = slotButton:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Transparency = 0.86
		end

		local assigned = currentBelt()[index]
		renderSlotVisual(slotButton, assigned, tostring(index % 10))

		registerSlot(slotButton, {
			Kind = "Hotbar",
			Index = index,
			GetItem = function()
				return currentBelt()[index]
			end,
		})
	end
end

function AetherionGameplayUI.Render()
	if not guiRefs.ScreenGui then
		return
	end

	if guiRefs.InventoryFrame then
		applyResponsiveScale(guiRefs.InventoryFrame, 0.68, 0.86)
	end

	if guiRefs.UpgradeFrame then
		applyResponsiveScale(guiRefs.UpgradeFrame, 0.78, 0.95)
	end

	buildHUD()
	buildInventory()
	buildPartyUI()
	buildUpgradeUI()
	buildHotbar()

	if guiRefs.StatusLabel then
		guiRefs.StatusLabel.Text = "Status: " .. uiState.StatusMessage
	end
end

local function performUpgrade()
	local equipment = uiState.UpgradeSlots.Equipment
	if not equipment then
		setStatus("Put equipment into upgrade slot first")
		return
	end

	local talicUids = {}

	for _, key in ipairs({ "Talic1", "Talic2", "Talic3", "Talic4" }) do
		local talic = uiState.UpgradeSlots[key]

		if talic then
			table.insert(talicUids, talic.Uid)
		end
	end

	if #talicUids <= 0 then
		setStatus("Put at least one talic into upgrade slot")
		return
	end

	local slotLimit = getUpgradeSlotLimit(equipment)

	if #talicUids > slotLimit then
		setStatus("Equipment only has " .. tostring(slotLimit) .. " upgrade slots")
		return
	end

	local catalyst = uiState.UpgradeSlots.Catalyst
	local catalystUid = catalyst and catalyst.Uid or nil

	local ok, successFlag, result = invokeRemote(UpgradeItemRequest, equipment.Uid, talicUids, catalystUid)
	if ok and successFlag then
		setStatus("Upgrade " .. tostring(result.Result or "done"))
		uiState.UpgradeSlots.Talic1 = nil
		uiState.UpgradeSlots.Talic2 = nil
		uiState.UpgradeSlots.Talic3 = nil
		uiState.UpgradeSlots.Talic4 = nil
		uiState.UpgradeSlots.Catalyst = nil
		refreshPlayerData()
		refreshPlayerStats()
		AetherionGameplayUI.Render()
	else
		setStatus(result or "Upgrade failed")
	end
end

local function toggleInventory()
	uiState.InventoryOpen = not uiState.InventoryOpen

	if guiRefs.InventoryFrame then
		guiRefs.InventoryFrame.Visible = uiState.InventoryOpen
	end

	setStatus("Inventory " .. (uiState.InventoryOpen and "opened" or "closed"))
	AetherionGameplayUI.Render()
end

local function toggleParty()
	uiState.PartyOpen = not uiState.PartyOpen

	if guiRefs.PartyFrame then
		guiRefs.PartyFrame.Visible = uiState.PartyOpen
	end

	refreshPartyData()
	setStatus("Party " .. (uiState.PartyOpen and "opened" or "closed"))
	AetherionGameplayUI.Render()
end

-- ============================================================
-- Belt helpers
-- ============================================================

local function cycleBeltSet()
	uiState.BeltSet = (uiState.BeltSet % 5) + 1
	setStatus("Belt Set " .. uiState.BeltSet .. " / 5")
	AetherionGameplayUI.Render()
end

local function executeBeltSlot(index)
	local belt = currentBelt()
	local assigned = belt[index]

	if not assigned then
		setStatus("Belt slot " .. index .. " is empty")
		return
	end

	if assigned.SkillId then
		local ok, result = invokeRemote(CastSkillRequest, assigned.SkillId, nil)
		if ok then
			setStatus("Skill: " .. tostring(assigned.SkillId))
		else
			setStatus("Cast failed: " .. tostring(result))
		end
	elseif assigned.ItemId then
		local ok, success, msg = invokeRemote(UseItemRequest, assigned.Uid)
		if ok and success then
			setStatus("Used: " .. tostring(assigned.ItemId))
			refreshPlayerData()
			AetherionGameplayUI.Render()
		else
			setStatus(tostring(msg) or "Cannot use item")
		end
	end
end

-- ============================================================
-- Macro helpers
-- ============================================================

local function fetchMacros()
	local ok, success, data = invokeRemote(GetMacrosRequest)
	if ok and success and data then
		uiState.MacroData = data
	end
end

local function refreshMacroWindow()
	if not guiRefs.MacroRows then return end
	fetchMacros()
	local data = uiState.MacroData
	if not data then return end

	for i = 1, 9 do
		local macro = data[i]
		local row = guiRefs.MacroRows[i]
		if row and macro then
			local skills = macro.Skills or {}
			local preview = table.concat(skills, " → ")
			if preview == "" then preview = "(empty)" end
			row.NameLabel.Text = preview
			row.NameLabel.TextColor3 = #skills > 0 and RF_THEME.Text or RF_THEME.TextDim
		end
	end
end

local function executeMacro(slotIndex)
	local ok, success, result = invokeRemote(ExecuteMacroRequest, slotIndex, nil)
	if ok and success and result then
		setStatus("Macro F" .. slotIndex .. ": " .. tostring(result.MacroSkillId or "?"))
	elseif ok and not success then
		setStatus("Macro F" .. slotIndex .. ": " .. tostring(result or "empty"))
	end
end

local function toggleMacroWindow()
	uiState.MacroOpen = not uiState.MacroOpen
	if guiRefs.MacroFrame then
		guiRefs.MacroFrame.Visible = uiState.MacroOpen
		if uiState.MacroOpen then
			refreshMacroWindow()
		end
	end
	setStatus("Macro " .. (uiState.MacroOpen and "opened" or "closed"))
end

-- ============================================================
-- Character window helpers
-- ============================================================

local CHAR_STAT_ROWS = {
	{ Key = "Attack",      Label = "ATK" },
	{ Key = "ForceAttack", Label = "FORCE" },
	{ Key = "Defense",     Label = "DEF" },
	{ Key = "Accuracy",    Label = "ACC" },
	{ Key = "Dodge",       Label = "DODGE" },
	{ Key = "CritChance",  Label = "CRIT",  Pct = true },
	{ Key = "MaxHP",       Label = "MAX HP" },
	{ Key = "MaxFP",       Label = "MAX FP" },
}

local function refreshCharacterWindow()
	if not guiRefs.CharacterFrame or not uiState.CharacterOpen then return end
	local data  = uiState.PlayerData
	local stats = uiState.PlayerStats

	if guiRefs.CharNameLabel then
		local name = player.Name
		local race  = data and data.RaceId   or "?"
		local class = data and data.ClassId  or "?"
		local level = data and data.Level    or 1
		guiRefs.CharNameLabel.Text = name
		guiRefs.CharSubLabel.Text  = "Lv." .. level .. "  " .. race .. " / " .. class
	end

	if guiRefs.CharStatLabels and stats then
		for i, row in ipairs(CHAR_STAT_ROWS) do
			local lbl = guiRefs.CharStatLabels[i]
			if lbl then
				local v = stats[row.Key] or 0
				lbl.Text = row.Pct and string.format("%.1f%%", v * 100) or tostring(math.floor(v))
			end
		end
	end
end

local function toggleCharacterWindow()
	uiState.CharacterOpen = not uiState.CharacterOpen
	if guiRefs.CharacterFrame then
		guiRefs.CharacterFrame.Visible = uiState.CharacterOpen
		if uiState.CharacterOpen then
			refreshPlayerData()
			refreshPlayerStats()
			refreshCharacterWindow()
		end
	end
	setStatus("Character " .. (uiState.CharacterOpen and "opened" or "closed"))
end

local function setInvitePromptVisible(visible)
	if guiRefs.PartyInvitePrompt then
		guiRefs.PartyInvitePrompt.Visible = visible
	end
end

local function showPartyInvite(invite)
	uiState.PendingPartyInvite = invite

	if guiRefs.PartyInviteText then
		guiRefs.PartyInviteText.Text = tostring(invite.InviterName or "A player") .. " invited you to join a party."
	end

	setInvitePromptVisible(true)
	setStatus("Party invitation received")
end

local function respondToPartyInvite(accepted)
	local ok, successFlag, result = invokeRemote(PartyInviteResponseRequest, accepted)

	if ok and successFlag then
		uiState.PendingPartyInvite = nil
		setInvitePromptVisible(false)
		refreshPlayerData()
		refreshPartyData()

		if accepted then
			uiState.PartyOpen = true
			setStatus("Joined party")
		else
			setStatus("Party invitation declined")
		end

		AetherionGameplayUI.Render()
	else
		setStatus(result or "Party invite response failed")
	end
end

local function inviteSelectedPartyTarget()
	local target = uiState.SelectedPartyTarget

	if not target or not target.Parent then
		setStatus("Ctrl-click a player first")
		return
	end

	local ok, successFlag, result = invokeRemote(PartyInviteRequest, target.UserId)

	if ok and successFlag then
		refreshPlayerData()
		refreshPartyData()
		uiState.PartyOpen = true
		setStatus("Party invite sent to " .. target.Name)
		AetherionGameplayUI.Render()
	else
		setStatus(result or "Party invite failed")
	end
end

local function leaveParty()
	local ok, successFlag, result = invokeRemote(PartyLeaveRequest)

	if ok and successFlag then
		refreshPlayerData()
		refreshPartyData()
		setStatus(tostring(result or "Left party"))
		AetherionGameplayUI.Render()
	else
		setStatus(result or "Leave party failed")
	end
end

local function togglePartyLock()
	local ok, successFlag, result = invokeRemote(PartyToggleLockRequest)

	if ok and successFlag then
		refreshPlayerData()
		refreshPartyData()
		setStatus("Party lock toggled")
		AetherionGameplayUI.Render()
	else
		setStatus(result or "Party lock failed")
	end
end

local function selectPartyTargetFromMouse()
	local mouse = player:GetMouse()
	local targetPart = mouse.Target

	if not targetPart then
		return
	end

	local model = targetPart:FindFirstAncestorOfClass("Model")
	local targetPlayer = model and Players:GetPlayerFromCharacter(model)

	if not targetPlayer or targetPlayer == player then
		return
	end

	uiState.SelectedPartyTarget = targetPlayer

	if guiRefs.PartyTargetLabel then
		guiRefs.PartyTargetLabel.Text = "Target: " .. targetPlayer.Name
	end

	setStatus("Selected party target: " .. targetPlayer.Name)
end

local function requestInventoryToggle()
	local now = os.clock()

	if now - lastInventoryToggleAt < 0.12 then
		return
	end

	lastInventoryToggleAt = now
	toggleInventory()
end

local function clearRuntimeConnections()
	for _, connection in ipairs(runtimeConnections) do
		connection:Disconnect()
	end

	runtimeConnections = {}
end

local function setupRuntime()
	clearRuntimeConnections()
	ContextActionService:UnbindAction("ToggleAetherionInventory")
	ContextActionService:UnbindAction("ToggleAetherionParty")

	table.insert(
		runtimeConnections,
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and activeDragWindow then
				activeDragWindow = nil
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 and uiState.DraggedItem then
				endDrag()
			end
		end)
	)

	table.insert(
		runtimeConnections,
		RunService.RenderStepped:Connect(function()
			if activeDragWindow then
				local mousePos = UserInputService:GetMouseLocation()
				local delta = mousePos - activeDragWindow.StartMouse
				local startPosition = activeDragWindow.StartPosition
				activeDragWindow.Frame.Position = clampFrameToViewport(
					activeDragWindow.Frame,
					UDim2.new(0, startPosition.X.Offset + delta.X, 0, startPosition.Y.Offset + delta.Y)
				)
			end

			if uiState.DragVisual then
				local mousePos = UserInputService:GetMouseLocation()
				uiState.DragVisual.Position = UDim2.new(0, mousePos.X + 8, 0, mousePos.Y + 8)
			end

			if guiRefs.TooltipFrame and guiRefs.TooltipFrame.Visible then
				local mousePos = UserInputService:GetMouseLocation()
				guiRefs.TooltipFrame.Position = UDim2.new(0, mousePos.X + 16, 0, mousePos.Y + 16)
			end
		end)
	)

	-- Refresh HP/FP/SP setiap 1 detik agar bar selalu up-to-date
	local lastHUDRefresh = 0
	table.insert(
		runtimeConnections,
		RunService.Heartbeat:Connect(function()
			local now = tick()
			if now - lastHUDRefresh >= 1 then
				lastHUDRefresh = now
				refreshPlayerData()
				buildHUD()
			end
		end)
	)

	table.insert(
		runtimeConnections,
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			local focusedTextBox = UserInputService:GetFocusedTextBox()

			if focusedTextBox then
				return
			end

			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				and (
					UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
					or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
				)
			then
				selectPartyTargetFromMouse()
				return
			end

			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end

			if input.KeyCode == Enum.KeyCode.P then
				return
			end

			-- TAB: cycle belt set — cek sebelum gameProcessed karena Roblox
			-- bisa consume Tab untuk UI focus cycling
			if input.KeyCode == Enum.KeyCode.Tab then
				cycleBeltSet()
				return
			end

			if gameProcessed then
				return
			end

			-- Belt 1-10 direct execute
			local beltKeyMap = {
				[Enum.KeyCode.One]   = 1,  [Enum.KeyCode.Two]   = 2,
				[Enum.KeyCode.Three] = 3,  [Enum.KeyCode.Four]  = 4,
				[Enum.KeyCode.Five]  = 5,  [Enum.KeyCode.Six]   = 6,
				[Enum.KeyCode.Seven] = 7,  [Enum.KeyCode.Eight] = 8,
				[Enum.KeyCode.Nine]  = 9,  [Enum.KeyCode.Zero]  = 10,
			}
			if beltKeyMap[input.KeyCode] then
				executeBeltSlot(beltKeyMap[input.KeyCode])
				return
			end

			-- F1-F8: execute macro (F9 dipakai Roblox untuk dev console)
			local macroKeyMap = {
				[Enum.KeyCode.F1] = 1, [Enum.KeyCode.F2] = 2, [Enum.KeyCode.F3] = 3,
				[Enum.KeyCode.F4] = 4, [Enum.KeyCode.F5] = 5, [Enum.KeyCode.F6] = 6,
				[Enum.KeyCode.F7] = 7, [Enum.KeyCode.F8] = 8,
			}
			if macroKeyMap[input.KeyCode] then
				executeMacro(macroKeyMap[input.KeyCode])
				return
			end

			-- ; : Toggle Battle/Peace mode manual
			if input.KeyCode == Enum.KeyCode.Semicolon then
				if uiState.BattleMode then
					uiState.LastBattleTick = 0
					setStatus("Peace Mode")
				else
					uiState.LastBattleTick = tick()
					setStatus("Battle Mode")
				end
				AetherionGameplayUI.Render()
				return
			end

			-- N: Walk / Run toggle
			if input.KeyCode == Enum.KeyCode.N then
				ToggleRunWalkRequest:FireServer()
				return
			end

			-- Z: Auto Attack (toggle, stub)
			if input.KeyCode == Enum.KeyCode.Z then
				setStatus("Auto Attack — coming soon")
				return
			end

			-- X: Pick-up item
			if input.KeyCode == Enum.KeyCode.X then
				setStatus("Pick-up — klik item di tanah atau dekati lalu tekan X")
				return
			end

			-- C: Character / Status
			if input.KeyCode == Enum.KeyCode.C then
				toggleCharacterWindow()
				return
			end

			-- Y: Macro window
			if input.KeyCode == Enum.KeyCode.Y then
				toggleMacroWindow()
				return
			end

			-- B: Daftar Teman / Guild (stub)
			if input.KeyCode == Enum.KeyCode.B then
				setStatus("Daftar Teman / Guild — coming soon")
				return
			end

			-- J: Journal / Quest (stub)
			if input.KeyCode == Enum.KeyCode.J then
				setStatus("Journal / Quest — coming soon")
				return
			end

			-- T: Window Chat
			if input.KeyCode == Enum.KeyCode.T then
				setStatus("Chat — ketik Enter atau / untuk membuka chat Roblox")
				return
			end

			-- M: Map (stub)
			if input.KeyCode == Enum.KeyCode.M then
				setStatus("Map — coming soon")
				return
			end

			-- R: Radar (stub)
			if input.KeyCode == Enum.KeyCode.R then
				setStatus("Radar — coming soon")
				return
			end

			-- O: Option Menu (stub)
			if input.KeyCode == Enum.KeyCode.O then
				setStatus("Option Menu — coming soon")
				return
			end

			-- U: Window Summon (khusus Cora/MYSTIC)
			if input.KeyCode == Enum.KeyCode.U then
				local data = uiState.PlayerData
				if data and data.RaceId == "MYSTIC" then
					setStatus("Summon Window — coming soon")
				else
					setStatus("Summon hanya tersedia untuk ras Cora (MYSTIC)")
				end
				return
			end
		end)
	)

	ContextActionService:BindActionAtPriority("ToggleAetherionInventory", function(_, inputState)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		requestInventoryToggle()
		return Enum.ContextActionResult.Sink
	end, false, INVENTORY_ACTION_PRIORITY, Enum.KeyCode.I)

	ContextActionService:BindActionAtPriority("ToggleAetherionParty", function(_, inputState)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		toggleParty()
		return Enum.ContextActionResult.Sink
	end, false, PARTY_ACTION_PRIORITY, Enum.KeyCode.P)

	table.insert(
		runtimeConnections,
		PartyInviteReceived.OnClientEvent:Connect(function(invite)
			showPartyInvite(invite)
		end)
	)

	table.insert(
		runtimeConnections,
		PartyChatReceived.OnClientEvent:Connect(function(senderName, msg, channel)
			local prefix = channel == "Party" and "[Party]" or channel == "Guild" and "[Guild]" or "[Whisper]"
			setStatus(prefix .. " " .. senderName .. ": " .. msg)
		end)
	)

	table.insert(
		runtimeConnections,
		BattleModeNotify.OnClientEvent:Connect(function()
			uiState.LastBattleTick = tick()
		end)
	)

	-- Server push SP langsung setiap detik — reliable, tidak bergantung polling
	table.insert(
		runtimeConnections,
		SPUpdateEvent.OnClientEvent:Connect(function(sp, maxSP, isRunning)
			if not uiState.PlayerData then return end
			uiState.PlayerData.Stats = uiState.PlayerData.Stats or {}
			uiState.PlayerData.Stats.SP    = sp
			uiState.PlayerData.Stats.MaxSP = maxSP
			walkRunIsRunning = isRunning
			if guiRefs.UpdateWalkRunButton then
				guiRefs.UpdateWalkRunButton(isRunning)
			end
			buildHUD()
		end)
	)

	table.insert(
		runtimeConnections,
		RunWalkStateChanged.OnClientEvent:Connect(function(newIsRunning)
			walkRunIsRunning = newIsRunning
			if guiRefs.UpdateWalkRunButton then
				guiRefs.UpdateWalkRunButton(newIsRunning)
			end
		end)
	)
end

function AetherionGameplayUI.Create()
	if guiRefs.ScreenGui then
		guiRefs.ScreenGui:Destroy()
		guiRefs = {}
		slotRegistry = {}
	end

	uiState.InventoryOpen  = false
	uiState.PartyOpen      = false
	uiState.MacroOpen      = false
	uiState.CharacterOpen  = false
	uiState.BattleMode     = false
	uiState.LastBattleTick = 0
	uiState.MacroData      = nil
	uiState.BeltSet        = 1

	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AetherionGameplayUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	guiRefs.ScreenGui = screenGui

	-- ============================================================
	-- HUD — RF Classic Style: lingkaran level + bar H/F/S kompak
	-- ============================================================
	local hudFrame = Instance.new("Frame")
	hudFrame.Name = "HUDFrame"
	hudFrame.Size = UDim2.new(0, 310, 0, 110)
	hudFrame.Position = UDim2.new(0, 10, 0, 10)
	hudFrame.BackgroundTransparency = 1
	hudFrame.BorderSizePixel = 0
	hudFrame.Parent = screenGui
	guiRefs.HUDFrame = hudFrame

	-- Lingkaran level (kiri)
	local circle = Instance.new("Frame")
	circle.Name = "LevelCircle"
	circle.Size = UDim2.new(0, 84, 0, 84)
	circle.Position = UDim2.new(0, 0, 0, 0)
	circle.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
	circle.BackgroundTransparency = 0.25
	circle.BorderSizePixel = 0
	circle.Parent = hudFrame
	local circleCorner = Instance.new("UICorner")
	circleCorner.CornerRadius = UDim.new(1, 0)
	circleCorner.Parent = circle
	local circleStroke = Instance.new("UIStroke")
	circleStroke.Color = Color3.fromRGB(160, 185, 210)
	circleStroke.Thickness = 2
	circleStroke.Parent = circle

	-- Level number di tengah circle
	local levelNum = makeLabel(circle, "1", UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 20), 28, true)
	levelNum.TextColor3 = Color3.fromRGB(240, 240, 255)
	levelNum.TextXAlignment = Enum.TextXAlignment.Center
	levelNum.TextStrokeTransparency = 0.5
	levelNum.TextStrokeColor3 = Color3.new(0, 0, 0)
	guiRefs.LevelLabel = levelNum

	-- "Lv." kecil di atas angka
	local lvText = makeLabel(circle, "Lv.", UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 8), 9, false)
	lvText.TextColor3 = RF_THEME.TextDim
	lvText.TextXAlignment = Enum.TextXAlignment.Center

	-- PEACE / COMBAT label di bawah angka
	local battleLabel = makeLabel(circle, "PEACE", UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 58), 8, true)
	battleLabel.TextColor3 = Color3.fromRGB(100, 210, 100)
	battleLabel.TextXAlignment = Enum.TextXAlignment.Center
	guiRefs.BattleModeLabel = battleLabel

	-- Helper buat bar RF-style (letter + track + fill + nilai)
	local function createRFBar(parent, letter, yPos, barColor)
		local row = Instance.new("Frame")
		row.Name = letter .. "Row"
		row.Size = UDim2.new(0, 218, 0, 22)
		row.Position = UDim2.new(0, 92, 0, yPos)
		row.BackgroundTransparency = 1
		row.BorderSizePixel = 0
		row.Parent = parent

		-- Huruf H / F / S
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 16, 1, 0)
		lbl.Position = UDim2.new(0, 0, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = letter
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 13
		lbl.TextColor3 = barColor
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.Parent = row

		-- Track (bar background)
		local track = Instance.new("Frame")
		track.Size = UDim2.new(0, 148, 0, 12)
		track.Position = UDim2.new(0, 20, 0.5, -6)
		track.BackgroundColor3 = Color3.fromRGB(4, 6, 10)
		track.BackgroundTransparency = 0.3
		track.BorderSizePixel = 0
		track.Parent = row
		local trackCorner = Instance.new("UICorner")
		trackCorner.CornerRadius = UDim.new(0, 2)
		trackCorner.Parent = track
		local trackStroke = Instance.new("UIStroke")
		trackStroke.Color = Color3.fromRGB(60, 70, 80)
		trackStroke.Thickness = 1
		trackStroke.Parent = track

		-- Fill
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(1, 0, 1, 0)
		fill.BackgroundColor3 = barColor
		fill.BorderSizePixel = 0
		fill.Parent = track
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 2)
		fillCorner.Parent = fill
		local fillGrad = Instance.new("UIGradient")
		fillGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, barColor),
		})
		fillGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.5),
			NumberSequenceKeypoint.new(1, 0),
		})
		fillGrad.Rotation = 90
		fillGrad.Parent = fill

		-- Nilai "150 / 150"
		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 48, 1, 0)
		valLbl.Position = UDim2.new(0, 172, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = "0 / 0"
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextSize = 10
		valLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.TextYAlignment = Enum.TextYAlignment.Center
		valLbl.TextStrokeTransparency = 0.4
		valLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
		valLbl.Parent = row

		return { Fill = fill, Value = valLbl }
	end

	guiRefs.HPBar = createRFBar(hudFrame, "H", 4,  Color3.fromRGB(210, 45, 45))
	guiRefs.FPBar = createRFBar(hudFrame, "F", 30, Color3.fromRGB(65, 115, 230))
	guiRefs.SPBar = createRFBar(hudFrame, "S", 56, Color3.fromRGB(220, 195, 50))

	-- Kill / Death baris bawah
	guiRefs.KillLabel  = makeLabel(hudFrame, "Kill 0",  UDim2.new(0, 90, 0, 16), UDim2.new(0, 92, 0, 82), 11, true)
	guiRefs.DeathLabel = makeLabel(hudFrame, "Death 0", UDim2.new(0, 90, 0, 16), UDim2.new(0, 182, 0, 82), 11, true)
	guiRefs.KillLabel.TextColor3  = Color3.fromRGB(240, 240, 240)
	guiRefs.DeathLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	guiRefs.KillLabel.TextStrokeTransparency  = 0.3
	guiRefs.DeathLabel.TextStrokeTransparency = 0.3
	guiRefs.KillLabel.TextStrokeColor3  = Color3.new(0, 0, 0)
	guiRefs.DeathLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

	-- PvP labels (disembunyikan jika 0, tetap ada untuk buildHUD)
	guiRefs.TempPvpLabel    = makeLabel(hudFrame, "", UDim2.new(0, 1, 0, 1), UDim2.new(0, 0, 2, 0), 1, false)
	guiRefs.CertainPvpLabel = makeLabel(hudFrame, "", UDim2.new(0, 1, 0, 1), UDim2.new(0, 0, 2, 0), 1, false)
	guiRefs.GoldPointLabel  = makeLabel(hudFrame, "", UDim2.new(0, 1, 0, 1), UDim2.new(0, 0, 2, 0), 1, false)

	-- Inventory kanan atas
	local viewport = getViewportSize()
	local inventoryFrame = makeFrame(
		screenGui,
		"InventoryFrame",
		UDim2.new(0, 520, 0, 500),
		UDim2.new(0, math.max(8, viewport.X - 470), 0, 42),
		RF_THEME.Window,
		0.14
	)
	guiRefs.InventoryFrame = inventoryFrame
	inventoryFrame.Visible = uiState.InventoryOpen
	applyResponsiveScale(inventoryFrame, 0.68, 0.86)
	createDragHandle(inventoryFrame, "InventoryDragHandle", 34)

	local invTitle = makeLabel(inventoryFrame, "Inventory", UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, 8), 15, true)
	invTitle.TextColor3 = RF_THEME.Gold
	invTitle.TextXAlignment = Enum.TextXAlignment.Center
	guiRefs.MoneyLabel =
		makeLabel(inventoryFrame, "CP 0   Gold 0", UDim2.new(0, 190, 0, 20), UDim2.new(1, -224, 0, 10), 12, false)
	guiRefs.MoneyLabel.TextXAlignment = Enum.TextXAlignment.Right

	local equipmentGrid = Instance.new("Frame")
	equipmentGrid.BackgroundTransparency = 1
	equipmentGrid.Size = UDim2.new(0, 202, 0, 434)
	equipmentGrid.Position = UDim2.new(0, 14, 0, 42)
	equipmentGrid.Parent = inventoryFrame
	guiRefs.EquipmentGrid = equipmentGrid

	local inventoryGrid = Instance.new("Frame")
	inventoryGrid.BackgroundTransparency = 1
	inventoryGrid.Size = UDim2.new(0, 232, 0, 290)
	inventoryGrid.Position = UDim2.new(0, 238, 0, 42)
	inventoryGrid.Parent = inventoryFrame
	guiRefs.InventoryGrid = inventoryGrid

	guiRefs.BagButtons = {}
	for bagIndex = 1, BAG_COUNT do
		local bagButton = makeButton(
			inventoryFrame,
			"Tas " .. tostring(bagIndex),
			UDim2.new(0, 42, 0, 24),
			UDim2.new(0, 238 + ((bagIndex - 1) * 45), 0, 338)
		)

		bagButton.MouseButton1Click:Connect(function()
			uiState.CurrentBag = bagIndex
			AetherionGameplayUI.Render()
		end)

		table.insert(guiRefs.BagButtons, bagButton)
	end

	local invToggleButton = makeButton(inventoryFrame, "I", UDim2.new(0, 26, 0, 24), UDim2.new(1, -34, 0, 8))
	invToggleButton.MouseButton1Click:Connect(function()
		uiState.InventoryOpen = false
		AetherionGameplayUI.Render()
	end)

	-- Party panel
	local partyFrame = makeFrame(
		screenGui,
		"PartyFrame",
		UDim2.new(0, 330, 0, 315),
		UDim2.new(0, math.max(8, viewport.X - 350), 0, 42),
		Color3.fromRGB(16, 18, 22)
	)
	guiRefs.PartyFrame = partyFrame
	partyFrame.Visible = uiState.PartyOpen
	createDragHandle(partyFrame, "PartyDragHandle", 54)

	local partyHeader = Instance.new("Frame")
	partyHeader.Name = "PartyHeader"
	partyHeader.Size = UDim2.new(1, -12, 0, 52)
	partyHeader.Position = UDim2.new(0, 6, 0, 6)
	partyHeader.BackgroundColor3 = Color3.fromRGB(22, 24, 28)
	partyHeader.BorderSizePixel = 0
	partyHeader.Parent = partyFrame
	createCorner(partyHeader, 2)
	createStroke(partyHeader, Color3.fromRGB(87, 95, 102), 1)

	guiRefs.PartyTitle = makeLabel(partyHeader, "Party 1/8", UDim2.new(0, 150, 0, 20), UDim2.new(0, 10, 0, 6), 15, true)
	guiRefs.PartyTitle.TextColor3 = Color3.fromRGB(236, 236, 236)
	guiRefs.PartyTargetLabel =
		makeLabel(partyHeader, "Target: No target", UDim2.new(0, 150, 0, 14), UDim2.new(0, 10, 0, 30), 10, false)
	guiRefs.PartyTargetLabel.TextColor3 = Color3.fromRGB(154, 162, 170)

	local actionCluster = Instance.new("Frame")
	actionCluster.Name = "ActionCluster"
	actionCluster.Size = UDim2.new(0, 116, 0, 48)
	actionCluster.Position = UDim2.new(1, -122, 0, 2)
	actionCluster.BackgroundTransparency = 1
	actionCluster.Parent = partyHeader

	local actionLayout = {
		{ Name = "Loot", Text = "01", X = 0 },
		{ Name = "Inspect", Text = "02", X = 38 },
		{ Name = "Invite", Text = "03", X = 76 },
	}

	for _, action in ipairs(actionLayout) do
		local actionButton = Instance.new("TextButton")
		actionButton.Name = action.Name
		actionButton.Size = UDim2.new(0, 32, 0, 32)
		actionButton.Position = UDim2.new(0, action.X, 0, 6)
		actionButton.Text = action.Text
		actionButton.TextSize = 11
		actionButton.Font = Enum.Font.GothamBold
		actionButton.TextColor3 = Color3.fromRGB(246, 248, 250)
		actionButton.BackgroundColor3 = Color3.fromRGB(28, 31, 36)
		actionButton.BorderSizePixel = 0
		actionButton.Parent = actionCluster
		createCorner(actionButton, 2)
		createStroke(actionButton, Color3.fromRGB(147, 112, 107), 1)

		actionButton.MouseButton1Click:Connect(function()
			if action.Name == "Invite" then
				inviteSelectedPartyTarget()
			elseif action.Name == "Loot" then
				setStatus("Loot mode: all members")
			elseif action.Name == "Inspect" then
				setStatus("Loot mode: party leader")
			end
		end)
	end

	local partyContent = Instance.new("Frame")
	partyContent.Name = "PartyContent"
	partyContent.BackgroundTransparency = 1
	partyContent.Size = UDim2.new(1, -12, 0, 210)
	partyContent.Position = UDim2.new(0, 6, 0, 62)
	partyContent.Parent = partyFrame
	guiRefs.PartyContent = partyContent

	local lockButton = makeButton(partyFrame, "Lock", UDim2.new(0, 132, 0, 38), UDim2.new(0.5, -66, 1, -46))
	guiRefs.PartyLockButton = lockButton
	lockButton.MouseButton1Click:Connect(function()
		togglePartyLock()
	end)

	local leaveButton = makeButton(partyFrame, "Leaving", UDim2.new(0, 82, 0, 26), UDim2.new(1, -94, 1, -40))
	leaveButton.MouseButton1Click:Connect(function()
		leaveParty()
	end)

	-- Upgrade UI
	local upgradeFrame =
		makeFrame(screenGui, "UpgradeFrame", UDim2.new(0, 260, 0, 285), UDim2.new(1, -275, 0, 510), RF_THEME.Window)
	guiRefs.UpgradeFrame = upgradeFrame
	upgradeFrame.Visible = uiState.UpgradeOpen
	applyResponsiveScale(upgradeFrame, 0.78, 0.95)
	createDragHandle(upgradeFrame, "UpgradeDragHandle", 34)

	makeLabel(upgradeFrame, "Upgrade", UDim2.new(0, 120, 0, 24), UDim2.new(0, 10, 0, 8), 16, true)

	local upgradeSlotContainer = Instance.new("Frame")
	upgradeSlotContainer.BackgroundTransparency = 1
	upgradeSlotContainer.Size = UDim2.new(1, 0, 0, 190)
	upgradeSlotContainer.Position = UDim2.new(0, 0, 0, 35)
	upgradeSlotContainer.Parent = upgradeFrame
	guiRefs.UpgradeSlotContainer = upgradeSlotContainer

	local upgradeButton = makeButton(upgradeFrame, "Upgrade", UDim2.new(0, 110, 0, 28), UDim2.new(0.5, -55, 1, -36))
	upgradeButton.MouseButton1Click:Connect(function()
		performUpgrade()
	end)

	local upgradeClose = makeButton(upgradeFrame, "U", UDim2.new(0, 26, 0, 24), UDim2.new(1, -34, 0, 8))
	upgradeClose.MouseButton1Click:Connect(function()
		uiState.UpgradeOpen = false
		AetherionGameplayUI.Render()
	end)

	-- Hotbar tengah bawah
	local hotbarFrame = makeFrame(
		screenGui,
		"HotbarFrame",
		UDim2.new(0, 450, 0, 54),
		UDim2.new(0.5, -225, 1, -72),
		Color3.fromRGB(10, 13, 18),
		0.32
	)
	guiRefs.HotbarFrame = hotbarFrame
	local hotbarStroke = hotbarFrame:FindFirstChildOfClass("UIStroke")
	if hotbarStroke then
		hotbarStroke.Transparency = 0.84
	end

	local hotbarSlots = Instance.new("Frame")
	hotbarSlots.BackgroundTransparency = 1
	hotbarSlots.Size = UDim2.new(0, 416, 0, 38)
	hotbarSlots.Position = UDim2.new(0.5, -208, 0, 8)
	hotbarSlots.Parent = hotbarFrame
	guiRefs.HotbarSlots = hotbarSlots

	-- Belt set indicator (kiri hotbar)
	local beltSetFrame = makeFrame(screenGui, "BeltSetFrame",
		UDim2.new(0, 46, 0, 46), UDim2.new(0.5, -279, 1, -71),
		Color3.fromRGB(10, 13, 18), 0.32)
	local beltSetLabel = makeLabel(beltSetFrame, "1/5",
		UDim2.new(1, 0, 0, 20), UDim2.new(0, 0, 0, 4), 14, true)
	beltSetLabel.TextColor3 = RF_THEME.Gold
	beltSetLabel.TextXAlignment = Enum.TextXAlignment.Center
	local beltHint = makeLabel(beltSetFrame, "TAB",
		UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 0, 24), 9, false)
	beltHint.TextColor3 = RF_THEME.TextDim
	beltHint.TextXAlignment = Enum.TextXAlignment.Center
	guiRefs.BeltSetLabel = beltSetLabel

	-- ============================================================
	-- Macro Window (Y key) — 9 slots, F1-F8 via keyboard (F9 = dev console)
	-- ============================================================
	local macroFrame = makeFrame(screenGui, "MacroFrame",
		UDim2.new(0, 380, 0, 352), UDim2.new(0.5, -190, 0.5, -176),
		RF_THEME.Window, 0.12)
	-- Hapus gradient gelap agar konten terlihat jelas
	do local g = macroFrame:FindFirstChildOfClass("UIGradient") if g then g:Destroy() end end
	macroFrame.Visible = false
	macroFrame.ZIndex = 25
	guiRefs.MacroFrame = macroFrame
	createDragHandle(macroFrame, "MacroDragHandle", 28)

	local macroTitle = makeLabel(macroFrame, "MACRO SYSTEM", UDim2.new(1, -48, 0, 24),
		UDim2.new(0, 8, 0, 6), 13, true)
	macroTitle.TextColor3 = RF_THEME.Gold
	macroTitle.TextXAlignment = Enum.TextXAlignment.Center

	local macroHint = makeLabel(macroFrame, "F1-F8 = execute  |  Slot 9 = klik ▶ RUN (F9 = dev console)",
		UDim2.new(1, -16, 0, 16), UDim2.new(0, 8, 0, 28), 9, false)
	macroHint.TextColor3 = RF_THEME.TextDim
	macroHint.TextXAlignment = Enum.TextXAlignment.Center

	local macroClose = makeButton(macroFrame, "X", UDim2.new(0, 22, 0, 20), UDim2.new(1, -28, 0, 6))
	macroClose.MouseButton1Click:Connect(function()
		uiState.MacroOpen = false
		macroFrame.Visible = false
	end)

	guiRefs.MacroRows = {}
	for i = 1, 9 do
		local rowY = 46 + (i - 1) * 33
		local row = Instance.new("Frame")
		row.Name = "MacroRow" .. i
		row.Size = UDim2.new(1, -16, 0, 28)
		row.Position = UDim2.new(0, 8, 0, rowY)
		row.BackgroundColor3 = RF_THEME.Panel
		row.BackgroundTransparency = 0.2
		row.BorderSizePixel = 0
		row.Parent = macroFrame
		createCorner(row, 2)

		local fLabel = makeLabel(row, (i < 9 and "F" .. i or "F9*"),
			UDim2.new(0, 32, 1, 0), UDim2.new(0, 4, 0, 0), 12, true)
		fLabel.TextColor3 = RF_THEME.Gold
		fLabel.TextStrokeTransparency = 0.5

		local nameLabel = makeLabel(row, "(empty)",
			UDim2.new(1, -120, 1, 0), UDim2.new(0, 38, 0, 0), 12, false)
		nameLabel.TextColor3 = RF_THEME.Text
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextStrokeTransparency = 0.5
		nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)

		local execBtn = makeButton(row, "▶", UDim2.new(0, 28, 0, 20), UDim2.new(1, -68, 0, 4))
		execBtn.TextSize = 12
		execBtn.TextColor3 = Color3.fromRGB(100, 220, 100)
		local capturedI = i
		execBtn.MouseButton1Click:Connect(function()
			executeMacro(capturedI)
		end)

		local clearBtn = makeButton(row, "CLR", UDim2.new(0, 34, 0, 20), UDim2.new(1, -36, 0, 4))
		clearBtn.TextSize = 10
		clearBtn.MouseButton1Click:Connect(function()
			invokeRemote(ClearMacroRequest, capturedI)
			refreshMacroWindow()
		end)

		guiRefs.MacroRows[i] = { Row = row, NameLabel = nameLabel }
	end

	-- ============================================================
	-- Character Window (C key)
	-- ============================================================
	local charFrame = makeFrame(screenGui, "CharacterFrame",
		UDim2.new(0, 260, 0, 310), UDim2.new(0.5, -130, 0.5, -155),
		RF_THEME.Window, 0.08)
	-- Hapus gradient gelap agar stat rows terlihat jelas
	do local g = charFrame:FindFirstChildOfClass("UIGradient") if g then g:Destroy() end end
	charFrame.Visible = false
	charFrame.ZIndex = 24
	guiRefs.CharacterFrame = charFrame
	createDragHandle(charFrame, "CharDragHandle", 28)

	local charTitle = makeLabel(charFrame, "CHARACTER", UDim2.new(1, -48, 0, 24),
		UDim2.new(0, 8, 0, 6), 13, true)
	charTitle.TextColor3 = RF_THEME.Gold
	charTitle.TextXAlignment = Enum.TextXAlignment.Center

	local charClose = makeButton(charFrame, "X", UDim2.new(0, 22, 0, 20), UDim2.new(1, -28, 0, 6))
	charClose.MouseButton1Click:Connect(function()
		uiState.CharacterOpen = false
		charFrame.Visible = false
	end)

	local charName = makeLabel(charFrame, player.Name,
		UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, 30), 16, true)
	charName.TextColor3 = RF_THEME.Gold
	charName.TextXAlignment = Enum.TextXAlignment.Center
	charName.TextStrokeTransparency = 0.5
	guiRefs.CharNameLabel = charName

	local charSub = makeLabel(charFrame, "Lv.1  ?  /  ?",
		UDim2.new(1, -16, 0, 18), UDim2.new(0, 8, 0, 54), 12, false)
	charSub.TextColor3 = RF_THEME.Text
	charSub.TextXAlignment = Enum.TextXAlignment.Center
	charSub.TextStrokeTransparency = 0.6
	guiRefs.CharSubLabel = charSub

	-- divider
	local charDiv = Instance.new("Frame")
	charDiv.Size = UDim2.new(1, -16, 0, 1)
	charDiv.Position = UDim2.new(0, 8, 0, 76)
	charDiv.BackgroundColor3 = RF_THEME.BorderBright
	charDiv.BackgroundTransparency = 0.5
	charDiv.BorderSizePixel = 0
	charDiv.Parent = charFrame

	guiRefs.CharStatLabels = {}
	for i, row in ipairs(CHAR_STAT_ROWS) do
		local rowY = 82 + (i - 1) * 26
		-- Plain row frame (bukan makeFrame agar tidak ada gradient/stroke yg mengaburkan)
		local rowFrame = Instance.new("Frame")
		rowFrame.Name = "CharStat" .. i
		rowFrame.Size = UDim2.new(1, -16, 0, 22)
		rowFrame.Position = UDim2.new(0, 8, 0, rowY)
		rowFrame.BackgroundColor3 = Color3.fromRGB(30, 38, 50)
		rowFrame.BackgroundTransparency = 0.3
		rowFrame.BorderSizePixel = 0
		rowFrame.Parent = charFrame
		createCorner(rowFrame, 2)

		local keyLbl = makeLabel(rowFrame, row.Label,
			UDim2.new(0, 90, 1, 0), UDim2.new(0, 6, 0, 0), 12, false)
		keyLbl.TextColor3 = RF_THEME.TextDim
		keyLbl.TextStrokeTransparency = 0.5
		keyLbl.TextStrokeColor3 = Color3.new(0, 0, 0)

		local valLbl = makeLabel(rowFrame, "0",
			UDim2.new(0, 100, 1, 0), UDim2.new(1, -106, 0, 0), 12, true)
		valLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.TextStrokeTransparency = 0.4
		valLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
		guiRefs.CharStatLabels[i] = valLbl
	end

	-- Walk/Run toggle button, di kanan hotbar
	local walkRunBtn = Instance.new("TextButton")
	walkRunBtn.Name = "WalkRunToggle"
	walkRunBtn.Size = UDim2.new(0, 52, 0, 46)
	walkRunBtn.Position = UDim2.new(0.5, 232, 1, -71)
	walkRunBtn.Text = "RUN"
	walkRunBtn.TextSize = 11
	walkRunBtn.Font = Enum.Font.GothamBold
	walkRunBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
	walkRunBtn.TextColor3 = Color3.fromRGB(110, 210, 110)
	walkRunBtn.BorderSizePixel = 0
	walkRunBtn.AutoButtonColor = false
	walkRunBtn.Parent = screenGui
	createCorner(walkRunBtn, 3)
	createStroke(walkRunBtn, RF_THEME.Border, 1)

	local walkRunLabel = Instance.new("TextLabel")
	walkRunLabel.Size = UDim2.new(1, 0, 0, 14)
	walkRunLabel.Position = UDim2.new(0, 0, 1, -16)
	walkRunLabel.BackgroundTransparency = 1
	walkRunLabel.Text = "SPEED"
	walkRunLabel.TextSize = 9
	walkRunLabel.Font = Enum.Font.Gotham
	walkRunLabel.TextColor3 = RF_THEME.TextDim
	walkRunLabel.Parent = walkRunBtn

	local function updateWalkRunButton(isRunning)
		if isRunning then
			walkRunBtn.Text = "RUN"
			walkRunBtn.TextColor3 = Color3.fromRGB(110, 210, 110)
			walkRunBtn.BackgroundColor3 = Color3.fromRGB(24, 46, 24)
			local s = walkRunBtn:FindFirstChildOfClass("UIStroke")
			if s then s.Color = Color3.fromRGB(80, 160, 80) end
		else
			walkRunBtn.Text = "WALK"
			walkRunBtn.TextColor3 = Color3.fromRGB(120, 170, 230)
			walkRunBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
			local s = walkRunBtn:FindFirstChildOfClass("UIStroke")
			if s then s.Color = Color3.fromRGB(70, 110, 170) end
		end
	end

	walkRunBtn.MouseButton1Click:Connect(function()
		ToggleRunWalkRequest:FireServer()
	end)

	walkRunBtn.MouseEnter:Connect(function()
		walkRunBtn.BackgroundTransparency = 0.25
	end)
	walkRunBtn.MouseLeave:Connect(function()
		walkRunBtn.BackgroundTransparency = 0
	end)

	updateWalkRunButton(walkRunIsRunning)
	guiRefs.WalkRunButton = walkRunBtn
	guiRefs.UpdateWalkRunButton = updateWalkRunButton

	-- Status bawah
	local statusFrame = makeFrame(
		screenGui,
		"StatusFrame",
		UDim2.new(0, 420, 0, 30),
		UDim2.new(0.5, -210, 1, -20),
		Color3.fromRGB(18, 20, 26)
	)
	guiRefs.StatusFrame = statusFrame
	createDragHandle(statusFrame, "StatusDragHandle", 30)
	guiRefs.StatusLabel =
		makeLabel(statusFrame, "Status: Ready.", UDim2.new(1, -12, 1, 0), UDim2.new(0, 6, 0, 0), 12, false)

	local invitePrompt = makeFrame(
		screenGui,
		"PartyInvitePrompt",
		UDim2.new(0, 520, 0, 66),
		UDim2.new(0.5, -260, 1, -170),
		Color3.fromRGB(17, 21, 28)
	)
	invitePrompt.Visible = false
	invitePrompt.ZIndex = 40
	guiRefs.PartyInvitePrompt = invitePrompt

	guiRefs.PartyInviteText = makeLabel(
		invitePrompt,
		"Party invitation received.",
		UDim2.new(1, -140, 0, 28),
		UDim2.new(0, 12, 0, 8),
		13,
		true
	)
	guiRefs.PartyInviteText.ZIndex = 41

	local inviteYesButton = makeButton(invitePrompt, "Yes", UDim2.new(0, 54, 0, 28), UDim2.new(1, -126, 0, 20))
	inviteYesButton.ZIndex = 41
	inviteYesButton.MouseButton1Click:Connect(function()
		respondToPartyInvite(true)
	end)

	local inviteNoButton = makeButton(invitePrompt, "No", UDim2.new(0, 54, 0, 28), UDim2.new(1, -66, 0, 20))
	inviteNoButton.ZIndex = 41
	inviteNoButton.MouseButton1Click:Connect(function()
		respondToPartyInvite(false)
	end)

	ensureTooltip()

	refreshPlayerData()
	refreshPlayerStats()
	AetherionGameplayUI.Render()
	setupRuntime()
	setStatus("UI loaded. I = Inventory, P = Party, right-click upgrader = Upgrade")
end

return AetherionGameplayUI
