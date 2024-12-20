local game = {}
game.__index = game

function game:enter()
	local self = setmetatable({}, game)

	engine:debugPrint("Enter in to game state...")
	self.id = "game"
	self.data = {}

	engine:initPhysics()
	engine:loadRendering(function() end, function()
		engine.render:setLODDistance(50)
	end)

	engine.physics.world:add(engine.physics:newPhysicsObject(engine.loader:getResource("models", "map")))
	engine.players[0] = require("core/objects/player").new(engine.loader:getResource("models", "player"))
	engine.canQuit = true
	engine.physics.accumulator = 0
	love.mouse.setRelativeMode(true)

	return self
end

function game:update(dt)
	if not engine.isWindowFocus then return end

	engine.physics.accumulator = engine.physics.accumulator + math.min(dt, 0.016)
	while engine.physics.accumulator >= 0.016 do
		engine.physics.world:update(0.016)
		engine.physics.accumulator = engine.physics.accumulator - 0.016
	end

	engine.cam:update(dt)
	engine.render:update(dt)
	engine.players[0]:update(0.016)

	if engine.config.engineConfig.rendering.animateTime then
		engine.config.engineConfig.rendering.dayTime = engine.config.engineConfig.rendering.dayTime + (dt * 0.02)
		engine.sky:setDaytime(engine.render.sun, engine.config.engineConfig.rendering.dayTime)
	end
end

function game:draw3D()
	love.graphics.setCanvas(engine.render.canvas)
	love.graphics.clear()
	engine.render:prepare()
	engine.render:addLight(engine.render.sun)

	for _, light in pairs(engine.render.lights) do
		engine.render:addLight(light)
	end

	engine.render:draw(engine.loader:getResource("models", "map"))
	for index, player in pairs(engine.players) do
		if not player then break end
		local view = player:getCurrentView()
		engine.cam:lookAt(engine.render.camera, player:getCollider():getPosition() + view.vec, view.up)
		if not (index == 0 and view == player:getView("firts")) then
			player:draw3D()
		end
	end
	engine.render:present()
end

function game:draw2D()
	love.graphics.setCanvas()
	engine.players[0]:draw2D()

	love.graphics.setColor(1, 1, 1)
	engine.profiler:draw()
end

function game:draw()
	self:draw3D()
	self:draw2D()
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