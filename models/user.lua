local Model = require("lib.model")

local User = Model:new('users')

function User:verifyPassword(login_id,password)
    local user = User:where("name","=",login_id):where("password","=",password):get()
    if not user then
    	return false
    else
    	return true,user
    end
end

return User