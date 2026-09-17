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

----------------------------------------------------------------
-- FAST TYPING / TURN PACING PROFILE
-- Añade margen al comienzo del turno para que la respuesta no
-- arranque de forma instantánea. El ritmo de teclas sigue rápido.
-- No añade lógica de evasión/anti-cheat ni errores falsos.
----------------------------------------------------------------

local timingReplacements = {
    { "local START_DELAY_MIN = 0.055", "local START_DELAY_MIN = 0.420" },
    { "local START_DELAY_MAX = 0.105", "local START_DELAY_MAX = 0.780" },
    { "local RETRY_START_DELAY_MIN = 0.025", "local RETRY_START_DELAY_MIN = 0.140" },
    { "local RETRY_START_DELAY_MAX = 0.055", "local RETRY_START_DELAY_MAX = 0.240" },
    { "local MIN_KEY_DELAY = 0.038", "local MIN_KEY_DELAY = 0.070" },
    { "local MAX_KEY_DELAY = 0.072", "local MAX_KEY_DELAY = 0.125" },
    { "local MIN_SUBMIT_DELAY = 0.085", "local MIN_SUBMIT_DELAY = 0.100" },
    { "local MAX_SUBMIT_DELAY = 0.150", "local MAX_SUBMIT_DELAY = 0.180" },
    { "local MIN_CLEAR_DELAY = 0.035", "local MIN_CLEAR_DELAY = 0.055" },
    { "local MAX_CLEAR_DELAY = 0.060", "local MAX_CLEAR_DELAY = 0.095" },
    { "local CLEAR_SETTLE_DELAY = 0.085", "local CLEAR_SETTLE_DELAY = 0.120" },
    { "0.045,\n0.080", "0.140,\n0.240" },
}

for _, replacement in ipairs(timingReplacements) do
    source = source:gsub(
        replacement[1],
        replacement[2],
        1
    )
end

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
