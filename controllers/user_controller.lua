local request = require('lib.request')
local response = require('lib.response')
local validator = require('lib.validator')
local auth = require("lib.auth_service_provider")
local User = require("models.user")
local Post = require("models.post")
local Comment = require("models.comment")
local config = require("config.app")
local user_service = require('services.user_service')

local _M = {}

function _M:count()
    response:json(0, 'show', User:count())
end

function _M:top()
    response:json(0, 'top', table_remove(User:orderby('created_at', 'desc'):get(5), {'password', 'phone'}))
end

function _M:show(id)
    local user = User:find(id)
    if not user then
        return response:json(0x010009)
    end
    return response:json(0, 'ok', table_remove(user, {'password'}))
end

function _M:userinfo()
    local user = auth:user()
    return response:json(0, 'ok', table_remove(user, {'password'}))
end

function _M:posts(user_id)
    local posts = Post:where('deleted_at', 'is', 'null'):where('user_id', '=', user_id):get()
    return response:json(0, 'ok', posts)
end

function _M:comments(user_id)
    local comments = Comment:where('user_id', '=', user_id):with('post'):get()
    return response:json(0, 'ok', comments)
end

return _M