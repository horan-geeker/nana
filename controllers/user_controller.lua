local request = require('lib.request')
local common = require('lib.common')
local validator = require('lib.validator')
local auth = require("providers.auth_service_provider")
local User = require("models.user")
local config = require("config.app")
local user_service = require('services.user_service')

local _M = {}

function _M:show(user_id)
    ngx.log(ngx.ERR, user_id, comment_id)
    common:response(0, 'show', {user_id=user_id, comment_id=comment_id})
end

function _M:comments(user_id, comment_id)
    ngx.log(ngx.ERR, user_id, comment_id)
    common:response(0, 'comments', {user_id=user_id, comment_id=comment_id})
end

function _M:userinfo()
    local ok,data = auth:user()
    if not ok then
        return common:response(0x010008, data)
    end
    return common:response(0,'ok',data)
end

return _M