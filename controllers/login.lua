local request = require("lib.request")
local common = require("lib.common")
local redis = require("models.redis")
local Model = require("models.model")

local password = redis:get(request.login_id)

if not password then
	local User = Model:new('users')
	local user = User:where("username","=",request.login_id):where("password","=",request.password):get()
	
	if not user then
		common:response('login error')
	else
		local ok,msg = redis:set(request.login_id,request.password)
	end
else
	if password ~= request.password then
		common:response('login error')
	end
end
ngx.say('login success')
