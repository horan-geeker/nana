local response = require("lib.response")

local _M = {}

-- todo controller extends

function _M:show(id, request)
	return response:json(0, 'user args', {id = id, params = request.params})
end

function _M:userinfo(request)
	return response:json(0, 'request args', request.params)
end

return _M
