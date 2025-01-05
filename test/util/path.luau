local frktest = require("@frktest/init")

local test = frktest.test
local check = frktest.assert.check

local path = require("@src/util/path")

return function()
    test.suite("utils > path.join", function()
        local testcases = {
            {
                name = "basic",
                input = { "a", "b", "c" },
                exp = "a/b/c",
            },
            {
                name = "trailing slash",
                input = { "a/", "b/", "c" },
                exp = "a/b/c",
            },
            {
                name = "leading slash",
                input = { "a", "/b", "/c" },
                exp = "a/b/c",
            },
            {
                name = "all slash",
                input = { "a/", "/b/", "/c" },
                exp = "a/b/c",
            },
        }
        for _, tt in testcases do
            test.case(tt.name, function()
                local got = path.join(table.unpack(tt.input))
                check.equal(tt.exp, got)
            end)
        end
    end)
end
