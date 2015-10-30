local grinDir = shell.resolve("/"..fs.combine(fs.getDir(shell.getRunningProgram()), ".."))

local grinPackagePath = "/" .. fs.combine(grinDir, "packages/Team-CC-Corp/Grin/")
local grinInstallPath = "/" .. fs.combine(grinPackagePath, "1.2.3")
shell.run("pastebin", "run", "VuBNx3va", "-u", "Team-CC-Corp", "-r", "Grin", "-t", "1.2.3", grinInstallPath)
local githubApiResponse = assert(http.get("https://api.github.com/repos/Team-CC-Corp/Grin/releases"))
assert(githubApiResponse.getResponseCode() == 200, "Failed github response")
local fh = fs.open(fs.combine(grinPackagePath, "releases.json"), "w")
fh.write(githubApiResponse.readAll())
fh.close()

shell.run(fs.combine(grinDir, "bin/grin-startup.lua"))

print("It is recommended that your startup file run grin/bin/grin-startup.lua")
