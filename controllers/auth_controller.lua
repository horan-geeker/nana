local request = require('lib.request')
local response = require('lib.response')
local User = require('models.user')
local validator = require('lib.validator')
local auth = require('lib.auth_service_provider')
local user_service = require('services.user_service')
local sms_service = require('services.sms_service')
local helpers = require("lib.helpers")
local table_remove = helpers.table_remove

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
        return response:json(0x000001, msg)
    end
    local user = User:where('phone', '=', args.phone):first()
    if not user then
        return response:json(0x010003)
    end
    if args.sms_code then
        local ok = sms_service:verify_sms_code(args.phone, args.sms_code)
        if not ok then
            return response:json(0x01000A)
        end
    elseif args.password then
        local ok, err = user_service:verify_password(args.password, user.password)
        if not ok then
            -- login fail
            return response:json(0x010002)
        end
    else
        return response:json(0x000001, 'need sms or password')
    end
    local ok, err = user_service:authorize(user)
    if not ok then
        -- @todo should render only error message
        return response:json(0x000001, err)
    end
    
    return response:json(0, 'ok', table_remove(user, {'password'}))
end

function _M:register()
    local args = request:all()
    local ok, msg =
        validator:check(
        args,
        {
            'phone',
            'password',
        }
    )
    if not ok then
        return response:json(0x000001, msg)
    end
    -- 检测是否重复
    local user = User:where('phone', '=', args.phone):first()
    if user then
        return response:json(0x010001)
    end
    local name = args.name
    if name == nil or name == '' then
        -- 如果没有昵称，拼接模糊手机号
        local phone_len = string.len(args.phone)
        local hidden_phone_len = math.floor(phone_len * 0.4)
        name = string.sub(args.phone, 1, hidden_phone_len - 1) .. string.rep('*', hidden_phone_len) .. string.sub(args.phone, phone_len - hidden_phone_len + 1, phone_len)
    end

    local user_obj = {
        name = name,
        password = ngx.md5(args.password),
        phone = args.phone
    }

    ok = User:create(user_obj)
    if not ok then
        return response:json(0x000005)
    end
    local user = User:where('phone', '=', args.phone):first()
    user_service:authorize(user)
    return response:json(0, 'ok', table_remove(user, {'password'}))
end

function _M:logout()
    local ok, err = auth:clear_token()
    if not ok then
        ngx.log(ngx.ERR, err)
        return response:json(0x00000A)
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
        return response:json(0x000001, msg)
    end
    if args.old_password == args.new_password then
        return response:json(0x010007)
    end
    local user = auth:user()
    local password = args.old_password
    ok = user_service:verify_password(args.old_password, user.password)
    if not ok then
        -- password error
        return response:json(0x010005)
    end
    local ok, err = User:where('id', '=', user.id):update({
        password=hash(args.new_password)
    })
    if not ok then
        return response:json(0x000005)
    end
    ok, err = auth:clear_token()
    if not ok then
        return response:json(0x010006)
    end
    return response:json(0)
end

-- @middleware: verify_guest_sms_code
function _M:forget_password()
    local args = request:all()
    local ok, msg = validator:check(args, {
        'phone',
        'new_password'
        })
    if not ok then
        return response:json(0x000001, msg)
    end
    local affected_rows, err = User:where('phone', '=', args.phone):update({
        password=hash(args.new_password)
    })
    if not affected_rows then
        ngx.log(ngx.ERR, err)
        return response:json(0x010006)
    end
    if affected_rows ~= 1 then
        return response:json(0x010009)
    end
    return response:json(0)
end

return _M
