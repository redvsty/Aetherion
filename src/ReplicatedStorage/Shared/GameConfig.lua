local GameConfig = {}

GameConfig.GameName = "Aetherion"
GameConfig.MaxLevel = 50

GameConfig.AdvancementLevels = {
	First = 30,
	Second = 40,
}

GameConfig.Factions = {
	MECHA = "MECHA",
	CYBORG = "CYBORG",
	MYSTIC = "MYSTIC",
}

GameConfig.StartingClasses = {
	Warrior = "Warrior",
	Ranger = "Ranger",
	Spiritualist = "Spiritualist",
	Specialist = "Specialist",
}

GameConfig.PTTypes = {
	Melee = "Melee",
	Ranged = "Ranged",
	Launcher = "Launcher",
	Shield = "Shield",
	Defense = "Defense",
	Magic = "Magic",
	Unit = "Unit",
}

GameConfig.ItemCategories = {
	Weapon = "Weapon",
	Armor = "Armor",
	Cloak = "Cloak",
	Booster = "Booster",
	Accessory = "Accessory",
	Shield = "Shield",
	Ammo = "Ammo",
	Unit = "Unit",
	Box = "Box",
	Material = "Material",
}

GameConfig.EquipmentSlots = {
	Weapon = "Weapon",
	Armor = "Armor",
	Shield = "Shield",
	Cloak = "Cloak",
	Accessory1 = "Accessory1",
	Accessory2 = "Accessory2",
	Accessory3 = "Accessory3",
	Accessory4 = "Accessory4",
}

GameConfig.Combat = {
	BaseDamageVarianceMin = 0.90,
	BaseDamageVarianceMax = 1.10,
	CritMultiplier = 1.5,
	DefenseScale = 100,
	MaxAttackDistance = 18,
}

return GameConfig
