local Item = {}
Item.__index = Item

function Item:new(name, quantity, img, desc)
    local item = setmetatable({}, Item)
    item.name = name or "Default."
    item.img = img or love.graphics.newImage("assets/UI/items/default.png")
    item.desc = desc or "Not set."
    item.quantity = quantity or 1
    return item
end

return Item
