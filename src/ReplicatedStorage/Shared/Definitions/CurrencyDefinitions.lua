local GameConfig = require(script.Parent.Parent.GameConfig)

local CurrencyDefinitions = {
	Gold = {
		Id = "Gold",
		DisplayName = "Aether Gold",
		IsGlobal = true,
		CanTradeCrossFaction = true,
	},

	[GameConfig.Factions.MECHA] = {
		Id = "MechaCredits",
		DisplayName = "Mechanis",
		FactionId = GameConfig.Factions.MECHA,
		IsGlobal = false,
		CanTradeCrossFaction = false,
	},

	[GameConfig.Factions.CYBORG] = {
		Id = "CyborgCredits",
		DisplayName = "Dominion Credit",
		FactionId = GameConfig.Factions.CYBORG,
		IsGlobal = false,
		CanTradeCrossFaction = false,
	},

	[GameConfig.Factions.MYSTIC] = {
		Id = "MysticCredits",
		DisplayName = "Elyndra Sigil",
		FactionId = GameConfig.Factions.MYSTIC,
		IsGlobal = false,
		CanTradeCrossFaction = false,
	},
}

function CurrencyDefinitions.GetFactionCurrencyId(factionId)
	local def = CurrencyDefinitions[factionId]
	return def and def.Id or nil
end

function CurrencyDefinitions.IsFactionCurrency(currencyId)
	for factionId, def in pairs(CurrencyDefinitions) do
		if type(def) == "table" and factionId ~= "Gold" and def.Id == currencyId then
			return true, def.FactionId
		end
	end

	return false, nil
end

return CurrencyDefinitions
