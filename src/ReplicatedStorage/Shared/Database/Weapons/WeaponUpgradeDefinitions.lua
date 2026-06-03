local WeaponUpgradeDefinitions = {}

WeaponUpgradeDefinitions.Slot = {
	Min = 0,
	Max = 7,
}

WeaponUpgradeDefinitions.Talic = {
	Ignorant = {
		Id = "Ignorant",
		DisplayName = "Ignorant Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "WeaponAttackUpgrade",
		},
	},

	Keen = {
		Id = "Keen",
		DisplayName = "Keen Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "WeaponAttackUpgrade",
		},
	},

	Destruction = {
		Id = "Destruction",
		DisplayName = "Destruction Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "AttackPercent",
			ValuePerTalic = 0.03,
		},
	},

	Chaos = {
		Id = "Chaos",
		DisplayName = "Chaos Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "CriticalChanceFlat",
			ValuePerTalic = 0.015,
		},
	},

	Glory = {
		Id = "Glory",
		DisplayName = "Glory Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "AccuracyFlat",
			ValuePerTalic = 2,
		},
	},

	Guard = {
		Id = "Guard",
		DisplayName = "Guard Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "DefensePercent",
			ValuePerTalic = 0.015,
		},
	},

	Mercy = {
		Id = "Mercy",
		DisplayName = "Mercy Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "DodgeFlat",
			ValuePerTalic = 2,
		},
	},

	SacredFire = {
		Id = "SacredFire",
		DisplayName = "Sacred Fire Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "FireElement",
			ValuePerTalic = 1,
		},
	},

	Belief = {
		Id = "Belief",
		DisplayName = "Belief Talic",
		AppliesTo = "Weapon",
		Effect = {
			Type = "AquaElement",
			ValuePerTalic = 1,
		},
	},
}

WeaponUpgradeDefinitions.UpgradeChance = {
	[1] = { Success = 1.00, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[2] = { Success = 1.00, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[3] = { Success = 0.70, Destroy = 0.00, Downgrade = 0.00, Lock = 0.00 },
	[4] = { Success = 0.50, Destroy = 0.00, Downgrade = 0.10, Lock = 0.00 },
	[5] = { Success = 0.30, Destroy = 0.00, Downgrade = 0.60, Lock = 0.70 },
	[6] = { Success = 0.15, Destroy = 0.35, Downgrade = 0.40, Lock = 0.50 },
	[7] = { Success = 0.07, Destroy = 0.55, Downgrade = 0.30, Lock = 0.60 },
}

return WeaponUpgradeDefinitions