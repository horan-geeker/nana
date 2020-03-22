local response = require('lib.response')
local auth = require("services.auth_service")
local User = require("models.user")

local _M = {}

function _M:show(id)
    local user = User:find(id)
    if not user then
        return response:json(0x01000B)
    end
    return response:json(0, '', user)
end

function _M:userinfo()
    local user = auth:user()
    return response:json(0, 'ok', user)
end

return _M