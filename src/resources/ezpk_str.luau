-- should be the same contents at the adjacent types.luau
return {
    luau = [[
local ezpk_types = require("./_ezpk_data/types")
local builtin: ezpk_types.Builtin = _G.builtin

local config: ezpk_types.Config = {
    actions = {
        post_switch = builtin.luaurc,
    },
    deps = {},
}
return config
]],
}
