--!nolint LocalShadow

local fs = require("@lune/fs")
local luau = require("@lune/luau")
local serde = require("@lune/serde")

local u = require("./util")

local types = require("./types")
local git = require("./git")

local types_str = require("./resources/types_str")

local SWITCH_DEFAULTS = {
    root = ".",
    -- if either below are nil, they will be joined to root
    config_file = "_ezpk.luau", -- e.g. default = "./_ezpk.luau"
    data_dir = "_ezpk_data",
}

export type SwitchOptions = {
    root: string?,
    config_file: string?,
    data_dir: string?,
    depth: number?, -- for print indentation
}

local function options_safe(opts_in: SwitchOptions)
    local root_tmp = u.null.default(opts_in.root, SWITCH_DEFAULTS.root)
    return {
        root = root_tmp,
        config_file = u.null.default(opts_in.config_file, u.path.join(root_tmp, SWITCH_DEFAULTS.config_file)),
        data_dir = u.null.default(opts_in.data_dir, u.path.join(root_tmp, SWITCH_DEFAULTS.data_dir)),
        depth = u.null.default(opts_in.depth, 0),
    }
end

local m_switch = {}

-- finds, executes, and validates config
function m_switch.gen_config(opts_in: SwitchOptions): (types.Config?, string?)
    local opts = options_safe(opts_in)

    local data_dir = opts.data_dir
    local config_file = opts.config_file

    if not fs.isFile(config_file) then
        return nil, "no file name '_ezpk.luau' found in dir"
    end

    -- clear dir, we re generate everything for now
    if fs.isDir(data_dir) then
        fs.removeDir(data_dir)
    end

    if not fs.isDir(data_dir) then
        fs.writeDir(data_dir)
        fs.writeFile(u.path.join(data_dir, "types.luau"), types_str)
    end

    print(config_file)
    local config_src = fs.readFile(config_file)
    local config_fn = function() end
    local ok, err = pcall(function()
        config_fn = luau.load(config_src, {
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
        return nil, `error loading _ezpk.luau: {err}`
    end

    local config: types.Config = {} :: types.Config
    local ok, err = pcall(function()
        config = config_fn()
    end)
    if not ok then
        return nil, `error executing ezpk file: {err}`
    end

    if config.deps == nil then
        config.deps = {}
    end

    return config
end

function m_switch.switch(opts_in: SwitchOptions)
    local opts = options_safe(opts_in)

    local data_dir = opts.data_dir
    local config, err = m_switch.gen_config(opts_in)
    if err ~= nil then
        error(err)
    end
    assert(config)

    local manifest = {
        deps = {},
    }

    for name, conf in config.deps do
        print(`{string.rep("  ", opts.depth)}installing {name}...`)
        local target_dir = u.path.join(data_dir, name)
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
                kind = "git",
            }
        elseif conf.path then
            local path = conf.path[1]
            if path == nil or typeof(path) ~= "string" then
                error(`dep '{name}' (kind path): arg [1] expected string, got {path}`)
            end

            path = u.path.expand_home(path)
            if not fs.isDir(path) then
                error(`dep '{name}' (kind path): path is not dir ({path})`)
            end
            if conf.path.copy then
                fs.copy(path, target_dir)
                manifest.deps[name] = {
                    root_dir = target_dir,
                    kind = "copy",
                }
            else
                manifest.deps[name] = {
                    root_dir = path,
                    kind = "path",
                }
            end
        end

        -- handle sub-dependencies
        for name, dep in manifest.deps do
            if not fs.isFile(u.path.join(dep.root_dir, "_ezpk.luau")) then
                continue -- not an ezpk project
            end

            local dep_data_dir = if dep.kind == "path" then nil else data_dir
            m_switch.switch({
                root = dep.root_dir,
                -- data_dir = dep_data_dir,
                depth = opts.depth + 1,
            })
        end
    end

    local manifest_str = serde.encode("json", manifest)
    fs.writeFile(u.path.join(data_dir, "manifest.json"), manifest_str)

    if config.actions and config.actions.post_switch then
        config.actions.post_switch(config, manifest)
    end
end

return m_switch
