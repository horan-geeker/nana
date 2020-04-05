local Model = require("lib.model")
-- local Post = require('models.post')

local attributes = {'id', 'name', 'phone', 'email', 'password', 'avatar', 'created_at', 'updated_at'}
local hidden = {'password', 'phone'}

local User = Model:new('users', attributes, hidden)

-- @todo: loop or previous error loading module
-- function User:post()
--     return User:hasMany(Post:new(), 'id', 'post_id')
-- end

return User