local request = require("lib.request")
local common = require("lib.common")
local User = require("models.user")
local validator = require("lib.validator")
local config = require("config.app")
local auth = require("providers.auth_service_provider")
local cjson = require("cjson")
local register = require("services.register_service")
local random = require("lib.random")

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
        -- login success
        auth:authorize(user)
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
    ok = register:verifyCheckcode(args.checkcode)
    if not ok then
        common:response(1, 'invalidate checkcode')
    end
    -- 检测是否重复
    ok = User:findByLoginId(args[config.login_id])
    if ok then
        common:response(1, 'login id duplicate')
    end
    -- 发送消息通知用户
    ok = register:notifyUser(args[config.login_id])
    if not ok then
        common:response(1, 'can not use this '..config.login_id)
    end
    -- 比较纠结的是你们会选择直接创建账户还是验证码激活,这里先直接创建吧
    local obj = {
        nickname=random.token(8),
        password=args.password
    }
    obj[config.login_id] = args[config.login_id]
    ok = User:create(obj)
    if not ok then
        common(2)
    end
    common:response(0)
end

function _M:userinfo()
    local ok,data = auth:user()
    if not ok then
        return common:response(1, data)
    end
    return common:response(0,'ok',data)
end

function _M:logout()
    local ok,err = auth:clear_token()
    if not ok then
        ngx.log(ngx.ERR, err)
    end
    return common:response(0)
end

return _M