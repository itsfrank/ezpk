local fs = require("@lune/fs")
local process = require("@lune/process")

local u = require("./util")
local ul = require("./util/lune")

local m_git = {}

function m_git.clone(
    uri: string,
    dir: string,
    opts: {
        branch: string?,
        rev: string?,
        del_history: boolean?,
    }
): string?
    if fs.isFile(dir) then
        return `existing non-dir file at target path: '{dir}'`
    end
    if not fs.isDir(dir) then
        fs.writeDir(dir)
    end

    local args = { "clone", "--depth", "1" }
    if opts.branch then
        table.insert(args, "--branch")
        table.insert(args, opts.branch)
    end
    table.insert(args, uri)
    table.insert(args, ".")
    local res = process.spawn("git", args, { cwd = dir })
    if not res.ok then
        print(res.stdout)
        print(res.stderr)
        return
    end

    if opts.rev then
        process.spawn("git", { "checkout", opts.rev }, { cwd = dir })
    end

    if opts.del_history then
        local dot_git = u.path.join(dir, ".git")
        ul.fs.rm(dot_git)
    end

    return nil
end

return m_git
