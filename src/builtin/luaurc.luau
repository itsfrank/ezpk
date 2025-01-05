local fs = require("@lune/fs")
local serde = require("@lune/serde")

local u_path = require("../util/path")

local types = require("../types")

type Luaurc = {
    aliases: { [string]: string }?,
    _ezpk_alias: { string }?,
}

local m_luaurc = {}

function m_luaurc.append_aliases(config: types.Config, manifest: types.Manifest)
    local luaurc: Luaurc = {}
    if fs.isFile(".luaurc") then
        local luaurc_src = fs.readFile(".luaurc")
        local luaurc_data = serde.decode("json", luaurc_src)
        if luaurc_data ~= nil then
            luaurc = luaurc_data
        end
    end

    if luaurc._ezpk_alias and luaurc.aliases then
        for _, name in luaurc._ezpk_alias do
            luaurc.aliases[name] = nil
        end
    end

    if luaurc.aliases == nil then
        luaurc.aliases = {}
    end

    luaurc._ezpk_alias = {}
    assert(luaurc._ezpk_alias ~= nil)
    assert(luaurc.aliases ~= nil)

    for name, data in manifest.deps do
        local path = data.root_dir
        local dep_config: any = config.deps[name]
        if dep_config and dep_config._luaurc and dep_config._luaurc.append_alias then
            path = u_path.join(path, dep_config._luaurc.append_alias)
        end
        luaurc.aliases[name] = path
        table.insert(luaurc._ezpk_alias, name)
    end

    local luaurc_out = serde.encode("json", luaurc, true)
    fs.writeFile(".luaurc", luaurc_out)
end

return m_luaurc
