-- StaminaService.lua
-- Patch RF-Accuracy: SP (Stamina Points) untuk sistem walk/run
-- Sumber: https://wiki.rfdatabase.net/game-controls/moving-around
--
-- RF Classic: Running mengkonsumsi SP. Walking gratis tapi lebih lambat.
-- Default mode = Running. Toggle dengan hotkey (W / CTRL+W di PC).
-- Di Roblox: kita pakai RemoteEvent untuk toggle run/walk dari client.
--
-- SP regen saat walking atau tidak bergerak.
-- Velocity FORCE buff dari Holy/Dark menambah move speed.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local StaminaService = {}

-- ============================================================
-- Konstanta SP
-- ============================================================

local SP_CONFIG = {
	MaxSP           = 100,    -- maksimum SP (bisa di-override per player dari equipment)
	RunCostPerSec   = 3,      -- SP drain saat running
	WalkRegenPerSec = 5,      -- SP regen saat walking / idle
	IdleRegenPerSec = 8,      -- SP regen saat tidak bergerak (berdiri)
	RunSpeed        = 16,     -- WalkSpeed saat run (studs/sec, default Roblox = 16)
	WalkSpeed       = 8,      -- WalkSpeed saat walk (setengah)
	-- Saat SP habis, paksa ke walk mode
	ForcedWalkThreshold = 5,
	-- SP harus >= ini untuk bisa kembali run
	RunResumeThreshold  = 20,
}

-- State per player: [player] = { IsRunning = bool, SP = number, ForcedWalk = bool }
local playerStates = {}

-- ============================================================
-- Init state untuk player baru
-- ============================================================
function StaminaService.InitPlayer(player, playerData)
	local maxSP = (playerData and playerData.Stats and playerData.Stats.MaxSP) or SP_CONFIG.MaxSP
	playerStates[player] = {
		IsRunning    = true,
		SP           = maxSP,
		MaxSP        = maxSP,
		ForcedWalk   = false,
		LastMoveTick = tick(),
		IsMoving     = false,
		LastPosition = nil,
	}

	-- Sync MaxSP ke playerData.Stats
	if playerData and playerData.Stats then
		playerData.Stats.SP    = playerData.Stats.SP or maxSP
		playerData.Stats.MaxSP = maxSP
	end
end

-- ============================================================
-- ToggleRunWalk(player) → isRunning (bool)
-- Dipanggil dari RemoteEvent ketika client menekan hotkey
-- ============================================================
function StaminaService.ToggleRunWalk(player)
	local state = playerStates[player]
	if not state then return false end

	-- Tidak bisa toggle ke run jika SP kurang dari threshold
	if not state.IsRunning and state.SP < SP_CONFIG.RunResumeThreshold then
		return false  -- masih forced walk
	end

	state.IsRunning = not state.IsRunning
	StaminaService.ApplySpeedToCharacter(player, state)
	return state.IsRunning
end

-- ============================================================
-- SetMoving(player, isMoving)
-- Dipanggil dari client heartbeat atau karakter movement event
-- ============================================================
function StaminaService.SetMoving(player, isMoving)
	local state = playerStates[player]
	if state then
		state.IsMoving = isMoving
		if isMoving then
			state.LastMoveTick = tick()
		end
	end
end

-- ============================================================
-- ApplySpeedToCharacter(player, state)
-- Set WalkSpeed pada Humanoid sesuai run/walk mode + velocity buff
-- ============================================================
function StaminaService.ApplySpeedToCharacter(player, state, buffedMoveSpeed)
	local character = player.Character
	if not character then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local baseSpeed = state.IsRunning and SP_CONFIG.RunSpeed or SP_CONFIG.WalkSpeed

	-- Tambahkan velocity buff jika ada (dari force buff)
	local finalSpeed = baseSpeed + (buffedMoveSpeed or 0)
	humanoid.WalkSpeed = math.max(4, finalSpeed)
end

-- ============================================================
-- Tick(deltaTime, profiles) — dipanggil dari server loop tiap detik
-- Proses SP drain/regen semua player
-- ============================================================
function StaminaService.Tick(deltaTime, profiles, getBuffedSpeed)
	for player, state in pairs(playerStates) do
		if not player or not player.Parent then
			playerStates[player] = nil
		else
			local playerData = profiles and profiles[player]
			local stats = playerData and playerData.Stats

			-- SP drain/regen sederhana dan reliable:
			-- Run mode  → drain terus (konsisten dengan "run stance" RF)
			-- Walk/idle → regen
			if state.IsRunning and not state.ForcedWalk then
				state.SP = math.max(0, state.SP - SP_CONFIG.RunCostPerSec * deltaTime)

				if state.SP <= SP_CONFIG.ForcedWalkThreshold then
					state.ForcedWalk = true
					state.IsRunning  = false
					StaminaService.ApplySpeedToCharacter(player, state)
				end
			else
				state.SP = math.min(state.MaxSP, state.SP + SP_CONFIG.IdleRegenPerSec * deltaTime)

				if state.ForcedWalk and state.SP >= SP_CONFIG.RunResumeThreshold then
					state.ForcedWalk = false
				end
			end

			-- Sync ke playerData.Stats agar bisa di-read client
			if stats then
				stats.SP    = math.floor(state.SP)
				stats.MaxSP = state.MaxSP
			end

			-- Apply velocity buff jika ada
			local buffSpeed = getBuffedSpeed and getBuffedSpeed(player) or 0
			StaminaService.ApplySpeedToCharacter(player, state, buffSpeed)
		end
	end
end

-- ============================================================
-- GetState(player) → { SP, MaxSP, IsRunning, ForcedWalk }
-- ============================================================
function StaminaService.GetState(player)
	return playerStates[player]
end

-- ============================================================
-- Cleanup
-- ============================================================
function StaminaService.OnPlayerRemoving(player)
	playerStates[player] = nil
end

return StaminaService
