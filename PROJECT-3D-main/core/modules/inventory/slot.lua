local Slot = {}
Slot.__index = Slot

function Slot:new()
    local slot = setmetatable({}, Slot)
    slot.item = nil
    return slot
end

function Slot:addItem(item)
    self.item = item
end

function Slot:removeItem()
    self.item = nil
end

function Slot:isEmpty()
    return self.item == nil
end

return Slot
