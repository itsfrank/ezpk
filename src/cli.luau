local frkcli = require("@frkcli/frkcli")
local process = require("@lune/process")

local cli = frkcli.new("ezpk", "Easy Package Manager")

cli:addPositional("command", {
    help = "A positional arg",
})

cli:addPositional("p2", {
    help = "A positional arg, that is optional",
    required = false,
    default = "hello",
})

cli:addFlag("foo", {
    aliases = { "-f" },
})

cli:addOption("opt", {
    help = "an option",
})
cli:addOption("optopt", {
    help = "an optional option",
    required = false,
    default = "goodbye",
})

local parsed, err = cli:parse(process.args)

if err ~= nil then
    print(`error while parsing args: {err}`)
    process.exit(1)
end
assert(parsed)

for k, v in parsed.values do
    print(`[{k}]: {v}`)
end
for k, v in parsed.flags do
    print(`[{k}]: {v}`)
end
