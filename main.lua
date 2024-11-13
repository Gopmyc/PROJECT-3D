local engineRender = require("engine/init")
local engineSky = require("engine/extensions/sky")
local engineCam = require("engine/extensions/utils/cameraController")
local engineUtils = require("engine/extensions/utils") -- // TODO : Modify to add more functions (print table)
local enginePhysics = require("engine/extensions/physics/init")
local engineRaytrace = require("engine/extensions/raytrace")
local configCore = require("core/config")
local LoaderCore = require("core/loader")
local PlayerCore = require("core/player")

love.mouse.setRelativeMode(true)

local models = {}
local shaders = {}
local inventory_images = {}

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

    engine.render.canvas = love.graphics.newCanvas()
    engine.physics.world = engine.physics:newWorld()
    engine.render.sun = engine.render:newLight("sun")
    engine.render.sun:addNewShadow()
    engine.render:setSky(engine.sky.render)
    engine.sky:setDaytime(engine.render.sun, 0.2)

    engine.render:init()

    --- Loading of game assets ---
	models = {map = engine.loader:getResource("models", "map"), player = engine.loader:getResource("models", "player")}
    shaders = {blurShader = engine.loader:getResource("shaders", "blur")}
    inventory_images = {
        default = engine.loader:getResource("images", "default"),
        backpack = engine.loader:getResource("images", "backpack"),
        book = engine.loader:getResource("images", "book"),
        clover = engine.loader:getResource("images", "clover"),
        heart = engine.loader:getResource("images", "heart"),
        spade = engine.loader:getResource("images", "spade"),
        tile = engine.loader:getResource("images", "tile"),
        document = engine.loader:getResource("images", "document"),
        map = engine.loader:getResource("images", "map")
    }

    player = PlayerCore.new(models.player)
    engine.physics.world:add(engine.physics:newPhysicsObject(models.map))
end

function love.update(dt)
    engine.cam:update(dt)
    engine.render:update()
    engine.physics.world:update(dt)
	player:update(dt)
end

function love.draw()
    love.graphics.setCanvas(engine.render.canvas)
    love.graphics.clear()

    engine.cam:lookAt(engine.render.camera, player.collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
    engine.render:prepare()
    engine.render:addLight(engine.render.sun)
    engine.render:draw(models.map)
    player:draw()
    engine.render:present()

    love.graphics.setCanvas()

    if player.inventory.isOpen then
        love.graphics.setShader(shaders.blurShader)
        shaders.blurShader:send("radius", 5)
    end

    love.graphics.draw(engine.render.canvas)
    love.graphics.setShader()

    if player.inventory.isOpen then player.inventory:draw() end

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 10, 10)
end


function love.mousemoved(_, _, x, y)
    if not player.inventory.isOpen then engine.cam:mousemoved(x, y) end
end

function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    player:keysPressed(key)
end

function love.resize(w, h)
    engine.render.canvas = love.graphics.newCanvas(w, h)
    engine.render:init()
end