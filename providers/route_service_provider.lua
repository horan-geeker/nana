local common = require('lib.common')
local cjson = require('cjson')

local _M = {middleware_group = {}}

local controller_prefix = 'controllers.'
local middleware_prefix = 'middleware.'


local function route_match(route_url, current_url)
    local new_router_url, n, err = ngx.re.gsub(route_url, '\\{[\\w]+\\}', '(\\d+)')
    new_router_url = new_router_url .. '$'
    local captures, err = ngx.re.match(current_url, new_router_url, 'jo')
    if captures then
        captures[0] = nil;
        return true, captures
    end
    return false
end

function _M:call_action(uri, controller, action)
    local ok, params = route_match(common:purge_uri(uri), common:purge_uri(ngx.var.request_uri))
    if ok then
        if self.middleware_group then
            for _,middleware in ipairs(self.middleware_group) do
                local result, status, message = require(middleware_prefix..middleware):handle()
                if result == false then
                    common:response(status, message)
                end
            end
        end
        if controller then
            require(controller_prefix..controller)[action](nil, table.unpack(params))
        else
            ngx.log(ngx.WARN, 'upsteam api')
        end
    end
end

function _M:get(uri, controller, action)
    if 'GET' == ngx.var.request_method then
        _M:call_action(uri, controller, action)
    end
end

function _M:post(uri, controller, action)
    if 'POST' == ngx.var.request_method then
        _M:call_action(uri, controller, action)
    end
end

function _M:group(middleware, func)
    for index,middleware_item in ipairs(middleware) do
        table.insert(self.middleware_group, index, middleware_item)
    end
    func()
    for index,middleware_item in ipairs(middleware) do
        -- remove middleware
        table.remove(self.middleware_group, index)
    end
end

return _M