local engineRender = require("engine/init")
local engineSky = require("engine/extensions/sky")
local engineCam = require("engine/extensions/utils/cameraController")
local engineUtils = require("engine/extensions/utils") -- to modify to add more functions (print table)
local enginePhysics = require("engine/extensions/physics/init")
local engineRaytrace = require("engine/extensions/raytrace")
local LoaderCore = require("core/loader").new()
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
    engine.loader = LoaderCore
    engine.config = LoaderCore.config

    for k, v in pairs(engine.loader) do
        print(k)
        print(v)
    end
    engine.physics.world = engine.physics:newWorld()
    engine.render.sun = engine.render:newLight("sun")
    engine.render.sun:addNewShadow()
    engine.render:setSky(engine.sky.render)
    engine.sky:setDaytime(engine.render.sun, 0.2)

    engine.render:init()

    --- Parallel loading of game assets ---
    engine.loader.newModel3D(objects, "map", engine.config.models.map)
    engine.loader.newModel3D(objects, "player", engine.config.models.player)

    --- Start loading and monitor progress ---
    engine.loader:start(function() 
        player = PlayerCore.new(objects.player)
        engine.physics.world:add(engine.physics:newPhysicsObject(objects.map))
		finishedLoading = true
	end)
end

--- Keep updating the loader until all resources are loaded ---
function love.update(dt)
    if not finishedLoading then
        engine.loader.update()
    end

    if finishedLoading then
        engine.cam:update(dt)
        engine.render:update()
        engine.physics.world:update(dt)

        if player then
            player:update(dt)
        end
    end
end

function love.draw()
    if not finishedLoading then
        local percent = 0
        if engine.loader.resourceCount ~= 0 then 
            percent = engine.loader.loadedCount / engine.loader.resourceCount
        end
        love.graphics.print(("Loading .. %d%%"):format(percent * 100), 100, 100)
    else
        love.graphics.draw(images.rabbit, 100, 200)
        
        if player then
            engine.cam:lookAt(engine.render.camera, player.collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
            engine.render:prepare()
            engine.render:addLight(engine.render.sun)
            engine.render:draw(models.map)

            player:draw()
            engine.render:present()

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(love.timer.getFPS(), 10, 10)
        end
    end
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