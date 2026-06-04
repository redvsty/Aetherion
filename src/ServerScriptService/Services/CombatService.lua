-- CombatService.lua
-- Fix 2: PT Exp diberikan ke attacker setelah berhasil hit, sesuai weapon PT type.
-- Fix 5: Server-side validation diperkuat:
--   - Rate limiting per player (cooldown antar attack)
--   - Validasi distance server-side (tidak bergantung client)
--   - Validasi target humanoid masih hidup
--   - Cek attacker character server-side

local Players = game:GetService("Players")

local GameConfig    = require(game.ReplicatedStorage.Shared.GameConfig)
local ItemDefinitions  = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local CombatFormulas   = require(game.ReplicatedStorage.Shared.CombatFormulas)
local EquipmentService = require(script.Parent.EquipmentService)
local LevelService     = require(script.Parent.LevelService)

local CombatService = {}

-- Fix 5: Rate limit — minimum detik antar attack per player (server-side)
local ATTACK_COOLDOWN = 0.4  -- detik, sesuaikan dengan attack speed design
local lastAttackTime  = {}   -- [player] = tick()

local function getPlayerFromModel(model)
	return Players:GetPlayerFromCharacter(model)
end

-- Ambil PT type dari weapon yang sedang diequip attacker
local function getAttackerWeaponPTType(attackerData)
	local weaponUid = attackerData.Equipment and attackerData.Equipment.Weapon

	if not weaponUid then
		return GameConfig.PTTypes.Melee  -- default fallback
	end

	-- Cari item di inventory
	for _, item in ipairs(attackerData.Inventory) do
		if item.Uid == weaponUid then
			local itemDef = ItemDefinitions[item.ItemId]

			if itemDef and itemDef.WeaponType then
				return itemDef.WeaponType
			end
		end
	end

	return GameConfig.PTTypes.Melee
end

-- Fix 2: Beri PT exp ke attacker sesuai weapon type, lalu cek PT level up
local function grantPTExp(attackerData, ptType, targetLevel)
	if not attackerData.PT then
		return
	end

	local pt = attackerData.PT[ptType]

	if not pt then
		return
	end

	local gain = math.max(1, math.floor(
		CombatFormulas.GetPTExpGain(pt.Level, targetLevel or 1, 10)
	))

	pt.Exp += gain

	-- Cek level up PT
	while true do
		local required = CombatFormulas.GetRequiredPTExp(pt.Level)

		if pt.Exp < required then
			break
		end

		pt.Exp  -= required
		pt.Level += 1
	end
end

function CombatService.CanDamage(attackerData, targetData)
	if not attackerData or not targetData then
		return false
	end

	if attackerData.FactionId ~= targetData.FactionId then
		return true
	end

	local now = os.time()

	if attackerData.ChaosUntil and attackerData.ChaosUntil > now then
		return true
	end

	return false
end

function CombatService.Attack(attackerPlayer, targetModel, profiles)
	-- Fix 5a: Rate limiting
	local now = tick()
	local lastTime = lastAttackTime[attackerPlayer] or 0

	if (now - lastTime) < ATTACK_COOLDOWN then
		return false, "Attack too fast"
	end

	lastAttackTime[attackerPlayer] = now

	-- Fix 5b: Validasi attacker data
	local attackerData = profiles[attackerPlayer]

	if not attackerData then
		return false, "No attacker data"
	end

	-- Fix 5c: Validasi attacker belum memilih faction (baru join)
	if not attackerData.FactionId then
		return false, "Attacker has no faction"
	end

	-- Fix 5d: Ambil character attacker dari SERVER (bukan percaya client)
	local attackerCharacter = attackerPlayer.Character

	if not attackerCharacter then
		return false, "Attacker has no character"
	end

	-- Fix 5e: Validasi target model valid (bukan nil / bukan string)
	if not targetModel or typeof(targetModel) ~= "Instance" then
		return false, "Invalid target"
	end

	local attackerRoot   = attackerCharacter:FindFirstChild("HumanoidRootPart")
	local targetRoot     = targetModel:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")

	if not attackerRoot or not targetRoot or not targetHumanoid then
		return false, "Invalid target model"
	end

	-- Fix 5f: Cek target masih hidup di server
	if targetHumanoid.Health <= 0 then
		return false, "Target already dead"
	end

	-- Fix 5g: Validasi jarak SERVER-SIDE (tidak percaya posisi dari client)
	local distance = (attackerRoot.Position - targetRoot.Position).Magnitude

	if distance > GameConfig.Combat.MaxAttackDistance then
		return false, "Target too far"
	end

	-- Fix 5h: Cek faction / PvP rules
	local targetPlayer = getPlayerFromModel(targetModel)
	local targetData   = targetPlayer and profiles[targetPlayer] or nil

	if targetData and not CombatService.CanDamage(attackerData, targetData) then
		return false, "Cannot damage same faction"
	end

	-- Hitung damage
	local attackerStats = EquipmentService.GetTotalStats(attackerData)
	local defenderStats = { Defense = 5 }

	if targetData then
		defenderStats = EquipmentService.GetTotalStats(targetData)
	end

	local damage, isCrit = CombatFormulas.CalculateDamage(attackerStats, defenderStats)

	targetHumanoid:TakeDamage(damage)

	-- Fix 2: Grant PT exp ke attacker sesuai weapon type
	local ptType      = getAttackerWeaponPTType(attackerData)
	local targetLevel = targetData and targetData.Level or 1
	grantPTExp(attackerData, ptType, targetLevel)

	-- Juga grant Defense PT ke defender jika player
	if targetData then
		grantPTExp(targetData, GameConfig.PTTypes.Defense, attackerData.Level)
	end

	return true, {
		Damage = damage,
		Crit   = isCrit,
	}
end

-- Cleanup rate limit saat player leave
function CombatService.OnPlayerRemoving(player)
	lastAttackTime[player] = nil
end

return CombatService
