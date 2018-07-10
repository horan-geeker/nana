local common = require('lib.common')
local validator = require('lib.validator')
local random = require('lib.random')
local config = require('config.app')
local sms_service = require('services.sms_service')
local request = require('lib.request')
local auth = require('providers.auth_service_provider')

local _M = {}

function _M:guest_send_sms()
    local args = request:all()
    local ok, err =
        validator:check(
        args,
        {
            config.login_id
        }
    )
    if not ok then
        common:response(1, err)
    end
    local res = sms_service:sendSMS(args['phone'])
    if res ~= true then
        common:response(res)
    end
    common:response(0)
end

function _M:user_send_sms()
    local user = auth:user()
    local res = sms_service:sendSMS(user.phone)
    if res ~= true then
        common:response(res)
    end
    common:response(0)
end

return _M