-- optional, typecheck your config!
local ezpk_types = require("./_ezpk_data/types")
local builtin: ezpk_types.Builtin = _G.builtin

local config: ezpk_types.Config = {
    actions = {
        post_switch = builtin.luaurc,
    },
    deps = {
        frkcli = {
            git = { "https://github.com/itsfrank/frkcli" },
            _luaurc = { append_alias = "src" },
        },
    },
}
return config
