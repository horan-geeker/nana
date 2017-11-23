local validator = require("lib.validator")
local common = require("lib.common")
local request = require("lib.request")
local config = require("config.app")

local args = request:all()
local ok,msg = validator:check(args, {
	config.login_id,
	'password'
	})

if not ok then
	common:log('args not exit')
	common:response(1, msg)
end
