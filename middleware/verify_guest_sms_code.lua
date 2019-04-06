local request = require('lib.request')
local validator = require('lib.validator')
local response = require('lib.response')
local sms_service = require("services.sms_service")

local _M = {}

function _M:handle()
    local args = request:all()
    local ok, msg = validator:check(args,{'sms_code', 'phone'})
    if not ok then
        return false, response:json(0x000001, msg)
    end
    ok = sms_service:verify_sms_code(args['phone'], args.sms_code)
    if not ok then
        return false, response:json(0x010004)
    end
    return true
end

return _M