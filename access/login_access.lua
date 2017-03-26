local validator = require("lib.validator")
local common = require("lib.common")
local request = require("lib.request")

local args = request:all()
local ok,msg = validator:check({
	'login_id',
	'password'
	},args)

if not ok then
	ngx.say(msg)
	ngx.log(ngx.ERR,"args not exit")
	ngx.exit(ngx.OK)
end
