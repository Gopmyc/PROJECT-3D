local Inventory = require("core/modules/inventory/inventory")
local InventoryManager = {}
InventoryManager.__index = InventoryManager

function InventoryManager:new()
    local manager = setmetatable({}, InventoryManager)
    manager.inventories = {}
    return manager
end

function InventoryManager:createInventory(size)
    local inventory = Inventory:new(size)
    table.insert(self.inventories, inventory)
    return inventory
end

function InventoryManager:save()
    -- // TODO : Implement save logic
end

function InventoryManager:load()
    -- // TODO : Implement loading logic
end

return InventoryManager
