local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AetherionDebug = {}

local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)

local function getRemote(name)
	if not remotes then
		warn("[AetherionDebug] ReplicatedStorage.Remotes not found")
		return nil
	end

	local remote = remotes:WaitForChild(name, 10)

	if not remote then
		warn("[AetherionDebug] Missing remote:", name)
		return nil
	end

	return remote
end

local GetPlayerDataRequest = getRemote("GetPlayerDataRequest")
local SelectRaceAndClassRequest = getRemote("SelectRaceAndClassRequest")
local EquipItemRequest = getRemote("EquipItemRequest")
local GetWeaponSummaryRequest = getRemote("GetWeaponSummaryRequest")
local GetWeaponsByLevelRequest = getRemote("GetWeaponsByLevelRequest")
local GetWeaponsByGradeRequest = getRemote("GetWeaponsByGradeRequest")
local GiveWeaponRequest = getRemote("GiveWeaponRequest")
local GiveItemRequest = getRemote("GiveItemRequest")
local GetPlayerStatsRequest = getRemote("GetPlayerStatsRequest")

local function invoke(remote, ...)
	if not remote then
		return false, "Remote is missing"
	end

	local success, result1, result2 = pcall(function(...)
		return remote:InvokeServer(...)
	end, ...)

	if not success then
		return false, result1
	end

	return true, result1, result2
end

local function printTable(tbl, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent)

	if type(tbl) ~= "table" then
		print(prefix .. tostring(tbl))
		return
	end

	for key, value in pairs(tbl) do
		if type(value) == "table" then
			print(prefix .. tostring(key) .. ":")
			printTable(value, indent + 1)
		else
			print(prefix .. tostring(key) .. ":", value)
		end
	end
end

function AetherionDebug.Ping()
	print("[AetherionDebug] Ping OK")
end

function AetherionDebug.Data()
	local success, data = invoke(GetPlayerDataRequest)

	if not success then
		warn("[AetherionDebug] Data failed:", data)
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

	print("Currencies:")
	printTable(data.Currencies, 1)

	print("PT:")
	printTable(data.PT, 1)

	print("Equipment:")
	printTable(data.Equipment, 1)

	print("Inventory:")
	for _, item in ipairs(data.Inventory or {}) do
		print(
			" -",
			item.Uid,
			item.ItemId,
			"Qty:",
			item.Quantity,
			"Upgrade:",
			item.UpgradeLevel,
			"Locked:",
			item.Locked,
			"Slots:",
			item.Slots
		)
	end

	print("===========================================")

	return data
end

function AetherionDebug.CreateCharacter(factionId, startingClassId)
	local success, ok, result = invoke(SelectRaceAndClassRequest, factionId, startingClassId)

	if not success then
		warn("[AetherionDebug] CreateCharacter failed:", ok)
		return
	end

	print("[AetherionDebug] CreateCharacter:", ok)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end

	return ok, result
end

function AetherionDebug.WeaponSummary()
	local success, summary = invoke(GetWeaponSummaryRequest)

	if not success then
		warn("[AetherionDebug] WeaponSummary failed:", summary)
		return
	end

	print("========== AETHERION WEAPON SUMMARY ==========")
	print("Total:", summary.Total)

	print("By Level:")
	for level, count in pairs(summary.ByLevel or {}) do
		print(" - Level", level, count)
	end

	print("By Grade:")
	for grade, count in pairs(summary.ByGrade or {}) do
		print(" - Grade", grade, count)
	end

	print("By Series:")
	for series, count in pairs(summary.BySeries or {}) do
		print(" - Series", series, count)
	end

	print("==============================================")

	return summary
end

function AetherionDebug.ListWeaponsByLevel(level, limit)
	local success, weapons = invoke(GetWeaponsByLevelRequest, level, limit or 50)

	if not success then
		warn("[AetherionDebug] ListWeaponsByLevel failed:", weapons)
		return
	end

	print("========== WEAPONS LEVEL", level, "==========")

	for _, weapon in ipairs(weapons or {}) do
		print(
			weapon.Id,
			"|",
			weapon.Name,
			"| Grade:",
			weapon.Grade,
			"| Series:",
			weapon.Series,
			"| Atk:",
			tostring(weapon.AttackMin) .. "-" .. tostring(weapon.AttackMax),
			"| Force:",
			tostring(weapon.ForceAttackMin) .. "-" .. tostring(weapon.ForceAttackMax),
			"| Effect:",
			weapon.SpecialEffectText
		)
	end

	print("==============================================")

	return weapons
end

function AetherionDebug.ListWeaponsByGrade(grade, limit)
	local success, weapons = invoke(GetWeaponsByGradeRequest, grade, limit or 50)

	if not success then
		warn("[AetherionDebug] ListWeaponsByGrade failed:", weapons)
		return
	end

	print("========== WEAPONS GRADE", grade, "==========")

	for _, weapon in ipairs(weapons or {}) do
		print(
			weapon.Id,
			"|",
			weapon.Name,
			"| Level:",
			weapon.RequiredLevel,
			"| Series:",
			weapon.Series,
			"| Atk:",
			tostring(weapon.AttackMin) .. "-" .. tostring(weapon.AttackMax),
			"| Effect:",
			weapon.SpecialEffectText
		)
	end

	print("==============================================")

	return weapons
end

function AetherionDebug.GiveWeapon(weaponId)
	local success, ok, result = invoke(GiveWeaponRequest, weaponId)

	if not success then
		warn("[AetherionDebug] GiveWeapon failed:", ok)
		return
	end

	print("[AetherionDebug] GiveWeapon:", ok)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end

	return ok, result
end

function AetherionDebug.GiveItem(itemId, amount)
	local success, ok, result = invoke(GiveItemRequest, itemId, amount or 1)

	if not success then
		warn("[AetherionDebug] GiveItem failed:", ok)
		return
	end

	print("[AetherionDebug] GiveItem:", ok)

	if type(result) == "table" then
		printTable(result, 1)
	else
		print(result)
	end

	return ok, result
end

function AetherionDebug.Equip(itemUid)
	local success, ok, result = invoke(EquipItemRequest, itemUid)

	if not success then
		warn("[AetherionDebug] Equip failed:", ok)
		return
	end

	print("[AetherionDebug] Equip:", ok, result)

	return ok, result
end

function AetherionDebug.Stats()
	local success, ok, stats = invoke(GetPlayerStatsRequest)

	if not success then
		warn("[AetherionDebug] Stats failed:", ok)
		return
	end

	if not ok then
		warn("[AetherionDebug] Stats failed:", stats)
		return
	end

	print("========== AETHERION TOTAL STATS ==========")

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

		"DebuffDurationReduction",
		"DebuffDurationIncrease",

		"FPCostReduction",
		"FPCostIncrease",
	}

	for _, key in ipairs(orderedKeys) do
		print(key .. ":", stats[key])
	end

	print("===========================================")

	return stats
end

return AetherionDebug
