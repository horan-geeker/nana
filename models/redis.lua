local common = require("lib.common")
local redis = require("lib.redis")
local _M = {}

function _M:set(key,value)
	local red = redis:new()
	local ok, err = red:set(key, value)
	if not ok then
	    return common:response("redis failed to set data: " )
	end
	return 0,'success'
end 

function _M:get(key)
	local red = redis:new()
	return red:get(key)
end

return _M