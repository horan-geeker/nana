local auth_service = require("lib.auth_service_provider")
local _M = {}

function _M:handle()
    if not auth_service:check() then
        return false, 0x000004, '未登录'
    end
end

return _M