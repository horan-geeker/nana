local response = require("lib.response")

local _M = {}

-- todo controller extends

function _M:index(request)
	return response:json(0, 'request args', request.params)
end

return _M
