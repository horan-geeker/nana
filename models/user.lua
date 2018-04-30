local Model = require("models.model")
local config = require("config.app")
local common = require("lib.common")

local User = Model:new(config.user_table_name)

function User:verifyPassword(login_id,password)
    local user = User:where(config.login_id,"=",login_id):where("password","=",common:hash(password)):first()
    if not user then
    	return false
    else
    	return true,user
    end
end

function User:findByLoginId(login_id)
    local user = User:where(config.login_id,"=",login_id):first()
    if not user then
    	return false
    else
    	return true, user
    end
end

return User