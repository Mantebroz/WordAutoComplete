----------------------------------------------------------------
-- WORD MEMORY
-- Blacklist remota + blacklist de sesión + banco de palabras X
----------------------------------------------------------------

local WordMemory = {}

local RAW_BASE =
    "https://raw.githubusercontent.com/Mantebroz/WordAutoComplete/main/"

local function normalize(word)
    if type(word) ~= "string" then
        return nil
    end

    word = string.lower(word)
    word = word:gsub("^%s+", "")
    word = word:gsub("%s+$", "")

    if word == "" then
        return nil
    end

    return word
end

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and type(result) == "string" then
        return result
    end

    local okService, HttpService = pcall(function()
        return game:GetService("HttpService")
    end)

    if okService and HttpService then
        local okHttp, body = pcall(function()
            return HttpService:GetAsync(url)
        end)

        if okHttp and type(body) == "string" then
            return body
        end
    end

    return nil
end

local function loadRemoteTable(fileName, fallback)
    local source = httpGet(RAW_BASE .. fileName)

    if not source then
        warn("[AUTO WORD] No se pudo descargar " .. fileName)
        return fallback
    end

    local compiler = loadstring or load

    if type(compiler) ~= "function" then
        warn("[AUTO WORD] loadstring/load no disponible para " .. fileName)
        return fallback
    end

    local chunk, compileError = compiler(source)

    if not chunk then
        warn("[AUTO WORD] Error compilando " .. fileName .. ":", compileError)
        return fallback
    end

    local ok, result = pcall(chunk)

    if not ok or type(result) ~= "table" then
        warn("[AUTO WORD] " .. fileName .. " no devolvió una tabla válida")
        return fallback
    end

    return result
end

----------------------------------------------------------------
-- MEMORIA QUE SOBREVIVE A VOLVER A EJECUTAR EL LOADSTRING
-- DURANTE LA MISMA SESIÓN
----------------------------------------------------------------

local environment

if type(getgenv) == "function" then
    environment = getgenv()
else
    environment = _G
end

environment.__WORD_AUTOCOMPLETE_BLACKLIST =
    environment.__WORD_AUTOCOMPLETE_BLACKLIST or {}

environment.__WORD_AUTOCOMPLETE_NEW_BLACKLIST =
    environment.__WORD_AUTOCOMPLETE_NEW_BLACKLIST or {}

local sessionBlacklist =
    environment.__WORD_AUTOCOMPLETE_BLACKLIST

local newBlacklist =
    environment.__WORD_AUTOCOMPLETE_NEW_BLACKLIST

----------------------------------------------------------------
-- CARGAR BLACKLIST GUARDADA EN GITHUB
----------------------------------------------------------------

local remoteBlacklist =
    loadRemoteTable(
        "BlacklistedWords.lua",
        {}
    )

for word, enabled in pairs(remoteBlacklist) do
    if enabled then
        local normalized = normalize(word)

        if normalized then
            sessionBlacklist[normalized] = true
        end
    end
end

----------------------------------------------------------------
-- CARGAR BANCO DE PALABRAS QUE TERMINAN EN X
----------------------------------------------------------------

local xWords =
    loadRemoteTable(
        "XWords.lua",
        {}
    )

----------------------------------------------------------------
-- API
----------------------------------------------------------------

function WordMemory.normalize(word)
    return normalize(word)
end

function WordMemory.isBlacklisted(word)
    local normalized = normalize(word)

    if not normalized then
        return false
    end

    return sessionBlacklist[normalized] == true
end

function WordMemory.markFailed(word)
    local normalized = normalize(word)

    if not normalized then
        return false
    end

    if sessionBlacklist[normalized] then
        return false
    end

    sessionBlacklist[normalized] = true
    newBlacklist[normalized] = true

    warn(
        "[AUTO WORD] BLACKLIST +",
        normalized
    )

    return true
end

function WordMemory.filter(words)
    local result = {}

    for _, word in ipairs(words or {}) do
        local normalized = normalize(word)

        if normalized
            and not sessionBlacklist[normalized] then

            table.insert(result, word)
        end
    end

    return result
end

function WordMemory.getXWords(prefix)
    prefix = normalize(prefix) or ""

    local result = {}

    for _, word in ipairs(xWords) do
        local normalized = normalize(word)

        if normalized
            and string.sub(normalized, -1) == "x"
            and not sessionBlacklist[normalized]
            and string.sub(normalized, 1, #prefix) == prefix then

            table.insert(result, normalized)
        end
    end

    return result
end

function WordMemory.getNextXWord(prefix)
    local candidates = WordMemory.getXWords(prefix)
    return candidates[1]
end

function WordMemory.getNewBlacklistedWords()
    local result = {}

    for word in pairs(newBlacklist) do
        table.insert(result, word)
    end

    table.sort(result)
    return result
end

function WordMemory.exportBlacklistLua()
    local all = {}

    for word in pairs(sessionBlacklist) do
        table.insert(all, word)
    end

    table.sort(all)

    local lines = {
        "-- Auto-generated blacklist",
        "return {",
    }

    for _, word in ipairs(all) do
        table.insert(
            lines,
            string.format("    [%q] = true,", word)
        )
    end

    table.insert(lines, "}")

    return table.concat(lines, "\n")
end

print(
    "[AUTO WORD] WordMemory cargado | blacklist:",
    tostring(#WordMemory.getNewBlacklistedWords()),
    "nuevas esta sesión"
)

return WordMemory
