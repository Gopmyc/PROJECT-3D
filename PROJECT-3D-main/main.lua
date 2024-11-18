local PlayerCore = require("core/player")

love.mouse.setRelativeMode(true)

function love.load()
    --- Initializing the game engine ---
    engine = engine or require("core/engineLoader").load(function() end, function() end)

    --- Loading of game assets ---
    engine.models = {map = engine.loader:getResource("models", "map"), player = engine.loader:getResource("models", "player")}
    engine.shaders = {blurShader = engine.loader:getResource("shaders", "blur")}
    engine.UI = {
        inventory = {
            default     =   engine.loader:getResource("images", "default"),
            backpack    =   engine.loader:getResource("images", "backpack"),
            book        =   engine.loader:getResource("images", "book"),
            clover      =   engine.loader:getResource("images", "clover"),
            heart       =   engine.loader:getResource("images", "heart"),
            spade       =   engine.loader:getResource("images", "spade"),
            tile        =   engine.loader:getResource("images", "tile"),
            document    =   engine.loader:getResource("images", "document"),
            map         =   engine.loader:getResource("images", "map")
        }
    }
    
    engine.physics.world:add(engine.physics:newPhysicsObject(engine.models.map))
    player = PlayerCore.new(engine.models.player)

    --// TODO : Setup light sources
end

function love.update(dt)
    engine:update(dt)
	player:update(dt)
end

function love.draw()
    engine:draw()
    engine.cam:lookAt(engine.render.camera, player.collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
    player:draw()
    engine.render:present()

    engine:drawShader(player)
    if player.inventory.isOpen or player.inventory.isAnimating then player.inventory:draw() end

    --- Draw 2D elements (HUD, UI, etc.) ---
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.mousepressed(x, y, button)
    player.inventory:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    player.inventory:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    if not player.inventory.isOpen then 
        engine.cam:mousemoved(dx, dy)
    end
    player.inventory:mousemoved(x, y)
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