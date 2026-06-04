-- DataStoreService.lua
-- Fix 3: Persistent player data menggunakan Roblox DataStoreService.
-- Data disave saat PlayerRemoving dan auto-load saat PlayerAdded.
-- Schema migration otomatis jika SchemaVersion berubah.
-- Retry logic untuk handle DataStore throttle / error sementara.

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)
local CurrencyDefinitions = require(game.ReplicatedStorage.Shared.Definitions.CurrencyDefinitions)

local DATASTORE_NAME = "AetherionPlayerData_v3"
local CURRENT_SCHEMA = 3
local MAX_RETRIES = 3
local RETRY_DELAY = 2 -- detik antar retry
local AUTO_SAVE_INTERVAL = 120 -- detik, auto-save tiap 2 menit

local playerStore = DataStoreService:GetDataStore(DATASTORE_NAME)

local DataPersistence = {}

-- ============================================================
-- Helpers
-- ============================================================

local function log(msg)
	print("[DataPersistence]", msg)
end

local function warn_(msg)
	warn("[DataPersistence]", msg)
end

-- Retry wrapper untuk DataStore calls
local function retryOperation(operation, label)
	for attempt = 1, MAX_RETRIES do
		local ok, result = pcall(operation)

		if ok then
			return true, result
		end

		warn_(string.format("%s gagal (attempt %d/%d): %s", label, attempt, MAX_RETRIES, tostring(result)))

		if attempt < MAX_RETRIES then
			task.wait(RETRY_DELAY * attempt)
		end
	end

	return false, nil
end

-- ============================================================
-- Schema Migration
-- ============================================================

-- Migrasi dari schema lama ke schema baru.
-- Tambahkan case baru di sini saat SchemaVersion naik.
local function migrateData(data)
	local version = data.SchemaVersion or 1

	-- v1 → v2: tambah ContributionPoints & ChaosUntil
	if version < 2 then
		data.ContributionPoints = data.ContributionPoints or 0
		data.ChaosUntil = data.ChaosUntil or 0
		version = 2
	end

	-- v2 → v3: pisahkan currency — hapus faction currency yang bukan milik player
	if version < 3 then
		if data.FactionId then
			-- Hanya simpan currency faction sendiri
			local ownCurrencyId = CurrencyDefinitions.GetFactionCurrencyId(data.FactionId)
			local newCurrencies = { Gold = data.Currencies and data.Currencies.Gold or 0 }

			if ownCurrencyId and data.Currencies and data.Currencies[ownCurrencyId] then
				newCurrencies[ownCurrencyId] = data.Currencies[ownCurrencyId]
			end

			data.Currencies = newCurrencies
		else
			-- Belum pilih faction, hapus semua kecuali Gold
			data.Currencies = { Gold = (data.Currencies and data.Currencies.Gold) or 0 }
		end

		version = 3
	end

	data.SchemaVersion = CURRENT_SCHEMA
	return data
end

-- ============================================================
-- Default data (dipanggil jika player belum punya data tersimpan)
-- Ini hanya struktur kosong — isi awal dari PlayerDataFactory
-- ============================================================

local function buildDefaultData(player)
	-- Import factory di sini untuk avoid circular dependency
	local PlayerDataFactory = require(script.Parent.PlayerDataFactory)
	return PlayerDataFactory.Create(player)
end

-- ============================================================
-- Load
-- ============================================================

function DataPersistence.Load(player)
	local key = tostring(player.UserId)

	local ok, data = retryOperation(function()
		return playerStore:GetAsync(key)
	end, "Load " .. key)

	if not ok or not data then
		if not ok then
			warn_(
				string.format(
					"Gagal load data player %s setelah %d retry. Menggunakan data default (tidak akan disave sampai berhasil).",
					player.Name,
					MAX_RETRIES
				)
			)
		else
			log(string.format("Player baru: %s. Membuat data default.", player.Name))
		end

		return buildDefaultData(player), not ok -- return (data, isLoadFailed)
	end

	-- Migration
	data = migrateData(data)
	data.Party = nil

	-- Pastikan field wajib ada (proteksi dari data corrupt parsial)
	data.UserId = data.UserId or player.UserId
	data.Name = player.Name -- selalu update nama terkini
	data.MaxLevel = GameConfig.MaxLevel

	log(string.format("Data player %s berhasil diload (schema v%d).", player.Name, data.SchemaVersion))

	return data, false
end

-- ============================================================
-- Save
-- ============================================================

function DataPersistence.Save(player, data)
	if not data then
		warn_("Save dipanggil tapi data nil untuk " .. player.Name)
		return false
	end

	-- Jangan save data template kosong yang belum punya UserId valid
	if not data.UserId then
		warn_("Data tidak punya UserId, skip save untuk " .. player.Name)
		return false
	end

	local key = tostring(player.UserId)
	local transientParty = data.Party
	data.Party = nil

	local ok, _ = retryOperation(function()
		playerStore:SetAsync(key, data)
	end, "Save " .. key)

	data.Party = transientParty

	if ok then
		log(string.format("Data player %s berhasil disave.", player.Name))
	else
		warn_(string.format("Gagal save data player %s setelah %d retry!", player.Name, MAX_RETRIES))
	end

	return ok
end

-- ============================================================
-- Auto Save Loop
-- ============================================================

-- Dipanggil dari GameServer dengan reference ke profiles table
function DataPersistence.StartAutoSave(profiles)
	task.spawn(function()
		while true do
			task.wait(AUTO_SAVE_INTERVAL)

			log("Auto-save dimulai...")

			for player, data in pairs(profiles) do
				if player and player.Parent and data then
					DataPersistence.Save(player, data)
					task.wait(0.5) -- throttle antar save
				end
			end

			log("Auto-save selesai.")
		end
	end)
end

return DataPersistence
