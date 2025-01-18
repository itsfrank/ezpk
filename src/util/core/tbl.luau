--- utilisites for tables
local m_tbl = {}

--- if not a table, returns as-is
function m_tbl.clone_deep<T>(t: T): T
    if type(t) ~= "table" then
        return t
    end
    assert(typeof(t) == "table")
    local r = table.clone(t)

    for k, v in r do
        if typeof(v) == "table" then
            r[k] = m_tbl.clone_deep(v)
        end
    end
    return r
end

function m_tbl.apply_if_nil<T, U>(dst: T, to_apply: U): T | U
    assert(type(dst) == "table")
    assert(type(to_apply) == "table")
    for k, v in to_apply do
        if dst[k] == nil then
            dst[k] = m_tbl.clone_deep(v)
        end
    end
    return dst
end

return m_tbl
