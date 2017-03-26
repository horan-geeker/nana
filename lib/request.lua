local M = {}

function M:all()
	local data = {}
	if ngx.req.get_method() == "GET" then
		data = ngx.req.get_uri_args()
	elseif ngx.req.get_method() == "POST" then
		ngx.req.read_body()
		data = ngx.req.get_post_args()
	else 
		return nil
	end
	return data
end

return M