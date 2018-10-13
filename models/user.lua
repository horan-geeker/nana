local Model = require("models.model")
local config = require("config.app")
-- local Post = require('models.post')

local attributes = {'id', 'name', 'phone', 'email', 'password', 'avatar', 'created_at', 'updated_at'}
local hidden = {'password', 'phone'}

local User = Model:new(config.user_table_name, attributes, hidden)

function User:new()
    return User
end

-- @todo: loop or previous error loading module
-- function User:post()
--     return User:hasMany(Post:new(), 'id', 'post_id')
-- end

return User