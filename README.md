# Aetherion Roblox MMORPG Core

Aetherion core backend starter untuk Roblox / Luau.

## Fitur awal

- Max level 50
- Pilih race/faction saat player baru masuk
- Pilih class awal saat character dibuat
- Race/faction:
  - MECHA
  - CYBORG
  - MYSTIC
- Class awal:
  - Warrior
  - Ranger
  - Spiritualist
  - Specialist
- CYBORG tidak bisa memilih Spiritualist
- Mata uang berbeda per bangsa
- Starter weapon + armor sesuai race/class
- Auto equip starter item
- Level 30 class advancement
- Level 40 class advancement
- PT/proficiency data structure
- Basic equipment validation
- Basic combat formula
- Basic upgrade logic
- Content import rules untuk filtering database item sampai level 50

## Cara pakai

1. Buka folder ini di VS Code.
2. Jalankan:

```bash
rojo serve
```

3. Buka Roblox Studio.
4. Connect menggunakan plugin Rojo.
5. Play.
6. Buka F9 console dan test:

```lua
_G.Aetherion.Data()
_G.Aetherion.CreateCharacter("MECHA", "Warrior")
_G.Aetherion.CreateCharacter("CYBORG", "Ranger")
_G.Aetherion.CreateCharacter("MYSTIC", "Spiritualist")
```

Test invalid:

```lua
_G.Aetherion.CreateCharacter("CYBORG", "Spiritualist")
```

Harus gagal karena CYBORG tidak punya Spiritualist.

## Struktur

```text
src/
├── ReplicatedStorage/
│   ├── Shared/
│   │   ├── GameConfig.lua
│   │   ├── CombatFormulas.lua
│   │   └── Definitions/
│   │       ├── CurrencyDefinitions.lua
│   │       ├── RaceDefinitions.lua
│   │       ├── ClassDefinitions.lua
│   │       ├── ItemDefinitions.lua
│   │       └── ContentImportRules.lua
│   └── Remotes/
├── ServerScriptService/
│   ├── Boot/
│   │   └── GameServer.server.lua
│   └── Services/
│       ├── PlayerDataFactory.lua
│       ├── CharacterCreationService.lua
│       ├── LevelService.lua
│       ├── InventoryService.lua
│       ├── EquipmentService.lua
│       ├── CombatService.lua
│       └── UpgradeService.lua
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── ClientController.client.lua
```
