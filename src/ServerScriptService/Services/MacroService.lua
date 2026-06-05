-- MacroService.lua
-- Patch RF-Accuracy: Macro System sesuai RF Classic
-- Sumber: https://wiki.rfdatabase.net/game-controls/macro-system
--
-- RF Classic Macro System:
--   - Player bisa assign skill/force ke macro slot (F1-F9 atau custom)
--   - Macro bisa berupa single skill atau skill chain (urutan)
--   - Auto-use potion juga bisa di-macro
--   - Macro execute satu skill per trigger, lanjut ke skill berikutnya di rantai
--
-- Implementasi Roblox:
--   - Macro data disimpan di playerData.Macros
--   - Client trigger macro via RemoteEvent (ExecuteMacroRequest)
--   - Server validasi dan jalankan SkillService.Cast

local MacroService = {}

-- ============================================================
-- Konstanta
-- ============================================================

local MAX_MACRO_SLOTS = 9       -- F1-F9
local MAX_SKILLS_PER_MACRO = 5  -- maksimum skill per chain

-- ============================================================
-- Inisialisasi macro data di playerData
-- ============================================================
function MacroService.InitMacros(playerData)
	if not playerData.Macros then
		playerData.Macros = {}
		for i = 1, MAX_MACRO_SLOTS do
			playerData.Macros[i] = {
				SlotIndex   = i,
				Skills      = {},   -- list skillId dalam urutan
				CurrentStep = 1,    -- pointer ke skill berikutnya dalam chain
				Label       = "Macro " .. i,
			}
		end
	end
	-- Inisialisasi current step jika belum ada
	for i = 1, MAX_MACRO_SLOTS do
		if playerData.Macros[i] then
			playerData.Macros[i].CurrentStep = playerData.Macros[i].CurrentStep or 1
		end
	end
end

-- ============================================================
-- SetMacro(playerData, slotIndex, skillList, label)
-- skillList = { "slash", "wild_rage", ... } (urutan cast)
-- ============================================================
function MacroService.SetMacro(playerData, slotIndex, skillList, label)
	if slotIndex < 1 or slotIndex > MAX_MACRO_SLOTS then
		return false, "Invalid macro slot"
	end
	if not playerData.Macros then
		MacroService.InitMacros(playerData)
	end

	-- Validasi dan truncate list
	local sanitized = {}
	for i, skillId in ipairs(skillList or {}) do
		if i > MAX_SKILLS_PER_MACRO then break end
		if type(skillId) == "string" then
			table.insert(sanitized, skillId)
		end
	end

	playerData.Macros[slotIndex] = {
		SlotIndex   = slotIndex,
		Skills      = sanitized,
		CurrentStep = 1,
		Label       = (type(label) == "string" and label) or ("Macro " .. slotIndex),
	}

	return true, playerData.Macros[slotIndex]
end

-- ============================================================
-- ClearMacro(playerData, slotIndex)
-- ============================================================
function MacroService.ClearMacro(playerData, slotIndex)
	if not playerData.Macros then return false end
	if slotIndex < 1 or slotIndex > MAX_MACRO_SLOTS then return false end

	playerData.Macros[slotIndex] = {
		SlotIndex   = slotIndex,
		Skills      = {},
		CurrentStep = 1,
		Label       = "Macro " .. slotIndex,
	}
	return true
end

-- ============================================================
-- ExecuteMacro(player, slotIndex, targetModel, profiles, SkillService, EquipSvc, onFPConsumed)
-- → ok, result
-- Jalankan skill berikutnya dalam chain di slot ini.
-- Setelah reach end, wrap ke step 1 (looping chain).
-- ============================================================
function MacroService.ExecuteMacro(player, slotIndex, targetModel, profiles, SkillService, EquipmentService, onFPConsumed)
	local playerData = profiles[player]
	if not playerData then
		return false, "No player data"
	end

	MacroService.InitMacros(playerData)

	if slotIndex < 1 or slotIndex > MAX_MACRO_SLOTS then
		return false, "Invalid macro slot"
	end

	local macro = playerData.Macros[slotIndex]
	if not macro or #macro.Skills == 0 then
		return false, "Macro slot is empty"
	end

	-- Ambil skill dari current step
	local skillId = macro.Skills[macro.CurrentStep]
	if not skillId then
		macro.CurrentStep = 1
		skillId = macro.Skills[1]
	end

	-- Advance step pointer
	macro.CurrentStep = (macro.CurrentStep % #macro.Skills) + 1

	-- Cast via SkillService
	local attackerStats = EquipmentService.GetTotalStats(playerData)
	local defenderStats = { Defense = 5 }

	if targetModel and typeof(targetModel) == "Instance" then
		local Players = game:GetService("Players")
		local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
		local targetData = targetPlayer and profiles[targetPlayer]
		if targetData then
			defenderStats = EquipmentService.GetTotalStats(targetData)
		end
	end

	local ok, result = SkillService.Cast(
		player,
		skillId,
		targetModel,
		attackerStats,
		defenderStats,
		profiles,
		onFPConsumed
	)

	if ok then
		result.MacroSlot    = slotIndex
		result.MacroStep    = macro.CurrentStep
		result.MacroSkillId = skillId
	end

	return ok, result
end

-- ============================================================
-- GetMacros(playerData) → table macros untuk client
-- ============================================================
function MacroService.GetMacros(playerData)
	MacroService.InitMacros(playerData)
	return playerData.Macros
end

return MacroService
