local _M = {}

function _M:init()
    return self
end

function _M:run()
    require('lib.router'):init()
end

return _M