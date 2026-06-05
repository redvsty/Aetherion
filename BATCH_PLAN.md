# Aetherion — Master Batch Plan
> Target: 100% RF Classic mechanics, beda nama saja.
> Setiap batch bisa dikerjakan mandiri. Dependensi dicantumkan di tiap batch.

---

## STATUS BATCH SEBELUMNYA

| Batch | Nama | Status |
|-------|------|--------|
| 1 | Core Foundation (data, schema, equipment) | ✅ Done |
| 2 | Combat, Skills, Buff, Defense Gauge | ✅ Done |
| 2.5 | UI Gameplay (HUD, belt, hotkey, macro, SP) | ✅ Done |

---

## BATCH 3 — Class System Lengkap
> Dep: Batch 1 (CharacterCreation, PT system)

RF Classic punya tiga jalur class per ras. Tiap ras punya nama class sendiri.

### 3A — Starting Classes (Level 1)
Semua ras punya 4 pilihan awal:

| RF Class | Aetherion Name | Spesialisasi |
|----------|---------------|--------------|
| Warrior | Vanguard | Melee DPS/Tank |
| Ranger | Striker | Ranged physical |
| Specialist | Technician | Support, ammo, craft |
| Spiritualist | Invoker | Force/magic, heal |

### 3B — Level 30 Advancement
Setiap starting class bercabang jadi 2:

| Starting | Branch A | Branch B |
|----------|----------|----------|
| Vanguard | Berserker (pure DPS) | Sentinel (tank/shield) |
| Striker | Sniper (single target) | Blaster (launcher/AoE) |
| Technician | Medic (heal support) | Saboteur (debuff/trap) |
| Invoker | Sage (Force DPS) | Warden (buff/support) |

### 3C — Level 40 Final Advancement
Tiap branch L30 maju ke versi final (total 8 end-class per ras).

### 3D — Stat Scaling Per Class
- Tiap class punya multiplier HP/FP/SP per level yang berbeda
- Vanguard: HP tinggi, FP rendah
- Invoker: FP tinggi, HP rendah
- Technician: SP tinggi (lebih banyak ammo = lebih lama run)

**Files yang perlu dibuat/edit:**
- `GameConfig.lua` — tambah class definitions lengkap
- `CharacterCreationService.lua` — validasi branch per class
- `DataPersistence.lua` — schema migration untuk class baru
- `AetherionGameplayUI.lua` — UI class selection visual upgrade

---

## BATCH 4 — Skill System Lengkap
> Dep: Batch 2 (SkillService), Batch 3 (class system)

### 4A — Skill Trees Per Class
Setiap class punya skill tree sendiri, mirip RF:
- **Vanguard/Berserker**: Slash, Wild Rage, Aura Blade, Battle Cry
- **Sentinel**: Shield Bash, Iron Wall, Provoke, Fortress Aura
- **Sniper**: Aimed Shot, Piercing Arrow, Eagle Eye, Rapid Fire
- **Blaster**: Grenade Launcher, Cluster Bomb, Smoke Screen, Barrage
- **Sage (Invoker)**: Force Bolt, Force Storm, Gravity Well, Arcane Pulse
- **Warden**: Bless, Restoration, Holy Barrier, Spirit Link
- **Medic/Technician**: Blood Shot (heal ally via ammo), Repair Drone, Shield Boost
- **Saboteur**: Stun Trap, Acid Shot, Debilitate, Overclock

### 4B — Force System (Sage/Warden/Invoker)
- Skill Force pakai FP
- Tiap skill Force punya Element: Fire / Ice / Lightning / Holy / Dark
- Cora Sage > Bellato Sage dalam power Force (sesuai lore RF)
- Accretia tidak punya Invoker (diganti Technician hybrid)

### 4C — Blood Ammo System (Accretia Technician/Medic)
> Mekanik unik Accretia — heal via tembakan ammo ke ally

- Technician punya ammo type: **Blood Round**
- Saat tembak ke **ally** → restore HP (heal)
- Saat tembak ke **enemy** → damage biasa (atau sedikit lebih lemah)
- Ammo terbatas, bisa dibeli/craft
- Implementasi: `ProjectileType = "BloodRound"`, target faction check di server

### 4D — Buff/Debuff Lengkap
- Duration system sudah ada (ActiveBuffs)
- Tambah: Stun, Slow, Silence (tidak bisa cast Force), Bleed
- Visual indicator buff di HUD

### 4E — Skill PT Gating
- Skill tier 1 buka di PT level 1-10
- Skill tier 2 buka di PT level 20-30
- Skill tier 3 (ultimate) buka di PT level 40+
- Sama persis dengan sistem PT RF Classic

**Files yang perlu dibuat/edit:**
- `src/ReplicatedStorage/Shared/Definitions/SkillDefinitions.lua` — semua skill per class
- `SkillService.lua` — Blood Ammo logic, element system
- `CombatService.lua` — element damage calculation
- `AetherionGameplayUI.lua` — skill tree UI panel

---

## BATCH 5 — Item & Potion System Lengkap
> Dep: Batch 1 (InventoryService, ItemDefinitions)

### 5A — Potion Definitions (RF Classic tiers)

**Bless HP Potion** (restore HP):
| Tier | Nama | Restore |
|------|------|---------|
| 1 | Small Bless Potion | +100 HP |
| 2 | Medium Bless Potion | +250 HP |
| 3 | Large Bless Potion | +500 HP |
| 4 | Grand Bless Potion | +1000 HP |
| 5 | Special Bless Potion | +2000 HP |
| 6 | Major Bless Potion | +3000 HP |

**Aid FP Potion** (restore FP):
| Tier | Nama | Restore |
|------|------|---------|
| 1 | Small Aid Potion | +50 FP |
| 2 | Medium Aid Potion | +125 FP |
| 3 | Large Aid Potion | +250 FP |
| 4 | Grand Aid Potion | +500 FP |
| 5 | Special Aid Potion | +1000 FP |

**Bless SP Potion** (restore SP):
| Tier | Nama | Restore |
|------|------|---------|
| 1 | Stamina Vial | +100 SP |
| 2 | Stamina Flask | +250 SP |
| 3 | Stamina Elixir | +500 SP |

### 5B — Equipment Tiers & Grades
RF Classic punya grade equipment: Normal → Rare → Unique → Legendary
- Normal: drop dari monster biasa
- Rare: drop dari elite monster / quest reward
- Unique: drop dari boss / event
- Legendary: craft atau world boss

### 5C — Blood Ammo Item (Accretia Technician)
- `blood_round_small`: stack 100, restore 50 HP ke ally
- `blood_round_medium`: stack 100, restore 150 HP ke ally
- `blood_round_large`: stack 100, restore 350 HP ke ally

### 5D — Upgrade & Talic System (expand existing)
- Talic types: Attack / Defense / Speed / Force / Element
- Slot max per item: 0-4 (random saat item drop)
- Upgrade level: +0 → +9 (sudah ada), tambah visual glow per +level

**Files yang perlu dibuat/edit:**
- `ItemDefinitions.lua` — semua potion + blood ammo
- `InventoryService.lua` — stack logic untuk ammo
- `UseItemRequest` handler — sudah ada, tinggal data

---

## BATCH 6 — MAU System (Bellato/MECHA)
> Dep: Batch 3 (class system), Batch 5 (item system)

Fitur paling ikonik Bellato. MAU = Mechanical Armor Unit = robot besar yang bisa dinaiki.

### 6A — MAU Types
| Tipe | RF Name | Spesialisasi |
|------|---------|--------------|
| Scout MAU | Scouter | Cepat, DPS ringan |
| Fighter MAU | Golem | Tank, melee berat |
| Blaster MAU | Tyrant | Ranged, AoE |

### 6B — MAU Mechanics
- Hanya **Bellato Vanguard/Berserker** dan **Blaster** yang bisa naik MAU
- MAU punya HP sendiri (bukan HP player)
- Saat MAU HP = 0 → eject otomatis ke character normal
- MAU punya Fuel (SP analog) — habis fuel = tidak bisa gerak
- MAU lebih lambat dari karakter normal tapi jauh lebih kuat
- MAU tidak bisa masuk dungeon/instanced zone tertentu

### 6C — MAU Implementation
- MAU = Model terpisah di workspace, player "mount" ke MAU
- Server-side: MAU state per player, HP/Fuel tracking
- Client: UI MAU stats (HP bar, Fuel bar) menggantikan normal HUD saat riding
- Keyboard: E = mount/dismount MAU

**Files yang perlu dibuat:**
- `src/ServerScriptService/Services/MAUService.lua`
- `src/ReplicatedStorage/Shared/Definitions/MAUDefinitions.lua`
- `src/ReplicatedStorage/Shared/Client/MAUPanel.lua` (UI)

---

## BATCH 7 — Animus System (Cora/MYSTIC)
> Dep: Batch 3 (class system)

Fitur ikonik Cora. Animus = creature companion yang ikut battle.

### 7A — Animus Types
| Tipe | Spesialisasi |
|------|--------------|
| Combat Animus | Attack enemy |
| Support Animus | Buff/heal owner |
| Scout Animus | Detect enemy/stealth |

### 7B — Animus Mechanics
- Hanya **Cora** yang bisa punya Animus
- Animus punya level dan stats sendiri
- Animus level naik dari kill bersama player
- Animus bisa mati (perlu revive dengan item)
- Max 1 Animus aktif per player

### 7C — Animus Implementation
- Animus = NPC yang follow player, server-side AI
- Stats Animus saved di playerData
- Client UI: panel Animus (stats, command: attack/stay/follow)

**Files yang perlu dibuat:**
- `src/ServerScriptService/Services/AnimusService.lua`
- `src/ReplicatedStorage/Shared/Definitions/AnimusDefinitions.lua`
- `src/ReplicatedStorage/Shared/Client/AnimusPanel.lua`

---

## BATCH 8 — World & Zone System
> Dep: Batch 1-5

### 8A — Zone Types (RF Classic)
| Tipe | Keterangan |
|------|-----------|
| Starter Zone | Per ras, aman (no PvP) |
| Neutral Zone | Bisa farming, PvP terbatas |
| Contested Zone | Full PvP, Chip War area |
| Outpost Zone | Capture point location |

### 8B — Monster System
- Monster spawn di lokasi tertentu per zone
- Monster punya faction preference (attack enemy ras, neutral ke ras sendiri)
- Elite monster / mini-boss spawn jarang, drop rare item
- World boss spawn terjadwal (RF Classic: Archon / Phoenia / dll)

### 8C — Resource Nodes
- Ore deposit: bisa ditambang Technician/Specialist
- Hasil: material untuk craft item/upgrade

**Files yang perlu dibuat:**
- `src/ServerScriptService/Services/SpawnService.lua`
- `src/ServerScriptService/Services/ZoneService.lua`
- `src/ReplicatedStorage/Shared/Definitions/MonsterDefinitions.lua`

---

## BATCH 9 — Chip War / Sector War System
> Dep: Batch 8 (Zone), Batch 3 (class)
> **Fitur utama RF Classic — ini alasan orang main RF**

### 9A — Chip War Mechanics
RF Classic Chip War:
- Tiap ras punya **Chip** (inti kekuatan ras)
- Chip diletakkan di **HQ (Headquarters)** ras masing-masing
- Tujuan: **hancurkan Chip milik 2 ras lain** sebelum chip kamu dihancurkan
- Chip War terjadwal: server-wide event (misal 3x seminggu)
- Menang → ras pemenang dapat buff ekonomi/resource 1 minggu

### 9B — Sector Capture
- Map dibagi dalam sector/zone
- Sector punya **Control Point** yang bisa di-capture
- Capture = bertahan di area X detik tanpa interrupted
- Makin banyak sector → makin besar bonus resource ras

### 9C — Kill System (RF Classic style)
- Kill enemy ras → dapat **Kill Point** (KP)
- KP dipakai untuk rank dalam ras
- Death → kehilangan sebagian EXP (RF Classic: death penalty)

### 9D — Council System
- Tiap ras punya **Council** (pemimpin ras)
- Dipilih dari player dengan KP/rank tertinggi
- Council punya power: deklarasi war, bagi resource, dll

**Files yang perlu dibuat:**
- `src/ServerScriptService/Services/ChipWarService.lua`
- `src/ServerScriptService/Services/SectorService.lua`
- `src/ServerScriptService/Services/CouncilService.lua`
- `src/ReplicatedStorage/Shared/Client/WarHUDPanel.lua`

---

## BATCH 10 — Economy & Trading
> Dep: Batch 5 (item system)

### 10A — NPC Shops
- Tiap ras punya NPC shop di starter zone
- Jual: potion, basic ammo, basic equipment
- Beli: item drop dari player (di harga bawah market)

### 10B — Player Market
- Market system: player bisa list item untuk dijual
- Buyer beli tanpa harus ketemu seller (async)
- Fee listing: kecil (anti dump)

### 10C — Currency
- Primary: **Dalant** (RF Classic = Dalant) → sudah ada di Currencies
- Secondary: **Carat** (premium, event reward)
- Ore/material sebagai barter di market

### 10D — Crafting System
- Technician/Specialist bisa craft item dari material
- Craft recipe: public, material dari drop/mining
- Gagal craft → material hilang (RF Classic style risk)

**Files yang perlu dibuat:**
- `src/ServerScriptService/Services/ShopService.lua`
- `src/ServerScriptService/Services/MarketService.lua`
- `src/ServerScriptService/Services/CraftService.lua`
- `src/ReplicatedStorage/Shared/Definitions/RecipeDefinitions.lua`

---

## BATCH 11 — Quest & Mission System
> Dep: Batch 8 (zone/monster)

### 11A — Quest Types (RF Classic)
| Tipe | Keterangan |
|------|-----------|
| Starter Quest | Tutorial per ras |
| Kill Quest | Bunuh X monster |
| Gather Quest | Kumpulkan X item |
| Escort Quest | Antar NPC ke titik tujuan |
| War Quest | Participate di Chip War |

### 11B — Daily Missions
- Reset tiap hari
- Reward: EXP bonus + Dalant + rare item chance

### 11C — Faction Quest
- Quest yang progress war story per ras
- Unlock lore dan NPC dialog

**Files yang perlu dibuat:**
- `src/ServerScriptService/Services/QuestService.lua`
- `src/ReplicatedStorage/Shared/Definitions/QuestDefinitions.lua`
- `src/ReplicatedStorage/Shared/Client/QuestPanel.lua`

---

## BATCH 12 — Polish & RF Fidelity
> Dep: semua batch di atas

### 12A — Death Penalty (RF Classic)
- Mati → kehilangan X% EXP (amount tergantung level)
- Level < 10: tidak ada penalty (newbie protection)
- Level 10-30: -2% EXP
- Level 30+: -5% EXP
- Mati di Chip War zone: -1% extra

### 12B — Resurrection System
- Mati → respawn di HQ ras sendiri
- Cora Warden punya skill Resurrection (revive ally in-place)
- Item: Resurrection Stone (revive diri sendiri in-place, cooldown)

### 12C — PvP Flag System
- Di neutral zone: harus **flag dulu** sebelum bisa attack player lain ras
- Di contested zone: auto-flag semua ras musuh
- Friendly fire: TIDAK ada (tidak bisa attack sesama ras)

### 12D — Spawn Protection
- Baru spawn: 5 detik invincible + tidak bisa attack
- Prevents spawn camping

### 12E — Anti-AFK System
- Idle > 15 menit → kick ke login screen
- Farming bot prevention

---

## URUTAN PENGERJAAN YANG DISARANKAN

```
Batch 5A (Potion items)     ← paling cepat, langsung berguna
    ↓
Batch 4A (Skill trees)      ← content terbesar, kerjakan bertahap
    ↓
Batch 4C (Blood Ammo)       ← unique mechanic, bikin game berasa RF
    ↓
Batch 3 (Class system)      ← foundation banyak batch lain
    ↓
Batch 9 (Chip War)          ← endgame content, paling penting buat retensi
    ↓
Batch 6 (MAU)               ← Bellato identity
    ↓
Batch 7 (Animus)            ← Cora identity
    ↓
Batch 8 (World/Zone)        ← butuh map design di Roblox Studio
    ↓
Batch 10 (Economy)
    ↓
Batch 11 (Quest)
    ↓
Batch 12 (Polish)
```

---

## CATATAN NAMA (RF → Aetherion)

| RF Classic | Aetherion |
|-----------|-----------|
| Bellato | MECHA |
| Cora | MYSTIC |
| Accretia | CYBORG |
| Dalant | Dalant (sama) |
| Animus | TBD |
| MAU | TBD |
| Chip | TBD |
| HQ | TBD |
| Council | TBD |
| Chip War | TBD |

> Nama TBD bisa ditentukan user kapan saja, implementasi tidak bergantung pada nama.
