-- LevelService.lua
-- Batch 3: Level up system dengan stat scaling per class & race (RF Classic).
--
-- EXP threshold: menggunakan CombatFormulas.GetRequiredPlayerExp (existing)
-- Saat level up:
--   1. MaxHP/MaxFP/MaxSP naik sesuai class scaling + race modifier
--   2. HP/FP/SP di-restore ke max (RF Classic: level up = full restore)
--   3. Cek threshold L30/L40 advancement

local GameConfig       = require(game.ReplicatedStorage.Shared.GameConfig)
local CombatFormulas   = require(game.ReplicatedStorage.Shared.CombatFormulas)
local RaceDefinitions  = require(game.ReplicatedStorage.Shared.Definitions.RaceDefinitions)

local LevelService = {}

-- Hitung stats final (MaxHP/MaxFP/MaxSP) berdasarkan class + ras + level
function LevelService.CalcStats(playerData)
	if not playerData.FactionId or not playerData.StartingClassId then
		return { MaxHP = 150, MaxFP = 100, MaxSP = 200 }
	end
	return RaceDefinitions.CalcFinalStats(
		playerData.FactionId,
		playerData.StartingClassId,
		playerData.Level or 1
	)
end

-- Apply stats ke playerData.Stats
-- restore=true  → RF Classic level up: full HP/FP/SP restore
-- restore=false → cap ke max baru tanpa heal (misal equip perubahan)
function LevelService.ApplyStats(playerData, restore)
	local newStats = LevelService.CalcStats(playerData)
	local s = playerData.Stats

	s.MaxHP = newStats.MaxHP
	s.MaxFP = newStats.MaxFP
	s.MaxSP = newStats.MaxSP

	if restore then
		s.HP = s.MaxHP
		s.FP = s.MaxFP
		s.SP = s.MaxSP
	else
		s.HP = math.min(s.HP or s.MaxHP, s.MaxHP)
		s.FP = math.min(s.FP or s.MaxFP, s.MaxFP)
		s.SP = math.min(s.SP or s.MaxSP, s.MaxSP)
	end
end

-- Tambahkan EXP, proses level up jika perlu
-- staminaService + player: opsional, untuk refresh MaxSP di StaminaService
-- Mengembalikan: levelsGained, newLevel
function LevelService.AddExp(playerData, amount, player, staminaService)
	if not playerData then return 0, 1 end

	if playerData.Level >= GameConfig.MaxLevel then
		playerData.Level = GameConfig.MaxLevel
		playerData.Exp = 0
		return 0, playerData.Level
	end

	playerData.Exp = (playerData.Exp or 0) + math.max(0, amount)

	local levelsGained = 0

	while playerData.Level < GameConfig.MaxLevel do
		local required = CombatFormulas.GetRequiredPlayerExp(playerData.Level)
		if playerData.Exp < required then break end

		playerData.Exp = playerData.Exp - required
		playerData.Level = playerData.Level + 1
		levelsGained = levelsGained + 1

		-- RF Classic: level up = full restore HP/FP/SP
		LevelService.ApplyStats(playerData, true)

		-- Update StaminaService MaxSP
		if staminaService and player then
			staminaService.RefreshMaxSP(player, playerData)
		end

		-- Cek advancement threshold
		if playerData.Level == GameConfig.AdvancementLevels.First
			and not playerData.ClassLevel30Id then
			playerData.NeedsLevel30ClassSelection = true
		end

		if playerData.Level == GameConfig.AdvancementLevels.Second
			and not playerData.ClassLevel40Id then
			playerData.NeedsLevel40ClassSelection = true
		end
	end

	if playerData.Level >= GameConfig.MaxLevel then
		playerData.Level = GameConfig.MaxLevel
		playerData.Exp = 0
	end

	return levelsGained, playerData.Level
end

return LevelService
