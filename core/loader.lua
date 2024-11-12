local config = require("core/config")

local Loader = {}
Loader.__index = Loader

function Loader.new()
    local self = setmetatable({}, Loader)
    self.pending = {}
    self.callbacks = {}
    self.resourceBeingLoaded = nil
    self.loadedCount = 0
    self.resourceCount = 0
    self.config = config
    self.resourceKinds = self:loadResourceKinds()
    return self
end

function Loader:loadResourceKinds()
    local resourceKinds = {}
    for k, data in pairs(self.config.threads.resourceKinds) do
        resourceKinds[k] = {
            requestKey = data.requestKey,
            resourceKey = data.resourceKey,
            constructor = data.constructor,
            postProcess = data.postProcess
        }
    end
    return resourceKinds
end

function Loader:addResource(kind, holder, key, requestParams)
    table.insert(self.pending, {
        kind = kind,
        holder = holder,
        key = key,
        requestParams = requestParams
    })
end

--- Retrieve a thread resource if it is available ---
function Loader:getResourceFromThreadIfAvailable()
    for _, kind in pairs(self.resourceKinds) do
        local channel = love.thread.getChannel("loader_" .. kind.resourceKey)
        local data = channel:pop()
        if data then
            local resource = kind.postProcess and kind.postProcess(data, self.resourceBeingLoaded) or data
            self.resourceBeingLoaded.holder[self.resourceBeingLoaded.key] = resource
            self.loadedCount = self.loadedCount + 1
            self.callbacks.oneLoaded(self.resourceBeingLoaded.kind, self.resourceBeingLoaded.holder, self.resourceBeingLoaded.key)
            self.resourceBeingLoaded = nil
        end
    end
end

--- Request a new resource from the thread ---
function Loader:requestNewResourceToThread()
    self.resourceBeingLoaded = table.remove(self.pending, 1)
    local requestKey = self.resourceKinds[self.resourceBeingLoaded.kind].requestKey
    local channel = love.thread.getChannel("loader_" .. requestKey)
    channel:push(self.resourceBeingLoaded.requestParams)
end

function Loader:endThreadIfAllLoaded()
    if not self.resourceBeingLoaded and #self.pending == 0 then
        love.thread.getChannel("loader_is_done"):push(true)
        self.callbacks.allLoaded()
    end
end

function Loader:newImage(holder, key, path)
    self:addResource('image', holder, key, {path})
end

function Loader:newFont(holder, key, path, size)
    self:addResource('font', holder, key, {path, size})
end

function Loader:newBMFont(holder, key, path, glyphsPath)
    self:addResource('font', holder, key, {path, glyphsPath})
end

function Loader:newSource(holder, key, path, sourceType)
    local kind = (sourceType == 'static' and 'staticSource' or 'streamSource')
    self:addResource(kind, holder, key, {path})
end

function Loader:newSoundData(holder, key, pathOrDecoder)
    self:addResource('soundData', holder, key, {pathOrDecoder})
end

function Loader:newImageData(holder, key, path)
    self:addResource('imageData', holder, key, {path})
end

function Loader:newCompressedData(holder, key, path)
    self:addResource('compressedData', holder, key, {path})
end

function Loader:read(holder, key, path)
    self:addResource('rawData', holder, key, {path})
end

function Loader:newModel3D(holder, key, path)
    self:addResource('model3D', holder, key, {path})
end

--- Start the loading process with callbacks ---
function Loader:start(allLoadedCallback, oneLoadedCallback)
    self.callbacks.allLoaded = allLoadedCallback or function() end
    self.callbacks.oneLoaded = oneLoadedCallback or function() end

    local thread = love.thread.newThread(pathToThisFile)
    self.loadedCount = 0
    self.resourceCount = #self.pending
    thread:start(true)
    self.thread = thread
end

--- Update the loader (manage the thread) ---
function Loader:update()
    if self.thread then
        if self.thread:isRunning() then
            if self.resourceBeingLoaded then
                self:getResourceFromThreadIfAvailable()
            elseif #self.pending > 0 then
                self:requestNewResourceToThread()
            else
                self:endThreadIfAllLoaded()
                self.thread = nil
            end
        else
            local errorMessage = self.thread:getError()
            assert(not errorMessage, errorMessage)
        end
    end
end

return Loader