local cjson = require('cjson')
local conf = require('config.app')
local User = require('models.user')
local validator = require('lib.validator')
local request = require("lib.request")
local common = require("lib.common")

local _M = {}

function _M:index()
	local args = request:all() -- get all args
	common:response(0,'request args', args)
end

return _M
