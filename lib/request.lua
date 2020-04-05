local new_tab = require('table.new')
local cjson = require('cjson.safe')
local ngx = ngx

local _M = {
	params = new_tab(0, 1000)
}

local function parse_uri_params()
	return ngx.req.get_uri_args()
end

local function parse_body_params()
	ngx.req.read_body() -- open read body
	local body = ngx.req.get_body_data()
	if not body then
		return
	end
	local result = cjson.decode(body) -- use cjson.safe instead of pcall
	if result then
		return result
	end
	return ngx.req.get_post_args()
end

function _M:capture()
	self.params = parse_uri_params()
	local body_params = parse_body_params()
	if body_params then
		for k,v in pairs(body_params) do
			self.params[k] = v
		end
	end
	return {
		uri = ngx.var.uri,
		method = ngx.req.get_method(),
		params = self.params,
		headers = ngx.req.get_headers()
	}
end


function _M:header(key)
	local headers = ngx.req.get_headers()
	return headers[key]
end


function _M:all()
	return self.params
end


return _M