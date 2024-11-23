require("run")

function love.load()
    if engine.config.engineConfig.profiling then
        engine.profiler:start() --> Use with caution because the profiler requires heavy operation
    end

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
    })

    --- Initializing the 3D game assets ---
    engine.states:addStateToQueue(engine.states.loading, 1, {
        { category = "models", name = "map"         },
        { category = "models", name = "player"      },
    })

    --- Initializing the shaders game assets ---
    engine.states:addStateToQueue(engine.states.loading, 1, {
        { category = "shaders", name = "blur"       },
    })

    --- Transition to the game state once loading is finished ---
    engine.states:addStateToQueue(engine.states.game, 0)
end

function love.update(dt)
    engine.profiler:update(dt) 
    engine.timer = engine.timer + dt
    engine.states:update(dt)
end

function love.draw()
    engine.states:draw()
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
    if key == engine.config.keys.window.close then
        love.event.quit()
    end
	if key == engine.config.keys.window.resize then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
    engine.states:keypressed(key, scancode, isrepeat)
end

function love.resize(w, h)
    engine.states:resize(w, h)
end

function love.focus(focus)
    if focus then
        engine.isWindowFocus = true
    else
        engine.isWindowFocus = false
    end
end

function love.quit()
	if not engine.canQuit then return true end
    engine.profiler:stop()
	return false
end