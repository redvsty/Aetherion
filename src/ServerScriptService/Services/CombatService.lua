local Players = game:GetService("Players")

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local ItemDefinitions = require(game.ReplicatedStorage.Shared.Definitions.ItemDefinitions)
local CombatFormulas = require(game.ReplicatedStorage.Shared.CombatFormulas)

local EquipmentService = require(script.Parent.EquipmentService)

local CombatService = {}

local function getPlayerFromModel(model)
	return Players:GetPlayerFromCharacter(model)
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
	local attackerData = profiles[attackerPlayer]

	if not attackerData then
		return false, "No attacker data"
	end

	local attackerCharacter = attackerPlayer.Character

	if not attackerCharacter or not targetModel then
		return false, "Invalid target"
	end

	local attackerRoot = attackerCharacter:FindFirstChild("HumanoidRootPart")
	local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
	local targetHumanoid = targetModel:FindFirstChildOfClass("Humanoid")

	if not attackerRoot or not targetRoot or not targetHumanoid then
		return false, "Invalid target model"
	end

	local distance = (attackerRoot.Position - targetRoot.Position).Magnitude

	if distance > GameConfig.Combat.MaxAttackDistance then
		return false, "Target too far"
	end

	local targetPlayer = getPlayerFromModel(targetModel)
	local targetData = targetPlayer and profiles[targetPlayer] or nil

	if targetData and not CombatService.CanDamage(attackerData, targetData) then
		return false, "Cannot damage same faction"
	end

	local attackerStats = EquipmentService.GetTotalStats(attackerData)
	local defenderStats = {
		Defense = 5,
	}

	if targetData then
		defenderStats = EquipmentService.GetTotalStats(targetData)
	end

	local damage, isCrit = CombatFormulas.CalculateDamage(attackerStats, defenderStats)

	if defenderStats.CritResistance and defenderStats.CritResistance > 0 then
		if isCrit and math.random() < defenderStats.CritResistance then
			isCrit = false
			damage = math.floor(damage / GameConfig.Combat.CritMultiplier)
		end
	end

	targetHumanoid:TakeDamage(damage)

	if attackerStats.LifeStealPercent and attackerStats.LifeStealPercent > 0 then
		local attackerHumanoid = attackerCharacter:FindFirstChildOfClass("Humanoid")

		if attackerHumanoid then
			local healAmount = math.floor(damage * attackerStats.LifeStealPercent)

			attackerHumanoid.Health = math.min(attackerHumanoid.MaxHealth, attackerHumanoid.Health + healAmount)
		end
	end

	return true, {
		Damage = damage,
		Crit = isCrit,
	}
end

return CombatService
