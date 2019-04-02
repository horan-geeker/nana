local random = require("lib.random")
local config = require("config.app")
local cjson = require("cjson")
local redis = require("lib.redis")
local cookie_obj = require("lib.cookie")
local response = require('lib.response')

local _M = {}
local token_name = 'token'

function generate_token(user_payload)
    -- 防止猜测token内容，加上随机数
    return random.token(40);
end

function _M:authorize(user)
    token = generate_token(user['phone']..user.id)
    local ok,err = redis:set(token_name..':'..token, cjson.encode(user), config.session_lifetime*60)
    if not ok then
        log('cannot set redis key, error_msg:'..err)
        return false, err
    end
    local ok, err = set_cookie(token_name, token, get_local_time() + config.session_lifetime)
    if not ok then
        return false, err
    end
    return true
end

function _M:check()
    local token = get_cookie(token_name)
    if not token then
        return false, 'cookie not exist'
    end
    local session = redis:get(token_name..':'..token)
    if session == nil then
        return false
    end
    return true, token
end

function _M:token_refresh()
    local token = get_cookie(token_name)
    local token_ttl = redis:ttl(token_name..':'..token)
    if token_ttl < config.session_refresh_time then
        local ok,err = set_cookie(token_name, token) -- @todo add refresh token in cookie?
        if not ok then
            return false, err
        end
        ok,err = redis:expire(token_name..':'..token, config.session_lifetime * 60)
        if not ok then
            return false, err
        end
    end
    return true
end

function _M:clear_token()
    local token = get_cookie(token_name)
    if not token then
        return false, 'cookie not exist'
    end
    local ok,err = set_cookie(token_name, '', get_local_time() - 1)
    if not ok then
        return false, err
    end
    local ok,err = redis:del(token_name..':'..token)
    if not ok then
        return false, err
    end
    return true
end

function _M:user()
    local token = get_cookie(token_name)
    if not token or token == '' then
        return nil
    end
    local userinfo = redis:get(token_name..':'..token)
    if not userinfo then
        return nil
    end
    return cjson.decode(userinfo)
end

return _M