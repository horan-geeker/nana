local cjson = require('cjson')
local conf = require('config.app')
local error_code = require('config.status')

local _M = {}

function _M:json(status, message, data, http_status)
	-- you can modify this resp struct as you favor
	local msg = message
	ngx.status = http_status or ngx.OK
	if msg == nil or msg == '' then
		local locale = ngx.ctx.locale or conf.locale
		if error_code[locale] ~= nil then
			msg = error_code[locale][status]
		end
	end
	local resp = {status=status, msg=msg, data=data}
	if not resp.status then
		resp.status = -1
		resp.message = 'not find status code'
	end
	ngx.say(cjson.encode(resp))
    ngx.exit(ngx.OK)
end

return _M
