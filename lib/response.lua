local cjson = require('cjson')
local conf = require('config.app')
local error_code = require('config.status')
local ngx = ngx

local _M = {}

function _M:json(status, message, data, http_status)
	-- you can modify this response struct as you favor
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
	return {
		status = response_status,
		headers = {content_type = 'application/json; charset=UTF-8'},
		body = cjson.encode(response)
	}
end


function _M:raw(http_status, http_body)
	return {
		status = http_status,
		headers = {},
		body = http_body
	}
end


function _M:error(http_status, http_headers, http_body)
	return {
		status = http_status,
		headers = http_headers,
		body = http_body
	}
end


function _M:send(response)
	ngx.status = response.status
	for name, value in pairs(response.headers) do
		ngx.header[name] = value
	end
    if response.body ~= nil then
        ngx.say(response.body)
	end
end


return _M
