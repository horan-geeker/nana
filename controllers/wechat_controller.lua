local wechat_service = require('services.wechat_service')
local validator = require("lib.validator")
local request = require("lib.request")
local common = require("lib.common")
local config = require("config.app")
local user_service = require("services.user_service")
local cjson = require("cjson")

local _M = {}

function _M:webLogin()
    local args = request:all()
    local ok,msg = validator:check(args, {
        'code',
        'state'
        })
    if not ok then
        common:response(1, msg)
    end
    
    local ok, msg, user = wechat_service:web_login(args.code, args.state)
    if not ok then
        common:response(ok, msg)
    end
    user_service:authorize(user)
    ngx.redirect(config.app_url)
end

function _M:get_userinfo()
    local res, msg = wechat_service:get_userinfo()
end

return _M