local common = require("lib.common")
local redis = require("lib.resty_redis")
local _M = {}

function _M:set(key,value,expire)
	local red = redis:new()
	local ok, err = red:set(key, value)
	if not ok then
	    return common:response("redis failed to set data: " )
	end
	if expire then
		red:expire(key, expire * 60) -- default expire is minutes
	end
	return 0,'success'
end

function _M:get(key)
	local red = redis:new()
	return red:get(key)
end

function _M:del(key)
	local red = redis:new()
	return red:del(key)
end

return _M