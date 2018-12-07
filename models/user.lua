local Model = require("models.model")
local Post = require('models.post')
local config = require("config.app")

local attributes = {'id', 'name', 'phone', 'email', 'password', 'avatar', 'created_at', 'updated_at'}
local hidden = {'password', 'phone'}

local User = Model:new(config.user_table_name, attributes, hidden)

function User:posts()
    return User:has_many(Post, 'user_id', 'id')
end

return User