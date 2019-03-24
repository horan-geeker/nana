-- Github Document: https://github.com/horan-geeker/nana
-- Author:          hejunwei
-- Version:         v0.3.0

local Core = {}

function Core:bootstrap()
    -- get helper function
    require('lib.helpers'):init(_G)
    -- dispatche route to controller
    require("lib.dispatcher"):run()
end

Core:bootstrap()