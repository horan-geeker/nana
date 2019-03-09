local Model = require("lib.model")
local config = require("config.app")

local attributes = {'id', 'name', 'phone', 'email', 'password', 'avatar', 'created_at', 'updated_at'}
local hidden = {'password', 'phone'}

local User = Model:new(config.user_table_name, attributes, hidden)

return User