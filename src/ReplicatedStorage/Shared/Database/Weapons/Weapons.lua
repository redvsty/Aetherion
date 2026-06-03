local WeaponFactory = require(script.Parent.WeaponFactory)
local GeneratedRows = require(script.Parent["Weapons.generated"])

local Weapons = {}

local function addWeaponFromRow(row)
	if row.RequiredLevel > 50 then
		return
	end

	local weapon = WeaponFactory.CreateFromGeneratedRow(row)
	Weapons[weapon.Id] = weapon
end

for _, row in ipairs(GeneratedRows) do
	addWeaponFromRow(row)
end

return Weapons
