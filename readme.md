# ezpk

A source-only tool to manage dependencies, currently mainly for Luau, but
there's no reason it can't work for other languages as well.

## Why did I build this?

I had two major gripes with the current offerings in the luau ecosystem:

1. I want to be able to consume projects that don't use my package manager of
choice without having to fork them or upload them to a registry
    - e.g. by simply pointing to their repo (and maybe performing some
    post-fetch work)
2. I want my dependency management tool to set aliases in my project's
`.luaurc` file

If existing tools provided this, I would not have taken the time to build my own.

## What should we expect from this project?

To be perfectly honest, I'm not too sure. For now, I will be using it for my
projects but if the community consolidates around something else that addresses
my concerns, I will probably abandon it.

Thankfully, there's no reason for it to stop working, it doesnt rely on any
hosting or registry, as long as git hosting services exist, it will keep
working (similar to the Go ecosystem).

## Fine, how does it work

**If you know Lua/Luau you already know how to use ezpk!**

An ezpk config is a single file called `_ezpk.luau` that returns a table (the
config)

```luau
return {
    deps = {
        CoolLib = {
            git = { "https://github.com/user/cool-lib" },
        },
    },
}
```

Running `> ezpk switch` in a directory with an `_ezpk.luau` file will fetch
your dependencies and set up your project. By default, all ezpk does is fecth
your dependencies into a folder called `_ezpk_data` (gitignore this folder!).

But frank, what about `.luaurc`? Isn't that the whole point? Oh yeah! Well we
have access to the power of Luau! And ezpk let's you leverage it!

```luau
return {
    actions = {
        post_switch = function(_conig, _manifest) -- ignore these params for now
            print("I get executed once all dependencies have been fetched!")
        end,
    },
    deps = {
        CoolLib = {
            git = { "https://github.com/user/cool-lib" },
        },
    },
}
```

So I have to implement the luaurc feature myself!?!? Of course not (but you could!), ezpk comes
with useful builtins like `builtin.luaurc` which does exactly what you expect.

```luau
return {
    actions = {
        post_switch = builtin.luaurc
    },
    deps = {
        CoolLib = {
            git = { "https://github.com/user/cool-lib" },
        },
    },
}
```

With this, after running `> ezpk switch` your `.luaurc` would have its aliases object look like this:

```json
...
  "aliases": {
    "CoolLib": "_ezpk_data/CoolLib",
  }
...
```

the luaurc builtin is smart enough to keep any manually defined aliases yhat
are already in there (although it's currently not smart enough to understand
json5, so dont use any comments).

That's kind of it, you should be able to use ezpk to manage standalone luau
dependencies, I will document more about ezpk later, but for now, the
`_ezpk.luau` files from my projects should make good examples.

- this project: [_ezpk.luau](./_ezpk.luau)
- frkcli: [_ezpk.luau](https://github.com/itsfrank/frkcli/blob/main/_ezpk.luau)
