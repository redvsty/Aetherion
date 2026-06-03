local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Aetherion] ClientController script is running")

local AetherionDebug = require(
	ReplicatedStorage:WaitForChild("Shared")
		:WaitForChild("Client")
		:WaitForChild("AetherionDebug")
)

_G.Aetherion = AetherionDebug

print("[Aetherion] Debug commands loaded.")
print("_G.Aetherion.Data()")
print('_G.Aetherion.CreateCharacter("MECHA", "Warrior")')
print("_G.Aetherion.WeaponSummary()")
print("_G.Aetherion.ListWeaponsByLevel(1)")
print('_G.Aetherion.ListWeaponsByGrade("N")')
print('_G.Aetherion.ListWeaponsByGrade("A")')
print('_G.Aetherion.ListWeaponsByGrade("B")')


-- local Players = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local player = Players.LocalPlayer

-- _G.Aetherion = _G.Aetherion or {}

-- local function printTable(tbl, indent)
-- 	indent = indent or 0
-- 	local prefix = string.rep("  ", indent)

-- 	if type(tbl) ~= "table" then
-- 		print(prefix .. tostring(tbl))
-- 		return
-- 	end

-- 	for key, value in pairs(tbl) do
-- 		if type(value) == "table" then
-- 			print(prefix .. tostring(key) .. ":")
-- 			printTable(value, indent + 1)
-- 		else
-- 			print(prefix .. tostring(key) .. ":", value)
-- 		end
-- 	end
-- end

-- local function waitForRemoteFunction(folder, name, timeout)
-- 	timeout = timeout or 10

-- 	local remote = folder:WaitForChild(name, timeout)

-- 	if not remote then
-- 		warn("[Aetherion Client] Missing RemoteFunction:", name)
-- 		return nil
-- 	end

-- 	if not remote:IsA("RemoteFunction") then
-- 		warn("[Aetherion Client] Remote is not RemoteFunction:", name)
-- 		return nil
-- 	end

-- 	return remote
-- end

-- local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

-- if not remotes then
-- 	warn("[Aetherion Client] ReplicatedStorage.Remotes not found.")
-- 	return
-- end

-- local GetPlayerDataRequest = waitForRemoteFunction(remotes, "GetPlayerDataRequest")
-- local SelectRaceAndClassRequest = waitForRemoteFunction(remotes, "SelectRaceAndClassRequest")
-- local SelectLevel30ClassRequest = waitForRemoteFunction(remotes, "SelectLevel30ClassRequest")
-- local SelectLevel40ClassRequest = waitForRemoteFunction(remotes, "SelectLevel40ClassRequest")
-- local GetClassOptionsRequest = waitForRemoteFunction(remotes, "GetClassOptionsRequest")
-- local EquipItemRequest = waitForRemoteFunction(remotes, "EquipItemRequest")
-- local UpgradeItemRequest = waitForRemoteFunction(remotes, "UpgradeItemRequest")
-- local AttackRequest = waitForRemoteFunction(remotes, "AttackRequest")

-- local GetWeaponSummaryRequest = waitForRemoteFunction(remotes, "GetWeaponSummaryRequest")
-- local GetWeaponsByLevelRequest = waitForRemoteFunction(remotes, "GetWeaponsByLevelRequest")
-- local GetWeaponsByGradeRequest = waitForRemoteFunction(remotes, "GetWeaponsByGradeRequest")
-- local GiveWeaponRequest = waitForRemoteFunction(remotes, "GiveWeaponRequest")

-- local function invoke(remote, ...)
-- 	if not remote then
-- 		return false, "Remote is missing"
-- 	end

-- 	local success, result1, result2 = pcall(function(...)
-- 		return remote:InvokeServer(...)
-- 	end, ...)

-- 	if not success then
-- 		return false, result1
-- 	end

-- 	return true, result1, result2
-- end

-- local function getPlayerData()
-- 	local success, result = invoke(GetPlayerDataRequest)

-- 	if not success then
-- 		warn("[Aetherion Client] Failed to get player data:", result)
-- 		return nil
-- 	end

-- 	return result
-- end

-- local function printData()
-- 	local data = getPlayerData()

-- 	if not data then
-- 		return
-- 	end

-- 	print("========== AETHERION PLAYER DATA ==========")
-- 	print("Name:", data.Name)
-- 	print("Level:", data.Level)
-- 	print("Exp:", data.Exp)
-- 	print("Faction:", data.FactionId)
-- 	print("StartingClass:", data.StartingClassId)
-- 	print("ClassLevel30:", data.ClassLevel30Id)
-- 	print("ClassLevel40:", data.ClassLevel40Id)

-- 	print("Flags:")
-- 	print("NeedsRaceSelection:", data.NeedsRaceSelection)
-- 	print("NeedsStartingClassSelection:", data.NeedsStartingClassSelection)
-- 	print("NeedsLevel30ClassSelection:", data.NeedsLevel30ClassSelection)
-- 	print("NeedsLevel40ClassSelection:", data.NeedsLevel40ClassSelection)

-- 	print("Currencies:")
-- 	printTable(data.Currencies, 1)

-- 	print("PT:")
-- 	for ptType, pt in pairs(data.PT or {}) do
-- 		print(" -", ptType, "Level:", pt.Level, "Exp:", pt.Exp)
-- 	end

-- 	print("Equipment:")
-- 	printTable(data.Equipment, 1)

-- 	print("Inventory:")
-- 	for _, item in ipairs(data.Inventory or {}) do
-- 		print(
-- 			" -",
-- 			item.Uid,
-- 			item.ItemId,
-- 			"Upgrade:",
-- 			item.UpgradeLevel,
-- 			"Locked:",
-- 			item.Locked,
-- 			"Slots:",
-- 			item.Slots
-- 		)
-- 	end

-- 	print("===========================================")
-- end

-- function _G.Aetherion.Data()
-- 	printData()
-- end

-- function _G.Aetherion.CreateCharacter(factionId, startingClassId)
-- 	local success, ok, result = invoke(SelectRaceAndClassRequest, factionId, startingClassId)

-- 	if not success then
-- 		warn("[Aetherion Client] CreateCharacter failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] CreateCharacter:", ok)

-- 	if type(result) == "table" then
-- 		printTable(result, 1)
-- 	else
-- 		print(result)
-- 	end

-- 	printData()
-- end

-- function _G.Aetherion.GetClassOptions(level)
-- 	local success, result = invoke(GetClassOptionsRequest, level)

-- 	if not success then
-- 		warn("[Aetherion Client] GetClassOptions failed:", result)
-- 		return
-- 	end

-- 	print("[Aetherion] Class options for level", level)

-- 	if type(result) == "table" then
-- 		printTable(result, 1)
-- 	else
-- 		print(result)
-- 	end
-- end

-- function _G.Aetherion.SelectLevel30Class(classId)
-- 	local success, ok, result = invoke(SelectLevel30ClassRequest, classId)

-- 	if not success then
-- 		warn("[Aetherion Client] SelectLevel30Class failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] SelectLevel30Class:", ok, result)
-- 	printData()
-- end

-- function _G.Aetherion.SelectLevel40Class(classId)
-- 	local success, ok, result = invoke(SelectLevel40ClassRequest, classId)

-- 	if not success then
-- 		warn("[Aetherion Client] SelectLevel40Class failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] SelectLevel40Class:", ok, result)
-- 	printData()
-- end

-- function _G.Aetherion.Equip(itemUid)
-- 	local success, ok, result = invoke(EquipItemRequest, itemUid)

-- 	if not success then
-- 		warn("[Aetherion Client] Equip failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] Equip:", ok, result)
-- 	printData()
-- end

-- function _G.Aetherion.Upgrade(itemUid, catalystPower)
-- 	local success, ok, result = invoke(UpgradeItemRequest, itemUid, catalystPower or 0)

-- 	if not success then
-- 		warn("[Aetherion Client] Upgrade failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] Upgrade:", ok)

-- 	if type(result) == "table" then
-- 		printTable(result, 1)
-- 	else
-- 		print(result)
-- 	end

-- 	printData()
-- end

-- function _G.Aetherion.Attack(targetModel)
-- 	if not targetModel then
-- 		warn("[Aetherion Client] Attack needs targetModel")
-- 		return
-- 	end

-- 	local success, ok, result = invoke(AttackRequest, targetModel)

-- 	if not success then
-- 		warn("[Aetherion Client] Attack failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] Attack:", ok)

-- 	if type(result) == "table" then
-- 		printTable(result, 1)
-- 	else
-- 		print(result)
-- 	end
-- end

-- function _G.Aetherion.WeaponSummary()
-- 	local success, result = invoke(GetWeaponSummaryRequest)

-- 	if not success then
-- 		warn("[Aetherion Client] WeaponSummary failed:", result)
-- 		return
-- 	end

-- 	print("========== AETHERION WEAPON SUMMARY ==========")
-- 	print("Total:", result.Total)

-- 	print("By Level:")
-- 	for level, count in pairs(result.ByLevel or {}) do
-- 		print(" - Level", level, count)
-- 	end

-- 	print("By Grade:")
-- 	for grade, count in pairs(result.ByGrade or {}) do
-- 		print(" - Grade", grade, count)
-- 	end

-- 	print("By Series:")
-- 	for series, count in pairs(result.BySeries or {}) do
-- 		print(" - Series", series, count)
-- 	end

-- 	print("==============================================")
-- end

-- function _G.Aetherion.ListWeaponsByLevel(level, limit)
-- 	local success, result = invoke(GetWeaponsByLevelRequest, level, limit or 50)

-- 	if not success then
-- 		warn("[Aetherion Client] ListWeaponsByLevel failed:", result)
-- 		return
-- 	end

-- 	print("========== WEAPONS LEVEL", level, "==========")

-- 	for _, weapon in ipairs(result or {}) do
-- 		print(
-- 			weapon.Id,
-- 			"|",
-- 			weapon.Name,
-- 			"| Grade:",
-- 			weapon.Grade,
-- 			"| Series:",
-- 			weapon.Series,
-- 			"| Atk:",
-- 			tostring(weapon.AttackMin) .. "-" .. tostring(weapon.AttackMax),
-- 			"| Force:",
-- 			tostring(weapon.ForceAttackMin) .. "-" .. tostring(weapon.ForceAttackMax),
-- 			"| Effect:",
-- 			weapon.SpecialEffectText
-- 		)
-- 	end

-- 	print("==============================================")
-- end

-- function _G.Aetherion.ListWeaponsByGrade(grade, limit)
-- 	local success, result = invoke(GetWeaponsByGradeRequest, grade, limit or 50)

-- 	if not success then
-- 		warn("[Aetherion Client] ListWeaponsByGrade failed:", result)
-- 		return
-- 	end

-- 	print("========== WEAPONS GRADE", grade, "==========")

-- 	for _, weapon in ipairs(result or {}) do
-- 		print(
-- 			weapon.Id,
-- 			"|",
-- 			weapon.Name,
-- 			"| Level:",
-- 			weapon.RequiredLevel,
-- 			"| Series:",
-- 			weapon.Series,
-- 			"| Atk:",
-- 			tostring(weapon.AttackMin) .. "-" .. tostring(weapon.AttackMax),
-- 			"| Effect:",
-- 			weapon.SpecialEffectText
-- 		)
-- 	end

-- 	print("==============================================")
-- end

-- function _G.Aetherion.GiveWeapon(weaponId)
-- 	local success, ok, result = invoke(GiveWeaponRequest, weaponId)

-- 	if not success then
-- 		warn("[Aetherion Client] GiveWeapon failed:", ok)
-- 		return
-- 	end

-- 	print("[Aetherion] GiveWeapon:", ok)

-- 	if type(result) == "table" then
-- 		printTable(result, 1)
-- 	else
-- 		print(result)
-- 	end

-- 	printData()
-- end

-- task.wait(2)

-- print("[Aetherion] ClientController loaded.")
-- print("[Aetherion] Console commands:")
-- print("_G.Aetherion.Data()")
-- print('_G.Aetherion.CreateCharacter("MECHA", "Warrior")')
-- print('_G.Aetherion.CreateCharacter("CYBORG", "Ranger")')
-- print('_G.Aetherion.CreateCharacter("MYSTIC", "Spiritualist")')
-- print("_G.Aetherion.WeaponSummary()")
-- print("_G.Aetherion.ListWeaponsByLevel(1)")
-- print('_G.Aetherion.ListWeaponsByGrade("N")')
-- print('_G.Aetherion.ListWeaponsByGrade("A")')
-- print('_G.Aetherion.ListWeaponsByGrade("B")')
-- print('_G.Aetherion.ListWeaponsByGrade("C")')
-- print('_G.Aetherion.GiveWeapon("classic_dagger")')

-- printData()