-- AetherionUILoader.client.lua
-- Di StarterPlayerScripts (bukan StarterGui) agar script INI tidak di-kill saat respawn.
-- StarterGui scripts di-restart tiap respawn → connections di-GC → hotkeys/HUD mati.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Aetherion] AetherionUILoader started")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function getGameplayUIModule()
	local shared = ReplicatedStorage:WaitForChild("Shared", 30)
	if not shared then
		return nil, "ReplicatedStorage.Shared not found"
	end

	local client = shared:WaitForChild("Client", 30)
	if not client then
		return nil, "ReplicatedStorage.Shared.Client not found"
	end

	local uiModule = client:WaitForChild("AetherionGameplayUI", 30)
	if not uiModule then
		return nil, "AetherionGameplayUI module not found"
	end

	return uiModule, nil
end

local function loadGameplayUI()
	local uiModule, moduleErr = getGameplayUIModule()
	if not uiModule then
		warn("[Aetherion] Cannot load Gameplay UI:", moduleErr)
		return false
	end

	local ok, UI = pcall(function()
		return require(uiModule)
	end)

	if not ok then
		warn("[Aetherion] Failed to require AetherionGameplayUI:", UI)
		return false
	end

	if type(UI) ~= "table" or type(UI.Create) ~= "function" then
		warn("[Aetherion] AetherionGameplayUI must return a table with Create()")
		return false
	end

	-- Jika UI sudah ada (restart loader karena Roblox), cukup reconnect connections
	if playerGui:FindFirstChild("AetherionGameplayUI") then
		print("[Aetherion] Gameplay UI already exists — reconnecting")
		if type(UI.Reconnect) == "function" then
			pcall(UI.Reconnect)
		end
		return true
	end

	local createOk, createErr = pcall(function()
		UI.Create()
	end)

	if not createOk then
		warn("[Aetherion] Failed to create Gameplay UI:", createErr)
		return false
	end

	-- Load SkillPanelUI setelah GameplayUI siap
	task.spawn(function()
		local client = ReplicatedStorage:WaitForChild("Shared", 10):WaitForChild("Client", 10)
		local skillModule = client:WaitForChild("SkillPanelUI", 10)

		if not skillModule then
			warn("[Aetherion] SkillPanelUI module not found, skill UI will not load")
			return
		end

		local okSkill, SkillUI = pcall(require, skillModule)

		if not okSkill then
			warn("[Aetherion] Failed to require SkillPanelUI:", SkillUI)
			return
		end

		local initOk, initErr = pcall(function()
			SkillUI.Init()
		end)

		if not initOk then
			warn("[Aetherion] Failed to init SkillPanelUI:", initErr)
			return
		end

		print("[Aetherion] SkillPanelUI initialized — L=Melee/Range, F=Force")
	end)

	print("[Aetherion] Gameplay UI created")
	return true
end

-- Cek apakah player adalah player baru (belum pilih race)
local function isNewPlayer()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
	if not remotes then return false end

	local getDataRemote = remotes:FindFirstChild("GetPlayerDataRequest")
	if not getDataRemote then return false end

	local ok, data = pcall(function()
		return getDataRemote:InvokeServer()
	end)

	if not ok or not data then return false end

	return data.FactionId == nil or data.NeedsRaceSelection == true
end

-- Flow utama: cek apakah perlu character creation, atau langsung load HUD
local function loadUI()
	-- Jika sudah punya gameplay UI, skip
	if playerGui:FindFirstChild("AetherionGameplayUI") then
		local shared = ReplicatedStorage:WaitForChild("Shared", 10)
		if shared then
			local client = shared:WaitForChild("Client", 10)
			if client then
				local uiModule = client:FindFirstChild("AetherionGameplayUI")
				if uiModule then
					local ok, UI = pcall(require, uiModule)
					if ok and type(UI) == "table" and type(UI.Reconnect) == "function" then
						pcall(UI.Reconnect)
					end
				end
			end
		end
		return true
	end

	-- Cek apakah player baru
	local needsCreation = isNewPlayer()

	if needsCreation then
		print("[Aetherion] New player detected — showing Character Creation screen")

		-- Load CharacterCreationUI module
		local shared = ReplicatedStorage:WaitForChild("Shared", 30)
		if not shared then
			warn("[Aetherion] Shared not found")
			return false
		end
		local client = shared:WaitForChild("Client", 30)
		if not client then
			warn("[Aetherion] Client not found")
			return false
		end
		local ccModule = client:WaitForChild("CharacterCreationUI", 15)
		if not ccModule then
			warn("[Aetherion] CharacterCreationUI module not found — falling back to gameplay UI")
			return loadGameplayUI()
		end

		local ok, CharCreationUI = pcall(require, ccModule)
		if not ok then
			warn("[Aetherion] Failed to require CharacterCreationUI:", CharCreationUI)
			return loadGameplayUI()
		end

		-- Show creation screen; after confirmed, load gameplay UI
		CharCreationUI.Show(function(factionId, classId)
			print("[Aetherion] Character created —", factionId, classId, "— loading gameplay UI")
			task.wait(0.5)
			loadGameplayUI()
		end)

		return true
	end

	-- Returning/existing player — load HUD directly
	return loadGameplayUI()
end

task.delay(1, function()
	local loaded = loadUI()

	if loaded then
		return
	end

	task.wait(2)
	loadUI()
end)

-- Fallback: jika karena alasan tertentu ScreenGui belum ada saat respawn, buat ulang
player.CharacterAdded:Connect(function()
	task.wait(1)

	if not playerGui:FindFirstChild("AetherionGameplayUI") then
		-- Hanya load gameplay UI saat respawn (race sudah dipilih di sesi ini)
		loadGameplayUI()
	end
end)
