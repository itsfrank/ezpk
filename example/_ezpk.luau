return {
    run = {
        build = function()
            print("hello world")
        end,
        test = function()
            print("hello world")
        end,
    },
    actions = {
        pre_switch = function(_) end,
        post_switch = function(_) end,
        pre_fetch_each = function(_) end,
        post_fetch_each = function(_) end,
    },
    deps = {
        frktest = {
            git = { "itsfrank/frktst", rev = "main" },
            actions = {
                pre_fetch = function() end,
                post_fetch = function() end,
            },
        },
    },
}
