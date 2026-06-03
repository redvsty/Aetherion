local InventoryService = {}

function InventoryService.FindItem(playerData, itemUid)
	for index, item in ipairs(playerData.Inventory) do
		if item.Uid == itemUid then
			return item, index
		end
	end

	return nil, nil
end

function InventoryService.AddItem(playerData, item)
	table.insert(playerData.Inventory, item)
	return true
end

function InventoryService.RemoveItem(playerData, itemUid)
	local _item, index = InventoryService.FindItem(playerData, itemUid)

	if not index then
		return false
	end

	table.remove(playerData.Inventory, index)
	return true
end

return InventoryService
