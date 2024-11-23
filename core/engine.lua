local engine = {}
engine.__index = engine

function engine.load(preLoaded, postLoaded)
	local self = setmetatable({}, engine)

    if preLoaded then preLoaded() end

    self:debugPrint("Start loading the game engine...")
    self.config         = require("core/config")
	self.render         = require("engine/init")
    self.sky            = require("engine/extensions/sky")
    self.cam            = require("engine/extensions/utils/cameraController")
    self.utils          = require("core/utils")
    self.physics        = require("engine/extensions/physics/init")
    self.raytrace       = require("engine/extensions/raytrace")
    self.loader         = require("core/loader"):new(self.config)
    self.states         = require("core/stateManager").new()
    self.profiler       = require("core/profiler").new()

    self.render.lights  = self.render.lights or {}
    self.players        = self.players or {}
    self.timer          = self.timer or 0
    self.isWindowFocus  = false
	self.canQuit		= false -- // It is set by default to 'false' for security, should I change it?

    for k, v in pairs(self.config.states) do
        self.states[k] = require(v.path)
    end
    self:debugPrint("End of game engine loading...")

    if postLoaded then postLoaded() end

	return self
end

function engine:initPhysics()
    self.physics.world = self.physics:newWorld()
end

function engine:debugPrint(msg)
    if self.config and self.config.engineConfig.debugPrint then
        print("[INITIAL DEBUG PRINT] : " .. msg)
        print("---------------")
    elseif not self.config then
        print("[INITIAL DEBUG PRINT] : " .. msg)
        print("---------------")
    end
end

function engine:loadRendering(preLoaded, postLoaded)
    preLoaded()

    engine:debugPrint("Start of loading the graphics rendering...")
    --- Canvas ---
    self.render.canvas  = love.graphics.newCanvas()

    --- Sky and Light ---
    self.render.sun     = self.render:newLight("sun")
    self.render.sun:addNewShadow()
    self.render:setSky(self.sky.render)
    self.sky:setDaytime(self.render.sun, self.config.engineConfig.rendering.dayTime)

    --- Shaders ---
    self.render:setAutoExposure(self.config.engineConfig.rendering.autoExposure)
    self.render.canvases:setRefractions(self.config.engineConfig.rendering.refraction)

    self.render:init()

    love.graphics.setCanvas(self.render.canvas)

    engine:debugPrint("End of graphics rendering loading...")

    postLoaded()
end

return engine