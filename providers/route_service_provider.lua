local common = require('lib.common')
local cjson = require('cjson')
local controller_prefix = 'controllers.'
local middleware_prefix = 'middleware.'
local _M = {}
local middleware_group = {}

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
        if middleware_group then
            for _,middleware in ipairs(middleware_group) do
                local result, status, message = require(middleware_prefix..middleware):handle()
                if result == false then
                    middleware_group = {}
                    common:response(status, message)
                end
            end
        end
        if controller then
            middleware_group = {}
            require(controller_prefix..controller)[action](nil, table.unpack(params))
        else
            ngx.log(ngx.WARN, 'upsteam api')
        end
    end
    middleware_group = {}
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
    for _,middleware_item in ipairs(middleware) do
        table.insert(middleware_group, middleware_item)
    end
    func()
end

return _M