# Aetherion Roblox MMORPG Core

Aetherion core backend starter untuk Roblox / Luau — terinspirasi dari RF Online Classic.

## Changelog

### v3 (current)
- **Fix: Upgrade roll logic** — sebelumnya DESTROY/DOWNGRADE/LOCK bisa terjadi bersamaan dalam 1 attempt. Sekarang menggunakan single cumulative roll (SUCCESS → DESTROY → DOWNGRADE → FAIL), LOCK tetap independen seperti RF asli.
- **Fix: PT level up** — PT exp sekarang diberikan ke attacker (sesuai weapon type) dan defender (Defense PT) setelah setiap hit berhasil.
- **Fix: DataStore persistence** — data player tersimpan ke Roblox DataStoreService. Auto-save tiap 2 menit, save saat PlayerRemoving, retry logic 3x untuk handle throttle. Schema migration otomatis.
- **Fix: Currency separation** — player hanya punya Gold + currency faction sendiri. Faction currency lain tidak ada di data mereka.
- **Fix: Anti-exploit attack** — rate limiting server-side (0.4s cooldown), validasi target Instance, validasi humanoid masih hidup, validasi faction sudah dipilih, jarak dihitung dari server bukan client.

## Fitur

- Max level 50
- Pilih race/faction saat player baru masuk
- Pilih class awal saat character dibuat
- Race/faction: MECHA · CYBORG · MYSTIC
- Class awal: Warrior · Ranger · Spiritualist · Specialist
- CYBORG tidak bisa memilih Spiritualist
- Mata uang berbeda per bangsa (hanya faction sendiri)
- Starter weapon + armor sesuai race/class, auto equip
- Level 30 & 40 class advancement
- PT/proficiency system dengan level up aktif
- Upgrade sistem dengan risk: SUCCESS / DESTROY / DOWNGRADE / FAIL / LOCK
- DataStore persistence dengan schema migration
- Server-side combat validation

## Struktur

```
src/
├── ReplicatedStorage/
│   └── Shared/
│       ├── GameConfig.lua
│       ├── CombatFormulas.lua
│       └── Definitions/
│           ├── CurrencyDefinitions.lua
│           ├── RaceDefinitions.lua
│           ├── ClassDefinitions.lua
│           ├── ItemDefinitions.lua
│           └── ContentImportRules.lua
└── ServerScriptService/
    ├── Boot/
    │   └── GameServer.server.lua        ← integrasi DataStore + semua service
    └── Services/
        ├── DataPersistence.lua          ← NEW: DataStore load/save/migration
        ├── PlayerDataFactory.lua        ← Fix: currency init
        ├── CharacterCreationService.lua ← Fix: currency faction only
        ├── CombatService.lua            ← Fix: PT exp + anti-exploit
        ├── UpgradeService.lua           ← Fix: roll logic
        ├── LevelService.lua
        ├── InventoryService.lua
        └── EquipmentService.lua
```

## Cara pakai

```bash
rojo serve
```

Buka Roblox Studio → Connect via Rojo plugin → Play → F9 console:

```lua
_G.Aetherion.Data()
_G.Aetherion.CreateCharacter("MECHA", "Warrior")
_G.Aetherion.CreateCharacter("CYBORG", "Ranger")
_G.Aetherion.CreateCharacter("MYSTIC", "Spiritualist")
-- Harus gagal:
_G.Aetherion.CreateCharacter("CYBORG", "Spiritualist")
```

## Catatan DataStore

Untuk testing di Studio, aktifkan **"Enable Studio Access to API Services"** di Game Settings → Security.
