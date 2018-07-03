local request = require('lib.request')
local validator = require('lib.validator')
local common = require('lib.common')
local user_service = require("services.user_service")
local config = require('config.app')

local _M = {}

function _M:handle()
    local args = request:all()
    local ok, msg =
        validator:check(
        args,
        {
            'sms_code'
        }
    )
    if not ok then
        common:response(0x000001, msg)
    end
    ok = user_service:verify_sms_code(args[config.login_id], args.sms_code)
    if not ok then
        common:response(0x010004)
    end
    return true
end

return _M