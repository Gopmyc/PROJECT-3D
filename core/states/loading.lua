local loading = {}
loading.__index = loading

function loading:enter(files, buffer)
    local self = setmetatable({}, loading)

    self.id = "loading"
    self.files = files
    self.buffer = buffer or {}
    self.done = 0
    self.count = #files
    return self
end

function loading:update(dt)
    if self.done < self.count then
        local file = self.files[self.done + 1]
        self.buffer[file.name] = engine.loader:getResource(file.category, file.name)
        self.done = self.done + 1
    end
end

function loading:draw()
    local progress = self.done / self.count
    love.graphics.print("Loading: " .. math.floor(progress * 100) .. "%", 400, 300)
    love.graphics.rectangle("fill", 100, 350, 600 * progress, 30)
end

function loading:isFinished()
    return self.done == self.count
end

function loading:getData()
    return self.buffer
end

function loading:exit()
    self.files = nil
end

return loading
