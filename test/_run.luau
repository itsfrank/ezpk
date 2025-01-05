function load_tests()
    require("./util/path")()
end

function run_tests()
    local frktest = require("@frktest/init")
    local console_reporter = frktest.reporters.console_reporter

    console_reporter.init()
    local success = frktest.run()
    return success
end

load_tests()
local passed = run_tests()

if not passed then
    require("@lune/process").exit(1)
end
