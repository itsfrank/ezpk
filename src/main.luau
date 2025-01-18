--!nolint LocalShadow

local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local u = require("./util")

local types = require("./types")
local git = require("./git")
local switch = require("./switch")

local types_str = require("./resources/types_str")
local ezpk_str = require("./resources/ezpk_str")

local function make_cli()
    local frkcli = require("@frkcli/frkcli")
    local cli = frkcli.new_subcommands("ezpk", "a luau-based too for managing source-only project dependencies")

    -- init
    local sc_init = cli:add_subcommand("init", "initialize ezpk project in current directory")
    sc_init:add_positional("kind", {
        help = "the kind of project to intiialize",
        default = "luau",
    })
    sc_init:add_flag("force", { help = "delete and reset any existing ezpk files (use with care)" })

    -- switch
    local _sc_switch
    cli:add_subcommand("switch", "fetch dependencies and perform project setup")

    return cli
end

local state = {
    file = "_ezpk.luau",
    data_dir = "_ezpk_data",
    src = "",
    fn = function()
        error("no function loaded (this should not happen)")
    end,
    config = { deps = {} } :: types.Config,
}

function print_color(color: stdio.Color, msg: string)
    print(`{stdio.color(color)}{msg}{stdio.color("reset")}`)
end

-- TODO: change this to not abort when things exist, but layer defaults when missing
local function do_init(kind: string, force: boolean)
    if kind ~= "luau" then
        print_color("red", `'{kind}' is not a valid project kind`)
        process.exit(1)
    end

    if fs.isFile(state.file) then
        if not force then
            print(`aborting init: file '{state.file}' already exists, use --force to reset the project`)
            process.exit(1)
        else
            fs.removeFile(state.file)
        end
    end

    if fs.isDir(state.data_dir) then
        if not force then
            print(`aborting init: folder '{state.data_dir}' already exists, use --force to reset the project`)
            process.exit(1)
        else
            fs.removeDir(state.data_dir)
        end
    end

    print(`initializing {kind} project with ezpk`)
    fs.writeDir(state.data_dir)
    fs.writeFile(u.path.join(state.data_dir, "types.luau"), types_str)
    fs.writeFile("_ezpk.luau", ezpk_str.luau)
end

local function do_switch()
    switch.switch({ root = "." })
end

-- used to bootstrap the ezpk project itself
-- should minimally fetch deps without needing any
if process.args[1] == "bootstrap" then
    do_switch()
    process.exit()
end

local cli = make_cli()

local res, err = cli:parse(process.args)
if err ~= nil then
    print_color("red", `error parsing cli args: {err}`)
    process.exit(1)
end

if res.command == "switch" then
    do_switch()
elseif res.command == "init" then
    do_init(res.result.values.kind, res.result.flags.force)
else -- this should never happen, frkcli handles this but what are you gonna do
    print_color("red", `command '{res.command}' is not a valid command`)
    process.exit(1)
end
