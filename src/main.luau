--!nolint LocalShadow

local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")

local types = require("./types")
local git = require("./git")
local u_path = require("./util/path")

local types_str = require("./resources/types_str")
local ezpk_str = require("./resources/ezpk_str")

local frkcli = require("@frkcli/frkcli")

local function make_cli()
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
    fs.writeFile(u_path.join(state.data_dir, "types.luau"), types_str)
    fs.writeFile("_ezpk.luau", ezpk_str.luau)
end

local function do_switch()
    if not fs.isFile(state.file) then
        error("no file name '_ezpk.luau' found in dir")
    end

    -- clear dir, we re generate everything for now
    if fs.isDir(state.data_dir) then
        fs.removeDir(state.data_dir)
    end

    if not fs.isDir(state.data_dir) then
        fs.writeDir(state.data_dir)
        fs.writeFile(u_path.join(state.data_dir, "types.luau"), types_str)
    end

    state.src = fs.readFile(state.file)
    local ok, err = pcall(function()
        state.fn = luau.load(state.src, {
            environment = {
                builtin = require("./builtin"),
                _G = {
                    builtin = require("./builtin"),
                },
            },
            injectGlobals = true,
        })
    end)
    if not ok then
        error(`error loading _ezpk.luau: {err}`)
    end

    local ok, err = pcall(function()
        state.config = state.fn()
    end)
    if not ok then
        error(`error executing ezpk file: {err}`)
    end

    if state.config.deps == nil then
        state.config.deps = {}
    end

    local manifest = {
        deps = {},
    }

    for name, conf in state.config.deps do
        print(`installing {name}...`)
        local target_dir = u_path.join(state.data_dir, name)
        if conf.git then
            local uri = conf.git[1]
            if uri == nil or typeof(uri) ~= "string" then
                error(`dep '{name}' (kind path): arg [1] expected string, got {uri}`)
            end
            local err: string? = nil
            if conf.git.branch then
                err = git.clone(uri, target_dir, { branch = conf.git.branch, del_history = true })
            elseif conf.git.rev then
                err = git.clone(uri, target_dir, { rev = conf.git.rev, del_history = true })
            else
                err = git.clone(uri, target_dir, { del_history = true })
            end
            if err then
                error(err)
            end
            manifest.deps[name] = {
                root_dir = target_dir,
            }
        elseif conf.path then
            local path = conf.path[1]
            if path == nil or typeof(path) ~= "string" then
                error(`dep '{name}' (kind path): arg [1] expected string, got {path}`)
            end

            path = u_path.expand_home(path)
            if not fs.isDir(path) then
                error(`dep '{name}' (kind path): path is not dir ({path})`)
            end
            if conf.path.copy then
                fs.copy(path, target_dir)
                manifest.deps[name] = {
                    root_dir = target_dir,
                }
            else
                manifest.deps[name] = {
                    root_dir = path,
                }
            end
        end
    end

    local manifest_str = serde.encode("json", manifest)
    fs.writeFile(u_path.join(state.data_dir, "manifest.json"), manifest_str)

    if state.config.actions and state.config.actions.post_switch then
        state.config.actions.post_switch(state.config, manifest)
    end
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
