local request = require("lib.request")
local response = require("lib.response")
local Post = require('models.post')

local _M = {}

function _M:index()
	local args = request:all() -- get all args
	local posts = Post:where('deleted_at', 'is', 'null'):with('tag'):get()
	response:json(0, 'request args', posts)
end

return _M
