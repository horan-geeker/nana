local common = require("lib.common")
local redis = require("lib.resty_redis")

local _M = {}

function _M:set(key, value, time)
	local red = redis:new()
	local ok, err = red:set(key, value)
	if not ok then
	    return common:response("redis failed to set data: " )
	end
	if time then
		ok,err = red:expire(key, time) -- default expire time is seconds
		if not ok then
			return false,err
		end
	end
	return true
end

function _M:get(key)
	local red = redis:new()
	return red:get(key)
end

function _M:del(key)
	local red = redis:new()
	return red:del(key)
end

function _M:expire(key, time)
	local red = redis:new()
	local ok,err = red:expire(key, time) -- default time is seconds
	if not ok then
		return false,err
	end
	return true
end

function _M:incr(key)
	local red = redis:new()
	local ok,err = red:incr(key)
	if not ok then
		return false, err
	end
	return true
end

return _M