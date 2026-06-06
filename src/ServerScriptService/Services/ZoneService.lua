-- ZoneService.lua
-- Deteksi zone berdasarkan posisi player, safe zone protection, PvP flag.

local MapDefinitions = require(game.ReplicatedStorage.Shared.Definitions.MapDefinitions)

local ZoneService = {}

local Zones = MapDefinitions.Zones

-- ============================================================
-- GetZone: cari zone yang mencakup posisi ini (radius check)
-- Returns: zone table atau nil jika di luar semua zone
-- ============================================================
function ZoneService.GetZoneAtPosition(position)
	local bestZone = nil
	local bestDist = math.huge

	for _, zone in pairs(Zones) do
		local center = zone.Center
		local dx = position.X - center.X
		local dz = position.Z - center.Z
		local dist2D = math.sqrt(dx * dx + dz * dz)

		if dist2D <= zone.Radius then
			-- Pilih zone dengan center terdekat jika posisi overlap beberapa zone
			if dist2D < bestDist then
				bestDist = dist2D
				bestZone = zone
			end
		end
	end

	return bestZone
end

-- ============================================================
-- GetPlayerZone: zone dari karakter player saat ini
-- ============================================================
function ZoneService.GetPlayerZone(player)
	local character = player.Character
	if not character then return nil end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	return ZoneService.GetZoneAtPosition(hrp.Position)
end

-- ============================================================
-- IsInSafeZone
-- ============================================================
function ZoneService.IsInSafeZone(position)
	local zone = ZoneService.GetZoneAtPosition(position)
	return zone ~= nil and zone.SafeZone == true
end

function ZoneService.IsPlayerInSafeZone(player)
	local character = player.Character
	if not character then return false end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	return ZoneService.IsInSafeZone(hrp.Position)
end

-- ============================================================
-- IsPvPZone
-- ============================================================
function ZoneService.IsPvPZone(position)
	local zone = ZoneService.GetZoneAtPosition(position)
	return zone ~= nil and zone.PvP == true
end

function ZoneService.IsPlayerInPvPZone(player)
	local character = player.Character
	if not character then return false end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	return ZoneService.IsPvPZone(hrp.Position)
end

-- ============================================================
-- GetLevelRange: level range yang sesuai di posisi ini
-- ============================================================
function ZoneService.GetLevelRangeAtPosition(position)
	local zone = ZoneService.GetZoneAtPosition(position)
	if not zone then return nil end
	return zone.LevelRange
end

return ZoneService
