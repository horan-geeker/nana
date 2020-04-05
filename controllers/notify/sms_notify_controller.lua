local response = require('lib.response')
local validator = require('lib.validator')
local sms_service = require('services.sms_service')
local request = require('lib.request')
local auth = require('lib.auth_service_provider')

local _M = {}

function _M:guest_send_sms()
    local args = request:all()
    local ok, err =
        validator:check(
        args,
        {
            'phone'
        }
    )
    if not ok then
        return response:json(1, err)
    end
    local res = sms_service:send_sms(args['phone'])
    if res ~= true then
        return response:json(res)
    end
    return response:json(0)
end

function _M:user_send_sms()
    local user = auth:user()
    local res = sms_service:send_sms(user.phone)
    if res ~= true then
        return response:json(res)
    end
    return response:json(0)
end

return _M