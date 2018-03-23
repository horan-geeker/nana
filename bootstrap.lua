-- github document https://github.com/horan-geeker/nana
-- author hejunwei

local router = require("router")
--get helper function
require("lib.helpers")
-- get env config
env = require('env')

local _M = {}

function _M:run()
    router:init()
end

_M:run()