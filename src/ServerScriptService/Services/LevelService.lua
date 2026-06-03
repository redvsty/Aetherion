local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local CombatFormulas = require(game.ReplicatedStorage.Shared.CombatFormulas)

local LevelService = {}

function LevelService.AddExp(playerData, amount)
	if playerData.Level >= GameConfig.MaxLevel then
		playerData.Level = GameConfig.MaxLevel
		playerData.Exp = 0
		return false, "Max level reached"
	end

	playerData.Exp += math.max(0, amount)

	while playerData.Level < GameConfig.MaxLevel do
		local required = CombatFormulas.GetRequiredPlayerExp(playerData.Level)

		if playerData.Exp < required then
			break
		end

		playerData.Exp -= required
		playerData.Level += 1

		if playerData.Level == GameConfig.AdvancementLevels.First and playerData.ClassLevel30Id == nil then
			playerData.NeedsLevel30ClassSelection = true
		end

		if playerData.Level == GameConfig.AdvancementLevels.Second and playerData.ClassLevel40Id == nil then
			playerData.NeedsLevel40ClassSelection = true
		end
	end

	if playerData.Level >= GameConfig.MaxLevel then
		playerData.Level = GameConfig.MaxLevel
		playerData.Exp = 0
	end

	return true, playerData.Level
end

return LevelService
