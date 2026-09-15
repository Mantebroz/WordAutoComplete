local ReplicatedStorage = game:GetService("ReplicatedStorage")

----------------------------------------------------------------
-- WORD MEMORY LOADER
----------------------------------------------------------------

local RAW_BASE =
    "https://raw.githubusercontent.com/Mantebroz/WordAutoComplete/main/"

local function httpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)

    if ok and type(result) == "string" then
        return result
    end

    local HttpService = game:GetService("HttpService")

    local okHttp, body = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if okHttp and type(body) == "string" then
        return body
    end

    return nil
end

local function loadRemoteModule(fileName)
    local source = httpGet(RAW_BASE .. fileName)

    if not source then
        warn("[AUTO WORD] No se pudo descargar " .. fileName)
        return nil
    end

    local compiler = loadstring or load

    if type(compiler) ~= "function" then
        warn("[AUTO WORD] loadstring/load no disponible")
        return nil
    end

    local chunk, compileError = compiler(source)

    if not chunk then
        warn("[AUTO WORD] Error compilando " .. fileName .. ":", compileError)
        return nil
    end

    local ok, result = pcall(chunk)

    if not ok then
        warn("[AUTO WORD] Error ejecutando " .. fileName .. ":", result)
        return nil
    end

    return result
end

local WordMemory =
    loadRemoteModule("WordMemory.lua")

if WordMemory then
    local environment

    if type(getgenv) == "function" then
        environment = getgenv()
    else
        environment = _G
    end

    environment.WordAutoCompleteMemory = WordMemory

    print("✓ WordMemory cargado")
else
    warn("[AUTO WORD] WordMemory no disponible")
end

----------------------------------------------------------------
-- EVENT MODULE PATCH
-- No depende de _G.import
----------------------------------------------------------------

local function loadEventModule()

    ------------------------------------------------------------
    -- RUTA REAL EN EL JUEGO
    ------------------------------------------------------------

    local services =
        ReplicatedStorage:FindFirstChild(
            "Services"
        )

    local communication =
        services
        and services:FindFirstChild(
            "Communication"
        )

    local eventModule =
        communication
        and communication:FindFirstChild(
            "event"
        )

    ------------------------------------------------------------
    -- INTENTO DIRECTO
    ------------------------------------------------------------

    if eventModule
        and eventModule:IsA(
            "ModuleScript"
        ) then

        local ok, result =
            pcall(
                require,
                eventModule
            )

        if ok
            and type(result)
                == "table"
            and type(
                result.fire
            ) == "function" then

            print(
                "✓ EVENT MODULE:",
                eventModule:GetFullName()
            )

            return result
        end

        warn(
            "[AUTO WORD] Falló require directo:",
            result
        )
    end

    ------------------------------------------------------------
    -- FALLBACK:
    -- BUSCAR CUALQUIER ModuleScript LLAMADO event
    ------------------------------------------------------------

    for _, object in ipairs(
        ReplicatedStorage:GetDescendants()
    ) do

        if object:IsA(
            "ModuleScript"
        )
            and string.lower(
                object.Name
            ) == "event" then

            local ok, result =
                pcall(
                    require,
                    object
                )

            if ok
                and type(result)
                    == "table"
                and type(
                    result.fire
                ) == "function" then

                print(
                    "✓ EVENT MODULE fallback:",
                    object:GetFullName()
                )

                return result
            end
        end
    end

    return nil
end


local Event =
    loadEventModule()

if not Event then

    error(
        "[AUTO WORD] No encontré/cargué el módulo event."
    )
end


print(
    "✓ Event.fire:",
    type(Event.fire)
)

print(
    "✓ Event.remoteFire:",
    type(Event.remoteFire)
)

print(
    "✓ Event.remoteConnect:",
    type(Event.remoteConnect)
)
