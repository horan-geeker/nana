local response = require('lib.response')
local User = require('models.user')
local validator = require('lib.validator')
local auth_service = require('services.auth_service')
local ngx = ngx

local _M = {}

function _M:login(request)
    local args = request.params
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
    if args.password then
        local ok, err = auth_service:verify_password(args.password, user.password)
        if not ok then
            -- login fail
            return response:json(0x010002, err)
        end
    else
        return response:json(0x000001, 'need password')
    end
    -- login success
    auth_service:authorize(user)
    return response:json(0, 'ok', user)
end

function _M:register(request)
    local args = request.params
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
    -- check if repeat
    local user = User:where('phone', '=', args.phone):first()
    if user then
        return response:json(0x010001)
    end
    local name = args.name
    if name == nil or name == '' then
        -- if dont have nickname, make up with a part of phone
        local phone_len = string.len(args.phone)
        local hidden_phone_len = math.floor(phone_len * 0.4)
        name = string.sub(args.phone, 1, hidden_phone_len - 1) ..
            string.rep('*', hidden_phone_len) ..
            string.sub(args.phone, phone_len - hidden_phone_len + 1, phone_len)
    end

    local user_obj = {
        name = name,
        password = ngx.md5(args.password),
        phone = args.phone
    }

    local ok = User:create(user_obj)
    if not ok then
        return response:json(0x000005)
    end
    local user = User:where('phone', '=', args.phone):first()
    if not user then
        return response:json(0x010001)
    end
    auth_service:authorize(user)
    return response:json(0, 'ok', user)
end

function _M:logout()
    local ok, err = auth_service:clear_token()
    if not ok then
        ngx.log(ngx.ERR, err)
        return response:json(0x00000A)
    end
    return response:json(0)
end

function _M:reset_password(request)
    local args = request.params
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
    local user = auth_service:user()
    local password = args.old_password
    ok = auth_service:verify_password(args.old_password, user.password)
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
    ok, err = auth_service:clear_token()
    if not ok then
        return response:json(0x010006)
    end
    return response:json(0)
end

function _M:forget_password(request)
    local args = request.params
    local ok, msg = validator:check(args, {
        'phone',
        'new_password'
        })
    if not ok then
        return response:json(0x000001, msg)
    end
    local affected_rows, err = User:where('phone', '=', args.phone):update({
        password = ngx.md5(args.new_password)
    })
    if not affected_rows then
        return response:json(0x010006)
    end
    if affected_rows ~= 1 then
        return response:json(0x010009)
    end
    return response:json(0)
end

return _M
