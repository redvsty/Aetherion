local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local GetPlayerDataRequest = remotes:WaitForChild("GetPlayerDataRequest")
local SelectRaceAndClassRequest = remotes:WaitForChild("SelectRaceAndClassRequest")
local SelectLevel30ClassRequest = remotes:WaitForChild("SelectLevel30ClassRequest")
local SelectLevel40ClassRequest = remotes:WaitForChild("SelectLevel40ClassRequest")
local GetClassOptionsRequest = remotes:WaitForChild("GetClassOptionsRequest")
local EquipItemRequest = remotes:WaitForChild("EquipItemRequest")
local UpgradeItemRequest = remotes:WaitForChild("UpgradeItemRequest")
local AttackRequest = remotes:WaitForChild("AttackRequest")

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
	print("NeedsRaceSelection:", data.NeedsRaceSelection)
	print("NeedsStartingClassSelection:", data.NeedsStartingClassSelection)
	print("NeedsLevel30ClassSelection:", data.NeedsLevel30ClassSelection)
	print("NeedsLevel40ClassSelection:", data.NeedsLevel40ClassSelection)

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
print('_G.Aetherion.CreateCharacter("MECHA", "Ranger")')
print('_G.Aetherion.CreateCharacter("MECHA", "Spiritualist")')
print('_G.Aetherion.CreateCharacter("MECHA", "Specialist")')
print('_G.Aetherion.CreateCharacter("CYBORG", "Warrior")')
print('_G.Aetherion.CreateCharacter("CYBORG", "Ranger")')
print('_G.Aetherion.CreateCharacter("CYBORG", "Specialist")')
print('_G.Aetherion.CreateCharacter("MYSTIC", "Warrior")')
print('_G.Aetherion.CreateCharacter("MYSTIC", "Ranger")')
print('_G.Aetherion.CreateCharacter("MYSTIC", "Spiritualist")')
print('_G.Aetherion.CreateCharacter("MYSTIC", "Specialist")')
print("_G.Aetherion.GetClassOptions(30)")
print("_G.Aetherion.GetClassOptions(40)")

printData()
