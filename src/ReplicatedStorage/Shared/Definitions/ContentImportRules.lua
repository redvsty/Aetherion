local GameConfig = require(script.Parent.Parent.GameConfig)

local ContentImportRules = {}

ContentImportRules.MaxLevel = GameConfig.MaxLevel

ContentImportRules.WeaponAllowedSeries = {
	Classic = true,
	RareD = true,
	Leon = true,
	Relic = true,
}

ContentImportRules.ArmorAllowedSeries = {
	Normal = true,
	RareC = true,
	Archon = true,
	Superior = true,
}

ContentImportRules.CloakAllowedSeries = {
	NormalBooster = true,
	RegularJetpack = true,
	SpecialityBooster = true,
}

ContentImportRules.AccessoryAllowedSeries = {
	NormalElemental = true,
	RareElementalPitBoss = true,
}

ContentImportRules.ShieldAllowedSeries = {
	Normal = true,
	RareC = true,
	Superior = true,
}

function ContentImportRules.AllowLevel(level, allowUnlimited)
	if allowUnlimited then
		return true
	end

	if level == nil then
		return true
	end

	return level <= GameConfig.MaxLevel
end

function ContentImportRules.AllowWeapon(record)
	return ContentImportRules.WeaponAllowedSeries[record.Series] == true
		and ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

function ContentImportRules.AllowArmor(record)
	return ContentImportRules.ArmorAllowedSeries[record.Series] == true
		and ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

function ContentImportRules.AllowCloak(record)
	return ContentImportRules.CloakAllowedSeries[record.Series] == true
		and ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

function ContentImportRules.AllowAccessory(record)
	return ContentImportRules.AccessoryAllowedSeries[record.Series] == true
		and ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

function ContentImportRules.AllowShield(record)
	return ContentImportRules.ShieldAllowedSeries[record.Series] == true
		and ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

function ContentImportRules.AllowMonster(_record)
	return true
end

function ContentImportRules.AllowQuest(record)
	return ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

function ContentImportRules.AllowUnit(record)
	return ContentImportRules.AllowLevel(record.RequiredLevel, false)
end

return ContentImportRules
