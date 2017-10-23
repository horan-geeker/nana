local cjson = require('cjson')
local conf = require('config.app')
local status_code = require('config.status')

local _M = {}

function _M:response(status, msg)
    local resp = {status=status_code.init_code, msg='not find status code'}
    if status == status_code.ok then
    	resp = {status=0, msg='ok'}
    elseif status == status_code.validate_error then
    	resp = {status=1, msg=msg}
    elseif status == status_code.data_not_found then
    	resp = {status=2, msg=msg}
    elseif status == status_code.password_error then
    	resp = {status=3, msg=msg}
    end
    ngx.say(cjson.encode(resp))
    ngx.exit(ngx.OK)
end

function _M:log(msg)
	if conf.env == 'dev' then
		ngx.log(ngx.ERR, msg)
	else
		ngx.log(ngx.WARN, msg)
	end
end

return _M
