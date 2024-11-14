local Slot = require("core/modules/inventory/slot")
local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(size)
    local inventory = setmetatable({}, Inventory)

	inventory.isOpen = false
    inventory.isAnimating = false
    inventory.animationProgress = 0
    inventory.animationSpeed = 5
    inventory.draggedItem = nil
    inventory.draggedSlotIndex = nil
    inventory.isDragging = false
    inventory.dragOffsetX = 0
    inventory.dragOffsetY = 0
    inventory.slots = {}
    for i = 1, size do
        inventory.slots[i] = Slot:new()
    end

    return inventory
end

function Inventory:addItem(item)
    for _, slot in ipairs(self.slots) do
        if slot:isEmpty() then
            slot:addItem(item)
            return true
        end
    end
    return false
end

function Inventory:removeItem(name)
    for _, slot in ipairs(self.slots) do
        if slot.item and slot.item.name == name then
            slot:removeItem()
            return true
        end
    end
    return false
end

function Inventory:getItem(name)
    for _, slot in ipairs(self.slots) do
        if slot.item and slot.item.name == name then
            return slot.item
        end
    end
    return nil
end

function Inventory:getSlotSize()
    local screenWidth = love.graphics.getDimensions()
    local baseSlotSize = 125
    local referenceWidth = 1920
    return (screenWidth / referenceWidth) * baseSlotSize
end

function Inventory:getSlotPosition(index)
    local rows, cols = 3, 5
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local baseSlotSize = 125
    local padding = 15
    local referenceWidth = 1920
    local slotSize = (screenWidth / referenceWidth) * baseSlotSize

    local inventoryWidth = cols * slotSize + (cols - 1) * padding
    local inventoryHeight = rows * slotSize + (rows - 1) * padding
    local startX = (screenWidth - inventoryWidth) / 2
    local startY = (screenHeight - inventoryHeight) / 2

    local row = math.floor((index - 1) / cols)
    local col = (index - 1) % cols
    local slotX = startX + col * (slotSize + padding)
    local slotY = startY + row * (slotSize + padding)
    
    return slotX, slotY
end

function Inventory:toggle()
    if not self.isAnimating then
        self.isAnimating = true
        self.isOpen = not self.isOpen
        self.animationProgress = self.isOpen and 0 or 1
    end
end

function Inventory:updateAnimation(dt)
    if self.isAnimating then
        local direction = self.isOpen and 1 or -1
        self.animationProgress = self.animationProgress + direction * self.animationSpeed * dt
        self.animationProgress = math.min(math.max(self.animationProgress, 0), 1)

        if self.animationProgress == 0 or self.animationProgress == 1 then
            self.isAnimating = false
        end
    end
end

function Inventory:cancelDrag()
    if self.draggedItem and self.draggedSlotIndex then
        self.slots[self.draggedSlotIndex].item = self.draggedItem
    end

    self.draggedItem = nil
    self.draggedSlotIndex = nil
    self.isDragging = false
end

function Inventory:mousepressed(x, y, button)
    if button == 1 then
        for i, slot in ipairs(self.slots) do
            local slotX, slotY = self:getSlotPosition(i)
            local slotSize = self:getSlotSize()

            if x >= slotX and x <= slotX + slotSize and y >= slotY and y <= slotY + slotSize then
                if slot.item then
                    self.isDragging = true
                    self.draggedItem = slot.item
                    self.draggedSlotIndex = i
                    self.dragOffsetX = x
                    self.dragOffsetY = y
                    slot.item = nil
                end
                break
            end
        end
    end
end

function Inventory:mousereleased(x, y, button)
    if button == 1 and self.isDragging then
        self.isDragging = false
        local droppedInSlot = false

        for i, slot in ipairs(self.slots) do
            local slotX, slotY = self:getSlotPosition(i)
            local slotSize = self:getSlotSize()

            if x >= slotX and x <= slotX + slotSize and y >= slotY and y <= slotY + slotSize then
                if i ~= self.draggedSlotIndex then
                    self.slots[self.draggedSlotIndex].item, slot.item = slot.item, self.draggedItem
                else
                    self.slots[self.draggedSlotIndex].item = self.draggedItem
                end
                droppedInSlot = true
                break
            end
        end

        if not droppedInSlot then
            self:cancelDrag()
        end
    end
end

function Inventory:mousemoved(x, y)
    if self.isDragging and self.draggedItem then
        self.dragOffsetX = x
        self.dragOffsetY = y
    end
end

function Inventory:draw()
    if self.animationProgress <= 0 then return end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local baseSlotSize = 125
    local padding = 15 
    local referenceWidth = 1920
    local slotSize = (screenWidth / referenceWidth) * baseSlotSize

    local rows, cols = 3, 5
    local inventoryWidth = cols * slotSize + (cols - 1) * padding
    local inventoryHeight = rows * slotSize + (rows - 1) * padding
    local targetX = (screenWidth - inventoryWidth) / 2
    local targetY = (screenHeight - inventoryHeight) / 2

    local startY = screenHeight
    local animatedY = startY * (1 - self.animationProgress) + targetY * self.animationProgress

    local backgroundPadding = 40
    local backgroundX = targetX - backgroundPadding
    local backgroundY = animatedY - backgroundPadding
    local backgroundWidth = inventoryWidth + 2 * backgroundPadding
    local backgroundHeight = inventoryHeight + 2 * backgroundPadding

    love.graphics.setColor(engine.config.color.background_inventory)
    love.graphics.rectangle("fill", backgroundX, backgroundY, backgroundWidth, backgroundHeight, 15, 15)

    local mouseX, mouseY = love.mouse.getPosition()
    local hoveredSlot = nil

    for i = 1, rows do
        for j = 1, cols do
            local slotX = targetX + (j - 1) * (slotSize + padding)
            local slotY = animatedY + (i - 1) * (slotSize + padding)
            
            love.graphics.setColor(engine.config.color.slot_inventory)
            love.graphics.rectangle("fill", slotX, slotY, slotSize, slotSize, 20, 20)

            if mouseX >= slotX and mouseX <= slotX + slotSize and mouseY >= slotY and mouseY <= slotY + slotSize then
                love.graphics.setColor(1, 1, 1)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", slotX, slotY, slotSize, slotSize, 20, 20)
                
                hoveredSlot = self.slots[(i - 1) * cols + j]
            end

            local slot = self.slots[(i - 1) * cols + j]
            if slot and slot.item then
                local itemImage = slot.item.img
                local imageWidth, imageHeight = itemImage:getWidth(), itemImage:getHeight()

                local scaleFactor = math.min(slotSize / imageWidth, slotSize / imageHeight)

                local scaledWidth = imageWidth * scaleFactor
                local scaledHeight = imageHeight * scaleFactor

                local imageX = slotX + (slotSize - scaledWidth) / 2
                local imageY = slotY + (slotSize - scaledHeight) / 2

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(itemImage, imageX, imageY, 0, scaleFactor, scaleFactor)
            end
        end
    end

    if hoveredSlot and hoveredSlot.item then
        local itemDesc = hoveredSlot.item.desc
        local rectWidth = screenWidth * 0.3
        local rectHeight = 100
        local rectX = screenWidth - rectWidth - 20
        local rectY = screenHeight - rectHeight - 20

        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight, 10)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Descriptions : " .. itemDesc, rectX + 10, rectY + 10, rectWidth - 20, "left")
    end

    if self.isDragging and self.draggedItem then
        love.graphics.setColor(1, 1, 1)
        local draggedImage = self.draggedItem.img
        local imageWidth, imageHeight = draggedImage:getWidth(), draggedImage:getHeight()
    
        local slotSize = self:getSlotSize()
        local scaleFactor = math.min(slotSize / imageWidth, slotSize / imageHeight)
    
        local imageX = self.dragOffsetX - (imageWidth * scaleFactor) / 2
        local imageY = self.dragOffsetY - (imageHeight * scaleFactor) / 2
    
        love.graphics.draw(draggedImage, imageX, imageY, 0, scaleFactor, scaleFactor)
    end    

    love.graphics.setColor(1, 1, 1)
end

return Inventory