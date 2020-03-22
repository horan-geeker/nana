local redis = require("lib.resty_redis")
local env = require('env')

local _M = setmetatable({}, {__index=function(self, key)
	local red = redis:new()
	local ok,err = red:connect(env.redis.host, env.redis.port)
	if not ok then
		ngx.log(ngx.ERR, err)
	end
	if key == 'red' then
		return red
	end
end})

function _M:set(key, value, time)
	local ok, err = self.red:set(key, value)
	if not ok then
	    return false, "redis failed to set data: " .. err
	end
	if time then
		ok,err = self.red:expire(key, time) -- default expire time is seconds
		if not ok then
			return false,err
		end
	end
	return true
end

function _M:get(key)
	local value = self.red:get(key)
	if value == ngx.null then
		return nil
	else
		return value
	end
end

function _M:del(key)
	return self.red:del(key)
end

function _M:expire(key, time)
	local ok,err = self.red:expire(key, time) -- default time is seconds
	if not ok then
		return false,err
	end
	return true
end

function _M:incr(key)
	local ok,err = self.red:incr(key)
	if not ok then
		return false, err
	end
	return true
end

function _M:ttl(key)
	return self.red:ttl(key)
end

return _M