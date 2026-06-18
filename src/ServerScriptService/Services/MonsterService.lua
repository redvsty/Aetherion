-- MonsterService.lua
-- Batch 4: Monster AI, spawning, loot drop, respawn system.
--
-- CARA PAKAI DI STUDIO:
--   Buat Part di Workspace, beri nama bebas, tambahkan attribute:
--     MonsterDefId (string) = "anabola"   ← id dari MonsterDefinitions
--     MonsterCount (number) = 3           ← jumlah monster di spawner ini
--   MonsterService akan otomatis mendeteksi dan spawn monster di sekitar Part itu.
--
-- ARSITEKTUR:
--   - State setiap monster disimpan di `monsters` table (server-side only)
--   - Monster model adalah PVEMonster Model di workspace dengan Humanoid
--   - Tick loop 0.5s: update AI state setiap monster
--   - Saat mati: drop LootBag (Part + ProximityPrompt), respawn timer
--   - Loot protection: 10 detik hanya killer yang bisa loot, setelah itu bebas

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local HttpService     = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local MonsterDefinitions = require(game.ReplicatedStorage.Shared.Definitions.MonsterDefinitions)

local MonsterService = {}

-- ============================================================
-- Constants
-- ============================================================
local AI_TICK          = 0.5  -- detik antar AI update
local LOOT_PROTECT_SEC = 10   -- detik loot hanya untuk killer
local LOOT_EXPIRE_SEC  = 60   -- detik sebelum loot bag hilang
local SPAWNER_TAG      = "MonsterSpawner"
local PATROL_RADIUS    = 15   -- radius patrol dari spawn
local MONSTER_FOLDER_NAME = "PVEMonsters"

-- AI States
local STATE = {
	IDLE    = "Idle",
	PATROL  = "Patrol",
	AGGRO   = "Aggro",
	ATTACK  = "Attack",
	DEAD    = "Dead",
	LEASH   = "Leash",
}

-- ============================================================
-- Runtime State
-- ============================================================

-- monsters[uid] = {
--   uid, defId, def, model, humanoid, hp,
--   spawnPos, state, target, lastAttack, lastPatrol,
--   patrolTarget, killedBy, respawnAt
-- }
local monsters = {}

-- lootBags[uid] = {
--   part, killerId, dropTime, gold, items
-- }
local lootBags = {}

-- Callbacks injected from GameServer
local _onMonsterKilled  = nil  -- function(killerPlayer, monsterUid, def)
local _onDamageDealt    = nil  -- function(targetModel, damage, isCrit, attackerPlayer)

-- ============================================================
-- Monster Model Builder
-- (placeholder box model — replace dengan proper mesh di Studio)
-- ============================================================

local function getMonsterFolder()
	local folder = workspace:FindFirstChild(MONSTER_FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = MONSTER_FOLDER_NAME
		folder.Parent = workspace
	end
	return folder
end

local MONSTER_COLORS = {
	anabola       = Color3.fromRGB(120, 200, 100),
	frog          = Color3.fromRGB(80, 160, 80),
	tweezer       = Color3.fromRGB(180, 120, 60),
	splinter      = Color3.fromRGB(140, 100, 180),
	warbeast      = Color3.fromRGB(200, 80, 80),
	snatcher      = Color3.fromRGB(160, 60, 60),
	vafer         = Color3.fromRGB(220, 100, 40),
	crawler       = Color3.fromRGB(100, 80, 160),
	high_elf_guard = Color3.fromRGB(200, 180, 100),
}

local function buildMonsterModel(def, position)
	local model = Instance.new("Model")
	model.Name = def.Name

	-- Root part
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.CFrame = CFrame.new(position)
	root.Anchored = false
	root.CanCollide = true
	root.BrickColor = BrickColor.new("Dark stone grey")
	root.Parent = model

	-- Body (visual)
	local body = Instance.new("Part")
	body.Name = "UpperTorso"
	body.Size = Vector3.new(2, 2.5, 1)
	body.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
	body.Anchored = false
	body.CanCollide = false
	body.Color = MONSTER_COLORS[def.Id] or Color3.fromRGB(180, 100, 100)
	body.Parent = model

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = body
	weld.Parent = root

	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
	head.Anchored = false
	head.CanCollide = false
	head.Color = MONSTER_COLORS[def.Id] or Color3.fromRGB(180, 100, 100)
	head.Parent = model

	local headWeld = Instance.new("WeldConstraint")
	headWeld.Part0 = root
	headWeld.Part1 = head
	headWeld.Parent = root

	-- HP bar BillboardGui
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "MonsterHPBar"
	billboard.Size = UDim2.new(0, 120, 0, 18)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = false
	billboard.Adornee = head
	billboard.Parent = head

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	bg.BorderSizePixel = 0
	bg.Parent = billboard

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	fill.BorderSizePixel = 0
	fill.Parent = bg

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "MonsterName"
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, -1.2, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.BuilderSansBold
	nameLabel.Text = def.Name .. " (Lv." .. def.Level .. ")"
	nameLabel.Parent = bg

	-- Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = def.MaxHP
	humanoid.Health = def.MaxHP
	humanoid.WalkSpeed = def.MoveSpeed
	humanoid.JumpPower = 0
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = model

	model.PrimaryPart = root

	-- Tag untuk identifikasi
	local tag = Instance.new("StringValue")
	tag.Name = "MonsterTag"
	tag.Value = def.Id
	tag.Parent = model

	model.Parent = getMonsterFolder()
	return model, humanoid
end

-- ============================================================
-- HP Bar Update
-- ============================================================

local function updateHPBar(monsterState)
	local model = monsterState.model
	if not model or not model.Parent then return end

	local head = model:FindFirstChild("Head")
	if not head then return end

	local billboard = head:FindFirstChild("MonsterHPBar")
	if not billboard then return end

	local fill = billboard:FindFirstChildOfClass("Frame") and
		billboard:FindFirstChildOfClass("Frame"):FindFirstChild("Fill")
	if not fill then return end

	local pct = math.clamp(monsterState.hp / monsterState.def.MaxHP, 0, 1)
	fill.Size = UDim2.new(pct, 0, 1, 0)
end

-- ============================================================
-- Loot Bag
-- ============================================================

local function spawnLootBag(position, killerPlayer, def)
	local uid = HttpService:GenerateGUID(false)

	local part = Instance.new("Part")
	part.Name = "LootBag_" .. uid
	part.Size = Vector3.new(1.5, 1, 1.5)
	part.Position = position + Vector3.new(0, 0.5, 0)
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromRGB(255, 215, 0)
	part.Material = Enum.Material.Neon
	part.CastShadow = false
	part.Parent = workspace

	-- Glow decoration
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Adornee = part
	selectionBox.Color3 = Color3.fromRGB(255, 215, 0)
	selectionBox.LineThickness = 0.05
	selectionBox.Parent = part

	-- ProximityPrompt untuk pickup
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "Loot"
	prompt.ActionText = "Pick Up"
	prompt.MaxActivationDistance = 8
	prompt.HoldDuration = 0
	prompt.Parent = part

	-- Gold amount
	local gold = math.random(def.GoldMin, def.GoldMax)

	lootBags[uid] = {
		part      = part,
		prompt    = prompt,
		killerId  = killerPlayer and killerPlayer.UserId or nil,
		dropTime  = tick(),
		gold      = gold,
		items     = {},  -- item drops (Batch 5 akan isi berdasarkan DropTable)
		defLevel  = def.Level,
	}

	-- ProximityPrompt handler
	prompt.Triggered:Connect(function(triggeringPlayer)
		local bag = lootBags[uid]
		if not bag or not bag.part or not bag.part.Parent then return end

		-- Loot protection: 10 detik hanya killer
		local now = tick()
		if bag.killerId and triggeringPlayer.UserId ~= bag.killerId then
			if now - bag.dropTime < LOOT_PROTECT_SEC then
				return -- still protected
			end
		end

		-- Ambil loot
		lootBags[uid] = nil
		bag.part:Destroy()

		-- Deliver gold + items ke player
		MonsterService.DeliverLoot(triggeringPlayer, bag)
	end)

	-- Auto expire
	task.delay(LOOT_EXPIRE_SEC, function()
		if lootBags[uid] then
			lootBags[uid] = nil
		end
		if part.Parent then
			part:Destroy()
		end
	end)

	return uid
end

-- ============================================================
-- Spawn Monster
-- ============================================================

local function spawnMonster(defId, spawnPos)
	local def = MonsterDefinitions.Get(defId)
	if not def then
		warn("[MonsterService] Unknown monster defId:", defId)
		return nil
	end

	local uid = HttpService:GenerateGUID(false)

	-- Offset posisi agar tidak tumpeng-tindih
	local offset = Vector3.new(
		math.random(-8, 8),
		0,
		math.random(-8, 8)
	)
	local pos = spawnPos + offset + Vector3.new(0, 3, 0)

	local model, humanoid = buildMonsterModel(def, pos)

	local state = {
		uid         = uid,
		defId       = defId,
		def         = def,
		model       = model,
		humanoid    = humanoid,
		hp          = def.MaxHP,
		spawnPos    = spawnPos,
		state       = STATE.IDLE,
		target      = nil,
		lastAttack  = 0,
		lastPatrol  = 0,
		patrolTarget = nil,
		killedBy    = nil,
		respawnAt   = nil,
		spawnerPos  = spawnPos,
	}

	monsters[uid] = state

	-- Hubungkan Humanoid.Died ke respawn
	humanoid.Died:Connect(function()
		if monsters[uid] then
			monsters[uid].state = STATE.DEAD
			monsters[uid].respawnAt = tick() + def.RespawnTime
		end
	end)

	return uid
end

-- ============================================================
-- AI Helpers
-- ============================================================

local function getCharacterPos(player)
	local char = player and player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	return hrp and hrp.Position or nil
end

local function distanceTo(posA, posB)
	return (posA - posB).Magnitude
end

local function findNearestPlayer(monsterPos, aggroRadius)
	local nearest, nearestDist = nil, aggroRadius

	for _, player in ipairs(Players:GetPlayers()) do
		local pos = getCharacterPos(player)
		if pos then
			local d = distanceTo(monsterPos, pos)
			if d < nearestDist then
				nearest = player
				nearestDist = d
			end
		end
	end

	return nearest, nearestDist
end

local function getMonsterPos(monsterState)
	local root = monsterState.model and monsterState.model:FindFirstChild("HumanoidRootPart")
	return root and root.Position or monsterState.spawnPos
end

local function randomPatrolTarget(origin, radius)
	return origin + Vector3.new(
		math.random(-radius, radius),
		0,
		math.random(-radius, radius)
	)
end

-- ============================================================
-- AI Tick
-- ============================================================

local function tickMonsterAI(uid, monsterState, now)
	local def = monsterState.def
	local model = monsterState.model

	-- Model sudah hancur (edge case)
	if not model or not model.Parent then
		if monsterState.state ~= STATE.DEAD then
			monsterState.state = STATE.DEAD
			monsterState.respawnAt = now + def.RespawnTime
		end
		return
	end

	local humanoid = monsterState.humanoid
	if not humanoid or humanoid.Health <= 0 then
		return -- handled via Died event
	end

	local monPos = getMonsterPos(monsterState)
	local state  = monsterState.state

	-- ── LEASH ────────────────────────────────────────────────
	if state == STATE.LEASH then
		local distFromSpawn = distanceTo(monPos, monsterState.spawnPos)
		if distFromSpawn < 5 then
			-- Kembali ke spawn, reset ke idle
			humanoid:MoveTo(monsterState.spawnPos)
			monsterState.state = STATE.IDLE
			monsterState.target = nil
			humanoid.WalkSpeed = def.MoveSpeed
			-- Heal penuh saat kembali ke spawn
			monsterState.hp = def.MaxHP
			humanoid.Health = def.MaxHP
			updateHPBar(monsterState)
		else
			humanoid:MoveTo(monsterState.spawnPos)
		end
		return
	end

	-- ── IDLE / PATROL ─────────────────────────────────────────
	if state == STATE.IDLE or state == STATE.PATROL then
		-- Cari player terdekat
		local nearPlayer, nearDist = findNearestPlayer(monPos, def.AggroRadius)
		if nearPlayer then
			monsterState.state  = STATE.AGGRO
			monsterState.target = nearPlayer
			return
		end

		-- Patrol
		if state == STATE.IDLE and now - monsterState.lastPatrol > 4 then
			monsterState.patrolTarget = randomPatrolTarget(monsterState.spawnPos, PATROL_RADIUS)
			monsterState.state = STATE.PATROL
			monsterState.lastPatrol = now
		end

		if state == STATE.PATROL and monsterState.patrolTarget then
			local distToPt = distanceTo(monPos, monsterState.patrolTarget)
			if distToPt < 3 then
				monsterState.state = STATE.IDLE
			else
				humanoid:MoveTo(monsterState.patrolTarget)
			end
		end
		return
	end

	-- ── AGGRO / CHASE ─────────────────────────────────────────
	if state == STATE.AGGRO then
		local target = monsterState.target
		if not target or not target.Parent then
			monsterState.state  = STATE.LEASH
			monsterState.target = nil
			return
		end

		local targetPos = getCharacterPos(target)
		if not targetPos then
			monsterState.state  = STATE.LEASH
			monsterState.target = nil
			return
		end

		-- Leash check
		local distFromSpawn = distanceTo(monPos, monsterState.spawnPos)
		if distFromSpawn > def.LeashRadius then
			monsterState.state  = STATE.LEASH
			monsterState.target = nil
			return
		end

		local distToTarget = distanceTo(monPos, targetPos)

		-- Dalam range serang?
		if distToTarget <= def.AttackRange then
			monsterState.state = STATE.ATTACK
			humanoid:MoveTo(monPos) -- berhenti bergerak
		else
			humanoid:MoveTo(targetPos)
		end
		return
	end

	-- ── ATTACK ───────────────────────────────────────────────
	if state == STATE.ATTACK then
		local target = monsterState.target
		if not target or not target.Parent then
			monsterState.state  = STATE.LEASH
			monsterState.target = nil
			return
		end

		local targetPos = getCharacterPos(target)
		if not targetPos then
			monsterState.state  = STATE.LEASH
			monsterState.target = nil
			return
		end

		local distToTarget = distanceTo(monPos, targetPos)

		-- Target keluar dari range?
		if distToTarget > def.AttackRange + 2 then
			monsterState.state = STATE.AGGRO
			return
		end

		-- Attack cooldown
		if now - monsterState.lastAttack >= def.AttackDelay then
			monsterState.lastAttack = now

			-- Apply damage ke player
			local char = target.Character
			local humanoidTarget = char and char:FindFirstChildOfClass("Humanoid")
			if humanoidTarget and humanoidTarget.Health > 0 then
				local variance = 0.9 + math.random() * 0.2
				local rawDmg = math.floor(def.Attack * variance)
				local isCrit = math.random() < 0.05
				if isCrit then rawDmg = math.floor(rawDmg * 1.5) end
				rawDmg = math.max(1, rawDmg)

				humanoidTarget:TakeDamage(rawDmg)

				-- Callback ke GameServer untuk update Stats.HP + damage number
				if _onDamageDealt then
					_onDamageDealt(char, rawDmg, isCrit, nil) -- nil = monster attacker
				end
			end
		end
		return
	end
end

-- ============================================================
-- Respawn Tick
-- ============================================================

local function tickRespawns(now)
	for uid, state in pairs(monsters) do
		if state.state == STATE.DEAD and state.respawnAt and now >= state.respawnAt then
			-- Hapus model lama jika masih ada
			if state.model and state.model.Parent then
				state.model:Destroy()
			end

			-- Respawn monster baru
			monsters[uid] = nil
			spawnMonster(state.defId, state.spawnerPos)
		end
	end
end

-- ============================================================
-- Main AI Loop
-- ============================================================

local function startAILoop()
	task.spawn(function()
		while true do
			task.wait(AI_TICK)
			local now = tick()

			for uid, state in pairs(monsters) do
				if state.state ~= STATE.DEAD then
					local ok, err = pcall(tickMonsterAI, uid, state, now)
					if not ok then
						warn("[MonsterService] AI error for", uid, ":", err)
					end
				end
			end

			tickRespawns(now)
		end
	end)
end

-- ============================================================
-- Public API
-- ============================================================

-- Dipanggil dari GameServer saat player menyerang monster
-- targetModel = model di workspace dengan MonsterTag
-- Mengembalikan: ok, { Damage, IsCrit, Killed }
function MonsterService.AttackMonster(attackerPlayer, targetModel, attackerStats)
	if not targetModel or not targetModel.Parent then
		return false, "Target tidak ditemukan"
	end

	local tag = targetModel:FindFirstChild("MonsterTag")
	if not tag then
		return false, "Bukan monster"
	end

	-- Cari state monster berdasarkan model
	local monsterState = nil
	for _, state in pairs(monsters) do
		if state.model == targetModel then
			monsterState = state
			break
		end
	end

	if not monsterState then
		return false, "Monster state tidak ditemukan"
	end

	if monsterState.state == STATE.DEAD then
		return false, "Monster sudah mati"
	end

	local def = monsterState.def

	-- Hitung damage (menggunakan formula mirip CombatService)
	local attack = attackerStats and attackerStats.Attack or 10
	local defense = def.Defense
	local variance = 0.9 + math.random() * 0.2
	local defReduction = defense / (defense + 100)
	local rawDmg = math.floor(attack * variance * (1 - defReduction))
	local isCrit = math.random() < (attackerStats and attackerStats.CritChance or 0.05)
	if isCrit then rawDmg = math.floor(rawDmg * 1.5) end
	rawDmg = math.max(1, rawDmg)

	-- Apply damage
	monsterState.hp = monsterState.hp - rawDmg
	if monsterState.humanoid and monsterState.humanoid.Parent then
		monsterState.humanoid.Health = math.max(0, monsterState.humanoid.Health - rawDmg)
	end
	updateHPBar(monsterState)

	-- Set aggro ke attacker
	if monsterState.state == STATE.IDLE or monsterState.state == STATE.PATROL then
		monsterState.state  = STATE.AGGRO
		monsterState.target = attackerPlayer
	end

	local killed = false

	-- Mati?
	if monsterState.hp <= 0 then
		killed = true
		monsterState.killedBy = attackerPlayer
		monsterState.state = STATE.DEAD
		monsterState.respawnAt = tick() + def.RespawnTime

		if monsterState.humanoid and monsterState.humanoid.Parent then
			monsterState.humanoid.Health = 0
		end

		-- Drop loot
		local monPos = getMonsterPos(monsterState)
		spawnLootBag(monPos, attackerPlayer, def)

		-- Hancurkan model setelah delay singkat
		task.delay(2, function()
			if monsterState.model and monsterState.model.Parent then
				monsterState.model:Destroy()
			end
		end)

		-- Callback ke GameServer untuk beri EXP + gold
		if _onMonsterKilled then
			_onMonsterKilled(attackerPlayer, monsterState.uid, def)
		end
	end

	return true, { Damage = rawDmg, IsCrit = isCrit, Killed = killed, MonsterName = def.Name }
end

-- Dipanggil dari GameServer untuk deliver loot ke player
function MonsterService.DeliverLoot(player, bag)
	if not _onMonsterKilled then return end
	-- Injected dari GameServer
	if MonsterService._deliverLootCallback then
		MonsterService._deliverLootCallback(player, bag)
	end
end

-- Cek apakah sebuah model adalah monster
function MonsterService.IsMonster(model)
	return model and model:FindFirstChild("MonsterTag") ~= nil
end

-- Init spawners dari workspace (cari Part dengan attribute MonsterDefId)
function MonsterService.InitSpawners()
	local spawnCount = 0

	-- Cari semua Part di workspace yang punya attribute MonsterDefId
	local function scanForSpawners(parent)
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("BasePart") or child:IsA("Model") then
				local defId = child:GetAttribute("MonsterDefId")
				local count = child:GetAttribute("MonsterCount") or 1

				if defId then
					local pos
					if child:IsA("BasePart") then
						pos = child.Position
					elseif child:IsA("Model") and child.PrimaryPart then
						pos = child.PrimaryPart.Position
					else
						pos = Vector3.new(0, 5, 0)
					end

					for i = 1, count do
						spawnMonster(defId, pos)
						spawnCount += 1
					end
				end
			end

			-- Rekursif ke children (folder, model)
			if child:IsA("Folder") or child:IsA("Model") then
				scanForSpawners(child)
			end
		end
	end

	scanForSpawners(workspace)

	print(string.format("[MonsterService] Initialized %d monsters dari spawners.", spawnCount))

	if spawnCount == 0 then
		print("[MonsterService] Tidak ada spawner ditemukan.")
		print("[MonsterService] Tambahkan Part di workspace dengan attribute:")
		print("  MonsterDefId (string) = 'anabola'")
		print("  MonsterCount (number) = 3")
	end

	startAILoop()
end

-- Init monster langsung dari MapDefinitions.SpawnConfig + Zones.
-- Tidak perlu Parts di workspace. Dipanggil setelah _MapGenerated.
function MonsterService.InitFromMapConfig(spawnConfig, zonesConfig)
	local totalSpawned = 0

	for zoneId, spawnEntries in pairs(spawnConfig) do
		local zone = zonesConfig[zoneId]
		if not zone then
			warn("[MonsterService] Zone tidak ditemukan di MapDefinitions:", zoneId)
			continue
		end

		local center = zone.Center
		local zoneRadius = zone.Radius or 400

		for _, entry in ipairs(spawnEntries) do
			local defId   = entry.DefId
			local count   = entry.Count or 1
			local spread  = math.min(entry.Spread or zoneRadius * 0.6, zoneRadius * 0.85)

			for _ = 1, count do
				local angle = math.random() * math.pi * 2
				local dist  = math.random() * spread
				local pos   = Vector3.new(
					center.X + math.cos(angle) * dist,
					center.Y + 3,
					center.Z + math.sin(angle) * dist
				)
				spawnMonster(defId, pos)
				totalSpawned += 1
			end
		end

		task.wait()  -- yield antar zone agar tidak timeout
	end

	print(string.format("[MonsterService] %d monster di-spawn dari MapConfig (%d zone).",
		totalSpawned, #spawnConfig))
	startAILoop()
end

-- Set callbacks dari GameServer
function MonsterService.SetCallbacks(onKilled, onDamage, deliverLoot)
	_onMonsterKilled = onKilled
	_onDamageDealt   = onDamage
	MonsterService._deliverLootCallback = deliverLoot
end

return MonsterService
