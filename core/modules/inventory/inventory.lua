local Slot = require("core/modules/inventory/slot")
local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(size)
    local inventory = setmetatable({}, Inventory)

	inventory.isOpen = false
    inventory.isAnimating = false
    inventory.animationProgress = 0
    inventory.animationSpeed = 5
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

function Inventory:toggle()
    if not self.isAnimating then
        self.isAnimating = true
        self.isOpen = not self.isOpen
        self.animationProgress = self.isOpen and 0 or 1  -- Reset la progression selon l’état cible
    end
end

function Inventory:updateAnimation(dt)
    if self.isAnimating then
        local direction = self.isOpen and 1 or -1
        self.animationProgress = self.animationProgress + direction * self.animationSpeed * dt
        self.animationProgress = math.min(math.max(self.animationProgress, 0), 1)

        -- Arrêter l'animation si elle est terminée
        if self.animationProgress == 0 or self.animationProgress == 1 then
            self.isAnimating = false
        end
    end
end

function Inventory:draw()
    -- Ne dessine l'inventaire que si l'animation est en cours ou s'il est ouvert
    if self.animationProgress <= 0 then
        return
    end

    local screenWidth, screenHeight = love.graphics.getDimensions()
    local baseSlotSize = 125
    local padding = 15 
    local referenceWidth = 1920
    local slotSize = (screenWidth / referenceWidth) * baseSlotSize

    -- Ajustement pour la grille de 3x5
    local rows, cols = 3, 5
    local inventoryWidth = cols * slotSize + (cols - 1) * padding
    local inventoryHeight = rows * slotSize + (rows - 1) * padding
    local targetX = (screenWidth - inventoryWidth) / 2
    local targetY = (screenHeight - inventoryHeight) / 2

    -- Calcul de la position animée en fonction de l'état d'ouverture/fermeture
    local startY = screenHeight  -- Position de départ (en bas de l'écran)
    local animatedY = startY * (1 - self.animationProgress) + targetY * self.animationProgress

    -- Dessiner le fond de l'inventaire avec animation
    local backgroundPadding = 40
    local backgroundX = targetX - backgroundPadding
    local backgroundY = animatedY - backgroundPadding
    local backgroundWidth = inventoryWidth + 2 * backgroundPadding
    local backgroundHeight = inventoryHeight + 2 * backgroundPadding

    love.graphics.setColor(engine.config.color.background_inventory)
    love.graphics.rectangle("fill", backgroundX, backgroundY, backgroundWidth, backgroundHeight, 15, 15)

    local mouseX, mouseY = love.mouse.getPosition()
    local hoveredSlot = nil

    -- Dessiner chaque slot avec animation
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
                
                -- Sauvegarder le slot survolé pour afficher la description
                hoveredSlot = self.slots[(i - 1) * cols + j]
            end

            -- Afficher l'image de l'item, si présent
            local slot = self.slots[(i - 1) * cols + j]
            if slot and slot.item then
                local itemImage = slot.item.img
                local imageWidth, imageHeight = itemImage:getWidth(), itemImage:getHeight()

                -- Calcul du facteur d'échelle pour s'adapter au slot
                local scaleFactor = math.min(slotSize / imageWidth, slotSize / imageHeight)

                -- Calcul des nouvelles dimensions de l'image redimensionnée
                local scaledWidth = imageWidth * scaleFactor
                local scaledHeight = imageHeight * scaleFactor

                -- Centrer l'image dans le slot
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

    love.graphics.setColor(1, 1, 1)
end

return Inventory