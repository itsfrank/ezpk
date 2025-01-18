local m_path = {}

m_path.sep = "/"

function m_path.join(...: string): string
    local res = ""
    for _, e in { ... } do
        if e:len() == 0 or e == m_path.sep then
            continue
        end
        if res:len() > 0 and e:sub(1, 1) ~= m_path.sep then
            res ..= m_path.sep
        end
        if e:sub(-1) == m_path.sep then
            e = e:sub(1, -2)
        end
        res ..= e
    end
    return res
end

--- expands '~' into the env var $HOME if it's first char
function m_path.expand_home(path)
    local lune_process = require("@lune/process")
    local home = lune_process.env["HOME"]
    if string.sub(path, 1, 1) == "~" then
        if home then
            return home .. string.sub(path, 2)
        end
    end
    return path
end

return m_path
