local _M = {}

function _M:verifyCheckcode(checkcode)
    return true
end

function _M:notifyUser(login_id)
    -- you can send a message to message queue
    return true
end

return _M