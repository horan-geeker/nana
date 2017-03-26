local request = require("lib.request")
local common = require("lib.common")
local redis = require("models.redis")
local User = require("models.user")
local validator = require("lib.validator")

local args = request:all()
local password = redis:get(args.login_id)

if not password then
	local ok,user = User:verifyPassword(args.login_id,args.password)
	if not ok then
		common:response('user not exists')
	else
		local ok,msg = redis:set(args.login_id,args.password)
	end
else
	if password ~= args.password then
		common:response('password error')
	end
end
common:response('login success')
