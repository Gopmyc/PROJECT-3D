local engineRender = require("engine/init")
local engineSky = require("engine/extensions/sky")
local engineCam = require("engine/extensions/utils/cameraController")
local engineUtils = require("engine/extensions/utils") -- to modify to add more functions (print table)
local enginePhysics = require("engine/extensions/physics/init")
local engineRaytrace = require("engine/extensions/raytrace")
local configCore = require("core/config")
local LoaderCore = require("core/loader")
local PlayerCore = require("core/player")

love.mouse.setRelativeMode(true)

local objects = {}
local finishedLoading = false

function love.load()
    --- Initializing the game engine ---
    engine = {}
    engine.render = engineRender
    engine.sky = engineSky
    engine.cam = engineCam
    engine.utils = engineUtils
    engine.physics = enginePhysics
    engine.raytrace = engineRaytrace
    engine.loader = LoaderCore:new(configCore)
	engine.config = configCore

    engine.physics.world = engine.physics:newWorld()
    engine.render.sun = engine.render:newLight("sun")
    engine.render.sun:addNewShadow()
    engine.render:setSky(engine.sky.render)
    engine.sky:setDaytime(engine.render.sun, 0.2)

    engine.render:init()

    --- Loading of game assets ---
	objects = {map = engine.loader:getResource("models", "map"), player = engine.loader:getResource("models", "player")}

    player = PlayerCore.new(objects.player)
    engine.physics.world:add(engine.physics:newPhysicsObject(objects.map))
end

--- Keep updating the loader until all resources are loaded ---
function love.update(dt)
    engine.cam:update(dt)
    engine.render:update()
    engine.physics.world:update(dt)
	player:update(dt)
end

function love.draw()

    engine.cam:lookAt(engine.render.camera, player.collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
    engine.render:prepare()
    engine.render:addLight(engine.render.sun)
    engine.render:draw(models.map)

    player:draw()
    engine.render:present()

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.mousemoved(_, _, x, y)
    engine.cam:mousemoved(x, y)
end

function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end

function love.resize()
    engine.render:init()
end