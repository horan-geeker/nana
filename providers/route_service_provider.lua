local cjson = require('cjson')
local response = require('lib.response')
local controller_prefix = 'controllers.'
local middleware_prefix = 'middleware.'

local _M = {}

local function route_match(route_url, http_url)
    local new_router_url, n, err = ngx.re.gsub(route_url, '\\{[\\w]+\\}', '(\\d+)')
    new_router_url = '^' .. new_router_url .. '$'
    local captures, err = ngx.re.match(http_url, new_router_url, 'jo')
    if captures then
        captures[0] = nil;
        return true, captures
    end
    return false
end

function _M:call_action(method, uri, controller, action)
    if method == ngx.var.request_method then
        local ok, params = route_match(purge_uri(uri), purge_uri(ngx.var.request_uri))
        if ok then
            if ngx.ctx.middleware_group then
                for _,middleware in ipairs(table_reverse(ngx.ctx.middleware_group)) do
                    local result, status, message = require(middleware_prefix..middleware):handle()
                    if result == false then
                        response:json(status, message)
                    end
                end
            end
            if controller then
                if type(require(controller_prefix..controller)) ~= 'table' then
                    return response:json(0x00000D, nil, nil, 500)
                end
                local action = require(controller_prefix..controller)[action]
                if action == nil then
                    return response:json(0x00000E, nil, nil, 500)
                end
                return action(nil, table.unpack(params))
            else
                return ngx.log(ngx.WARN, 'upsteam api')
            end
        -- else
        --     return ngx.exit(ngx.HTTP_NOT_FOUND)
        end
    end
end

function _M:get(uri, controller, action)
    _M:call_action('GET', uri, controller, action)
end

function _M:post(uri, controller, action)
    _M:call_action('POST', uri, controller, action)
end

function _M:put(uri, controller, action)
    _M:call_action('PUT', uri, controller, action)
end

function _M:patch(uri, controller, action)
    _M:call_action('PATCH', uri, controller, action)
end

function _M:delete(uri, controller, action)
    _M:call_action('DELETE', uri, controller, action)
end

function _M:head(uri, controller, action)
    _M:call_action('HEAD', uri, controller, action)
end

function _M:group(middleware, func)
    -- index always be 1 and data will push back one by one
    for index,middleware_item in ipairs(middleware) do
        table.insert(ngx.ctx.middleware_group, index, middleware_item)
    end
    func()
    -- if not match any route, remove part of middleware
    for index,middleware_item in ipairs(middleware) do
        -- remove middleware
        table.remove(ngx.ctx.middleware_group, index)
    end
end

return _M