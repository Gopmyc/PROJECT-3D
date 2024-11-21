local inventory = require("core/modules/inventory/inventoryManager"):new()
local item = require("core/modules/inventory/item")

local Player = {}
Player.__index = Player

function Player.new(model)
    local self = setmetatable({}, Player)

    self.position = {x = -10, y = 15, z = 0}
    self:createCollider()
    self.speed = 60
    self.maxSpeed = 100
    self.acceleration = 20000
    self.airAcceleration = self.acceleration * 0.03
    self.velocity = {x = 0, y = 0, z = 0}
    self.jumpHeight = 5
    self.model = model or engine.render:loadObject("objects/player")
    self.transform = self.model:getTransform()
    self.inventory = inventory:createInventory(15)
    self.views = {
        firts = {vec = engine.render.vec3(0, 2, 0), up = 0},
        third = {vec = engine.render.vec3(0, 2, 0), up = 5},
    }
    self.currentView = self.views["third"]

	--------- TEST [to delet] ---------
	local item_t = item:new()
	self.inventory:addItem(item_t)

    return self
end

function Player:createCollider()
    self.collider = engine.physics.world:add(engine.physics:newCylinder(0.5, 2), "dynamic", self.position.x, self.position.y, self.position.z)
    self.collider:getBody():setLinearDamping(1)
    self.collider:getBody():setAngularDamping(1)
end

function Player:getCollider()
	return self.collider
end

function Player:move(dt)
    local d = love.keyboard.isDown
    local ax, az = 0, 0

    if d(engine.config.keys.movements.forward) then
        ax = ax + math.cos(engine.cam.ry - math.pi / 2)
        az = az + math.sin(engine.cam.ry - math.pi / 2)
    end
    if d(engine.config.keys.movements.backward) then
        ax = ax + math.cos(engine.cam.ry + math.pi - math.pi / 2)
        az = az + math.sin(engine.cam.ry + math.pi - math.pi / 2)
    end
    if d(engine.config.keys.movements.left) then
        ax = ax + math.cos(engine.cam.ry - math.pi / 2 - math.pi / 2)
        az = az + math.sin(engine.cam.ry - math.pi / 2 - math.pi / 2)
    end
    if d(engine.config.keys.movements.right) then
        ax = ax + math.cos(engine.cam.ry + math.pi / 2 - math.pi / 2)
        az = az + math.sin(engine.cam.ry + math.pi / 2 - math.pi / 2)
    end

    local a = math.sqrt(ax ^ 2 + az ^ 2)
    if a > 0 then
        ax = ax / a
        az = az / a
        local v = self.collider:getVelocity()
        local speed = math.sqrt(v.x ^ 2 + v.z ^ 2)
        local dot = speed > 0 and (ax * v.x / speed + az * v.z / speed) or 0

        local accel = (self.collider.touchedFloor and self.acceleration or self.airAcceleration) * math.max(0, 1 - speed / self.maxSpeed * math.abs(dot))
        self.collider:applyForce(ax * accel, 0, az * accel)
    end
end

function Player:jump()
    if self.collider.touchedFloor and love.keyboard.isDown(engine.config.keys.movements.jump) then
        self.collider.vy = self.jumpHeight
    end
end

function Player:update(dt)
    if not self.inventory.isOpen then
        self:move(dt)
        self:jump()
    end
    self.inventory:updateAnimation(dt)
end

function Player:setView(viewName)
	assert(self.views[viewName], "Error: View does not exist.")
    self.currentView = self.views[viewName]
end

function Player:getCurrentView()
	return self.currentView
end

function Player:getView(viewName)
	assert(self.views[viewName], "Error: View does not exist.")
    return self.views[viewName]
end

function Player:draw3D()
    local pos = self.collider:getPosition()
    self.model:setTransform(self.transform)
    self.model:translateWorld(pos)

    engine.render:draw(self.model)
end

function Player:draw2D()
    if self.inventory and (self.inventory.isOpen or self.inventory.isAnimating) then
        engine.render:blurCanvas(engine.render.canvas, 5, 1)
    end

    love.graphics.draw(engine.render.canvas)
    love.graphics.setShader()

    if self.inventory.isOpen or self.inventory.isAnimating then
        self.inventory:draw()
    end
end

function Player:keysPressed(key)
    if key == engine.config.keys.inventory.open then self.inventory:toggle() love.mouse.setRelativeMode(not self.inventory.isOpen) end
    if key == engine.config.keys.views.switch then self:setView((self:getCurrentView() == self:getView("third")) and "firts" or "third") end
end

return Player
