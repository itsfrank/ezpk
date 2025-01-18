local ezpk_types = require("./_ezpk_data/types")
local builtin: ezpk_types.Builtin = _G.builtin

local config: ezpk_types.Config = {
    actions = {
        post_switch = builtin.luaurc,
    },
    deps = {
        ezpk = { git = { "https://github.com/itsfrank/ezpk.git" } },
    },
}
return config
