local request = require('lib.request')
local response = require('lib.response')
local validator = require('lib.validator')
local auth = require("providers.auth_service_provider")
local User = require("models.user")
local config = require("config.app")
local user_service = require('services.user_service')

local _M = {}

function _M:count()
    response:json(0, 'show', User:count())
end

function _M:top()
    response:json(0, 'comments', table_remove(User:orderby('created_at', 'desc'):get(5), {'password', 'phone'}))
end

function _M:userinfo()
    local user = auth:user()
    return response:json(0, 'ok', table_remove(user, {'password'}))
end

return _M