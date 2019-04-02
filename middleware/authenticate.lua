local auth_service = require("lib.auth_service_provider")
local response = require("lib.response")

local _M = {}

function _M:handle()
    if not auth_service:check() then
        return false, response:json(0x000004, '未登录')
    end
    return true
end

return _M