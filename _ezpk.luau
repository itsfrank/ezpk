local builtin = _G.builtin -- prevent lsp errors

return {
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
