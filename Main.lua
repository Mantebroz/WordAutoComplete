----------------------------------------------------------------
-- AUTO WORD MASTER V3 - BOOTSTRAP
-- Ensambla el script completo desde /parts y lo ejecuta.
----------------------------------------------------------------

local BASE =
    "https://raw.githubusercontent.com/Mantebroz/WordAutoComplete/main/"

local PART_COUNT = 6
local chunks = {}

for i = 1, PART_COUNT do
    local path =
        string.format(
            "parts/Main.part%02d",
            i
        )

    local ok, body =
        pcall(function()
            return game:HttpGet(
                BASE .. path,
                true
            )
        end)

    if not ok then
        error(
            "[AUTO WORD] No se pudo descargar "
            .. path
            .. ": "
            .. tostring(body)
        )
    end

    if type(body) ~= "string"
        or body == "" then

        error(
            "[AUTO WORD] Parte vacía: "
            .. path
        )
    end

    ------------------------------------------------------------
    -- Corrección del primer corte subido inicialmente:
    -- Main.part01 terminó con un 'true' duplicado respecto al
    -- comienzo de Main.part02. Se elimina antes de ensamblar.
    ------------------------------------------------------------

    if i == 1
        and body:sub(-4) == "true" then

        body = body:sub(1, -5)
    end

    chunks[i] = body

    print(
        "✓ Parte cargada:",
        i,
        "/",
        PART_COUNT,
        #body,
        "bytes"
    )
end

local source =
    table.concat(chunks)

print(
    "✓ AUTO WORD completo ensamblado:",
    #source,
    "bytes"
)

local compiler =
    loadstring or load

if type(compiler) ~= "function" then
    error(
        "[AUTO WORD] loadstring/load no disponible."
    )
end

local fn, compileError =
    compiler(
        source,
        "AutoWordMasterV3"
    )

if not fn then
    error(
        "[AUTO WORD] Error compilando Main: "
        .. tostring(compileError)
    )
end

print(
    "✓ AUTO WORD completo compilado"
)

return fn()
