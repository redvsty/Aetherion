local WeaponEnums = require(script.Parent.WeaponEnums)
local WeaponHelpers = require(script.Parent.WeaponHelpers)

local S = WeaponEnums.Series
local R = WeaponEnums.Rarity

local Rows = {
	-- ============================================================
	-- CLASSIC KNIFE / DAGGER, LEVEL 1-50
	-- ============================================================

	{ "Recruit Knife", S.Classic, R.Classic, 1, 6, 10, 0, 0, "None" },
	{ "Scout Knife", S.Classic, R.Classic, 5, 16, 24, 0, 0, "None" },
	{ "Combat Knife", S.Classic, R.Classic, 10, 36, 55, 0, 0, "None" },
	{ "Steel Fang", S.Classic, R.Classic, 15, 74, 112, 0, 0, "None" },
	{ "Carbon Fang", S.Classic, R.Classic, 20, 138, 209, 0, 0, "None" },
	{ "Plasma Cutter", S.Classic, R.Classic, 25, 242, 366, 0, 0, "None" },
	{ "Beam Cutter", S.Classic, R.Classic, 30, 386, 582, 0, 0, "None" },
	{ "Arc Fang", S.Classic, R.Classic, 35, 570, 862, 0, 0, "None" },
	{ "Intense Gun Blade", S.Classic, R.Classic, 40, 815, 1138, 0, 0, "None" },
	{ "Intense Sickle Knife", S.Classic, R.Classic, 45, 1180, 1554, 0, 0, "None" },
	{ "Intense Hora Knife", S.Classic, R.Classic, 50, 1559, 2036, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC SWORD, LEVEL 1-50
	-- ============================================================

	{ "Recruit Saber", S.Classic, R.Classic, 1, 8, 13, 0, 0, "None" },
	{ "Scout Saber", S.Classic, R.Classic, 5, 21, 32, 0, 0, "None" },
	{ "Combat Saber", S.Classic, R.Classic, 10, 49, 74, 0, 0, "None" },
	{ "Steel Saber", S.Classic, R.Classic, 15, 101, 153, 0, 0, "None" },
	{ "Carbon Saber", S.Classic, R.Classic, 20, 190, 285, 0, 0, "None" },
	{ "Plasma Saber", S.Classic, R.Classic, 25, 332, 498, 0, 0, "None" },
	{ "Beam Saber", S.Classic, R.Classic, 30, 529, 795, 0, 0, "None" },
	{ "Arc Saber", S.Classic, R.Classic, 35, 782, 1176, 0, 0, "None" },
	{ "Intense Estoc", S.Classic, R.Classic, 40, 1147, 1611, 0, 0, "None" },
	{ "Intense Spadona", S.Classic, R.Classic, 45, 1699, 2153, 0, 0, "None" },
	{ "Intense Hora Sword", S.Classic, R.Classic, 50, 2244, 2806, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC AXE, LEVEL 1-50
	-- ============================================================

	{ "Recruit Axe", S.Classic, R.Classic, 1, 9, 14, 0, 0, "None" },
	{ "Scout Axe", S.Classic, R.Classic, 5, 24, 36, 0, 0, "None" },
	{ "Combat Axe", S.Classic, R.Classic, 10, 55, 84, 0, 0, "None" },
	{ "Steel Axe", S.Classic, R.Classic, 15, 114, 172, 0, 0, "None" },
	{ "Carbon Axe", S.Classic, R.Classic, 20, 214, 322, 0, 0, "None" },
	{ "Plasma Axe", S.Classic, R.Classic, 25, 374, 563, 0, 0, "None" },
	{ "Beam Axe", S.Classic, R.Classic, 30, 597, 898, 0, 0, "None" },
	{ "Arc Axe", S.Classic, R.Classic, 35, 882, 1328, 0, 0, "None" },
	{ "Intense Bullova", S.Classic, R.Classic, 40, 1108, 1520, 0, 0, "None" },
	{ "Intense Tower Axe", S.Classic, R.Classic, 45, 1584, 2068, 0, 0, "None" },
	{ "Intense Hora Axe", S.Classic, R.Classic, 50, 2070, 2714, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC MACE / HAMMER, LEVEL 1-50
	-- ============================================================

	{ "Recruit Mace", S.Classic, R.Classic, 1, 9, 13, 0, 0, "None" },
	{ "Scout Mace", S.Classic, R.Classic, 5, 23, 34, 0, 0, "None" },
	{ "Combat Mace", S.Classic, R.Classic, 10, 53, 80, 0, 0, "None" },
	{ "Steel Mace", S.Classic, R.Classic, 15, 110, 166, 0, 0, "None" },
	{ "Carbon Mace", S.Classic, R.Classic, 20, 206, 310, 0, 0, "None" },
	{ "Plasma Hammer", S.Classic, R.Classic, 25, 361, 543, 0, 0, "None" },
	{ "Beam Hammer", S.Classic, R.Classic, 30, 576, 867, 0, 0, "None" },
	{ "Arc Hammer", S.Classic, R.Classic, 35, 852, 1283, 0, 0, "None" },
	{ "Intense Beam Great Hammer", S.Classic, R.Classic, 40, 1160, 1486, 0, 0, "None" },
	{ "Intense Beam Great Maul", S.Classic, R.Classic, 45, 1584, 2068, 0, 0, "None" },
	{ "Intense Hora Hammer", S.Classic, R.Classic, 50, 2070, 2714, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC SPEAR / LANCE, LEVEL 1-50
	-- ============================================================

	{ "Recruit Spear", S.Classic, R.Classic, 1, 9, 16, 0, 0, "None" },
	{ "Scout Spear", S.Classic, R.Classic, 5, 25, 45, 0, 0, "None" },
	{ "Combat Spear", S.Classic, R.Classic, 10, 58, 104, 0, 0, "None" },
	{ "Steel Spear", S.Classic, R.Classic, 15, 120, 215, 0, 0, "None" },
	{ "Carbon Spear", S.Classic, R.Classic, 20, 225, 403, 0, 0, "None" },
	{ "Plasma Spear", S.Classic, R.Classic, 25, 394, 705, 0, 0, "None" },
	{ "Beam Spear", S.Classic, R.Classic, 30, 628, 1126, 0, 0, "None" },
	{ "Arc Lance", S.Classic, R.Classic, 35, 929, 1664, 0, 0, "None" },
	{ "Intense Lance", S.Classic, R.Classic, 40, 912, 1753, 0, 0, "None" },
	{ "Intense Field Lance", S.Classic, R.Classic, 45, 1484, 2280, 0, 0, "None" },
	{ "Intense Hora Spear", S.Classic, R.Classic, 50, 1960, 2980, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC BOW, LEVEL 1-50
	-- ============================================================

	{ "Recruit Bow", S.Classic, R.Classic, 1, 7, 15, 0, 0, "None" },
	{ "Scout Bow", S.Classic, R.Classic, 5, 20, 42, 0, 0, "None" },
	{ "Combat Bow", S.Classic, R.Classic, 10, 45, 98, 0, 0, "None" },
	{ "Steel Bow", S.Classic, R.Classic, 15, 93, 202, 0, 0, "None" },
	{ "Carbon Bow", S.Classic, R.Classic, 20, 175, 378, 0, 0, "None" },
	{ "Plasma Bow", S.Classic, R.Classic, 25, 306, 661, 0, 0, "None" },
	{ "Beam Bow", S.Classic, R.Classic, 30, 488, 1055, 0, 0, "None" },
	{ "Arc Siege Bow", S.Classic, R.Classic, 35, 722, 1559, 0, 0, "None" },
	{ "Intense Beam Siege Bow", S.Classic, R.Classic, 40, 742, 1476, 0, 0, "None" },
	{ "Intense Beam Gun Bow", S.Classic, R.Classic, 45, 1025, 2044, 0, 0, "None" },
	{ "Intense Hora Bow", S.Classic, R.Classic, 50, 1373, 2673, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC RIFLE / GUN, LEVEL 1-50
	-- ============================================================

	{ "Recruit Rifle", S.Classic, R.Classic, 1, 7, 15, 0, 0, "None" },
	{ "Scout Rifle", S.Classic, R.Classic, 5, 19, 41, 0, 0, "None" },
	{ "Combat Rifle", S.Classic, R.Classic, 10, 43, 95, 0, 0, "None" },
	{ "Steel Rifle", S.Classic, R.Classic, 15, 90, 197, 0, 0, "None" },
	{ "Carbon Rifle", S.Classic, R.Classic, 20, 169, 369, 0, 0, "None" },
	{ "Plasma Rifle", S.Classic, R.Classic, 25, 295, 645, 0, 0, "None" },
	{ "Beam Rifle", S.Classic, R.Classic, 30, 470, 1029, 0, 0, "None" },
	{ "Arc Rifle", S.Classic, R.Classic, 35, 696, 1520, 0, 0, "None" },
	{ "Intense Bolt Rifle", S.Classic, R.Classic, 40, 713, 1477, 0, 0, "None" },
	{ "Intense Vulcan", S.Classic, R.Classic, 45, 1021, 2045, 0, 0, "None" },
	{ "Intense Hora Vulcan", S.Classic, R.Classic, 50, 1348, 2682, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC LAUNCHER, LEVEL 1-50
	-- ============================================================

	{ "Recruit Launcher", S.Classic, R.Classic, 1, 10, 28, 0, 0, "None" },
	{ "Scout Launcher", S.Classic, R.Classic, 5, 28, 78, 0, 0, "None" },
	{ "Combat Launcher", S.Classic, R.Classic, 10, 64, 181, 0, 0, "None" },
	{ "Steel Launcher", S.Classic, R.Classic, 15, 132, 374, 0, 0, "None" },
	{ "Carbon Launcher", S.Classic, R.Classic, 20, 248, 700, 0, 0, "None" },
	{ "Plasma Launcher", S.Classic, R.Classic, 25, 434, 1225, 0, 0, "None" },
	{ "Beam Launcher", S.Classic, R.Classic, 30, 692, 1954, 0, 0, "None" },
	{ "Arc Launcher", S.Classic, R.Classic, 35, 1023, 2889, 0, 0, "None" },
	{ "Intense Bazooka", S.Classic, R.Classic, 40, 720, 1570, 0, 0, "None" },
	{ "Intense Missile Launcher", S.Classic, R.Classic, 45, 1265, 2714, 0, 0, "None" },
	{ "Intense Hora Faust", S.Classic, R.Classic, 50, 1730, 3540, 0, 0, "None" },

	-- ============================================================
	-- CLASSIC STAFF / MAGIC, LEVEL 1-50
	-- ============================================================

	{ "Recruit Staff", S.Classic, R.Classic, 1, 2, 4, 8, 14, "None" },
	{ "Scout Staff", S.Classic, R.Classic, 5, 5, 8, 22, 38, "None" },
	{ "Combat Staff", S.Classic, R.Classic, 10, 11, 17, 55, 88, "None" },
	{ "Steel Staff", S.Classic, R.Classic, 15, 22, 33, 120, 185, "None" },
	{ "Carbon Staff", S.Classic, R.Classic, 20, 36, 52, 220, 335, "None" },
	{ "Plasma Staff", S.Classic, R.Classic, 25, 48, 68, 360, 540, "None" },
	{ "Beam Staff", S.Classic, R.Classic, 30, 56, 76, 520, 780, "None" },
	{ "Arc Staff", S.Classic, R.Classic, 35, 62, 84, 660, 990, "None" },
	{ "Intense Black Stick Bead", S.Classic, R.Classic, 40, 66, 88, 816, 1224, "None" },
	{ "Intense Sickle Staff", S.Classic, R.Classic, 45, 87, 117, 1008, 1512, "None" },
	{ "Intense Hora Staff", S.Classic, R.Classic, 50, 86, 118, 1648, 2472, "None" },

	-- ============================================================
	-- TYPE C WEAPONS, LEVEL 30-50
	-- Format:
	-- { Name, Series, Rarity, Level, AtkMin, AtkMax, ForceMin, ForceMax, SpecialText, TypeCAbilityId }
	-- ============================================================

	{ "Strong Intense Beam Cutter", S.TypeC, R.TypeC, 30, 386, 582, 0, 0, "Type C Strong: Attack Power Increased", "Strong" },
	{ "Fine Intense Beam Cutter", S.TypeC, R.TypeC, 30, 386, 582, 0, 0, "Type C Fine: Accuracy Rate Increased", "Fine" },
	{ "Sharp Intense Beam Cutter", S.TypeC, R.TypeC, 30, 386, 582, 0, 0, "Type C Sharp: Critical Attack Rate Increased", "Sharp" },
	{ "Vampire Intense Beam Cutter", S.TypeC, R.TypeC, 30, 386, 582, 0, 0, "Type C Vampire: Exchange Attack Damage to HP", "Vampire" },

	{ "Strong Arc Saber", S.TypeC, R.TypeC, 35, 782, 1176, 0, 0, "Type C Strong: Attack Power Increased", "Strong" },
	{ "Solid Arc Saber", S.TypeC, R.TypeC, 35, 782, 1176, 0, 0, "Type C Solid: Defense Power Increased", "Solid" },
	{ "Strength Arc Saber", S.TypeC, R.TypeC, 35, 782, 1176, 0, 0, "Type C Strength: Max HP Increased", "Strength" },
	{ "Anti-Sharp Arc Saber", S.TypeC, R.TypeC, 35, 782, 1176, 0, 0, "Type C Anti-Sharp: Critical Resistance Increased", "AntiSharp" },

	{ "Strong Intense Estoc", S.TypeC, R.TypeC, 40, 1147, 1611, 0, 0, "Type C Strong: Attack Power Increased", "Strong" },
	{ "Fine Intense Estoc", S.TypeC, R.TypeC, 40, 1147, 1611, 0, 0, "Type C Fine: Accuracy Rate Increased", "Fine" },
	{ "Sharp Intense Estoc", S.TypeC, R.TypeC, 40, 1147, 1611, 0, 0, "Type C Sharp: Critical Attack Rate Increased", "Sharp" },
	{ "Vampire Intense Estoc", S.TypeC, R.TypeC, 40, 1147, 1611, 0, 0, "Type C Vampire: Exchange Attack Damage to HP", "Vampire" },
	{ "Grand Intense Bolt Rifle", S.TypeC, R.TypeC, 40, 713, 1477, 0, 0, "Type C Grand: Shooting Range Increased", "Grand" },
	{ "Saving Intense Black Stick Bead", S.TypeC, R.TypeC, 40, 66, 88, 816, 1224, "Type C Saving: FP Cost Reduced", "Saving" },

	{ "Strong Intense Spadona", S.TypeC, R.TypeC, 45, 1699, 2153, 0, 0, "Type C Strong: Attack Power Increased", "Strong" },
	{ "Solid Intense Tower Axe", S.TypeC, R.TypeC, 45, 1584, 2068, 0, 0, "Type C Solid: Defense Power Increased", "Solid" },
	{ "Vampire Intense Field Lance", S.TypeC, R.TypeC, 45, 1484, 2280, 0, 0, "Type C Vampire: Exchange Attack Damage to HP", "Vampire" },
	{ "Sharp Intense Vulcan", S.TypeC, R.TypeC, 45, 1021, 2045, 0, 0, "Type C Sharp: Critical Attack Rate Increased", "Sharp" },
	{ "Grand Intense Missile Launcher", S.TypeC, R.TypeC, 45, 1265, 2714, 0, 0, "Type C Grand: Shooting Range Increased", "Grand" },
	{ "Advanced Strength Intense Sickle Staff", S.TypeC, R.TypeC, 45, 87, 117, 1008, 1512, "Type C Advanced Strength: Max HP and FP Increased", "AdvancedStrength" },

	{ "Strong Intense Hora Sword", S.TypeC, R.TypeC, 50, 2244, 2806, 0, 0, "Type C Strong: Attack Power Increased", "Strong" },
	{ "Fine Intense Hora Sword", S.TypeC, R.TypeC, 50, 2244, 2806, 0, 0, "Type C Fine: Accuracy Rate Increased", "Fine" },
	{ "Sharp Intense Hora Sword", S.TypeC, R.TypeC, 50, 2244, 2806, 0, 0, "Type C Sharp: Critical Attack Rate Increased", "Sharp" },
	{ "Vampire Intense Hora Sword", S.TypeC, R.TypeC, 50, 2244, 2806, 0, 0, "Type C Vampire: Exchange Attack Damage to HP", "Vampire" },
	{ "Solid Intense Hora Axe", S.TypeC, R.TypeC, 50, 2070, 2714, 0, 0, "Type C Solid: Defense Power Increased", "Solid" },
	{ "Strength Intense Hora Hammer", S.TypeC, R.TypeC, 50, 2070, 2714, 0, 0, "Type C Strength: Max HP Increased", "Strength" },
	{ "Grand Intense Hora Bow", S.TypeC, R.TypeC, 50, 1373, 2673, 0, 0, "Type C Grand: Shooting Range Increased", "Grand" },
	{ "Fine Intense Hora Vulcan", S.TypeC, R.TypeC, 50, 1348, 2682, 0, 0, "Type C Fine: Accuracy Rate Increased", "Fine" },
	{ "Grand Intense Hora Faust", S.TypeC, R.TypeC, 50, 1730, 3540, 0, 0, "Type C Grand: Shooting Range Increased", "Grand" },
	{ "Saving Intense Hora Staff", S.TypeC, R.TypeC, 50, 86, 118, 1648, 2472, "Type C Saving: FP Cost Reduced", "Saving" },
	{ "Endurance Intense Hora Staff", S.TypeC, R.TypeC, 50, 86, 118, 1648, 2472, "Type C Endurance: Elemental Resistance Increased", "Endurance" },
	{ "Level Down Intense Hora Spear", S.TypeC, R.TypeC, 50, 1960, 2980, 0, 0, "Type C Level Down: Required Level Reduced", "LevelDown" },

	-- ============================================================
	-- RARE D, LEVEL 50 ONLY
	-- ============================================================

	{ "Crimson Sword Rare D", S.RareD, R.RareD, 50, 2616, 2776, 1, 2200, "None" },
	{ "Crimson Axe Rare D", S.RareD, R.RareD, 50, 2157, 3236, 1, 2200, "None" },
	{ "Crimson Mace Rare D", S.RareD, R.RareD, 50, 2097, 2217, 1, 2200, "None" },
	{ "Crimson Spear Rare D", S.RareD, R.RareD, 50, 1618, 3775, 1, 2200, "None" },
	{ "Crimson Hammer Rare D", S.RareD, R.RareD, 50, 1831, 1943, 1000, 2200, "None" },
	{ "Crimson Knife Rare D", S.RareD, R.RareD, 50, 1062, 1202, 1700, 2200, "None" },
	{ "Crimson Bow Rare D", S.RareD, R.RareD, 50, 2022, 3371, 1, 2200, "None" },
	{ "Crimson Fire Arm Rare D", S.RareD, R.RareD, 50, 2427, 2966, 1, 2200, "None" },
	{ "Crimson Launcher Rare D", S.RareD, R.RareD, 50, 1321, 4521, 1, 2200, "None" },
	{ "Crimson Wand Rare D", S.RareD, R.RareD, 50, 72, 96, 2067, 2247, "None" },
	{ "Crimson Staff Rare D", S.RareD, R.RareD, 50, 94, 129, 2292, 3101, "None" },

	-- ============================================================
	-- LEON, LEVEL 40-50
	-- ============================================================

	{ "Leon's Gun Blade Low", S.Leon, R.LeonLow, 40, 652, 1365, 0, 0, "None" },
	{ "Leon's Gun Blade Med", S.Leon, R.LeonMedium, 40, 652, 1365, 0, 0, "None" },
	{ "Leon's Gun Blade High", S.Leon, R.LeonHigh, 40, 652, 1365, 0, 0, "None" },

	{ "Leon's Sickle Knife Low", S.Leon, R.LeonLow, 45, 944, 1864, 0, 0, "None" },
	{ "Leon's Sickle Knife Med", S.Leon, R.LeonMedium, 45, 944, 1864, 0, 0, "None" },
	{ "Leon's Sickle Knife High", S.Leon, R.LeonHigh, 45, 944, 1864, 0, 0, "None" },

	{ "Leon's Hora Knife Low", S.Leon, R.LeonLow, 50, 1247, 2443, 0, 0, "None" },
	{ "Leon's Hora Knife Med", S.Leon, R.LeonMedium, 50, 1247, 2443, 0, 0, "None" },
	{ "Leon's Hora Knife High", S.Leon, R.LeonHigh, 50, 1247, 2443, 0, 0, "None" },

	{ "Leon's Hora Bow Low", S.Leon, R.LeonLow, 50, 1098, 3207, 0, 0, "None" },
	{ "Leon's Hora Bow Med", S.Leon, R.LeonMedium, 50, 1098, 3207, 0, 0, "None" },
	{ "Leon's Hora Bow High", S.Leon, R.LeonHigh, 50, 1098, 3207, 0, 0, "None" },

	{ "Leon's Hora Vulcan Low", S.Leon, R.LeonLow, 50, 1078, 3218, 0, 0, "None" },
	{ "Leon's Hora Vulcan Med", S.Leon, R.LeonMedium, 50, 1078, 3218, 0, 0, "None" },
	{ "Leon's Hora Vulcan High", S.Leon, R.LeonHigh, 50, 1078, 3218, 0, 0, "None" },

	{ "Leon's Hora Faust Low", S.Leon, R.LeonLow, 50, 1384, 4248, 0, 0, "None" },
	{ "Leon's Hora Faust Med", S.Leon, R.LeonMedium, 50, 1384, 4248, 0, 0, "None" },
	{ "Leon's Hora Faust High", S.Leon, R.LeonHigh, 50, 1384, 4248, 0, 0, "None" },

	{ "Leon's Hora Staff Low", S.Leon, R.LeonLow, 50, 86, 118, 1318, 2966, "None" },
	{ "Leon's Hora Staff Med", S.Leon, R.LeonMedium, 50, 86, 118, 1318, 2966, "None" },
	{ "Leon's Hora Staff High", S.Leon, R.LeonHigh, 50, 86, 118, 1318, 2966, "None" },

	-- ============================================================
	-- RELIC, LEVEL 45 ONLY FOR MAX LEVEL 50 SERVER
	-- ============================================================

	{ "Izen Ritter's Back Blade", S.Relic, R.Relic, 45, 2366, 2972, 0, 0, "Moving speed 1.00 increase" },
	{ "Armor Killer", S.Relic, R.Relic, 45, 2847, 3981, 0, 0, "Critical probability 20.00 increase" },
	{ "The End", S.Relic, R.Relic, 45, 2405, 4271, 0, 0, "HP 20% increase" },
	{ "Kimera", S.Relic, R.Relic, 45, 2010, 3950, 0, 0, "All resistance 30.00% increase" },
	{ "Valkyrie", S.Relic, R.Relic, 45, 2040, 3937, 0, 0, "All resistance 30.00% increase" },
	{ "Double Hitter", S.Relic, R.Relic, 45, 2015, 3948, 0, 0, "Ignore opponent blocking 100.00% increase" },
	{ "Beast", S.Relic, R.Relic, 45, 2027, 3943, 0, 0, "Range 10.00% increase" },
	{ "MG-L-073 Lightning", S.Relic, R.Relic, 45, 1959, 3973, 0, 0, "Range 10.00% increase" },
	{ "M-72 Dark Bullet", S.Relic, R.Relic, 45, 2002, 3954, 0, 0, "Range 10.00% increase" },
	{ "Cerberus", S.Relic, R.Relic, 45, 2480, 5236, 0, 0, "Attack delay of launcher 0.10 increase" },
	{ "Inferno", S.Relic, R.Relic, 45, 2434, 5255, 0, 0, "Attack delay of launcher 0.10 increase" },
	{ "Titan", S.Relic, R.Relic, 45, 2570, 5201, 0, 0, "Attack delay of launcher 0.10 increase" },
	{ "Blunt of Oblivion", S.Relic, R.Relic, 45, 2405, 3163, 0, 0, "Critical probability 10 increase" },
	{ "Vengeance", S.Relic, R.Relic, 45, 2665, 4403, 0, 0, "Exchange 10% attack damage to HP" },
	{ "Accelleon", S.Relic, R.Relic, 45, 104, 152, 2288, 3432, "Defense ability 20.00% increase" },
	{ "Man Eater", S.Relic, R.Relic, 45, 2986, 4188, 0, 0, "Accuracy rate 20.00% increase" },
}

local Weapons = {}

for _, row in ipairs(Rows) do
	local weapon = WeaponHelpers.CreateWeapon(row)

	if weapon.RequiredLevel <= 50 then
		Weapons[weapon.Id] = weapon
	end
end

return Weapons