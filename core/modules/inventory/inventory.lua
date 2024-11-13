local Slot = require("core/modules/inventory/Slot")
local Inventory = {}
Inventory.__index = Inventory

function Inventory:new(size)
    local inventory = setmetatable({}, Inventory)
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

function Inventory:draw()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local baseSlotSize = 125
    local padding = 15 
    local referenceWidth = 1920
    local referenceHeight = 1080
    local slotSize = (screenWidth / referenceWidth) * baseSlotSize
    local inventoryWidth = 4 * slotSize + 3 * padding
    local inventoryHeight = 4 * slotSize + 3 * padding
    local x = (screenWidth - inventoryWidth) / 4
    local y = (screenHeight - inventoryHeight) / 2

    local rows, cols = 4, 4
    local mouseX, mouseY = love.mouse.getPosition()
    local hoveredSlot = nil

    -- Dessiner les slots et vérifier si on survole un item
    for i = 1, rows do
        for j = 1, cols do
            local slotX = x + (j - 1) * (slotSize + padding)
            local slotY = y + (i - 1) * (slotSize + padding)
            
            -- Dessin du fond du slot
            love.graphics.setColor(engine.config.color.slot)
            love.graphics.rectangle("fill", slotX, slotY, slotSize, slotSize, 20, 20)

            -- Vérification si le curseur est sur un slot pour dessiner les contours
            if mouseX >= slotX and mouseX <= slotX + slotSize and mouseY >= slotY and mouseY <= slotY + slotSize then
                love.graphics.setColor(1, 1, 1)
                love.graphics.setLineWidth(3)
                love.graphics.rectangle("line", slotX, slotY, slotSize, slotSize, 20, 20)

                -- Sauvegarder le slot survolé pour afficher la description
                hoveredSlot = self.slots[(i - 1) * cols + j]
            end

            -- Affichage de l'image de l'item, si présent
            local slot = self.slots[(i - 1) * cols + j]
            if slot and slot.item then
                -- Calcul du facteur de mise à l'échelle basé sur la taille de l'écran
                local scaleX = (screenWidth / referenceWidth) * 1.5
                local scaleY = (screenHeight / referenceHeight) * 1.5

                -- Calcul des nouvelles dimensions de l'image
                local itemImage = slot.item.img
                local newWidth = itemImage:getWidth() * scaleX
                local newHeight = itemImage:getHeight() * scaleY

                -- Dessiner l'image redimensionnée dans le slot, centrée
                love.graphics.setColor(1, 1, 1)  -- On s'assure que la couleur est blanche pour afficher l'image
                love.graphics.draw(itemImage, slotX + (slotSize - newWidth) / 2, slotY + (slotSize - newHeight) / 2, 0, scaleX, scaleY)
            end
        end
    end

    -- Afficher la description de l'item dans un rectangle en bas à droite si un item est survolé
    if hoveredSlot and hoveredSlot.item then
        local itemDesc = hoveredSlot.item.desc

        -- Position du rectangle
        local rectWidth = screenWidth * 0.3  -- Largeur de 30% de l'écran
        local rectHeight = 100
        local rectX = screenWidth - rectWidth - 20
        local rectY = screenHeight - rectHeight - 20

        -- Dessiner le rectangle gris en bas à droite
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)  -- Gris foncé avec un peu de transparence
        love.graphics.rectangle("fill", rectX, rectY, rectWidth, rectHeight, 10)

        -- Afficher la description de l'item à l'intérieur du rectangle
        love.graphics.setColor(1, 1, 1)  -- Couleur blanche pour le texte
        love.graphics.printf(itemDesc, rectX + 10, rectY + 10, rectWidth - 20, "left")
    end

    love.graphics.setColor(1, 1, 1)  -- Réinitialiser la couleur
end

return Inventory