local lm = require("@list_math/lm")

local a = { 10, 20, 30 }
local b = { 1, 2, 3 }

local function l_to_str(l: { number })
    local str = "{ "
    for _, v in l do
        str ..= `{v}, `
    end
    str ..= "}"
    return str
end

print("arrs:")
print("  ", l_to_str(a))
print("  ", l_to_str(b))
print()
print("a+b = ", l_to_str(lm.add(a, b)))
print("a-b = ", l_to_str(lm.sub(a, b)))
