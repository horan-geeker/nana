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
		-- body may get buffered in a temp file:
		body = ngx.req.get_body_file()
		if body then
			ngx.log(ngx.ERR, "client body was too big, try to increase client_body_buffer_size")
			return nil
		end
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
		uri = self:get_uri(),
		method = self:get_method(),
		params = self.params,
		headers = self:get_headers()
	}
end


function _M:all()
	return self.params
end


function _M:get_headers()
	return ngx.req.get_headers()
end


function _M:get_uri()
	return ngx.re.sub(ngx.var.request_uri, '[?].*$', '') -- use ngx.re.sub insteat of string.sub
end


function _M:get_method()
	return ngx.var.request_method
end

return _M