-- github document https://github.com/horan-geeker/nana
-- author hejunwei

local Core = {}

function Core:bootstrap()
    --get helper function
    require('lib.helpers'):init(_G)
    require("lib.application"):init():run()
end

Core:bootstrap()