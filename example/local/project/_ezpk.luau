local ezpk_types = require("./_ezpk_data/types")
local builtin: ezpk_types.Builtin = _G.builtin

local config: ezpk_types.Config = {
    actions = {
        post_switch = builtin.luaurc,
    },
    deps = {
        list_math = { path = { "../list_math", copy = true } },
    },
}
return config
