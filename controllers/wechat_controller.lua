local wechat_service = require('services.wechat_service')
local validator = require("lib.validator")
local request = require("lib.request")
local common = require("lib.common")

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
    
    ok,msg = wechat_service:web_login(args.code, args.state)
    if not ok then
        common:response(ok, msg)
    end

    common:response(0)
end

function _M:get_userinfo()
    local res, msg = wechat_service:get_userinfo()
end

return _M