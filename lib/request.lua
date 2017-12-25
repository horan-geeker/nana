local cjson = require('cjson')
local _M = {}

function _M:all()
	local data = {}
	if ngx.req.get_method() == "GET" then
		data = ngx.req.get_uri_args()
	elseif ngx.req.get_method() == "POST" then
		if ngx.req.get_headers()["Content-Type"] == 'application/json' then
			data = cjson.decode(ngx.req.get_body_data())
		else
			ngx.req.read_body()
			data = ngx.req.get_post_args()
		end
	else
		data = cjson.decode(ngx.req.get_body_data())
	end

	return data
end

-- lua 语言调用 demo.foo(demo.bar('test')) 会出错
function _M.foo(self, arg)
	ngx.log(ngx.ERR, arg,'foo')
	return arg
end
function _M.bar(self, arg)
	ngx.log(ngx.ERR, arg,'bar')
end

return setmetatable(_M, {__index = _M:all()})