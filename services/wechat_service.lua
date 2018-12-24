local config = require("env")
local http = require('lib.http')
local cjson = require('cjson')

local _M = {}

function _M:web_login(code, state)
    local res, err, data = _M:get_access_token(code, state)
    local res, err, data = _M:get_userinfo(data.access_token, data.openid)
    
end

function _M:get_access_token(code, state)
    local url = 'https://api.weixin.qq.com/sns/oauth2/access_token?appid=' .. config.wechat.web.app_id ..'&secret=' .. config.wechat.web.secret .. '&code=' .. code .. '&grant_type=authorization_code'
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {ssl_verify=false})
    if not res then
        ngx.log(ngx.ERR, res, err)
        return res, err
    end
    local data = cjson.decode(res.body)
    ngx.log(ngx.ERR, res.body)
    return res, err, data
end

function _M:get_userinfo(access_token, openid)
    local url = 'https://api.weixin.qq.com/sns/userinfo?access_token=' .. access_token .. '&openid=' .. openid
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {ssl_verify=false})
    if not res then
        ngx.log(ngx.ERR, res, err)
        return res, err
    end
    local data = cjson.decode(res.body)
    ngx.log(ngx.ERR, res.body)
    return res, err, data
end

return _M