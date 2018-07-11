local request = require('lib.request')
local validator = require('lib.validator')
local common = require('lib.common')
local sms_service = require("services.sms_service")
local config = require('config.app')

local _M = {}

function _M:handle()
    local args = request:all()
    local ok, msg = validator:check(args,{'sms_code'})
    if not ok then
        common:response(0x000001, msg)
    end
    ok = sms_service:verify_sms_code(args[config.login_id], args.sms_code)
    if not ok then
        common:response(0x010004)
    end
    return true
end

return _M