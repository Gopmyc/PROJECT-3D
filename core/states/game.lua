local game = {}
game.__index = game

function game:enter()
	local self = setmetatable({}, game)

	self.id = "game"
	self.data = {}

    --- Initializing game engine rendering and associated values ---
    engine:loadRendering(function() end, function() end)
    
    engine.physics.world:add(engine.physics:newPhysicsObject(engine.assets.models.map))
    engine.players[0] = require("core/objects/player").new(engine.assets.models.player)

    --// TODO : Setup light sources

	return self
end

function game:update(dt)
    engine.cam:update(dt)
    engine.render:update()
    engine.physics.world:update(dt)
    engine.players[0]:update(dt)
end

function game:draw()
    love.graphics.setCanvas(engine.render.canvas)
    love.graphics.clear()
    engine.render:prepare()
    engine.render:addLight(engine.render.sun)
    for _, light in pairs(engine.render.lights) do
        engine.render:addLight(ligth) 
    end
    engine.render:draw(engine.assets.models.map)
    engine.cam:lookAt(engine.render.camera, engine.players[0].collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
    engine.players[0]:draw()
    engine.render:present()
    engine:drawShader(engine.players[0])
end

function game:mousepressed(x, y, button)
    engine.players[0].inventory:mousepressed(x, y, button)
end

function game:mousereleased(x, y, button)
    engine.players[0].inventory:mousereleased(x, y, button)
end

function game:mousemoved(x, y, dx, dy)
    if not engine.players[0].inventory.isOpen then 
        engine.cam:mousemoved(dx, dy)
    end
    engine.players[0].inventory:mousemoved(x, y)
end

function game:keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    engine.players[0]:keysPressed(key)
end

function game:resize(w, h)
    engine.render.canvas = love.graphics.newCanvas(w, h)
    engine.render:init()
end

function game:isFinished()
	return true
end

function game:getData()
    return self.data
end

return game