local validator = require("lib.validator")
local request = require("lib.request")
local ok,msg = validator:check({
    'login_id',
    'password'
},request)

if not ok then
	ngx.say(msg)
end