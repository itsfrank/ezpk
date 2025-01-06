--!nolint LocalShadow

local luau = require("@lune/luau")
local serde = require("@lune/serde")
local fs = require("@lune/fs")

local types = require("./types")

local git = require("./git")
local u_path = require("./util/path")

local state = {
    file = "_ezpk.luau",
    data_dir = "_ezpk_data",
    src = "",
    fn = function()
        error("no function loaded (this should not happen)")
    end,
    config = { deps = {} } :: types.Config,
}

if not fs.isFile(state.file) then
    error("no file name '_ezpk.luau' found in dir")
end

-- clear dir, we re generate everything for now
if fs.isDir(state.data_dir) then
    fs.removeDir(state.data_dir)
end

if not fs.isDir(state.data_dir) then
    fs.writeDir(state.data_dir)
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
