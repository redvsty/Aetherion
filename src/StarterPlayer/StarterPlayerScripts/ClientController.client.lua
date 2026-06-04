local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("[Aetherion] ClientController started")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function loadGameplayUI()
	local shared = ReplicatedStorage:WaitForChild("Shared", 30)

	if not shared then
		warn("[Aetherion] Shared folder not found")
		return
	end

	local clientFolder = shared:WaitForChild("Client", 30)

	if not clientFolder then
		warn("[Aetherion] Client folder not found")
		return
	end

	local uiModule = clientFolder:WaitForChild("AetherionGameplayUI", 30)

	if not uiModule then
		warn("[Aetherion] AetherionGameplayUI module not found")
		return
	end

	local ok, AetherionGameplayUI = pcall(function()
		return require(uiModule)
	end)

	if not ok then
		warn("[Aetherion] Failed to require AetherionGameplayUI:", AetherionGameplayUI)
		return
	end

	task.wait(1)

	local createOk, createErr = pcall(function()
		AetherionGameplayUI.Create()
	end)

	if not createOk then
		warn("[Aetherion] Failed to create Gameplay UI:", createErr)
		return
	end

	print("[Aetherion] Gameplay UI created automatically")
end

task.defer(loadGameplayUI)

player.CharacterAdded:Connect(function()
	task.wait(1)

	if not playerGui:FindFirstChild("AetherionGameplayUI") then
		loadGameplayUI()
	end
end)
