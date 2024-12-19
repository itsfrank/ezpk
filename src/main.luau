--!nolint LocalShadow

local process = require("@lune/process")
local luau = require("@lune/luau")
local fs = require("@lune/fs")

local config = {
    file = "_ezpk.luau",
    data_dir = "_ezpk_data",
    src = "",
    fn = function()
        error("no function loaded (this should not happen)")
    end,
    config = {},
}

if not fs.isFile(config.file) then
    error("no file name '_ezpk.luau' found in dir")
end

config.src = fs.readFile(config.file)
local ok, err = pcall(function()
    config.fn = luau.load(config.src)
end)
if not ok then
    error(`error loading _ezpk.luau: {err}`)
end

local ok, err = pcall(function()
    config.config = config.fn()
end)
if not ok then
    error(`error executing ezpk file: {err}`)
end
