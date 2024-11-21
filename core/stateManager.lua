local BinaryHeap = require("core/objects/binaryHeap")

local StateManager = {}
StateManager.__index = StateManager

function StateManager.new()
    local self = setmetatable({}, StateManager)

    self.currentState = nil
    self.currentArgs = nil
    self.currentKeyData = nil
    self.currentBufferData = nil
    self.previousState = nil
    self.previousArgs = nil
    self.previousKeyData = nil
    self.previousBufferData = nil
    self.stateQueue = BinaryHeap.new()
    self.stateQueueData = {}

    --- Memory management ---
    self.gcThreshold = 1024
    self.gcScale = 1.5
    self.lastGCTime = 0
    self.gcCooldown = 1.0

    return self
end

--- Helper function to check if the function exists in the state ---
local function assertFunction(state, funcName)
    if state and state[funcName] then
        assert(type(state[funcName]) == "function", funcName .. " must be a function")
    end
end

--- Get the current state ---
function StateManager:getCurrentState()
    if not self.currentState or not self.currentState.id then
        return nil
    end
    return self.currentState.id
end

--- Get data from a state finish ---
function StateManager:getStateQueueData(key)
    return self.stateQueueData[key]
end

--- Adds a state to the queue with priority ---
function StateManager:addStateToQueue(state, priority, tbl, key, buffer)
    self.stateQueue:insert(state, priority, tbl, key, buffer)
end

--- Execute the state at the head of the queue if the current state has completed ---
function StateManager:processStateQueue()
    if not self.currentState and self.stateQueue:size() > 0 then
        local nextState = self.stateQueue:removeMax()  -- Extraire l'état avec la priorité la plus haute
        self:setState(nextState.state, nextState.args, nextState.keyData, nextState.bufferData)
    end

    if self.currentState then
        local finish = self.currentState:isFinished()
        if finish then
            if self.keyData then
                self.stateQueueData[self.keyData] = self.currentState:getData()
            end
            if self.stateQueue:size() > 0 then
                local nextState = self.stateQueue:removeMax()
                self:setState(nextState.state, nextState.args, nextState.keyData, nextState.bufferData)
            end
        end
    end
end

--- Apply a new state with its arguments ---
function StateManager:setState(newState, args, keyData, bufferData)
    assert(type(newState) == "table" and newState.enter ~= nil, "State must be a table and have an enter function")

    if self.currentState == newState and args == self.currentArgs then return end
    if self.currentState then
        if self.currentState:isFinished() and self.currentState.getData then
            local stateData = self.currentState:getData()

            if type(bufferData) == "table" and type(stateData) == "table" then
                for k, v in pairs(stateData) do
                    bufferData[k] = v
                end
            elseif stateData then
                bufferData = stateData
            end
        end

        if self.currentState.exit then
            self.currentState:exit()
        end
    end

    self.previousState = self.currentState
    self.previousArgs = self.currentArgs
    self.previousKeyData = self.currentKeyData
    self.previousBufferData = self.currentBufferData

    self.currentArgs = args
    self.currentKeyData = keyData
    self.currentBufferData = bufferData
    self.currentState = newState:enter(self.currentArgs, self.currentBufferData)

    if self.currentState.resize then
        self.currentState:resize(love.graphics.getWidth(), love.graphics.getHeight())
    end
end

function StateManager:reloadState()
    if self.currentState then
        assertFunction(self.currentState, "enter")
        if self.currentState.enter then
            return self.currentState:enter(self.currentArgs, self.currentBufferData)
        end
    end
end

function StateManager:revertState()
    if self.previousState then
        self:setState(self.previousState)
    end
end

--- Event Handling ---
function StateManager:mousemoved(x, y, ...)
    assert(type(x) == "number", "x must be a number")
    assert(type(y) == "number", "y must be a number")
    if self.currentState then
        assertFunction(self.currentState, "mousemoved")
        if self.currentState.mousemoved then
            self.currentState:mousemoved(x, y, ...)
        end
    end
end

function StateManager:wheelmoved(x, y)
    assert(type(x) == "number", "x must be a number")
    assert(type(y) == "number", "y must be a number")
    if self.currentState then
        assertFunction(self.currentState, "wheelmoved")
        if self.currentState.wheelmoved then
            self.currentState:wheelmoved(x, y)
        end
    end
end

function StateManager:mousepressed(x, y, button)
    assert(type(x) == "number", "x must be a number")
    assert(type(y) == "number", "y must be a number")
    assert(type(button) == "number", "button must be a number")
    if self.currentState then
        assertFunction(self.currentState, "mousepressed")
        if self.currentState.mousepressed then
            self.currentState:mousepressed(x, y, button)
        end
    end
end

function StateManager:mousereleased(x, y, button)
    assert(type(x) == "number", "x must be a number")
    assert(type(y) == "number", "y must be a number")
    assert(type(button) == "number", "button must be a number")
    if self.currentState then
        assertFunction(self.currentState, "mousereleased")
        if self.currentState.mousereleased then
            self.currentState:mousereleased(x, y, button)
        end
    end
end

function StateManager:keypressed(key, scancode, isrepeat)
    assert(type(key) == "string", "key must be a string")
    assert(type(scancode) == "string", "scancode must be a string")
    assert(type(isrepeat) == "boolean", "isrepeat must be a boolean")
    if self.currentState then
        assertFunction(self.currentState, "keypressed")
        if self.currentState.keypressed then
            self.currentState:keypressed(key, scancode, isrepeat)
        end
    end
end

function StateManager:keyreleased(key, scancode)
    assert(type(key) == "string", "key must be a string")
    assert(type(scancode) == "string", "scancode must be a string")
    if self.currentState then
        assertFunction(self.currentState, "keyreleased")
        if self.currentState.keyreleased then
            self.currentState:keyreleased(key, scancode)
        end
    end
end

function StateManager:textinput(text)
    assert(type(text) == "string", "text must be a string")
    if self.currentState then
        assertFunction(self.currentState, "textinput")
        if self.currentState.textinput then
            self.currentState:textinput(text)
        end
    end
end

--- Update the state ---
function StateManager:update(dt)
    assert(type(dt) == "number", "dt must be a number [in the update method of the state manager]")
    
    if self.gcThreshold and self.gcFrequency then
        local currentMemory = collectgarbage("count")
        local now = love.timer.getTime()
        
        
        if currentMemory > self.gcThreshold and (not self.lastGCTime or now - self.lastGCTime >= self.gcCooldown) then
            collectgarbage("collect")
            self.lastGCTime = now
            print(string.format("GC triggered: Memory before = %.2f KB, after = %.2f KB", currentMemory, collectgarbage("count")))
            self.gcThreshold = math.max(self.gcThreshold, currentMemory * self.gcScale)
        end
    end

    if self.currentState then
        if self.currentBufferData and self.currentState:isFinished() then
            local stateData = self.currentState:getData()
            
            if type(self.currentBufferData) == "table" and type(stateData) == "table" then
                for k, v in pairs(stateData) do
                    if self.currentBufferData[k] == nil then
                        self.currentBufferData[k] = v
                    else
                        if type(self.currentBufferData[k]) == "table" and type(v) == "table" then
                            for innerK, innerV in pairs(v) do
                                self.currentBufferData[k][innerK] = innerV
                            end
                        elseif type(self.currentBufferData[k]) == "string" and type(v) == "string" then
                            self.currentBufferData[k] = self.currentBufferData[k] .. v
                        end
                    end
                end
            else
                self.currentBufferData = stateData
            end
        end

        assertFunction(self.currentState, "update")
        if self.currentState.update then
            self.currentState:update(dt)
        end
    end
    
    self:processStateQueue()
end

--- Quit the game ---
function StateManager:quit()
    if self.currentState then
        assertFunction(self.currentState, "quit")
        if self.currentState.quit then
            self.currentState:quit()
        end
    end
end

--- Draw the current state ---
function StateManager:draw()
    if self.currentState then
        assertFunction(self.currentState, "draw")
        if self.currentState.draw then
            self.currentState:draw()
        end
    end
end

--- Resize window handling ---
function StateManager:resize(w, h)
    assert(type(w) == "number", "w must be a number")
    assert(type(h) == "number", "h must be a number")
    if self.currentState then
        assertFunction(self.currentState, "resize")
        if self.currentState.resize then
            self.currentState:resize(w, h)
        end
    end
end

return StateManager
