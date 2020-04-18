local response = require("lib.response")

local _M = {}

-- todo controller extends

function _M:index(request)
	return response:json(0, 'user index', request.params)
end

function _M:show(id)
	return response:json(0, 'user show', id)
end

function _M:update(id)
	return response:json(0, 'user update', id)
end

function _M:store(request)
	return response:json(0, 'user store', request)
end

function _M:delete(id)
	return response:json(0, 'user delete', id)
end

function _M:posts(user_id)
	return response:json(0, 'user posts', user_id)
end

function _M:post_detail(user_id, post_id)
	return response:json(0, 'user posts id', {user_id = user_id,post_id = post_id})
end

return _M
