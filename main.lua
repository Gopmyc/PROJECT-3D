love.mouse.setRelativeMode(true)

function love.load()
    --- Initializing the game engine ---
    engine = engine or require("core/engine").load(function() end, function() end)

    --- Initializing the state game manager ---
    -- TODO: Call the main menu constructor and initialize the default value {Loading, Menu, Game}
    -- Engine Loading State = Make a default screen to see the loading bar. The loading state includes {EngineLoading, AssetsLoading}
    -- Menu State = Freez (player, game rendering, camera contorller). The menu state includes {Inventory, MainMenu, allUI}
    -- Game State = Calculate and update the rendering and update the game. The game state includes {game}

    --- Initializing the main menu assets ---
    -- TODO: Make the loading of menu assets

    --- Initializing the main menu ---
    -- TODO: Call the main menu constructor and initialize the default value

    --- Initializing the 2D assets for game ---
    -- TODO : Trouver un moyen de recuperer le contenue des assets charger (avec un buffer ?)
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

    -- Forcer la réinitialisation de l'état de loading
    engine.states:processStateQueue()
end

function love.update(dt)
    engine.states:update(dt)
end

function love.draw()
    engine:draw()

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