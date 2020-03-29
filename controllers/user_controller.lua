local response = require("lib.response")

local _M = {}

-- todo controller extends

function _M:show(user_id, post_id, request)
	return response:json(0, 'user args', {user_id, post_id, request})
end

function _M:userinfo(request)
	return response:json(0, 'request args', request.params)
end

return _M
