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

local GetPlayerDataRequest = waitRemoteFunction("GetPlayerDataRequest")
local GetPlayerStatsRequest = waitRemoteFunction("GetPlayerStatsRequest")
local EquipItemRequest = waitRemoteFunction("EquipItemRequest")
local UpgradeItemRequest = waitRemoteFunction("UpgradeItemRequest")

local BAG_COUNT = 5
local BAG_SIZE = 20
local HOTBAR_SIZE = 10

local uiState = {
	CurrentBag = 1,
	InventoryOpen = true,
	UpgradeOpen = false,

	PlayerData = nil,
	PlayerStats = nil,

	HotbarAssignments = {},
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
	stroke.Parent = parent
	return stroke
end

local function makeFrame(parent, name, size, position, color)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = color or RF_THEME.Window
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
	button.BorderSizePixel = 0
	button.Parent = parent

	createCorner(button, 1)
	createStroke(button, RF_THEME.Border, 1)

	local inner = Instance.new("Frame")
	inner.Name = "Inner"
	inner.Size = UDim2.new(1, -6, 1, -6)
	inner.Position = UDim2.new(0, 3, 0, 3)
	inner.BackgroundColor3 = Color3.fromRGB(17, 21, 28)
	inner.BorderSizePixel = 0
	inner.Parent = button

	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.fromRGB(35, 43, 55)
	innerStroke.Thickness = 1
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
			uiState.HotbarAssignments[meta.Index] = nil
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

	if slotKey == "Ring1" or slotKey == "Ring2" then
		return equipSlot == "Ring" or equipSlot == "Accessory"
	end

	return equipSlot == slotKey
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
		uiState.HotbarAssignments[targetMeta.Index] = {
			Uid = item.Uid,
			ItemId = item.ItemId,
		}
		setStatus("Assigned to hotbar slot " .. tostring(targetMeta.Index))
		AetherionGameplayUI.Render()
		return
	end

	if targetMeta.Kind == "Upgrade" then
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
		return
	end

	local def = getDefinition(item.ItemId)

	icon.Text = getShortLabel(item)
	icon.TextColor3 = Color3.fromRGB(240, 240, 240)

	if item.UpgradeLevel and item.UpgradeLevel > 0 then
		bottomText.Text = "+" .. tostring(item.UpgradeLevel)
	else
		bottomText.Text = ""
	end

	stroke.Color = getGradeColor(def)
end

local function buildHUD()
	local hud = guiRefs.HUDFrame
	local data = uiState.PlayerData or {}
	local stats = uiState.PlayerStats or {}

	guiRefs.LevelLabel.Text = "Lv. " .. tostring(data.Level or 1)

	local currentHP = (data.Stats and data.Stats.HP) or stats.MaxHP or 150
	local maxHP = stats.MaxHP or currentHP or 150
	local currentFP = (data.Stats and data.Stats.FP) or stats.MaxFP or 100
	local maxFP = stats.MaxFP or currentFP or 100
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

	local equipmentSlots = {
		{ Key = "Helmet", Label = "Head", X = 0, Y = 0 },
		{ Key = "Weapon", Label = "Weapon", X = 0, Y = 58 },
		{ Key = "Shield", Label = "Shield", X = 58, Y = 58 },
		{ Key = "Armor", Label = "Armor", X = 0, Y = 116 },
		{ Key = "Gloves", Label = "Gloves", X = 58, Y = 116 },
		{ Key = "Boots", Label = "Boots", X = 0, Y = 174 },
		{ Key = "Cloak", Label = "Cloak", X = 58, Y = 174 },
		{ Key = "Amulet", Label = "Amulet", X = 0, Y = 232 },
		{ Key = "Ring1", Label = "Ring 1", X = 58, Y = 232 },
		{ Key = "Ring2", Label = "Ring 2", X = 0, Y = 290 },
	}

	for _, slotInfo in ipairs(equipmentSlots) do
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

	for index = 1, HOTBAR_SIZE do
		local slotButton = createSlot(
			guiRefs.HotbarSlots,
			"Hotbar" .. tostring(index),
			UDim2.new(0, 48, 0, 48),
			UDim2.new(0, (index - 1) * 52, 0, 0)
		)

		local assigned = uiState.HotbarAssignments[index]
		renderSlotVisual(slotButton, assigned, tostring(index % 10))

		registerSlot(slotButton, {
			Kind = "Hotbar",
			Index = index,
			GetItem = function()
				return uiState.HotbarAssignments[index]
			end,
		})
	end
end

function AetherionGameplayUI.Render()
	if not guiRefs.ScreenGui then
		return
	end

	buildHUD()
	buildInventory()
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

	local ok, successFlag, result = invokeRemote(UpgradeItemRequest, equipment.Uid, 0)
	if ok and successFlag then
		setStatus("Upgrade success")
		refreshPlayerData()
		refreshPlayerStats()
		AetherionGameplayUI.Render()
	else
		setStatus(result or "Upgrade failed")
	end
end

local function setupRuntime()
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and uiState.DraggedItem then
			endDrag()
		end
	end)

	RunService.RenderStepped:Connect(function()
		if uiState.DragVisual then
			local mousePos = UserInputService:GetMouseLocation()
			uiState.DragVisual.Position = UDim2.new(0, mousePos.X + 8, 0, mousePos.Y + 8)
		end

		if guiRefs.TooltipFrame and guiRefs.TooltipFrame.Visible then
			local mousePos = UserInputService:GetMouseLocation()
			guiRefs.TooltipFrame.Position = UDim2.new(0, mousePos.X + 16, 0, mousePos.Y + 16)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		local focusedTextBox = UserInputService:GetFocusedTextBox()

		if focusedTextBox then
			return
		end

		if input.KeyCode == Enum.KeyCode.I then
			uiState.InventoryOpen = not uiState.InventoryOpen

			if guiRefs.InventoryFrame then
				guiRefs.InventoryFrame.Visible = uiState.InventoryOpen
			end

			setStatus("Inventory " .. (uiState.InventoryOpen and "opened" or "closed"))
			AetherionGameplayUI.Render()
			return
		end

		if input.KeyCode == Enum.KeyCode.U then
			uiState.UpgradeOpen = not uiState.UpgradeOpen

			if guiRefs.UpgradeFrame then
				guiRefs.UpgradeFrame.Visible = uiState.UpgradeOpen
			end

			setStatus("Upgrade " .. (uiState.UpgradeOpen and "opened" or "closed"))
			AetherionGameplayUI.Render()
			return
		end

		if input.KeyCode == Enum.KeyCode.One then
			setStatus("Use hotbar slot 1")
		elseif input.KeyCode == Enum.KeyCode.Two then
			setStatus("Use hotbar slot 2")
		elseif input.KeyCode == Enum.KeyCode.Three then
			setStatus("Use hotbar slot 3")
		elseif input.KeyCode == Enum.KeyCode.Four then
			setStatus("Use hotbar slot 4")
		elseif input.KeyCode == Enum.KeyCode.Five then
			setStatus("Use hotbar slot 5")
		elseif input.KeyCode == Enum.KeyCode.Six then
			setStatus("Use hotbar slot 6")
		elseif input.KeyCode == Enum.KeyCode.Seven then
			setStatus("Use hotbar slot 7")
		elseif input.KeyCode == Enum.KeyCode.Eight then
			setStatus("Use hotbar slot 8")
		elseif input.KeyCode == Enum.KeyCode.Nine then
			setStatus("Use hotbar slot 9")
		elseif input.KeyCode == Enum.KeyCode.Zero then
			setStatus("Use hotbar slot 10")
		end
	end)
	ContextActionService:UnbindAction("ToggleAetherionInventory")
	ContextActionService:BindAction("ToggleAetherionInventory", function(_, inputState)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if UserInputService:GetFocusedTextBox() then
			return Enum.ContextActionResult.Pass
		end

		uiState.InventoryOpen = not uiState.InventoryOpen

		if guiRefs.InventoryFrame then
			guiRefs.InventoryFrame.Visible = uiState.InventoryOpen
		end

		setStatus("Inventory " .. (uiState.InventoryOpen and "opened" or "closed"))
		AetherionGameplayUI.Render()

		return Enum.ContextActionResult.Sink
	end, false, Enum.KeyCode.I)
end

function AetherionGameplayUI.Create()
	if guiRefs.ScreenGui then
		guiRefs.ScreenGui:Destroy()
		guiRefs = {}
	end

	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AetherionGameplayUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = playerGui

	guiRefs.ScreenGui = screenGui

	local quickInventoryButton = makeButton(screenGui, "INV", UDim2.new(0, 52, 0, 28), UDim2.new(1, -120, 0, 8))

	quickInventoryButton.MouseButton1Click:Connect(function()
		uiState.InventoryOpen = not uiState.InventoryOpen
		AetherionGameplayUI.Render()
	end)

	local quickUpgradeButton = makeButton(screenGui, "UPG", UDim2.new(0, 52, 0, 28), UDim2.new(1, -62, 0, 8))

	quickUpgradeButton.MouseButton1Click:Connect(function()
		uiState.UpgradeOpen = not uiState.UpgradeOpen
		AetherionGameplayUI.Render()
	end)

	-- HUD kiri atas
	local hudFrame =
		makeFrame(screenGui, "HUDFrame", UDim2.new(0, 300, 0, 135), UDim2.new(0, 12, 0, 12), Color3.fromRGB(18, 20, 26))
	guiRefs.HUDFrame = hudFrame

	local levelLabel = makeLabel(hudFrame, "Lv. 1", UDim2.new(0, 80, 0, 22), UDim2.new(0, 8, 0, 6), 18, true)
	guiRefs.LevelLabel = levelLabel

	guiRefs.HPBar = createBar(hudFrame, "HP", UDim2.new(0, 8, 0, 28), Color3.fromRGB(195, 50, 50))
	guiRefs.FPBar = createBar(hudFrame, "FP", UDim2.new(0, 8, 0, 56), Color3.fromRGB(80, 120, 255))
	guiRefs.SPBar = createBar(hudFrame, "SP", UDim2.new(0, 8, 0, 84), Color3.fromRGB(240, 210, 70))

	guiRefs.KillLabel = makeLabel(hudFrame, "Kill 0", UDim2.new(0, 130, 0, 18), UDim2.new(0, 8, 0, 112), 12, true)
	guiRefs.DeathLabel = makeLabel(hudFrame, "Death 0", UDim2.new(0, 130, 0, 18), UDim2.new(0, 78, 0, 112), 12, true)
	guiRefs.TempPvpLabel =
		makeLabel(hudFrame, "PvP Sementara 0", UDim2.new(0, 160, 0, 18), UDim2.new(0, 8, 0, 128), 12, false)
	guiRefs.CertainPvpLabel =
		makeLabel(hudFrame, "Point Tertentu 0", UDim2.new(0, 160, 0, 18), UDim2.new(0, 8, 0, 144), 12, false)
	guiRefs.GoldPointLabel =
		makeLabel(hudFrame, "Point Emas 0", UDim2.new(0, 160, 0, 18), UDim2.new(0, 8, 0, 160), 12, false)

	-- Inventory kanan atas
	local inventoryFrame =
		makeFrame(screenGui, "InventoryFrame", UDim2.new(0, 355, 0, 455), UDim2.new(1, -370, 0, 42), RF_THEME.Window)
	guiRefs.InventoryFrame = inventoryFrame

	local invTitle = makeLabel(inventoryFrame, "Inventory", UDim2.new(1, -20, 0, 24), UDim2.new(0, 10, 0, 8), 15, true)
	invTitle.TextColor3 = RF_THEME.Gold
	invTitle.TextXAlignment = Enum.TextXAlignment.Center
	guiRefs.MoneyLabel =
		makeLabel(inventoryFrame, "CP 0   Gold 0", UDim2.new(0, 180, 0, 20), UDim2.new(0, 180, 0, 10), 12, false)
	guiRefs.MoneyLabel.TextXAlignment = Enum.TextXAlignment.Right

	local equipmentGrid = Instance.new("Frame")
	equipmentGrid.BackgroundTransparency = 1
	equipmentGrid.Size = UDim2.new(0, 120, 0, 350)
	equipmentGrid.Position = UDim2.new(0, 10, 0, 42)
	equipmentGrid.Parent = inventoryFrame
	guiRefs.EquipmentGrid = equipmentGrid

	local inventoryGrid = Instance.new("Frame")
	inventoryGrid.BackgroundTransparency = 1
	inventoryGrid.Size = UDim2.new(0, 232, 0, 290)
	inventoryGrid.Position = UDim2.new(0, 138, 0, 42)
	inventoryGrid.Parent = inventoryFrame
	guiRefs.InventoryGrid = inventoryGrid

	guiRefs.BagButtons = {}
	for bagIndex = 1, BAG_COUNT do
		local bagButton = makeButton(
			inventoryFrame,
			"Tas " .. tostring(bagIndex),
			UDim2.new(0, 42, 0, 24),
			UDim2.new(0, 138 + ((bagIndex - 1) * 45), 0, 338)
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

	-- Upgrade UI
	local upgradeFrame =
		makeFrame(screenGui, "UpgradeFrame", UDim2.new(0, 260, 0, 285), UDim2.new(1, -275, 0, 510), RF_THEME.Window)
	guiRefs.UpgradeFrame = upgradeFrame

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
		UDim2.new(0, 560, 0, 74),
		UDim2.new(0.5, -280, 1, -94),
		Color3.fromRGB(18, 20, 26)
	)
	guiRefs.HotbarFrame = hotbarFrame

	local hotbarSlots = Instance.new("Frame")
	hotbarSlots.BackgroundTransparency = 1
	hotbarSlots.Size = UDim2.new(0, 520, 0, 48)
	hotbarSlots.Position = UDim2.new(0, 20, 0, 13)
	hotbarSlots.Parent = hotbarFrame
	guiRefs.HotbarSlots = hotbarSlots

	-- Status bawah
	local statusFrame = makeFrame(
		screenGui,
		"StatusFrame",
		UDim2.new(0, 420, 0, 30),
		UDim2.new(0.5, -210, 1, -20),
		Color3.fromRGB(18, 20, 26)
	)
	guiRefs.StatusFrame = statusFrame
	guiRefs.StatusLabel =
		makeLabel(statusFrame, "Status: Ready.", UDim2.new(1, -12, 1, 0), UDim2.new(0, 6, 0, 0), 12, false)

	ensureTooltip()

	refreshPlayerData()
	refreshPlayerStats()
	AetherionGameplayUI.Render()
	setupRuntime()
	setStatus("UI loaded. I = Inventory, U = Upgrade")
end

return AetherionGameplayUI
