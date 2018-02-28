local cjson = require('cjson')
local conf = require('config.app')
local status_code = require('config.status')

local _M = {}

function _M:purge_uri(uri)
	local uri = string.gsub(uri, "?.*", "")
	local uri_without_slash = _M:remove_slash(uri)
	return uri_without_slash
end

function _M:remove_slash(target)
	local len = string.len(target)
	if string.find(target,'/', len) then
		return string.sub(target, 1, len-1)
	end
	return target
end

function _M:hash(password)
	return ngx.md5(password)
end

function _M:response(status, message, data)
	-- you can modify this resp struct as you favor
	local msg = message or status_code[status]
	local resp = {status=status, msg=msg, data=data}
	if not resp.status then
		resp.status = -1
		resp.message = 'not find status code'
	end
    ngx.say(cjson.encode(resp))
    ngx.exit(ngx.OK)
end

function _M:log(...)
	local args = {}
	if #{...}>1 then
		args = {...}
	else
		args = ...
	end
	if conf.env == 'dev' then
		ngx.log(ngx.WARN, cjson.encode(args))
	end
end

return _M
