local Model = require("models.model")
local config = require("config.app")
local common = require("lib.common")

-- local attributes = {'id', 'nickname', 'phone', 'email', 'password', 'avatar', 'created_at', 'updated_at'}

local User = Model:new(config.user_table_name)

function User:find_by_login_id(login_id)
    local user = User:where(config.login_id,"=",login_id):first()
    if not user then
    	return false
    else
    	return true, user
    end
end

return User