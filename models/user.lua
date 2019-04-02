local Model = require("lib.model")

local attributes = {'id', 'name', 'phone', 'email', 'password', 'avatar', 'created_at', 'updated_at'}
local hidden = {'password', 'phone'}

local User = Model:new('users', attributes, hidden)

return User