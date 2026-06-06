-- HideHealthGui.client.lua
-- Sembunyikan semua health display bawaan Roblox.
-- LocalScript di StarterGui jalan lebih awal dari StarterPlayerScripts,
-- sehingga lebih andal untuk disable CoreGui sebelum game dimulai.

local StarterGui = game:GetService("StarterGui")
local Players    = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- 1. Matikan CoreGui health (bar merah Roblox di sekitar layar)
local function disableCoreHealth()
	local ok = pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
	end)
	return ok
end

-- Coba langsung, retry jika gagal (bisa gagal saat game baru start)
if not disableCoreHealth() then
	task.wait(0.5)
	disableCoreHealth()
end

-- 2. Matikan HealthGui ScreenGui di PlayerGui (bar kanan atas default Roblox)
local function disableHealthGui(gui)
	if gui and gui.Name == "HealthGui" and gui:IsA("ScreenGui") then
		gui.Enabled = false
	end
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui", 20)
if playerGui then
	-- Disable yang sudah ada
	for _, child in ipairs(playerGui:GetChildren()) do
		disableHealthGui(child)
	end
	-- Disable yang ditambah nanti (setelah respawn Roblox inject ulang)
	playerGui.ChildAdded:Connect(disableHealthGui)
end
