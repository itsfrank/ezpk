local m_null = {}

function m_null.default<T>(a: T?, default: T): T
    if a == nil then
        return default
    end
    return a
end

return m_null
