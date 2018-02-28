local auth_service = require("providers.auth_service_provider")
local common = require("lib.common")
local _M = {}

function _M:handle()
    if not auth_service:check() then
        return false, 4, 'no authorized in authenticate'
    end
end

return _M