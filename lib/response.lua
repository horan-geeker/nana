local cjson = require('cjson')
local conf = require('config.app')
local error_code = require('config.status')

local _M = {}

function _M:json(status, message, data, http_status)
	-- you can modify this resp struct as you favor
	local msg = message
	local response_status = http_status or ngx.OK
	if msg == nil or msg == '' then
		local locale = ngx.ctx.locale or conf.locale
		if error_code[locale] ~= nil then
			msg = error_code[locale][status]
		end
	end
	local response = {status=status, msg=msg, data=data}
	if not response.status then
		response.status = -1
		response.message = 'not find status code'
	end
	return cjson.encode(response), response_status
end

-- server error
function _M:error(error_message)
	ngx.log(ngx.ERR, error_message)
	ngx.exit(500)
end

return _M
