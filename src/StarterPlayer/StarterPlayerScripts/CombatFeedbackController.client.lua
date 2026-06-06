-- CombatFeedbackController.client.lua
-- Batch 4: Floating damage numbers + loot gold notification
--
-- DamageNumberEvent(worldPos, damage, isCrit, isPlayerAttacking)
--   worldPos           = Vector3 posisi target
--   damage             = angka damage
--   isCrit             = boolean (crit = kuning + besar)
--   isPlayerAttacking  = true jika player yang menyerang (putih), false jika monster serang player (merah)
--
-- LootGoldEvent(gold)  = notifikasi gold yang didapat dari loot bag

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local StarterGui        = game:GetService("StarterGui")

-- Sembunyikan semua health display bawaan Roblox — pakai HUD custom Aetherion saja.
-- Ada dua sumber: CoreGui Health (chat area) dan HealthGui ScreenGui di PlayerGui.
local function hideRobloxHealthBar()
	-- CoreGui health display
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	end)

	-- HealthGui ScreenGui di PlayerGui (bar kanan atas default Roblox)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
	if playerGui then
		local healthGui = playerGui:FindFirstChild("HealthGui")
		if healthGui then
			healthGui.Enabled = false
		end
		-- Listener: HealthGui bisa respawn setiap character respawn
		playerGui.ChildAdded:Connect(function(child)
			if child.Name == "HealthGui" then
				child.Enabled = false
			end
		end)
	end
end

hideRobloxHealthBar()

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- Tunggu remotes tersedia
local remotes = ReplicatedStorage:WaitForChild("Remotes", 30)
if not remotes then return end

local DamageNumberEvent = remotes:WaitForChild("DamageNumberEvent", 30)
local LootGoldEvent     = remotes:WaitForChild("LootGoldEvent", 30)

-- ============================================================
-- Damage Number
-- ============================================================

local DAMAGE_LIFETIME = 1.5  -- detik sebelum fade out
local FLOAT_HEIGHT    = 6    -- studs ke atas
local MAX_DISTANCE    = 80   -- studs max dari camera untuk render

local function createDamageNumber(worldPos, damage, isCrit, isPlayerDamage)
	-- Cek jarak dari camera
	local camPos = Camera.CFrame.Position
	if (camPos - worldPos).Magnitude > MAX_DISTANCE then return end

	-- Root part sementara untuk BillboardGui
	local adornee = Instance.new("Part")
	adornee.Size = Vector3.new(0.1, 0.1, 0.1)
	adornee.Position = worldPos + Vector3.new(
		math.random(-10, 10) * 0.1,
		2,
		math.random(-10, 10) * 0.1
	)
	adornee.Anchored = true
	adornee.CanCollide = false
	adornee.Transparency = 1
	adornee.CastShadow = false
	adornee.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, isCrit and 80 or 60, 0, isCrit and 36 or 28)
	billboard.StudsOffset = Vector3.new(0, 0, 0)
	billboard.AlwaysOnTop = false
	billboard.Adornee = adornee
	billboard.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = isCrit and ("CRIT! " .. tostring(damage)) or tostring(damage)
	label.TextStrokeTransparency = 0.4
	label.TextStrokeColor3 = Color3.new(0, 0, 0)

	if isCrit then
		label.TextColor3 = Color3.fromRGB(255, 220, 0)  -- kuning
	elseif isPlayerDamage then
		label.TextColor3 = Color3.fromRGB(255, 255, 255)  -- putih (player serang monster)
	else
		label.TextColor3 = Color3.fromRGB(255, 80, 80)  -- merah (monster serang player)
	end

	label.Parent = billboard

	-- Animasi: float up + fade out
	local targetPos = adornee.Position + Vector3.new(0, FLOAT_HEIGHT, 0)

	local tweenInfo = TweenInfo.new(
		DAMAGE_LIFETIME,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(adornee, tweenInfo, { Position = targetPos })
	tween:Play()

	-- Fade out label di akhir
	task.delay(DAMAGE_LIFETIME * 0.6, function()
		local fadeInfo = TweenInfo.new(DAMAGE_LIFETIME * 0.4)
		TweenService:Create(label, fadeInfo, { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	end)

	task.delay(DAMAGE_LIFETIME + 0.1, function()
		if adornee and adornee.Parent then
			adornee:Destroy()
		end
	end)
end

if DamageNumberEvent then
	DamageNumberEvent.OnClientEvent:Connect(function(worldPos, damage, isCrit, isPlayerAttacking)
		createDamageNumber(worldPos, damage, isCrit, isPlayerAttacking)
	end)
end

-- ============================================================
-- Loot Gold Notification
-- ============================================================

local function showGoldNotif(gold)
	-- Cari ScreenGui HUD atau buat tempat sementara
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not playerGui then return end

	local gui = playerGui:FindFirstChild("GoldNotifGui")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "GoldNotifGui"
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = playerGui
	end

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 160, 0, 34)
	notif.AnchorPoint = Vector2.new(0.5, 0)
	notif.Position = UDim2.new(0.5, 0, 0.75, 0)
	notif.BackgroundColor3 = Color3.fromRGB(40, 35, 0)
	notif.BackgroundTransparency = 0.2
	notif.BorderSizePixel = 0
	notif.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = notif

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "+ " .. tostring(gold) .. " Gold"
	label.TextColor3 = Color3.fromRGB(255, 215, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.Parent = notif

	-- Float up + fade
	task.spawn(function()
		task.wait(0.8)
		local fadeInfo = TweenInfo.new(0.5)
		TweenService:Create(notif, fadeInfo, {
			Position = UDim2.new(0.5, 0, 0.72, 0),
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(label, fadeInfo, { TextTransparency = 1 }):Play()
		task.wait(0.6)
		notif:Destroy()
	end)
end

if LootGoldEvent then
	LootGoldEvent.OnClientEvent:Connect(function(gold)
		showGoldNotif(gold)
	end)
end
