-- optional, typecheck your config!
local ezpk_types = require("./_ezpk_data/types")
local builtin: ezpk_types.Builtin = _G.builtin

local config: ezpk_types.Config = {
    actions = {
        post_switch = builtin.luaurc,
    },
    deps = {
        frktest_git = {
            git = { "https://github.com/itsfrank/frktest", rev = "main" },
            _luaurc = { append_alias = "src" },
        },
        frktest_path = {
            path = { "~/dev/frktest" },
            _luaurc = { append_alias = "src" },
        },
        frktest_copy = {
            path = { "~/dev/frktest", copy = true },
            _luaurc = { append_alias = "src" },
        },
    },
}

return config
