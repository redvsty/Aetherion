# Aetherion — Master Batch Plan
> Target: 1:1 RF Classic mechanics, nama berbeda.
> Direvisi 2026-06-05 berdasarkan audit eksplisit kode vs memory RF Classic.
>
> Phase 1 = Max Level 50 — semua batch di bawah ini
> Phase 2 = Max Level 66 — tambah map baru, equipment tier baru, content L51-66
> Phase 3 = Max Level 75 — tambah map baru, equipment tier baru, content L67-75

---

## STATUS BATCH

| Batch | Nama | Status |
|-------|------|--------|
| Batch 0 | Foundation Fix | ✅ Done |
| Batch 1 | HUD + Belt + UI Windows | ✅ Done |
| Batch 2 | Skill + Force System | ✅ Done |
| Batch 3 | Class + Race System | ✅ Done |
| Batch 3.1 | Pre-Batch Fix (Audit Gaps) | 🔲 Next |
| Batch 4 | Monster + PvE Core | 🔲 Pending |
| Batch 5 | Potion + NPC + Quest Dasar | 🔲 Pending |
| Batch 6 | MAU + Launcher Siege | 🔲 Pending |
| Batch 7 | Animus System | 🔲 Pending |
| Batch 8 | World + Zone + Mining | 🔲 Pending |
| Batch 9 | Chip War + PvP System | 🔲 Pending |
| Batch 10 | Economy + Guild | 🔲 Pending |
| Batch 11 | Quest Lanjutan + Archon | 🔲 Pending |
| Batch 12 | Dungeon + Boss | 🔲 Pending |
| Batch 13 | Polish + Audio + VFX | 🔲 Pending |

---

## BATCH 3.1 — Pre-Batch Fix (Deviasi Struktural)
> Harus selesai sebelum Batch 4. Memperbaiki deviasi hasil audit RF Classic.

### Tujuan
Memperbaiki bagian yang sudah diimplementasi tapi tidak akurat vs RF Classic.

### Tasks

**Fix 1: Accretia/CYBORG Specialist L30 — dari 2 opsi jadi 1**
- RF Classic: Specialist → L30: Engineer (satu) → L40: Scientist / Battle Leader
- Aetherion sekarang: MechanicEngineer + BloodMedic (dua L30)
- Fix: Hapus BloodMedic dari L30, jadikan FieldSurgeon + BloodArsenal tetap di L40 dari MechanicEngineer
- File: `ClassDefinitions.lua` → `Advancement30.CYBORG.Specialist`

**Fix 2: Cora/MYSTIC Specialist L30 — dari 2 opsi jadi 1**
- RF Classic: Specialist → L30: Craftsman (satu) → L40: Artisan
- Aetherion sekarang: SoulArtisan + RuneEngineer (dua L30)
- Fix: Jadikan satu L30 (SoulArtisan), RuneEngineer pindah ke L40
- File: `ClassDefinitions.lua` → `Advancement30.MYSTIC.Specialist`

**Fix 3: Tambah 4 Talic yang Hilang**
- Vital Talic → HP flat increase (semua armor)
- Force Talic → FP flat increase (semua armor)
- Speed Talic → Movement speed % (boots)
- Luck Talic → Crit rate / item drop rate increase
- File: `ItemDefinitions.lua`

**Fix 4: Tambah Summoning PT ke GameConfig**
- RF Classic: Cora punya Summoning PT (untuk Animus)
- File: `GameConfig.lua` → tambah `Summoning = "Summoning"` ke PTTypes
- File: `PlayerDataFactory.lua` → tambah Summoning ke PT field

**Fix 5: Level milestones di level gating**
- L4: Armor hanya bisa dipakai mulai level 4 (training armor tetap L1)
- L13: Class-specific armor harus cek level 13
- L15: Launcher hanya bisa dipakai CYBORG mulai level 15
- File: `EquipmentService.lua`

### Deliverables
- [ ] ClassDefinitions.lua: Specialist path CYBORG dan MYSTIC diperbaiki
- [ ] ItemDefinitions.lua: +4 talic (Vital, Force, Speed, Luck)
- [ ] GameConfig.lua: PTTypes += Summoning
- [ ] PlayerDataFactory.lua: PT field += Summoning
- [ ] EquipmentService.lua: Level gate L4/L13/L15

---

## BATCH 4 — Monster + PvE Core
> Dependensi: Batch 3.1 selesai.

### Tujuan
Membuat game bisa dimainkan untuk PvE. Tanpa ini, tidak ada progression loop.

### Tasks

**Monster System**
- `MonsterDefinitions.lua` — definisi semua monster dengan stats:
  - Level, MaxHP, Attack, Defense, ExpReward, GoldDrop
  - Monster RF level 1-20 (near HQ): Anabola, Warbeast, Frog, Tweezer, Splinter
  - DropTable: item apa yang bisa drop + probabilitas
- `MonsterService.lua` (Server) — spawn, respawn timer, AI
  - Spawn di posisi tertentu di map
  - Respawn 30 detik setelah mati
  - Patrol AI: idle, aggro radius (deteksi player), chase, attack
  - Leash: kembali ke spawn jika player kabur terlalu jauh
- RemoteEvent: `MonsterHitEvent`, `MonsterDiedEvent`

**Death Penalty (RF Classic accurate)**
- PvE death: kehilangan EXP 2% (sesuai RF default)
- PvP death: kehilangan CP, TIDAK kehilangan EXP
- Respawn: muncul di HQ ras masing-masing
- L8+: Bisa di-resurrect oleh NPC (tombol) — akan disambungkan ke Batch 5 NPC

**Combat Visual Feedback**
- Damage numbers mengambang di atas target (putih=normal, kuning=crit, merah=miss)
- HP bar di atas kepala monster
- Buff/debuff icons di HUD (di bawah HP/FP/SP bar)
- Skill cast visual (glow sederhana di tangan)

**Loot System**
- Saat monster mati: spawn loot bag di lokasi monster
- Loot bag bisa diklik untuk pickup
- Item masuk ke inventory player
- Gold langsung masuk ke wallet
- Loot protected: hanya player yang membunuh yang bisa ambil (10 detik), setelah itu free-for-all

### Deliverables
- [ ] MonsterDefinitions.lua
- [ ] MonsterService.lua (server)
- [ ] MonsterController.client.lua (client AI update)
- [ ] Death penalty di GameServer/LevelService
- [ ] Damage numbers UI
- [ ] Buff/debuff icon HUD
- [ ] Loot system (bag, pickup, inventory insert)

---

## BATCH 5 — Potion + NPC + Quest Dasar
> Dependensi: Batch 4 (monster + loot ada).

### Tujuan
Player bisa beli potion, ada NPC vendor, ada quest sederhana untuk progression awal.

### Tasks

**Potion Items (RF Classic accurate)**
Tambahkan ke `ItemDefinitions.lua`:
- HP Potion 7 tier: Small(100), Normal(250), Medium(500), Large(1000), Great(2000), Super(3000), Major(5000)
- FP Potion 7 tier: Small(50), Normal(125), Medium(250), Large(500), Great(1000), Super(1500), Major(2500)
- SP Potion: 3 tier (nilai estimasi: 50/150/300)

**Potion Mechanics**
- `UseItemRequest` handler di GameServer
- HP/FP/SP restore sesuai definisi
- Cooldown per tipe: HP cooldown 10 detik, FP cooldown 10 detik, SP cooldown 15 detik
- Cooldown terpisah (bisa minum HP + FP bersamaan)
- Macro auto-potion: jika HP < threshold, otomatis pakai HP potion dari hotbar

**NPC System**
- `NPCDefinitions.lua` — definisi NPC (id, nama, tipe, posisi, inventory jual)
- `NPCService.lua` — interaksi NPC
- Tipe NPC:
  - Weapon Vendor: jual senjata sesuai level range
  - Armor Vendor: jual armor sesuai level range
  - Potion Vendor: jual semua tier potion
  - Buffer NPC: kasih buff gratis (durasi pendek)
- Shop UI: tampilkan item NPC, tombol beli, cek gold

**Quest System Dasar**
- `QuestDefinitions.lua` — definisi quest:
  - Kill Quest: bunuh X monster
  - Collect Quest: kumpulkan X item drop
- `QuestService.lua` — track progress, reward
- Quest UI (J key): daftar quest aktif, progress, objective
- Starter quest per ras (masing-masing 3 quest level 1-20)

**Chat Commands**
- `/party` — info party
- `/whisper [nama]` — pesan private
- `/guild` — info guild (placeholder)

### Deliverables
- [ ] ItemDefinitions.lua: +HP/FP/SP potions (17 item)
- [ ] UseItemRequest handler di GameServer
- [ ] PotionCooldown tracking di PlayerData atau server state
- [ ] NPCDefinitions.lua
- [ ] NPCService.lua + shop UI
- [ ] QuestDefinitions.lua (starter quests)
- [ ] QuestService.lua
- [ ] Quest UI (J key)
- [ ] Chat commands /party /whisper

---

## BATCH 6 — MAU + Launcher Siege Mode
> Dependensi: Batch 5 selesai. Batch ini butuh map yang sudah ada.

### Tujuan
Mengimplementasi unique mechanic MECHA (MAU) dan CYBORG (Siege Mode) — dua dari tiga RF signature feature.

### Tasks

**MAU System (MECHA/Bellato exclusive)**
- Hanya bisa dipakai class ArmorDriver (L30) dan GoliathPilot/CatapultPilot (L40)
- MAU sebagai item di inventory (beli dari NPC ~1 juta Gold)
- Saat aktif: player masuk ke MAU model
  - MAU punya HP sendiri (bukan HP player)
  - MAU punya Fuel (analog SP) — habis saat bergerak
  - Speed lebih lambat dari karakter normal
  - DEF jauh lebih tinggi, ATK lebih tinggi
- Saat MAU HP = 0: player eject, MAU hancur (bisa repair)
- 2 tipe MAU:
  - Goliath: melee tank, energy blade weapon
  - Catapult: ranged, AoE attack
- Repair MAU: NPC Mechanic atau item Repair Kit

**Launcher Siege Mode (CYBORG/Accretia exclusive)**
- Launcher sudah ada sebagai weapon type
- Tambah Siege Mode activation:
  - Item Siege Kit di inventory
  - Klik "Enter Siege Mode" saat equip Launcher
  - Karakter tidak bisa bergerak saat Siege Mode
  - Damage launcher meningkat 150%
  - AoE radius lebih besar
  - Chain Rocket (L40 Striker only): tembak 3 roket sekaligus
- Exit Siege Mode: tombol atau kena interrupt
- Ammo system: launcher butuh ammo item, bisa habis

### Deliverables
- [ ] MAU item definitions (Goliath, Catapult)
- [ ] MAUService.lua (server: enter/exit MAU, HP tracking, fuel)
- [ ] MAU model controller (client: input saat di MAU)
- [ ] Siege Mode state di StaminaService atau baru SiegeService.lua
- [ ] Ammo item definitions + consumption system
- [ ] Siege Mode UI indicator

---

## BATCH 7 — Animus System
> Dependensi: Batch 5 selesai.

### Tujuan
Mengimplementasi unique mechanic MYSTIC (Cora) — Animus companion.

### Tasks

**Animus System (MYSTIC/Cora exclusive)**
- Hanya AnimusCaller (L30) dan SummonMaster/SoulBinder (L40) yang bisa summon
- 4 tipe Animus (item Animus Egg per tipe):
  - Paimon (Sword): melee attacker, close combat
  - Inanna (Cure): healer — heal summoner + ally sesama MYSTIC
  - Hecate (Flame): Force damage attacker, fastest Force growth
  - Isis (Lightning): highest ATK, efektif vs heavy armor
- Mechanic:
  - Max 1 Animus aktif per player
  - Animus punya level dan EXP sendiri (naik dari ikut membunuh monster)
  - Animus punya HP — bisa mati → perlu Animus Revival item
  - Animus berubah model saat level naik (milestone tertentu)
  - AI: follow summoner, auto-attack target summoner
- Summoning PT naik setiap Animus membunuh atau aktif
- Jika summoner mati, Animus menghilang (tidak mati permanen)

### Deliverables
- [ ] AnimusDefinitions.lua (4 tipe, stat scaling per level)
- [ ] AnimusService.lua (server: summon, AI, level, HP)
- [ ] Animus item definitions (4 Egg + Revival)
- [ ] Animus model per tipe (basic model)
- [ ] Summoning PT naik saat Animus aktif
- [ ] Animus HUD indicator (nama, HP, level)

---

## BATCH 8 — World + Zone + Mining
> Dependensi: Batch 4-5 selesai.

### Tujuan
World navigation, zona berbeda dengan monster berbeda, dan mining system RF Classic.

### Tasks

**Zone System**
- `ZoneDefinitions.lua` — definisi zona (nama, level range, faction akses, monster list)
- Zona Phase 2:
  - HQ per ras (MECHA HQ, CYBORG HQ, MYSTIC HQ)
  - Starter zone (L1-20) per ras
  - Mid zone (L20-35): Haram/213 equivalents
  - Ether zone (L35-45)
  - Crag Mine (contested, level 30+)
- Zone transition: teleport ke zona lain via portal
- Mini-map: tampilkan posisi player + zona saat ini

**Mining System (RF Classic accurate)**
- 5 ore type items: Blue Ore, Red Ore, Yellow Ore, Green Ore, Black Ore
- Mining Tool + Battery items
- `MiningService.lua` (server):
  - Klik ore node → mulai mining (animasi + progress bar)
  - Butuh Mining Tool + Battery di inventory
  - Battery drain per ore mined
  - Hasil: ore item masuk inventory
- Ore Processing NPC:
  - Input ore → output ore lain + talic + gems
  - T1-T5 gems dari ore biasa/+1/+2/+3
- Crag Mine: hanya bisa diakses ras yang menang Chip War

**World Map UI**
- M key: buka world map
- Tampilkan zona yang sudah unlocked
- Fast travel via waypoint (bayar gold)

### Deliverables
- [ ] ZoneDefinitions.lua
- [ ] ZoneService.lua (server: zone tracking, access control)
- [ ] Portal objects di Roblox map
- [ ] Ore node objects di Crag Mine
- [ ] Ore + Gems item definitions
- [ ] MiningService.lua
- [ ] Ore Processing NPC + UI
- [ ] Mini-map UI
- [ ] World map UI (M key)

---

## BATCH 9 — Chip War + PvP System
> Dependensi: Batch 8 (Zone + Crag Mine ada).

### Tujuan
Chip War sebagai core PvP loop RF Classic. CP rank system.

### Tasks

**Chip War (RF Classic accurate)**
- Schedule: 3x per hari (bisa diconfig server)
- Lokasi: Crag Mine (zona khusus)
- Level minimum peserta: 30
- Mechanic:
  - Setiap ras punya Control Chip (object dengan HP bar besar)
  - Tujuan: hancurkan chip 2 ras musuh
  - Ras pertama yang menghancurkan chip lawan = menang sesi itu
  - Timer per sesi (15 menit default)
- Reward pemenang:
  - Mining rights Crag Mine sampai Chip War berikutnya
  - Buff: Victorious Vigor (+stat selama durasi)
- Penalty kalah:
  - Debuff: Car of Defeat (-stat)
  - Tidak bisa masuk area tengah Crag Mine

**CP Rank System (RF Classic accurate)**
- 8 rank total
- CP didapat dari: membunuh player ras lain, menang Chip War, quest reward
- PvP death → kehilangan CP (sudah di death penalty Batch 4)
- Higher rank kill higher rank → lebih banyak CP
- CP loss lebih besar jika dibunuh lower rank
- Rank ditampilkan di Character window (C key)

**PvP Zone**
- Zona tertentu = PvP zone (semua ras bisa saling serang)
- Zona safe = tidak bisa serang sesama atau musuh
- Chaos flag: player yang menyerang sesama ras di zona tertentu jadi chaos

### Deliverables
- [ ] ChipWarService.lua (scheduler, chip HP, reward/penalty)
- [ ] Chip object di Crag Mine map
- [ ] Chip War UI (timer, chip HP bar 3 ras)
- [ ] CP gain/loss mechanics di CombatService
- [ ] Rank calculation dari CP total
- [ ] Rank display di Character window
- [ ] PvP zone flag system

---

## BATCH 10 — Economy + Guild
> Dependensi: Batch 9 (CP ada, Chip War ada).

### Tujuan
Player economy RF Classic: trading, auction, guild system.

### Tasks

**Trading System**
- Player-to-player trade (sesama ras saja — RF Classic accurate)
- Trade window: 5 item slot (10 untuk Specialist — RF accurate)
- Konfirmasi dua pihak sebelum trade terjadi

**Auction House**
- Player bisa listing item + harga
- Player lain bisa beli
- Fee 0.1% dari harga (RF Classic accurate)
- Filter: by item type, level, faction
- Notifikasi saat item terjual

**Guild System**
- Buat guild: butuh level 30+ dan bayar gold
- Tipe guild: Battle Guild atau Friendly Guild
- Struktur: Guild Leader + Committee (top 10% rank)
- Guild roster, guild chat
- Circle Zone Scramble (guild vs guild mini-PvP):
  - Entry fee: 5000 gold per member
  - Skor dari gravity stone mechanic
  - Pemenang: 10000 gold

### Deliverables
- [ ] TradeService.lua + trade UI
- [ ] AuctionService.lua + auction UI
- [ ] GuildService.lua (create, join, roster, chat)
- [ ] Guild UI (G key)
- [ ] Circle Zone Scramble scheduler

---

## BATCH 11 — Quest Lanjutan + Archon
> Dependensi: Batch 10.

### Tujuan
Quest 2nd tier dan Archon election system.

### Tasks

**Quest Lanjutan**
- 2nd Quest (L51-55): quest chains dengan rewards lebih baik
- Repeatable Quest: bisa diulang daily, reward currency
- Time-Limit Quest: contoh "bunuh 10 monster dalam 10 menit"
- Quest NPC dialogue sederhana

**Archon Election System (RF Classic accurate)**
- 1 Archon per ras, dipilih via voting
- Syarat kandidat: Rank 30+ (dari CP rank system)
- Jadwal: voting minggu 20:00-22:00
- Bobot suara: dipengaruhi level + rank player
- Masa jabatan: 1 minggu
- Archon privileges:
  - Broadcast ke seluruh ras
  - Bisa chat dengan Archon ras lain
  - Armor khusus + aura

**Primary Council (4 posisi)**
- Consul (suara terbanyak ke-2)
- Strike Team Leader
- Defense Team Leader
- Support Team Leader

### Deliverables
- [ ] 2nd Quest definitions + service update
- [ ] Repeatable/Time-Limit quest types
- [ ] Archon election scheduler
- [ ] Archon voting UI
- [ ] Council role assignment
- [ ] Archon broadcast command
- [ ] Archon cosmetic (armor override + aura)

---

## BATCH 12 — Dungeon + Boss
> Dependensi: Batch 8 (zone system).

### Tujuan
Instanced content RF Classic: Battle Dungeon + boss encounters.

### Tasks

**Battle Dungeon System**
- Akses: Level 53+
- 3 tipe dungeon:
  1. Normal Battle Dungeon: briefing + objective
  2. Boss Fight Battle Dungeon: kill target dalam timer
  3. Dark Hole Battle Dungeon: puzzle + clues
- Instance: setiap grup punya copy dungeon sendiri
- Reward: D-grade weapon/armor, rare items

**DDD Brothers Boss**
- Dagon + Dagan: bisa dilawan satu ras
- Dagnu: butuh aliansi temporer — mechanic unik RF Classic
  - Semua ras bisa masuk ke area Dagnu bersama
  - PvP dimatikan sementara di area Dagnu
  - Setelah Dagnu mati: PvP kembali aktif

**PB (Point Boss) System**
- Boss dengan respawn timer
- Drop D-grade (Rare D) weapon/armor
- Contested: ras lain bisa rebut kill
- PB spawn di zona PvP

### Deliverables
- [ ] DungeonDefinitions.lua (3 tipe, 10 dungeon)
- [ ] DungeonService.lua (instancing, timer, reward)
- [ ] Boss definitions (Dagon, Dagan, Dagnu)
- [ ] Dagnu cease-fire mechanic
- [ ] PB spawn system + respawn timer
- [ ] Dungeon entry portal + UI

---

## BATCH 13 — Polish + Audio + VFX
> Dependensi: Semua batch sebelumnya.

### Tujuan
Membuat game terasa seperti RF Classic: audio, animasi, efek visual.

### Tasks

- Sound effects: combat hit, skill cast, force cast, UI click, level up, item pickup
- BGM per zona (RF-inspired tracks atau original)
- Skill VFX: Slash glow, Multi Shot projectile, Elemental force visuals
- Force VFX: Fire Arrow particle, Meteor Swarm, Terra Destruction
- MAU entry/exit animation
- Animus summon effect
- Launcher rocket trail + explosion
- Character level up effect (aura burst)
- Chip War ambiance (explosions, warning siren)
- Death screen + respawn countdown
- Loading screen per zona
- Character creation screen polish

### Deliverables
- [ ] SoundService.lua + asset setup
- [ ] VFX per skill/force (ParticleEmitter + Beam)
- [ ] BGM per zone
- [ ] Character creation polish
- [ ] Loading screen system
- [ ] Death + respawn UI

---

## CATATAN PENTING

### Jangan Diubah Sampai User Minta
- `GameConfig.MaxLevel = 50` — tetap 50 sampai semua Batch 3.1-13 selesai dan game sudah jalan
- Phase 2 dan 3 bukan batch baru — hanya update MaxLevel + tambah equipment tier + map baru untuk level yang lebih tinggi
- Nama race/class Aetherion (MECHA/CYBORG/MYSTIC, bukan Bellato/Accretia/Cora) — intentional

### Deviasi yang Diizinkan (Creative Addition)
- Blood Ammo CYBORG Specialist — tidak ada di wiki RF resmi tapi user menyetujui sebagai mechanic unik
- Nama class Aetherion (MechaGuardian, DarkInvoker, dll) — beda nama, sama role
- Aetherion skill names (Slash, Blitz, dll) — beda nama, sama mechanic

### Source of Truth
Semua implementasi harus mengacu ke memory files:
- `rf_classic_mechanics.md` — race/class facts
- `rf_classes_detailed.md` — class trees
- `rf_game_systems.md` — game systems
- `rf_controls_progression.md` — controls, milestones, maps
- `rf_items_database.md` — items, potions, talics
- `aetherion_rf_gaps.md` — checklist gap audit
