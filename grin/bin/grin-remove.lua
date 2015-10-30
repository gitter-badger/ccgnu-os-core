local argparse = grin.getPackageAPI("Team-CC-Corp/Grin", "argparse")

local parser = argparse.new()
parser
    :argument"package"
local options = parser:parse({}, ...)
if not options then
    return
end
grin.assert(options.package, "Usage: grin-remove <user>/<repo>[/<tag>]", 0)

shell.run("rm", "/"..grin.combine(grin.getGrinDir(), "packages", options.package))
grin.refreshPath(shell)