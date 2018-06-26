-- github document https://github.com/horan-geeker/nana
-- author hejunwei

local router = require('router')
--get helper function
require('lib.helpers')

local _M = {}

function _M:run()
    router:init()
end

_M:run()
