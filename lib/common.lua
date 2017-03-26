local cjson = require("cjson")
local conf = require('config.app')
local _M = {}

function _M:response(data)
    if ngx.ctx[MYSQL] then
        local ok,err = ngx.ctx[MYSQL]:set_keepalive(conf.pool_timeout,conf.pool_size)
        if not ok then
			ngx.log(ngx.ERR,"failed to set keepalive:"..err);
		end 
        ngx.ctx[MYSQL] = nil
    end
    ngx.say(cjson.encode(data))
    ngx.exit(ngx.OK)
end

return _M
