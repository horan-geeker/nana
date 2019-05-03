local router = require('lib.router')
local request = require('lib.request')
local database = require('lib.database')

local _M = {}

function _M:init(G)
    -- init helper function
    require('lib.helpers'):init(G)
    -- init route
    router:init()
    return self
end

function _M:run()
    -- match route, dispatch request to action
    local http_response, http_status = router:run()
    -- do some thing after run action
    self:terminate(request:all(), response_content)
    -- dispatch route to controller
    require('lib.response'):send(http_response, http_status)
end

function _M:terminate(request, resposne)
    database:close()
end

return _M