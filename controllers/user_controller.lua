local request = require('lib.request')
local response = require('lib.response')
local validator = require('lib.validator')
local auth = require("providers.auth_service_provider")
local User = require("models.user")
local Post = require("models.post")
local Comment = require("models.comment")
local config = require("config.app")
local user_service = require('services.user_service')

local _M = {}

function _M:userinfo()
    local user = auth:user()
    return response:json(0, 'ok', table_remove(user, {'password'})) -- hidden password field
end

return _M