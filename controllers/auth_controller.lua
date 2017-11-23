local request = require("lib.request")
local common = require("lib.common")
local User = require("models.user")
local validator = require("lib.validator")
local config = require("config.app")
local auth_service = require("services.auth_service")
local cjson = require("cjson")

local _M = {}

function _M:login()

    local args = request:all()
    local ok,msg = validator:check(args, {
        config.login_id,
        'password'
        })
    
    if not ok then
        common:log('args not exit')
        common:response(1, msg)
    end

    local ok,user = User:verifyPassword(args[config.login_id],args.password)
    if not ok then
        -- login fail
        common:response(2, config.login_id..' or password error')
    else
        -- login success
        auth_service:authorize(user)
    end
    
    common:response(0)
    
end

function _M:logout()
    local ok,err = auth_service:clear_token()
    if not ok then
        ngx.log(ngx.ERR, err)
    end
    return common:response(0)
end

return _M