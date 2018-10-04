local request = require('lib.request')
local response = require('lib.response')
local User = require('models.user')
local AccountLog = require('models.account_log')
local validator = require('lib.validator')
local config = require('config.app')
local auth = require('providers.auth_service_provider')
local cjson = require('cjson')
local user_service = require('services.user_service')
local random = require('lib.random')
local env = require('env')
local random = require('lib.random')
local redis = require('lib.redis')
local sms_service = require('services.sms_service')

local _M = {}

function _M:login()
    local args = request:all()
    local ok, msg =
        validator:check(
        args,
        {
            'phone',
        }
    )
    if not ok then
        response:json(0x000001, msg)
    end
    local user = User:where('phone', '=', args.phone):first()
    if not user then
        response:json(0x010003)
    end
    if args.smscode then
        ok = user_service:verify_checkcode(args.phone, args.smscode)
        if not ok then
            response:json(0x000001, 'invalidate sms code')
        else
            user_service:authorize(user)
        end
    elseif args.password then
        ok, err = user_service:verify_password(args.password, user.password)
        if not ok then
            -- login fail
            response:json(0x010002)
        else
            ok, err = user_service:authorize(user)
            if not ok then
                -- @todo should render only error message
                response:json(0x000001, err)
            end
        end
    else
        response:json(0x000001, 'need sms or password')
    end
    
    response:json(0, 'ok', table_remove(user, {'password'}))
end

function _M:register()
    local args = request:all()
    local ok, msg =
        validator:check(
        args,
        {
            config.login_id,
            'password',
        }
    )
    if not ok then
        response:json(0x000001, msg)
    end
    -- 检测是否重复
    ok = User:find_by_login_id(args[config.login_id])
    if ok then
        response:json(0x010001)
    end

    local user_obj = {
        name = args[config.login_id],
        password = hash(args.password)
    }
    user_obj[config.login_id] = args[config.login_id]
    ok = User:create(user_obj)
    if not ok then
        response:json(0x000005)
    end
    local user = User:where('phone', '=', args.phone):first()
    response:json(0, 'ok', table_remove(user, {'password'}))
end

function _M:logout()
    local ok, err = auth:clear_token()
    if not ok then
        ngx.log(ngx.ERR, err)
        response:json(0x00000A)
    end
    return response:json(0)
end

function _M:reset_password()
    local args = request:all()
    local ok, msg = validator:check(args, {
        'old_password',
        'new_password'
        })
    if not ok then
        response:json(0x000001, msg)
    end
    if args.old_password == args.new_password then
        response:json(0x010007)
    end
    local user = auth:user()
    local password = args.old_password
    ok = user_service:verify_password(args.old_password, user.password)
    if not ok then
        -- password error
        response:json(0x010005)
    end
    local ok, err = User:where('id', '=', user.id):update({
        password=hash(args.new_password)
    })
    if not ok then
        response:json(0x000005)
    end
    ok, err = auth:clear_token()
    if not ok then
        response:json(0x010006)
    end
    response:json(0)
end

-- use sms verify
function _M:forget_password()
    local args = request:all()
    local ok, msg = validator:check(args, {
        'phone',
        'new_password'
        })
    if not ok then
        response:json(0x000001, msg)
    end
    local user = auth:user()
    local ok, err = User:where('phone', '=', args.phone):update({
        password=hash(args.new_password)
    })
    if not ok then
        ngx.log(ngx.ERR, err)
        response:json(0x010006)
    end
    response:json(0)
end

return _M
