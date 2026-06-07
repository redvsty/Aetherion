-- AetherionUILoader.client.lua
-- Di StarterPlayerScripts agar tidak di-kill saat respawn.

local Players       = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("[Aetherion] AetherionUILoader started")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Flag: true saat character creation sedang ditampilkan.
-- Blokir CharacterAdded handler agar tidak load gameplay HUD di saat creation.
local creationActive = false

-- ── Gameplay UI ────────────────────────────────────────────
local function loadGameplayUI()
	local shared = ReplicatedStorage:WaitForChild("Shared", 30)
	if not shared then warn("[Aetherion] Shared not found") return false end
	local client = shared:WaitForChild("Client", 30)
	if not client then warn("[Aetherion] Client not found") return false end
	local uiModule = client:WaitForChild("AetherionGameplayUI", 30)
	if not uiModule then warn("[Aetherion] AetherionGameplayUI not found") return false end

	local ok, UI = pcall(require, uiModule)
	if not ok then warn("[Aetherion] Failed to require AetherionGameplayUI:", UI) return false end
	if type(UI) ~= "table" or type(UI.Create) ~= "function" then
		warn("[Aetherion] AetherionGameplayUI must return table with Create()")
		return false
	end

	if playerGui:FindFirstChild("AetherionGameplayUI") then
		if type(UI.Reconnect) == "function" then pcall(UI.Reconnect) end
		return true
	end

	local createOk, createErr = pcall(UI.Create)
	if not createOk then warn("[Aetherion] Failed to create Gameplay UI:", createErr) return false end

	-- SkillPanelUI
	task.spawn(function()
		local skillModule = client:WaitForChild("SkillPanelUI", 10)
		if not skillModule then warn("[Aetherion] SkillPanelUI not found") return end
		local okS, SkillUI = pcall(require, skillModule)
		if not okS then warn("[Aetherion] Failed to require SkillPanelUI:", SkillUI) return end
		local okI, err = pcall(SkillUI.Init)
		if not okI then warn("[Aetherion] Failed to init SkillPanelUI:", err) return end
		print("[Aetherion] SkillPanelUI initialized")
	end)

	print("[Aetherion] Gameplay UI created")
	return true
end

-- ── New player check ───────────────────────────────────────
local function isNewPlayer()
	local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
	if not remotes then return false end
	local remote = remotes:FindFirstChild("GetPlayerDataRequest")
	if not remote then return false end
	local ok, data = pcall(function() return remote:InvokeServer() end)
	if not ok or not data then return false end
	return data.FactionId == nil or data.NeedsRaceSelection == true
end

-- ── Main loader ────────────────────────────────────────────
local function loadUI()
	-- Sudah punya gameplay UI (returning player / respawn)
	if playerGui:FindFirstChild("AetherionGameplayUI") then
		if creationActive then return true end  -- jangan reconnect saat creation berlangsung
		local shared = ReplicatedStorage:WaitForChild("Shared", 10)
		if shared then
			local client = shared:FindFirstChild("Client")
			local mod    = client and client:FindFirstChild("AetherionGameplayUI")
			if mod then
				local ok, UI = pcall(require, mod)
				if ok and type(UI) == "table" and type(UI.Reconnect) == "function" then
					pcall(UI.Reconnect)
				end
			end
		end
		return true
	end

	local needsCreation = isNewPlayer()

	if needsCreation then
		print("[Aetherion] Player baru — tampilkan Character Creation")
		creationActive = true

		local shared = ReplicatedStorage:WaitForChild("Shared", 30)
		local client = shared and shared:WaitForChild("Client", 30)
		local ccMod  = client and client:WaitForChild("CharacterCreationUI", 15)

		if not ccMod then
			warn("[Aetherion] CharacterCreationUI tidak ditemukan — fallback ke gameplay UI")
			creationActive = false
			return loadGameplayUI()
		end

		local ok, CC = pcall(require, ccMod)
		if not ok then
			warn("[Aetherion] Gagal require CharacterCreationUI:", CC)
			creationActive = false
			return loadGameplayUI()
		end

		CC.Show(function(factionId, classId)
			print("[Aetherion] Character dibuat:", factionId, classId)
			creationActive = false
			task.wait(0.5)
			loadGameplayUI()
		end)

		return true
	end

	return loadGameplayUI()
end

-- Delay kecil agar remotes dan data sudah siap
task.delay(0.5, function()
	local ok = loadUI()
	if not ok then
		task.wait(2)
		loadUI()
	end
end)

-- Fallback respawn: hanya load HUD jika BUKAN saat character creation
player.CharacterAdded:Connect(function()
	task.wait(1)
	if creationActive then return end  -- jangan load HUD saat creation berlangsung
	if not playerGui:FindFirstChild("AetherionGameplayUI") then
		loadGameplayUI()
	end
end)
