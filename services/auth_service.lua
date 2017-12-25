local random = require("lib.random")
local common = require("lib.common")
local config = require("config.app")
local cjson = require("cjson")
local redis = require("lib.redis")
local cookie_obj = require("lib.cookie")

local _M = {}
local token_name = 'token'
local cookie, err = cookie_obj:new()
local cookie_payload = {
    key = token_name, value = ''
}
if config.time_zone == 'beijing' then
    cookie_payload.expires = ngx.cookie_time(ngx.time() + config.session_lifetime + 8 * 3600)
else
    cookie_payload.expires = ngx.cookie_time(ngx.time() + config.session_lifetime)
end

function generate_token(user_payload)
    return random.token(40)..common.hash(user_payload);
end

local function set_cookie(token)
    if not cookie then
        ngx.log(ngx.ERR, err)
        return false
    end
    cookie_payload.value = token
    local ok, err = cookie:set(cookie_payload)
    if not ok then
        ngx.log(ngx.ERR, err)
        return false
    end
    return true
end

local function get_token_from_cookie()
    if not cookie then
        ngx.log(ngx.ERR, err)
        return false
    end
    return cookie:get(token_name)
end

function _M:authorize(user)
    token = generate_token(user[config.login_id]..user.id)
    local ok,err = redis:set(token_name..':'..token, cjson.encode(user), config.session_lifetime*60)
    if not ok then
        ngx.log(ngx.ERR, 'cannot set redis key, error_msg:'..err)
    end
    set_cookie(token)
end

function _M:check()
    local token = get_token_from_cookie()
    if not token then
        return false
    end
    local session = redis:get(token_name..':'..token)
    if not session then
        return false
    end
    return true, token
end

function _M:token_refresh()
    local token = get_token_from_cookie()
    local ok,err = set_cookie(token)
    if not ok then
        return false, err
    end
    ok,err = redis:expire(token_name..':'..token, config.session_lifetime * 60)
    if not ok then
        return false, err
    end
    return true
end

function _M:clear_token()
    local token = get_token_from_cookie()
    local ok,err = cookie:set({key = token_name, value='',expires=ngx.cookie_time(ngx.time()-1)})
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
    local token = get_token_from_cookie()
    if not token then
        ngx.log(ngx.ERR, 'token not in cookie')
    end
    local userinfo = redis:get(token_name..':'..token)
    return cjson.decode(userinfo)
end

return _M