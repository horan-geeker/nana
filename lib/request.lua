local request = {}

for arg_name,arg_val in pairs(ngx.req.get_uri_args()) do
	request[arg_name] = arg_val
end

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body

for arg_name,arg_val in pairs(ngx.req.get_post_args()) do
	request[arg_name] = arg_val
end

return request