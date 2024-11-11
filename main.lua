local engineRender = require("engine/init")
local engineSky = require("engine/extensions/sky")
local engineCam = require("engine/extensions/utils/cameraController")
local engineUtils = require("engine/extensions/utils")
local enginePhysics = require("engine/extensions/physics/init")
local engineRaytrace = require("engine/extensions/raytrace")
local PlayerModule = require("player")

love.mouse.setRelativeMode(true)

local objects = {
	map = engineRender:loadObject("objects/scene"),
	player = engineRender:loadObject("objects/player")
}

function love.load()
	engine = engine or {}
	engine.render = engineRender
	engine.sky = engineSky
	engine.cam = engineCam
	engine.utils = engineUtils
	engine.physics = enginePhysics
	engine.raytrace = engineRaytrace

	engine.render.sun = engine.render:newLight("sun")
	engine.render.sun:addNewShadow()
	engine.render:setSky(engine.sky.render)
	engine.sky:setDaytime(engine.render.sun, 0.2)

	engine.render:init()

	engine.physics.world = engine.physics:newWorld()
	engine.physics.world:add(engine.physics:newPhysicsObject(objects.map))

	player = PlayerModule.new(objects.player)
end

function love.draw()
	engine.cam:lookAt(engine.render.camera, player.collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
	engine.render:prepare()
	engine.render:addLight(engine.render.sun)
	engine.render:draw(objects.map)

	player:draw()
	engine.render:present()

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.mousemoved(_, _, x, y)
	engine.cam:mousemoved(x, y)
end

function love.update(dt)
    engine.cam:update(dt)
    engine.render:update()
    engine.physics.world:update(dt)

    player:update(dt)
end


function love.keypressed(key)
	if key == "f11" then
		love.window.setFullscreen(not love.window.getFullscreen())
	end
end

function love.resize()
	engine.render:init()
end