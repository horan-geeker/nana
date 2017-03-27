local cjson = require("cjson")
local _M = {}

function _M:response(data)
    ngx.say(cjson.encode(data))
    ngx.exit(ngx.OK)
end

return _M
