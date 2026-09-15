----------------------------------------------------------------
-- LEGACY ENTRYPOINT / COMPATIBILITY LOADER
-- Mantiene funcionando el loadstring viejo que apunta a este archivo.
----------------------------------------------------------------

local url =
    "https://raw.githubusercontent.com/Mantebroz/WordAutoComplete/main/Main.lua"

local ok, source =
    pcall(function()
        return game:HttpGet(
            url,
            true
        )
    end)

if not ok then
    error(
        "[AUTO WORD] No se pudo descargar Main.lua: "
        .. tostring(source)
    )
end

if type(source) ~= "string"
    or source == "" then

    error(
        "[AUTO WORD] Main.lua llegó vacío."
    )
end

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
        "Main.lua"
    )

if not fn then
    error(
        "[AUTO WORD] Error compilando Main.lua: "
        .. tostring(compileError)
    )
end

print(
    "✓ Entrypoint cargado: Main.lua"
)

return fn()
