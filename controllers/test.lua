local cjson = require("cjson")
local request = require("lib.request")
ngx.say(cjson.encode(request.get()))
ngx.say(cjson.encode(ngx.req.get_uri_args()))
