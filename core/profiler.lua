local ffi = require("ffi")

Profiler = {}
Profiler.__index = Profiler

if ffi then
	ffi.cdef[[
		typedef struct {
			unsigned long dwLength;
			unsigned long dwFlags;
			unsigned long dwIdleTime;
			unsigned long dwKernelTime;
			unsigned long dwUserTime;
		} SYSTEM_PROCESSOR_INFORMATION;
		int GetSystemTimes(unsigned long* lpIdleTime, unsigned long* lpKernelTime, unsigned long* lpUserTime);
	]]
end

function Profiler.new()
	local self = setmetatable({}, Profiler)
	self.fps = 0
	self.memoryAllocated = 0
	self.memoryUsed = 0
	self.memoryFreed = 0
	self.totalMemoryFreed = 0
	self.previousMemoryUsed = 0
	self.cpuUsage = 0
	self.gpuStats = {}
	self.sampleInterval = 1
	self.lastSampleTime = 0
	self.previousIdleTime = 0
	self.previousKernelTime = 0
	self.previousUserTime = 0
	return self
end

function Profiler:status()
	return self.running
end

function Profiler:start()
	self.running = true
end

function Profiler:stop()
	self.running = false
end

function Profiler:update(dt)
	if not self:status() then return end
	self.fps = love.timer.getFPS()
	self.lastSampleTime = self.lastSampleTime + dt
	if self.lastSampleTime >= self.sampleInterval then
		self:sample()
		self.lastSampleTime = 0
	end
end

function Profiler:sample()
	if not self:status() then return end
	collectgarbage("collect")
	local currentMemoryUsed = collectgarbage("count")
	if currentMemoryUsed < self.previousMemoryUsed then
		local freedThisCycle = self.previousMemoryUsed - currentMemoryUsed
		self.totalMemoryFreed = self.totalMemoryFreed + freedThisCycle
	end
	self.memoryUsed = currentMemoryUsed
	self.memoryAllocated = self.memoryUsed + self.totalMemoryFreed
	self.memoryFreed = self.totalMemoryFreed
	self.previousMemoryUsed = self.memoryUsed
	if love.system.getOS() == "Windows" then
		self.cpuUsage = self:getCPUUsageWindows()
	elseif love.system.getOS() == "Linux" then
		self.cpuUsage = self:getCPUUsageLinux()
	else
		self.cpuUsage = 0
	end

	-- Utilisation correcte de love.graphics.getStats
	local stats = {}
	self.gpuStats = love.graphics.getStats(stats)
end

function Profiler:getCPUUsageWindows()
	local idleTime, kernelTime, userTime = ffi.new("unsigned long[1]"), ffi.new("unsigned long[1]"), ffi.new("unsigned long[1]")
	ffi.C.GetSystemTimes(idleTime, kernelTime, userTime)
	local idle = tonumber(idleTime[0])
	local kernel = tonumber(kernelTime[0])
	local user = tonumber(userTime[0])
	local total = kernel + user
	if not self.previousIdleTime or not self.previousKernelTime or not self.previousUserTime then
		self.previousIdleTime = idle
		self.previousKernelTime = kernel
		self.previousUserTime = user
		return 0
	end
	local idleDiff = idle - self.previousIdleTime
	local kernelDiff = kernel - self.previousKernelTime
	local userDiff = user - self.previousUserTime
	local totalDiff = kernelDiff + userDiff
	self.previousIdleTime = idle
	self.previousKernelTime = kernel
	self.previousUserTime = user
	local cpuUsage = ((totalDiff - idleDiff) / totalDiff) * 100
	return math.max(0, math.min(100, cpuUsage))
end

function Profiler:getCPUUsageLinux()
	local file = io.open("/proc/stat", "r")
	local line = file:read()
	file:close()
	local cpuData = {}
	for value in string.gmatch(line, "%S+") do
		table.insert(cpuData, tonumber(value))
	end
	local total = 0
	for i = 2, #cpuData do
		total = total + cpuData[i]
	end
	local idle = cpuData[5]
	if not self.previousTotal or not self.previousIdle then
		self.previousTotal = total
		self.previousIdle = idle
		return 0
	end
	local totalDiff = total - self.previousTotal
	local idleDiff = idle - self.previousIdle
	self.previousTotal = total
	self.previousIdle = idle
	local cpuUsage = ((totalDiff - idleDiff) / totalDiff) * 100
	return math.max(0, math.min(100, cpuUsage))
end

function Profiler:draw()
	if not self:status() then return end
	love.graphics.setFont(love.graphics.newFont(12))
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("FPS: " .. self.fps, 10, 10)
	love.graphics.print("Memory Allocated: " .. string.format("%.2f MB", self.memoryAllocated / 1024), 10, 30)
	love.graphics.print("Memory Used: " .. string.format("%.2f MB", self.memoryUsed / 1024), 10, 50)
	love.graphics.print("Total Memory Freed: " .. string.format("%.2f MB", self.totalMemoryFreed / 1024), 10, 70)
	love.graphics.print("CPU Usage: " .. string.format("%.2f%%", self.cpuUsage), 10, 90)

	-- Affichage des statistiques GPU
	love.graphics.print("Texture Memory: " .. string.format("%.2f MB", self.gpuStats.texturememory / (1024 * 1024)), 10, 110)
	love.graphics.print("Images Loaded: " .. self.gpuStats.images, 10, 130)
	love.graphics.print("Canvases Loaded: " .. self.gpuStats.canvases, 10, 150)
	love.graphics.print("Fonts Loaded: " .. self.gpuStats.fonts, 10, 170)
end

return Profiler
