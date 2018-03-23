local redis = require("lib.redis")
local config = require("config.app")

local _M = {}

function _M:handle()
    local access_limit = config.max_request_per_second
    local key = 'request_limit:'..ngx.var.remote_addr
    local shared_dict = ngx.shared.shared_dict
    local times = shared_dict:get(key)
    if not times then
        shared_dict:set(key, 1, 1)
    else
        if times > access_limit then
            ngx.log(ngx.WARN, 'request limit '..times)
            return false, 6
        else
            local ok,err = shared_dict:incr(key, 1)
            if not ok then
                ngx.log(ngx.ERR, err)
                return false, 7
            end
        end
    end
    return true
end

return _M