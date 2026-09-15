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
