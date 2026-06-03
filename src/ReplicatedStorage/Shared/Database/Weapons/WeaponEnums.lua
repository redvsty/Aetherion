local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

local WeaponEnums = {}

WeaponEnums.Series = {
	Classic = "Classic",
	TypeA = "TypeA",
	TypeB = "TypeB",
	TypeC = "TypeC",
	RareD = "RareD",
	Leon = "Leon",
	Relic = "Relic",
}

WeaponEnums.Rarity = {
	Normal = "Normal",
	TypeA = "TypeA",
	TypeB = "TypeB",
	TypeC = "TypeC",
	RareD = "RareD",
	LeonLow = "LeonLow",
	LeonMedium = "LeonMedium",
	LeonHigh = "LeonHigh",
	Relic = "Relic",
}

WeaponEnums.Grade = {
	N = "N",
	A = "A",
	B = "B",
	C = "C",
	D = "D",
	Leon = "Leon",
	Relic = "Relic",
}

WeaponEnums.WeaponType = {
	Knife = "Knife",
	Sword = "Sword",
	TwoHandSword = "TwoHandSword",
	Axe = "Axe",
	Mace = "Mace",
	Spear = "Spear",
	Bow = "Bow",
	Gun = "Gun",
	Rifle = "Rifle",
	Gatling = "Gatling",
	Launcher = "Launcher",
	GrenadeLauncher = "GrenadeLauncher",
	Staff = "Staff",
	Wand = "Wand",
	Throwing = "Throwing",
	Unknown = "Unknown",
}

WeaponEnums.AmmoType = {
	None = "None",
	Arrow = "Arrow",
	Bullet = "Bullet",
	LauncherShell = "LauncherShell",
	GrenadeShell = "GrenadeShell",
	ForceReaver = "ForceReaver",
	ThrowingKnife = "ThrowingKnife",
}

WeaponEnums.FactionId = {
	All = "ALL",
	Mecha = GameConfig.Factions.MECHA,
	Cyborg = GameConfig.Factions.CYBORG,
	Mystic = GameConfig.Factions.MYSTIC,
}

WeaponEnums.AbilityId = {
	Wind = "Wind",
	Strong = "Strong",
	Fine = "Fine",
	Smart = "Smart",
	Solid = "Solid",
	Strength = "Strength",
	AdvancedStrength = "AdvancedStrength",
	Vampire = "Vampire",
	Guardian = "Guardian",
	Sharp = "Sharp",
	Protection = "Protection",
	Grand = "Grand",
	AntiSharp = "AntiSharp",
	Saving = "Saving",
	Endurance = "Endurance",
	LevelDown = "LevelDown",
}

return WeaponEnums
