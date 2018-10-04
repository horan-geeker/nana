local request = require('lib.request')
local response = require('lib.response')
local validator = require('lib.validator')
local auth = require("providers.auth_service_provider")
local User = require("models.user")
local config = require("config.app")
local user_service = require('services.user_service')

local _M = {}

function _M:show(user_id)
    response:json(0, 'show', {user_id=user_id})
end

function _M:comments(user_id, comment_id)
    response:json(0, 'comments', {user_id=user_id, comment_id=comment_id})
end

function _M:userinfo()
    local user = auth:user()
    return response:json(0, 'ok', table_remove(user, {'password'}))
end

return _M