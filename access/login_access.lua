local validator = require("lib.validator")
local common = require("lib.common")
local request = ngx.req.get_uri_args()
local ok,msg = validator:check({
    'login_id',
    'password'
},request)
if not ok then
	ngx.say(msg)
    ngx.log(ngx.ERR,"access not exit")
    ngx.exit(ngx.OK)
end
