local utils = {}
utils.__index = utils

function utils:getTableSize(tbl)
    assert(type(tbl) == "table", "The 'getTableSize' method only accepts a table as an argument")
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function utils:supportsColors()
    return os.getenv("TERM") ~= nil and os.getenv("TERM") ~= "" and os.getenv("TERM") ~= "dumb" and not (os.getenv("OS") and os.getenv("OS"):match("Windows"))
end

function utils:printTable(tbl, prefix)
    prefix = prefix or ""  -- Initialiser le préfixe si ce n'est pas déjà défini
    for key, value in pairs(tbl) do
        local line = tostring(key)
        if type(value) == "table" then
            print(prefix .. "+--" .. line .. " : ")
            utils:printTable(value, prefix .. "|   ")  -- Appel récursif pour les sous-tables
        else
            print(prefix .. "+--" .. line .. " : " .. tostring(value))
        end
    end
end

function utils:print(msg, msgType)
    local useColors = self:supportsColors()
    local colors = {
        RESET = "\27[0m",
        RED = "\27[31m",
        GREEN = "\27[32m",
        YELLOW = "\27[33m",
        BLUE = "\27[34m",
        MAGENTA = "\27[35m",
        CYAN = "\27[36m",
        WHITE = "\27[37m",
    }

    local prefix_default = "[GOP]"
    local prefix = "[LOG]"
    local color = colors.WHITE

    if type(msg) == "table" then
        self:printTable(msg)
    else
        if msgType == "INFO" then
            prefix = "[INFO]"
            color = colors.GREEN
        elseif msgType == "WARN" then
            prefix = "[WARN]"
            color = colors.YELLOW
        elseif msgType == "ERROR" then
            prefix = "[ERROR]"
            color = colors.RED
        end

        local color_prefix = useColors and (colors.RESET .. prefix_default .. colors.RESET) or prefix_default
        local color_msg = useColors and (color .. prefix .. colors.RESET) or prefix
        local color_text = useColors and (colors.WHITE .. msg) or msg

        local formatted_msg
        if useColors then
            formatted_msg = string.format(
                "%s%s %s%s%s",
                color_prefix,
                color_msg,
                color_text,
                colors.RESET
            )
        else
            formatted_msg = string.format(
                "%s %s %s",
                color_prefix,
                color_msg,
                color_text
            )
        end

        print(formatted_msg)
    end
end

function utils:getProjectFiles(dir)
    local filesAndDirs = {}

    local entries = love.filesystem.getDirectoryItems(dir)
    for _, entry in ipairs(entries) do
        local fullPath = dir .. "/" .. entry
        local isDir = love.filesystem.isDirectory(fullPath)

        if isDir then
            filesAndDirs[entry] = self:getProjectFiles(fullPath)
        else
            table.insert(filesAndDirs, fullPath)
        end
    end

    return filesAndDirs
end

return utils