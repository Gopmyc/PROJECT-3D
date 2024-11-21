local loading = {}
loading.__index = loading

function loading:enter(files, buffer)
    local self = setmetatable({}, loading)

    self.id = "loading"
    self.files = files
    self.buffer = buffer or {}
    self.done = 0
    self.count = #files
    self.progressBar = {
        x = 100,
        y = 350,
        width = 600,
        height = 30,
        currentWidth = 0,
        targetWidth = 0,
        borderWidth = 4,
    }
    self.colors = {
        background = {0.1, 0.1, 0.1},
        bar = {0.2, 0.8, 0.2},
        border = {1, 1, 1},
        text = {1, 1, 1},
    }
    self.font = love.graphics.newFont(24)
    
    self.startTime = love.timer.getTime()
    self.timeSinceLastUpdate = 0
    self.estimatedTimeRemaining = 0

    return self
end

function loading:update(dt)
    if self.done < self.count then
        local file = self.files[self.done + 1]
        self.buffer[file.name] = engine.loader:getResource(file.category, file.name)
        self.done = self.done + 1
    end

    self.progressBar.targetWidth = (self.done / self.count) * self.progressBar.width

    local current = self.progressBar.currentWidth
    local target = self.progressBar.targetWidth
    local distanceRemaining = math.abs(target - current)

    local lerpSpeed = math.max(0.5, 1 + distanceRemaining * 0.05)
    self.progressBar.currentWidth = math.min(
        current + (target - current) * lerpSpeed * dt,
        self.progressBar.width
    )

    local progress = self.progressBar.currentWidth / self.progressBar.width

    local timeElapsed = love.timer.getTime() - self.startTime
    if progress > 0 then
        local estimatedTotalTime = timeElapsed / progress
        self.estimatedTimeRemaining = estimatedTotalTime - timeElapsed
    end
end

function loading:draw()
    local progress = self.progressBar.currentWidth / self.progressBar.width

    love.graphics.clear(self.colors.background)
    love.graphics.setColor(self.colors.text)
    love.graphics.setFont(self.font)
    love.graphics.printf(
        "Loading... " .. math.floor(progress * 100) .. "%",
        0, self.progressBar.y - 50,
        love.graphics.getWidth(),
        "center"
    )

    -- Affichage du temps restant si disponible
    if self.done > 0 then
        local minutes = math.floor(self.estimatedTimeRemaining / 60)
        local seconds = math.floor(self.estimatedTimeRemaining % 60)
        love.graphics.printf(
            string.format("Time remaining: %02d:%02d", minutes, seconds),
            0, self.progressBar.y + self.progressBar.height + 10,
            love.graphics.getWidth(),
            "center"
        )
    end

    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle(
        "line",
        self.progressBar.x,
        self.progressBar.y,
        self.progressBar.width,
        self.progressBar.height
    )
    love.graphics.setColor(self.colors.bar)
    love.graphics.rectangle(
        "fill",
        self.progressBar.x,
        self.progressBar.y,
        self.progressBar.currentWidth,
        self.progressBar.height
    )
    love.graphics.setColor(1, 1, 1)
end

function loading:isFinished()
    local barFilled = math.abs(self.progressBar.currentWidth - self.progressBar.width) < 0.01
    return self.done == self.count and barFilled
end

function loading:resize(w, h)
    self.progressBar.width = w - 200
    self.progressBar.x = (w - self.progressBar.width) / 2
    self.textX = w / 2
end

function loading:getData()
    return self.buffer
end

function loading:exit()
    self.id, self.files, self.done, self.count, self.progressBar, self.colors, self.font, self.startTime, self.timeSinceLastUpdate, self.estimatedTimeRemaining = nil
end

return loading
