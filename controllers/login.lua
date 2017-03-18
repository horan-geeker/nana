local request = require("lib.request")
local common = require("lib.common")
local redis = require("models.redis")
local Model = require("models.model")
local validator = require("lib.validator")
local request = ngx.req.get_uri_args()

local password = redis:get(request.login_id)

if not password then
	local User = Model:new('users')
	local user = User:where("username","=",request.login_id):where("password","=",request.password):get()
	
	if not user then
		common:response('user not exists')
	else
		local ok,msg = redis:set(request.login_id,request.password)
	end
else
	if password ~= request.password then
		common:response('password error')
	end
end
common:response('login success')
