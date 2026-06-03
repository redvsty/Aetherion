local GameConfig = require(game.ReplicatedStorage.Shared.GameConfig)

local WeaponEnums = {}

WeaponEnums.Series = {
	Classic = "Classic",
	RareD = "RareD",
	Leon = "Leon",
	Relic = "Relic",
	TypeC = "TypeC",
}

WeaponEnums.Rarity = {
	Classic = "Classic",
	RareD = "RareD",
	LeonLow = "LeonLow",
	LeonMedium = "LeonMedium",
	LeonHigh = "LeonHigh",
	Relic = "Relic",
	TypeC = "TypeC",
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

return WeaponEnums