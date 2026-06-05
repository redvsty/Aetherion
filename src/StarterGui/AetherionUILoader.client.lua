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

local function loadUI()
	if playerGui:FindFirstChild("AetherionGameplayUI") then
		print("[Aetherion] Gameplay UI already exists")
		return true
	end

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

	local createOk, createErr = pcall(function()
		UI.Create()
	end)

	if not createOk then
		warn("[Aetherion] Failed to create Gameplay UI:", createErr)
		return false
	end

	-- Batch 2.5: Load SkillPanelUI setelah GameplayUI
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

	print("[Aetherion] Gameplay UI created from StarterGui loader")
	return true
end

task.delay(1, function()
	local loaded = loadUI()

	if loaded then
		return
	end

	task.wait(2)
	loadUI()
end)

player.CharacterAdded:Connect(function()
	task.wait(1)

	if not playerGui:FindFirstChild("AetherionGameplayUI") then
		loadUI()
	end
end)
