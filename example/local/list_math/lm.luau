local add = require("@add/add")
local sub = require("@sub/sub")

local m_lm = {}

function m_lm.add(a: { number }, b: { number }): { number }
    local res = {}
    local max = math.max(#a, #b)
    for i = 1, max do
        local v_a = if a[i] then a[i] else 0
        local v_b = if b[i] then b[i] else 0
        res[i] = add(v_a, v_b)
    end
    return res
end

function m_lm.sub(a: { number }, b: { number }): { number }
    local res = {}
    local max = math.max(#a, #b)
    for i = 1, max do
        local v_a = if a[i] then a[i] else 0
        local v_b = if b[i] then b[i] else 0
        res[i] = sub(v_a, v_b)
    end
    return res
end

return m_lm
