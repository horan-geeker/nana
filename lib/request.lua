local cjson = require('cjson')
local _M = {}

function _M:all()
	local data = {}
	if ngx.req.get_method() == "GET" or ngx.req.get_method() == "HEAD" then
		data = ngx.req.get_uri_args()
	else
		ngx.req.read_body() -- open read body
		if ngx.req.get_headers()['Content-Type'] then
			local start_pos, end_pos = string.find(ngx.req.get_headers()['Content-Type'], 'application/json')
		else
			local start_pos = nil
		end
		if start_pos ~= nil then
			data = cjson.decode(ngx.req.get_body_data())
		else
			data = ngx.req.get_post_args()
		end
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