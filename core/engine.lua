local engine = {}
engine.__index = engine

function engine.load(preLoaded, postLoaded)
	local self = setmetatable({}, engine)

    preLoaded()

    self.config         = require("core/config")
	self.render         = require("engine/init")
    self.sky            = require("engine/extensions/sky")
    self.cam            = require("engine/extensions/utils/cameraController")
    self.utils          = require("engine/extensions/utils") -- // TODO : Modify to add more functions (print table)
    self.physics        = require("engine/extensions/physics/init")
    self.raytrace       = require("engine/extensions/raytrace")
    self.loader         = require("core/loader"):new(self.config)
    self.states         = require("core/stateManager")

    self.render.canvas  = love.graphics.newCanvas()
    self.physics.world  = self.physics:newWorld()
    self.render.sun     = self.render:newLight("sun")
    self.render.lights  = self.render.lights or {}
    self.players        = self.players or {}
    self.assets         = self.assets or {
        images = {},
        fonts  = {},
        sounds = {},
        models = {},
        shaders = {},
    }

    for k, v in pairs(self.config.states) do
        self.states[k] = require(v)
    end

    postLoaded()

	return self
end

function engine:loadRendering(preLoaded, postLoaded)
    preLoaded()

    self.render:setAutoExposure(self.config.engineConfig.rendering.autoExposure)
    self.render.canvases:setRefractions(self.config.engineConfig.rendering.refraction)
    self.render.sun:addNewShadow()
    self.render:setSky(self.sky.render)
    self.sky:setDaytime(self.render.sun, self.config.engineConfig.rendering.dayTime)

    self.render:init()

    postLoaded()
end

function engine:draw()
    --love.graphics.setCanvas(self.render.canvas)
    --love.graphics.clear()
    self.states:draw()
end

function engine:drawShader(player)
    love.graphics.setCanvas()

    --- Draw the shaders here ---
    if player.inventory.isOpen or player.inventory.isAnimating then
        love.graphics.setShader(self.shaders.blurShader)
        self.shaders.blurShader:send("radius", 5)
    end
    -----------------------------

    love.graphics.draw(self.render.canvas)
    love.graphics.setShader()
end

return engine