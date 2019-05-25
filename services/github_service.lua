local http = require("lib.http")
local config = require('config.app')
local cjson = require('cjson')

local _M = {}

function _M:get_access_token(args)
    local httpc = http.new()
    local body_params = 'client_id=' .. config.github.client_id .. '&client_secret=' .. config.github.client_secret .. '&code=' .. args.code .. '&redirect_uri=' .. config.github.redirect_uri
    local res, err = httpc:request_uri("https://github.com/login/oauth/access_token", {
        ssl_verify=false,
        method = "POST",
        body = body_params,
        headers = {
          ["Accept"] = "application/json",
        },
    })
    if not res then
        return nil, err
    end
    local data = cjson.decode(res.body)
    if not data.access_token then
        log(data)
        return nil, data.error
    end
    return data.access_token
end

function _M:get_userinfo(access_token)
    local httpc = http.new()
    local res, err = httpc:request_uri("https://api.github.com/user?access_token=" .. access_token, {
        ssl_verify=false,
    })
    if not res then
        return nil, err
    end
    local data = cjson.decode(res.body)
    return data, nil
end

function _M:get_emails(access_token)
    local httpc = http.new()
    local res, err = httpc:request_uri("https://api.github.com/user/emails?access_token=" .. access_token, {
        ssl_verify=false,
    })
    if not res then
        return nil, err
    end
    local data = cjson.decode(res.body)
    if #data > 0 then
        return data[1].email
    end
    return nil, res.body
end

return _M