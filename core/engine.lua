local engine = {}
engine.__index = engine

function engine.load(preLoaded, postLoaded)
	local self = setmetatable({}, engine)

    preLoaded()

    self.config         = require("core/config")
	self.render         = require("engine/init")
    self.sky            = require("engine/extensions/sky")
    self.cam            = require("engine/extensions/utils/cameraController")
    self.utils          = require("core/utils")
    self.physics        = require("engine/extensions/physics/init")
    self.raytrace       = require("engine/extensions/raytrace")
    self.loader         = require("core/loader"):new(self.config)
    self.states         = require("core/stateManager").new()

    self.render.canvas  = love.graphics.newCanvas()
    self.physics.world  = self.physics:newWorld()
    self.render.sun     = self.render:newLight("sun")
    self.render.lights  = self.render.lights or {}
    self.players        = self.players or {}
    self.timer          = self.timer or 0
	self.canQuit		= false -- // It is set by default to 'false' for security, should I change it?
    self.assets         = self.assets or {
        images	= {},
        fonts 	= {},
        sounds	= {},
        models	= {},
        shaders	= {},
    }

    for k, v in pairs(self.config.states) do
        self.states[k] = require(v.path)
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

return engine