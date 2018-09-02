local cjson = require('cjson')
local conf = require('config.app')
local error_code = require('config.status')

local _M = {}

function _M:json(status, message, data)
	-- you can modify this resp struct as you favor
	local msg = message
	if message == nil or message == '' then
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
