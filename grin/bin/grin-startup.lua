local grinDir = shell.resolve("/"..fs.combine(fs.getDir(shell.getRunningProgram()), ".."))

if grin then
    os.unloadAPI("grin")
end
assert(os.loadAPI(fs.combine(grinDir, "lib/grin")), "Failed to load Grin API")

if json then
    os.unloadAPI("json")
end
local jsonAPIPath = grin.combine(grinDir, "packages/Team-CC-Corp/Grin/1.2.3/lib/json")
assert(os.loadAPI(jsonAPIPath), "Failed to load JSON API") -- grin requires a minimum of the json API

grin.setGrinDir(grinDir)
grin.refreshPath(shell)
grin.refreshHelpPath()

local startupFunctions = {}
grin.forEach(function(pkg, pkgDir)
    local jsonData = grin.getPackageGrinJSON(pkg)
    local startup
    if jsonData and jsonData.startup then
        startup = grin.getFromPackage(pkg, jsonData.startup)
    else
        startup = grin.resolveInPackage(pkg, "startup")
    end
    if startup then
        table.insert(startupFunctions, function()
            shell.run(startup)
        end)
    end
end)

if #startupFunctions > 0 then
    parallel.waitForAll(unpack(startupFunctions))
end