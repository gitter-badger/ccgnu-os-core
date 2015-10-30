local json = grin.getPackageAPI("Team-CC-Corp/Grin", "json")
local argparse = grin.getPackageAPI("Team-CC-Corp/Grin", "argparse")

local parser = argparse.new()
parser
    :argument"package"
local options = parser:parse({}, ...)
if not options then
    return
end
grin.assert(options.package, "Usage: grin-install <user>/<repo>[/<tag>]", 0)

local user, repo, tag = grin.packageNameComponents(options.package)
if grin.isPackageInstalled(grin.combine(user, repo, tag)) then
    print("Package already installed")
    return
end

local releaseInfo = grin.getReleaseInfoFromGithub(grin.combine(user, repo))
local release
if tag then
    for i,v in ipairs(releaseInfo) do
        if v.tag_name == tag then
            release = v
            break
        end
    end
    assert(release, "Tag not found " .. tag)
else
    release = assert(releaseInfo[1], "No releases found")
end

local grinPrg = grin.resolveInPackage("Team-CC-Corp/Grin", "grin")

local ok, err
parallel.waitForAny(function()
    ok, err = pcall(shell.run, grinPrg, "-e", "-u", user, "-r", repo, "-t", release.tag_name,
        grin.combine(grin.getGrinDir(), "packages", user, repo, release.tag_name))
end, function()
    while true do
        local e, s = os.pullEvent("grin_install_status")
        local x, y = term.getCursorPos()
        term.setCursorPos(1, y)
        term.clearLine()
        term.write(s)
    end
end)

assert(ok, err)
local x, y = term.getCursorPos()
term.setCursorPos(1, y)
term.clearLine()
print(options.package, " successfully downloaded")


local packageGrinData = grin.getPackageGrinJSON(grin.combine(user, repo, release.tag_name))
if packageGrinData and packageGrinData.dependencies then
    local tDep = {}
    if type(packageGrinData.dependencies) == "string" then
        for v in packageGrinData.dependencies:gmatch("[^:]+") do
            table.insert(tDep, v)
        end
    elseif type(packageGrinData.dependencies) == "table" then
        for i,v in ipairs(packageGrinData.dependencies) do
            table.insert(tDep, v)
        end
    end

    for i,v in ipairs(tDep) do
        shell.run("/"..shell.getRunningProgram(), v)
    end
end


grin.refreshPath(shell)
grin.refreshHelpPath()