local configCore = require("core/config")
local LoaderCore = require("core/loader")

local engine = {}
engine.__index = engine

function engine.load(preLoaded, postLoaded)
	local self = setmetatable({}, engine)

    preLoaded()

	self.render = require("engine/init")
    self.sky = require("engine/extensions/sky")
    self.cam = require("engine/extensions/utils/cameraController")
    self.utils = require("engine/extensions/utils") -- // TODO : Modify to add more functions (print table)
    self.physics = require("engine/extensions/physics/init")
    self.raytrace = require("engine/extensions/raytrace")
    engine.loader = LoaderCore:new(configCore)
	engine.config = configCore

    self.render.canvas = love.graphics.newCanvas()
    self.physics.world = self.physics:newWorld()
    self.render.sun = self.render:newLight("sun")
    self.render.sun:addNewShadow()
    self.render:setSky(self.sky.render)
    self.sky:setDaytime(self.render.sun, 0.5)

    self.render:init()

    postLoaded()

	return self
end

function engine:update(dt)
	self.cam:update(dt)
    self.render:update()
    self.physics.world:update(dt)
end

function engine:draw()
    love.graphics.setCanvas(self.render.canvas)
    love.graphics.clear()
    self.render:prepare()
    self.render:addLight(self.render.sun)
    self.render:draw(self.models.map)
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