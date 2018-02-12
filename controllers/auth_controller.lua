local request = require("lib.request")
local common = require("lib.common")
local User = require("models.user")
local AccountLog = require("models.account_log")
local validator = require("lib.validator")
local config = require("config.app")
local auth = require("providers.auth_service_provider")
local cjson = require("cjson")
local user_service = require("services.user_service")
local random = require("lib.random")
local ipLocation = require("lib.ip_location")

local _M = {}

function _M:login()
    -- request.bar(request.foo('hi'))
    local args = request:all()
    local ok,msg = validator:check(args, {
        config.login_id,
        'password'
        })
    if not ok then
        common:response(1, msg)
    end
    local ok,user = User:verifyPassword(args[config.login_id],args.password)
    if not ok then
        -- login fail
        common:response(2, config.login_id..' or password error')
    else
        user_service:authorize(user)
    end
    common:response(0, 'ok', user)
    
end

function _M:register()
    local args = request:all()
    local ok,msg = validator:check(args, {
        config.login_id,
        'password',
        'checkcode'
        })
    if not ok then
        common:response(1, msg)
    end
    -- 先校验验证码
    ok = user_service:verifyCheckcode(args.checkcode)
    if not ok then
        common:response(1, 'invalidate checkcode')
    end
    -- 检测是否重复
    ok = User:findByLoginId(args[config.login_id])
    if ok then
        common:response(1, 'login id duplicate')
    end
    -- 发送消息通知用户
    ok = user_service:notify(args[config.login_id])
    if not ok then
        common:response(1, 'can not use this '..config.login_id)
    end
    -- 比较纠结的是你们会选择直接创建账户还是验证码激活,这里先直接创建吧
    local obj = {
        nickname=random.token(8),
        password=common:hash(args.password)
    }
    obj[config.login_id] = args[config.login_id]
    ok = User:create(obj)
    if not ok then
        common(2)
    end
    common:response(0)
end

function _M:logout()
    local ok,err = auth:clear_token()
    if not ok then
        ngx.log(ngx.ERR, err)
    end
    return common:response(0)
end

function _M:getCaptcha()
    
end

return _M