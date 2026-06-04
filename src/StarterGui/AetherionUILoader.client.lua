local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("[Aetherion] AetherionUILoader started")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function loadUI()
	if playerGui:FindFirstChild("AetherionGameplayUI") then
		print("[Aetherion] Gameplay UI already exists")
		return
	end

	local shared = ReplicatedStorage:WaitForChild("Shared", 30)
	if not shared then
		warn("[Aetherion] Shared not found")
		return
	end

	local client = shared:WaitForChild("Client", 30)
	if not client then
		warn("[Aetherion] Shared.Client not found")
		return
	end

	local uiModule = client:WaitForChild("AetherionGameplayUI", 30)
	if not uiModule then
		warn("[Aetherion] AetherionGameplayUI not found")
		return
	end

	local ok, UI = pcall(function()
		return require(uiModule)
	end)

	if not ok then
		warn("[Aetherion] Failed to require AetherionGameplayUI:", UI)
		return
	end

	local createOk, createErr = pcall(function()
		UI.Create()
	end)

	if not createOk then
		warn("[Aetherion] Failed to create Gameplay UI:", createErr)
		return
	end

	print("[Aetherion] Gameplay UI created from StarterGui loader")
end

task.delay(1, loadUI)