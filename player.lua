local Player = {}
Player.__index = Player

function Player.new(model)
	local self = setmetatable({}, Player)
	self.position = {x = -10, y = 15, z = 0}
	self:createCollider()
	self.speed = 60
	self.maxSpeed = 100
	self.acceleration = 20000
	self.airAcceleration = self.acceleration * 0.03 -- Réduction de l'accélération dans les airs
	self.velocity = {x = 0, y = 0, z = 0}
	self.jumpHeight = 5
	self.model = model or engine.render:loadObject("objects/player")
	self.transform = self.model:getTransform()

	return self
end

function Player:createCollider()
	self.collider = engine.physics.world:add(engine.physics:newCylinder(0.5, 2), "dynamic", self.position.x, self.position.y, self.position.z)
	self.collider:getBody():setLinearDamping(1)
	self.collider:getBody():setAngularDamping(1)
end

function Player:move(dt)
	local d = love.keyboard.isDown
	local ax, az = 0, 0

	if d("z") then
		ax = ax + math.cos(engine.cam.ry - math.pi / 2)
		az = az + math.sin(engine.cam.ry - math.pi / 2)
	end
	if d("s") then
		ax = ax + math.cos(engine.cam.ry + math.pi - math.pi / 2)
		az = az + math.sin(engine.cam.ry + math.pi - math.pi / 2)
	end
	if d("q") then
		ax = ax + math.cos(engine.cam.ry - math.pi / 2 - math.pi / 2)
		az = az + math.sin(engine.cam.ry - math.pi / 2 - math.pi / 2)
	end
	if d("d") then
		ax = ax + math.cos(engine.cam.ry + math.pi / 2 - math.pi / 2)
		az = az + math.sin(engine.cam.ry + math.pi / 2 - math.pi / 2)
	end

	local a = math.sqrt(ax ^ 2 + az ^ 2)
	if a > 0 then
		ax = ax / a
		az = az / a
		local v = self.collider:getVelocity()
		local speed = math.sqrt(v.x ^ 2 + v.z ^ 2)
		local dot = speed > 0 and (ax * v.x / speed + az * v.z / speed) or 0

		-- Utilise une accélération réduite si le joueur est dans les airs
		local accel = (self.collider.touchedFloor and self.acceleration or self.airAcceleration) * math.max(0, 1 - speed / self.maxSpeed * math.abs(dot))
		self.collider:applyForce(ax * accel, 0, az * accel)
	end
end

function Player:jump()
	if self.collider.touchedFloor and love.keyboard.isDown("space") then
		self.collider.vy = self.jumpHeight
	end
end

function Player:update(dt)
	self:move(dt)
	self:jump()
	engine.cam:lookAt(engine.render.camera, self.collider:getPosition() + engine.render.vec3(0, 2, 0), 5)
end

function Player:draw()
	local pos = self.collider:getPosition()
	self.model:setTransform(self.transform)
	self.model:translateWorld(pos)

	engine.render:draw(self.model)
end

return Player