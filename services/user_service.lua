local auth = require('lib.auth_service_provider')
local redis = require('lib.redis')

local _M = {}

function _M:verify_password(password, user_password)
    if hash(password) == user_password then
        return true
    end
    return false
end

function _M:notify(phone)
    -- you can send a message to message queue
    -- consider queue need a long live consumer but ngx.time_at not need
    return true
end

return _M
