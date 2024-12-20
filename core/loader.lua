local Loader = {}
Loader.__index = Loader

-- // TODO : Subsequently set up a very fast loading and unloading system with thread for very high priority resources: UI, Sound, Font
function Loader:new(config)
    local self = setmetatable({}, Loader)
    self.config = config.loader
    self.resources = { images = {}, sounds = {}, fonts = {}, models = {}, shaders = {}, data = {} }
    self.cacheOrder = {}
	self.cacheLimit = 10
    return self
end

function Loader:loadResource(category, name, path)
	if not engine.render then return end
    local resolution = "medium"
    if type(path) == "table" then path = path[resolution] end

    if category == "images" then
        return love.graphics.newImage(path)
    elseif category == "sounds" then
        local bufferType = self.config.assets[category][name].buffer or "static"
        return love.audio.newSource(path, bufferType)
    elseif category == "fonts" then
        return love.graphics.newFont(path.path, path.size)
    elseif category == "models" then
        return engine.render:loadObject(path)
    elseif category == "shaders" then
        return love.graphics.newShader(path)
    elseif category == "data" then
        local file = love.filesystem.read(path)
        return file and love.filesystem.load(file)()
    end
end

function Loader:getResource(category, name)
    if not self.resources[category][name] then
        if not self.config.dynamic then assert(self.resources[category][name], "Warning: You are trying to access a resource that has not been loaded. Dynamic loading is disabled.") end
        if #self.cacheOrder >= self.cacheLimit then
            local oldest = table.remove(self.cacheOrder, 1)
            self:releaseResource(oldest.category, oldest.name)
        end

        local path = self.config.assets[category][name].path
        self.resources[category][name] = self:loadResource(category, name, path)
        table.insert(self.cacheOrder, { category = category, name = name })
    end
    return self.resources[category][name]
end

function Loader:releaseResource(category, name)
    if self.resources[category][name] then
        self.resources[category][name] = nil
        collectgarbage("collect")
    end
    for i, item in ipairs(self.cacheOrder) do
        if item.category == category and item.name == name then
            table.remove(self.cacheOrder, i)
            break
        end
    end
end

function Loader:checkVideoMemory()
    local videoMemoryUsed = love.graphics.getStats().texturememory
    local maxMemory = 512 * 1024 * 1024
    if videoMemoryUsed > maxMemory * 0.9 then
        self:releaseLowPriorityResources()
    end
end

function Loader:releaseLowPriorityResources()
    for category, resources in pairs(self.resources) do
        for name, resource in pairs(resources) do
            if self.config.assets[category][name].priority == 0 then
                self:releaseResource(category, name)
            end
        end
    end
end

return Loader