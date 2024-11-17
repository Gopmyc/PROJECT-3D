local loading = {}
loading.__index = loading

function loading:enter(tbl)
    local self = setmetatable({}, loading)

    self.data = {}
    self.state = false
    self.files = tbl
    self.done = 0
    self.count = #tbl

    return self
end

function loading:update(dt)
    for _, v in pairs(self.files) do
        self.data[v.name] = engine.loader:getResource(v.category, v.name)
        self.done = self.done + 1
    end
end

function loading:draw()
    local progress = self.done / self.count
    love.graphics.print("Loading: " .. math.floor(progress * 100) .. "%", 400, 300)
    love.graphics.rectangle("fill", 100, 350, 600 * progress, 30)
end


function loading:isFinished()
    if self.done == self.count then
        return self.data
    end
    return false
end

return loading
