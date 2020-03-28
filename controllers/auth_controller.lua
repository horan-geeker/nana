local response = require("lib.response")

local _M = {}

-- todo controller extends

function _M:login(request)
	return response:json(0, 'auth login', request.params)
end

function _M:register(request)
	return response:json(0, 'request args', request.params)
end

function _M:forget_password(request)
	return response:json(0, 'request args', request.params)
end

function _M:reset_password()
	-- body
end

return _M
