local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AetherionDebug =
	require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Client"):WaitForChild("AetherionDebug"))

local player = Players.LocalPlayer

local AetherionDebugUI = {}

local screenGui
local mainFrame
local outputText
local selectedWeaponId
local selectedItemUid

local function createTextButton(parent, text, size, position)
	local button = Instance.new("TextButton")
	button.Name = text:gsub("%s+", "") .. "Button"
	button.Text = text
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.Gotham
	button.TextSize = 13
	button.BorderSizePixel = 0
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	return button
end

local function createTextLabel(parent, text, size, position)
	local label = Instance.new("TextLabel")
	label.Name = text:gsub("%s+", "") .. "Label"
	label.Text = text
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	return label
end

local function createInput(parent, placeholder, size, position)
	local input = Instance.new("TextBox")
	input.Name = placeholder:gsub("%s+", "") .. "Input"
	input.PlaceholderText = placeholder
	input.Text = ""
	input.Size = size
	input.Position = position
	input.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	input.TextColor3 = Color3.fromRGB(255, 255, 255)
	input.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	input.Font = Enum.Font.Gotham
	input.TextSize = 13
	input.BorderSizePixel = 0
	input.ClearTextOnFocus = false
	input.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = input

	return input
end

local function appendOutput(text)
	if not outputText then
		return
	end

	outputText.Text = tostring(text)
end

local function formatTable(value, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)

	if type(value) ~= "table" then
		return prefix .. tostring(value)
	end

	local lines = {}

	for key, child in pairs(value) do
		if type(child) == "table" then
			table.insert(lines, prefix .. tostring(key) .. ":")
			table.insert(lines, formatTable(child, indent + 1))
		else
			table.insert(lines, prefix .. tostring(key) .. ": " .. tostring(child))
		end
	end

	return table.concat(lines, "\n")
end

local function getInventoryText(data)
	local lines = {}

	for _, item in ipairs(data.Inventory or {}) do
		table.insert(lines, item.Uid .. " | " .. item.ItemId)
	end

	if #lines == 0 then
		return "Inventory empty"
	end

	return table.concat(lines, "\n")
end

local function showData()
	local data = AetherionDebug.Data()

	if not data then
		appendOutput("No player data")
		return
	end

	local text = {}

	table.insert(text, "PLAYER DATA")
	table.insert(text, "Name: " .. tostring(data.Name))
	table.insert(text, "Level: " .. tostring(data.Level))
	table.insert(text, "Exp: " .. tostring(data.Exp))
	table.insert(text, "Faction: " .. tostring(data.FactionId))
	table.insert(text, "StartingClass: " .. tostring(data.StartingClassId))
	table.insert(text, "")
	table.insert(text, "Equipment:")
	table.insert(text, formatTable(data.Equipment, 1))
	table.insert(text, "")
	table.insert(text, "Inventory:")
	table.insert(text, getInventoryText(data))

	appendOutput(table.concat(text, "\n"))
end

local function showStats()
	local stats = AetherionDebug.Stats()

	if not stats then
		appendOutput("No stats")
		return
	end

	local orderedKeys = {
		"Attack",
		"ForceAttack",
		"Defense",
		"MaxHP",
		"MaxFP",
		"MoveSpeed",
		"CritChance",
		"CritResistance",
		"Accuracy",
		"Dodge",
		"BlockChance",
		"RangeMultiplier",
		"LifeStealPercent",
		"IgnoreBlockChance",
		"ElementalResistanceFlat",
		"ElementalResistancePercent",
		"LauncherAttackDelayReduction",
		"ForceDelayReduction",
		"FPCostReduction",
		"FPCostIncrease",
	}

	local lines = {
		"TOTAL STATS",
	}

	for _, key in ipairs(orderedKeys) do
		table.insert(lines, key .. ": " .. tostring(stats[key]))
	end

	appendOutput(table.concat(lines, "\n"))
end

local function showWeaponSummary()
	local summary = AetherionDebug.WeaponSummary()

	if not summary then
		appendOutput("No weapon summary")
		return
	end

	local lines = {
		"WEAPON SUMMARY",
		"Total: " .. tostring(summary.Total),
		"",
		"By Level:",
	}

	for level, count in pairs(summary.ByLevel or {}) do
		table.insert(lines, "Level " .. tostring(level) .. ": " .. tostring(count))
	end

	table.insert(lines, "")
	table.insert(lines, "By Grade:")

	for grade, count in pairs(summary.ByGrade or {}) do
		table.insert(lines, "Grade " .. tostring(grade) .. ": " .. tostring(count))
	end

	table.insert(lines, "")
	table.insert(lines, "By Series:")

	for series, count in pairs(summary.BySeries or {}) do
		table.insert(lines, tostring(series) .. ": " .. tostring(count))
	end

	appendOutput(table.concat(lines, "\n"))
end

local function showWeaponsByLevel(level)
	local weapons = AetherionDebug.ListWeaponsByLevel(level, 80)

	if not weapons then
		appendOutput("No weapons")
		return
	end

	local lines = {
		"WEAPONS LEVEL " .. tostring(level),
	}

	for _, weapon in ipairs(weapons) do
		table.insert(
			lines,
			weapon.Id
				.. " | "
				.. tostring(weapon.Name)
				.. " | Grade: "
				.. tostring(weapon.Grade)
				.. " | Atk: "
				.. tostring(weapon.AttackMin)
				.. "-"
				.. tostring(weapon.AttackMax)
		)
	end

	appendOutput(table.concat(lines, "\n"))

	if weapons[1] then
		selectedWeaponId = weapons[1].Id
	end
end

local function showWeaponsByGrade(grade)
	local weapons = AetherionDebug.ListWeaponsByGrade(grade, 80)

	if not weapons then
		appendOutput("No weapons")
		return
	end

	local lines = {
		"WEAPONS GRADE " .. tostring(grade),
	}

	for _, weapon in ipairs(weapons) do
		table.insert(
			lines,
			weapon.Id
				.. " | Lv "
				.. tostring(weapon.RequiredLevel)
				.. " | "
				.. tostring(weapon.Name)
				.. " | Atk: "
				.. tostring(weapon.AttackMin)
				.. "-"
				.. tostring(weapon.AttackMax)
		)
	end

	appendOutput(table.concat(lines, "\n"))

	if weapons[1] then
		selectedWeaponId = weapons[1].Id
	end
end

local function createCharacter()
	local ok, result = AetherionDebug.CreateCharacter("MECHA", "Warrior")

	if ok then
		appendOutput("Character created: MECHA Warrior")
	else
		appendOutput("Create character failed:\n" .. tostring(result))
	end
end

local function giveWeapon(weaponId)
	if not weaponId or weaponId == "" then
		weaponId = selectedWeaponId
	end

	if not weaponId or weaponId == "" then
		appendOutput("No weapon selected. Open weapon list or type weapon ID.")
		return
	end

	local ok, result = AetherionDebug.GiveWeapon(weaponId)

	if ok then
		appendOutput("Weapon given:\n" .. formatTable(result))
	else
		appendOutput("Give weapon failed:\n" .. tostring(result))
	end
end

local function equipItem(uid)
	if not uid or uid == "" then
		uid = selectedItemUid
	end

	if not uid or uid == "" then
		appendOutput("No item UID. Copy UID from Data inventory.")
		return
	end

	local ok, result = AetherionDebug.Equip(uid)

	if ok then
		appendOutput("Equipped item:\n" .. tostring(uid))
	else
		appendOutput("Equip failed:\n" .. tostring(result))
	end
end

function AetherionDebugUI.Destroy()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
end

function AetherionDebugUI.Toggle()
	if screenGui then
		screenGui.Enabled = not screenGui.Enabled
	end
end

function AetherionDebugUI.Create()
	if screenGui then
		screenGui:Destroy()
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AetherionDebugUI"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 760, 0, 520)
	mainFrame.Position = UDim2.new(0, 24, 0, 80)
	mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = mainFrame

	createTextLabel(mainFrame, "Aetherion Debug Panel", UDim2.new(1, -20, 0, 30), UDim2.new(0, 12, 0, 10))

	local leftPanel = Instance.new("Frame")
	leftPanel.Name = "LeftPanel"
	leftPanel.Size = UDim2.new(0, 250, 1, -55)
	leftPanel.Position = UDim2.new(0, 12, 0, 50)
	leftPanel.BackgroundTransparency = 1
	leftPanel.Parent = mainFrame

	local rightPanel = Instance.new("Frame")
	rightPanel.Name = "RightPanel"
	rightPanel.Size = UDim2.new(1, -285, 1, -65)
	rightPanel.Position = UDim2.new(0, 270, 0, 50)
	rightPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
	rightPanel.BorderSizePixel = 0
	rightPanel.Parent = mainFrame

	local outputCorner = Instance.new("UICorner")
	outputCorner.CornerRadius = UDim.new(0, 8)
	outputCorner.Parent = rightPanel

	outputText = Instance.new("TextLabel")
	outputText.Name = "OutputText"
	outputText.Size = UDim2.new(1, -20, 1, -20)
	outputText.Position = UDim2.new(0, 10, 0, 10)
	outputText.BackgroundTransparency = 1
	outputText.TextColor3 = Color3.fromRGB(230, 230, 230)
	outputText.Text = "Ready.\nClick a button on the left."
	outputText.Font = Enum.Font.Code
	outputText.TextSize = 12
	outputText.TextXAlignment = Enum.TextXAlignment.Left
	outputText.TextYAlignment = Enum.TextYAlignment.Top
	outputText.TextWrapped = false
	outputText.Parent = rightPanel

	local y = 0
	local function addButton(text, callback)
		local button = createTextButton(leftPanel, text, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, y))
		y += 36
		button.MouseButton1Click:Connect(callback)
		return button
	end

	addButton("Create MECHA Warrior", createCharacter)
	addButton("Player Data", showData)
	addButton("Stats", showStats)
	addButton("Weapon Summary", showWeaponSummary)
	addButton("Weapons Level 1", function()
		showWeaponsByLevel(1)
	end)
	addButton("Grade N", function()
		showWeaponsByGrade("N")
	end)
	addButton("Grade A", function()
		showWeaponsByGrade("A")
	end)
	addButton("Grade B", function()
		showWeaponsByGrade("B")
	end)
	addButton("Grade C", function()
		showWeaponsByGrade("C")
	end)

	y += 8

	local weaponInput = createInput(leftPanel, "Weapon ID", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, y))
	y += 36

	addButton("Give Weapon", function()
		giveWeapon(weaponInput.Text)
	end)

	local uidInput = createInput(leftPanel, "Item UID", UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, y))
	y += 36

	addButton("Equip UID", function()
		equipItem(uidInput.Text)
	end)

	addButton("Refresh Data", showData)
	addButton("Hide Panel", function()
		screenGui.Enabled = false
	end)

	return screenGui
end

return AetherionDebugUI
