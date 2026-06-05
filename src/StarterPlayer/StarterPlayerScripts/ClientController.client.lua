local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local REMOTE_TIMEOUT = 30

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes", REMOTE_TIMEOUT)
if not remotes then error("[ClientController] Remotes folder not found after " .. REMOTE_TIMEOUT .. "s") end

local function waitRemote(name)
	local r = remotes:WaitForChild(name, REMOTE_TIMEOUT)
	if not r then error("[ClientController] Remote not found: " .. name) end
	return r
end

local GetPlayerDataRequest       = waitRemote("GetPlayerDataRequest")
local SelectRaceAndClassRequest  = waitRemote("SelectRaceAndClassRequest")
local SelectLevel30ClassRequest  = waitRemote("SelectLevel30ClassRequest")
local SelectLevel40ClassRequest  = waitRemote("SelectLevel40ClassRequest")
local GetClassOptionsRequest     = waitRemote("GetClassOptionsRequest")
local EquipItemRequest           = waitRemote("EquipItemRequest")
local UpgradeItemRequest         = waitRemote("UpgradeItemRequest")
local AttackRequest              = waitRemote("AttackRequest")
local ToggleRunWalkRequest       = waitRemote("ToggleRunWalkRequest")
local RunWalkStateChanged        = waitRemote("RunWalkStateChanged")
local SetMacroRequest            = waitRemote("SetMacroRequest")
local ClearMacroRequest          = waitRemote("ClearMacroRequest")
local ExecuteMacroRequest        = waitRemote("ExecuteMacroRequest")
local GetMacrosRequest           = waitRemote("GetMacrosRequest")
local GetDefenseGaugeRequest     = waitRemote("GetDefenseGaugeRequest")
local GetBuffedStatsRequest      = waitRemote("GetBuffedStatsRequest")

local function printTable(tbl, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			print(prefix .. tostring(key) .. ":")
			printTable(value, indent + 1)
		else
			print(prefix .. tostring(key) .. ":", value)
		end
	end
end

local function getPlayerData()
	local success, result = pcall(function()
		return GetPlayerDataRequest:InvokeServer()
	end)

	if not success then
		warn("[Aetherion Client] Failed to get player data:", result)
		return nil
	end

	return result
end

local function printData()
	local data = getPlayerData()

	if not data then
		return
	end

	print("========== AETHERION PLAYER DATA ==========")
	print("Name:", data.Name)
	print("Level:", data.Level)
	print("Exp:", data.Exp)
	print("Faction:", data.FactionId)
	print("StartingClass:", data.StartingClassId)
	print("ClassLevel30:", data.ClassLevel30Id)
	print("ClassLevel40:", data.ClassLevel40Id)

	print("Flags:")
	print("  NeedsRaceSelection:", data.NeedsRaceSelection)
	print("  NeedsStartingClassSelection:", data.NeedsStartingClassSelection)
	print("  NeedsLevel30ClassSelection:", data.NeedsLevel30ClassSelection)
	print("  NeedsLevel40ClassSelection:", data.NeedsLevel40ClassSelection)

	print("Currencies:")
	printTable(data.Currencies, 1)

	print("PT:")
	for ptType, pt in pairs(data.PT) do
		print(" -", ptType, "Level:", pt.Level, "Exp:", pt.Exp)
	end

	print("Equipment:")
	printTable(data.Equipment, 1)

	print("Inventory:")
	for _, item in ipairs(data.Inventory) do
		print(
			" -",
			item.Uid,
			item.ItemId,
			"Upgrade:",
			item.UpgradeLevel,
			"Locked:",
			item.Locked,
			"Slots:",
			item.Slots
		)
	end

	print("===========================================")
end

_G.Aetherion = {}

function _G.Aetherion.Data()
	printData()
end

function _G.Aetherion.CreateCharacter(factionId, startingClassId)
	local success, ok, result = pcall(function()
		return SelectRaceAndClassRequest:InvokeServer(factionId, startingClassId)
	end)

	if not success then
		warn("[Aetherion Client] CreateCharacter failed:", ok)
		return
	end

	print("[Aetherion] CreateCharacter:", ok)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end

	printData()
end

function _G.Aetherion.GetClassOptions(level)
	local success, result = pcall(function()
		return GetClassOptionsRequest:InvokeServer(level)
	end)

	if not success then
		warn("[Aetherion Client] GetClassOptions failed:", result)
		return
	end

	print("[Aetherion] Class options for level", level)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end
end

function _G.Aetherion.SelectLevel30Class(classId)
	local success, ok, result = pcall(function()
		return SelectLevel30ClassRequest:InvokeServer(classId)
	end)

	if not success then
		warn("[Aetherion Client] SelectLevel30Class failed:", ok)
		return
	end

	print("[Aetherion] SelectLevel30Class:", ok, result)
	printData()
end

function _G.Aetherion.SelectLevel40Class(classId)
	local success, ok, result = pcall(function()
		return SelectLevel40ClassRequest:InvokeServer(classId)
	end)

	if not success then
		warn("[Aetherion Client] SelectLevel40Class failed:", ok)
		return
	end

	print("[Aetherion] SelectLevel40Class:", ok, result)
	printData()
end

function _G.Aetherion.Equip(itemUid)
	local success, ok, result = pcall(function()
		return EquipItemRequest:InvokeServer(itemUid)
	end)

	if not success then
		warn("[Aetherion Client] Equip failed:", ok)
		return
	end

	print("[Aetherion] Equip:", ok, result)
	printData()
end

function _G.Aetherion.Upgrade(itemUid, catalystPower)
	local success, ok, result = pcall(function()
		return UpgradeItemRequest:InvokeServer(itemUid, catalystPower or 0)
	end)

	if not success then
		warn("[Aetherion Client] Upgrade failed:", ok)
		return
	end

	print("[Aetherion] Upgrade:", ok)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end

	printData()
end

function _G.Aetherion.Attack(targetModel)
	if not targetModel then
		warn("[Aetherion Client] Attack needs targetModel")
		return
	end

	local success, ok, result = pcall(function()
		return AttackRequest:InvokeServer(targetModel)
	end)

	if not success then
		warn("[Aetherion Client] Attack failed:", ok)
		return
	end

	print("[Aetherion] Attack:", ok)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end
end

task.wait(2)

print("[Aetherion] ClientController loaded.")
print("[Aetherion] Console commands:")
print('_G.Aetherion.Data()')
print('_G.Aetherion.CreateCharacter("MECHA", "Warrior")')
print('_G.Aetherion.CreateCharacter("CYBORG", "Ranger")')
print('_G.Aetherion.CreateCharacter("MYSTIC", "Spiritualist")')
print("_G.Aetherion.GetClassOptions(30)")
print("_G.Aetherion.GetClassOptions(40)")
-- Patch RF-Accuracy
print("_G.Aetherion.ToggleRun()  -- Toggle Walk/Run (seperti W di RF)")
print("_G.Aetherion.DefenseGauge()  -- Cek defense gauge")
print("_G.Aetherion.BuffedStats()  -- Stats setelah buff aktif")
print("_G.Aetherion.SetMacro(1, {'slash','wild_rage'})  -- Set macro slot 1")
print("_G.Aetherion.ExecMacro(1, target)  -- Execute macro slot 1")

printData()

-- ============================================================
-- Walk/Run Toggle — hotkey N, atau klik tombol UI di hotbar
-- ============================================================

local isRunning = true

RunWalkStateChanged.OnClientEvent:Connect(function(newIsRunning)
	isRunning = newIsRunning
	if newIsRunning then
		print("[Aetherion] Mode: RUNNING (SP akan berkurang)")
	else
		print("[Aetherion] Mode: WALKING (SP regen)")
	end
end)

function _G.Aetherion.ToggleRun()
	ToggleRunWalkRequest:FireServer()
end

-- ============================================================
-- Patch RF-Accuracy: Defense Gauge
-- ============================================================

function _G.Aetherion.DefenseGauge()
	local success, result = pcall(function()
		return GetDefenseGaugeRequest:InvokeServer()
	end)
	if not success then
		warn("[Aetherion] DefenseGauge failed:", result)
		return
	end
	if not result then return end
	local ok, gaugeInfo = result, (select(2, pcall(function() return result end)))
	print("===== DEFENSE GAUGE =====")
	if type(result) == "table" then
		local info = result
		print("State:", info.State, "(" .. string.format("%.1f", info.Percent or 0) .. "%)")
		print("Current:", info.Current, "/", info.Max)
		if info.State == "Stable" then
			print("→ Talic bonus: FULL (100%)")
		elseif info.State == "Reduced" then
			print("→ Talic bonus: REDUCED (50%)")
		else
			print("→ Talic bonus: MINIMAL (5%) — DANGER!")
		end
	end
	print("=========================")
end

-- ============================================================
-- Patch RF-Accuracy: Buffed Stats
-- ============================================================

function _G.Aetherion.BuffedStats()
	local success, ok, stats = pcall(function()
		return GetBuffedStatsRequest:InvokeServer()
	end)
	if not success or not ok then
		warn("[Aetherion] BuffedStats failed")
		return
	end
	print("===== BUFFED STATS =====")
	if type(stats) == "table" then
		for k, v in pairs(stats) do
			print(" -", k, ":", v)
		end
	end
	print("========================")
end

-- ============================================================
-- Patch RF-Accuracy: Macro System
-- ============================================================

function _G.Aetherion.SetMacro(slotIndex, skillList, label)
	if not slotIndex or type(skillList) ~= "table" then
		warn("[Aetherion] Usage: SetMacro(slotIndex, {skillId1, skillId2, ...})")
		return
	end
	local success, ok, result = pcall(function()
		return SetMacroRequest:InvokeServer(slotIndex, skillList, label)
	end)
	if not success then
		warn("[Aetherion] SetMacro failed:", ok)
		return
	end
	print("[Aetherion] Macro", slotIndex, "set:", ok)
	if type(result) == "table" then
		print("  Skills:", table.concat(result.Skills or {}, " → "))
	end
end

function _G.Aetherion.ClearMacro(slotIndex)
	local success, result = pcall(function()
		return ClearMacroRequest:InvokeServer(slotIndex)
	end)
	if not success then
		warn("[Aetherion] ClearMacro failed:", result)
		return
	end
	print("[Aetherion] Macro", slotIndex, "cleared")
end

function _G.Aetherion.GetMacros()
	local success, ok, macros = pcall(function()
		return GetMacrosRequest:InvokeServer()
	end)
	if not success or not ok then
		warn("[Aetherion] GetMacros failed")
		return
	end
	print("===== MACROS =====")
	for i, macro in pairs(macros or {}) do
		if #macro.Skills > 0 then
			print(string.format("  Slot %d [%s]: %s", i, macro.Label, table.concat(macro.Skills, " → ")))
		end
	end
	print("==================")
end

function _G.Aetherion.ExecMacro(slotIndex, targetModel)
	local success, ok, result = pcall(function()
		return ExecuteMacroRequest:InvokeServer(slotIndex, targetModel)
	end)
	if not success then
		warn("[Aetherion] ExecMacro failed:", ok)
		return
	end
	print("[Aetherion] Macro", slotIndex, "->", ok)
	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end
end
