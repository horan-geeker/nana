local request = require('lib.request')
local validator = require('lib.validator')
local common = require('lib.common')
local sms_service = require("services.sms_service")
local config = require('config.app')
local auth = require('lib.auth_service_provider')

local _M = {}

function _M:handle()
    local args = request:all()
    local ok, msg = validator:check(args,{'sms_code'})
    if not ok then
        common:response(0x000001, msg)
    end
    local user = auth:user()
    if not user then
        common:response(0x00000C)
    end
    ok = sms_service:verify_sms_code(user.phone, args.sms_code)
    if not ok then
        common:response(0x010004)
    end
    return true
end

return _M