
return {
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
