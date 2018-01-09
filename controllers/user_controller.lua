local request = require('lib.request')
local common = require('lib.common')
local validator = require('lib.validator')
local auth = require("providers.auth_service_provider")
local User = require("models.user")
local config = require("config.app")

_M = {}

function _M:userinfo()
    local ok,data = auth:user()
    if not ok then
        return common:response(1, data)
    end
    return common:response(0,'ok',data)
end

function _M:resetPassword()
    local args = request:all()
    local ok, msg = validator:check(args, {
        'old_password',
        'new_password'
        })
    if not ok then
        common:response(1, msg)
    end
    if args.old_password == args.new_password then
        common:response(1, 'old password can not equal to new password')
    end
    local ok,user = auth:user()
    local password = args.old_password
    local ok,user = User:verifyPassword(user[config.login_id],password)
    if not ok then
        -- login fail
        common:response(2, config.login_id..' or password error')
    else
        local ok, err = User:where('id', '=', user.id):update({
            password=common:hash(args.new_password)
        })
        if not ok then
            common:response(5)
        end
    end
    common:response(0)
end

return _M