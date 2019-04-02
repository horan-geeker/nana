-- Github Document: https://github.com/horan-geeker/nana
-- Author:          hejunwei
-- Version:         v0.4.0

local Core = {}

function Core:bootstrap()
    -- get helper function
    require('lib.helpers'):init(_G)
    -- run application
    require("lib.application"):init():run()
end

Core:bootstrap()