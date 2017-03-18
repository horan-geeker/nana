local cjson = require("cjson")
local _M = {}

function _M:response(data)
    if ngx.ctx[MYSQL] then
        ngx.ctx[MYSQL]:set_keepalive(0,100)
        ngx.ctx[MYSQL] = nil
    end
    ngx.say(cjson.encode(data))
    ngx.exit(ngx.OK)
end

return _M
