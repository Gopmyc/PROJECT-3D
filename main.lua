love.mouse.setRelativeMode(true)

function love.load()
    --- Initializing the game engine ---
    engine = engine or require("core/engine").load(function() end, function() end)

    --- Initializing the 2D assets for game ---
    engine.states:addStateToQueue(engine.states.loading, 2, {
        { category = "images", name = "default"     },
        { category = "images", name = "backpack"    },
        { category = "images", name = "book"        },
        { category = "images", name = "clover"      },
        { category = "images", name = "heart"       },
        { category = "images", name = "spade"       },
        { category = "images", name = "tile"        },
        { category = "images", name = "document"    },
        { category = "images", name = "map"         },
    }, "images", engine.assets.images)

    --- Initializing the 3D game assets ---
    engine.states:addStateToQueue(engine.states.loading, 1, {
        { category = "models", name = "map"         },
        { category = "models", name = "player"      },
    }, "models", engine.assets.models)

    --- Initializing the shaders game assets ---
    engine.states:addStateToQueue(engine.states.loading, 1, {
        { category = "shaders", name = "blur"       },
    }, "shaders", engine.assets.shaders)

    --- Transition to the game state once loading is finished ---
    engine.states:addStateToQueue(engine.states.game, 0)
end

function love.update(dt)
    engine.states:update(dt)
end

function love.draw()
    engine.states:draw()

    --- Draw 2D elements (HUD, UI, etc.) ---
    -- // TODO : Implement in menu state : if self.players[0].inventory.isOpen or self.players[0].inventory.isAnimating then self.players[0].inventory:draw() end
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.mousepressed(x, y, button)
    engine.states:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    engine.states:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    engine.states:mousemoved(x, y, dx, dy)
end

function love.keypressed(key, scancode, isrepeat)
    engine.states:keypressed(key, scancode, isrepeat)
end

function love.resize(w, h)
    engine.states:resize(w, h)
end