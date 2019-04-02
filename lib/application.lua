local _M = {}

function _M:init()
    return self
end

function _M:run()
    -- dispatche route to controller
    require('lib.router'):init()
end

return _M