local cjson = require('cjson')
local conf = require('config.app')
local status_code = require('config.status')

local _M = {}

function _M:remove_slash(target)
	len = string.len(target)
	if string.find(target,'/', len) then
		return string.sub(target, 1, len-1)
	end
	return target
end

function _M:hash(password)
	return ngx.md5(password)
end

function _M:response(status, msg, data)
	local resp = {status=status_code.init_code, msg=msg, data=data}
	if status == status_code.ok then
		resp.status=0
		resp.msg='ok'
	elseif status == status_code.validate_error then
		resp.status=1
	elseif status == status_code.data_not_found then
		resp.status=2
	elseif status == status_code.password_error then
		resp.status=3
	elseif status == status_code.no_authorization then
		resp.status=4
	end
	if resp.status == status_code.init_code then
		resp.msg = 'not find status code'
	end
    ngx.say(cjson.encode(resp))
    ngx.exit(ngx.OK)
end

function _M:log(...)
	local arg = {}
	if #{...}>1 then
		arg = {...}
	else
		arg = ...
	end
	if conf.env == 'dev' then
		ngx.log(ngx.ERR, cjson.encode(arg))
	end
end

return _M
