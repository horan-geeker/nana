local cjson = require('cjson')
local _M = {}

function _M:all()
	local data, start_pos, end_post = nil, nil, nil
	if ngx.req.get_method() == "GET" or ngx.req.get_method() == "HEAD" then
		data = ngx.req.get_uri_args()
	else
		ngx.req.read_body() -- open read body
		if not ngx.req.get_headers()['content-type'] then
			start_pos = nil
		else
			start_pos, end_pos = string.find(ngx.req.get_headers()['content-type'], 'application/json')
		end
		if start_pos ~= nil then
			data = cjson.decode(ngx.req.get_body_data())
		else
			data = ngx.req.get_post_args()
		end
	end
	return data
end

return _M