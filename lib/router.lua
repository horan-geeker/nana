local request = require('lib.request')

local controller_prefix = 'controllers'
local middleware_prefix = 'middleware'

local _M = {
    routes = {},
    middlewares = {}
}

function _M:route_match(route_uri, http_uri)
    local captures, err = ngx.re.match(http_uri, route_uri, 'jo')
    if captures then
        captures[0] = nil;
        return true, captures
    end
    return false
end

function _M:find_action(controller, action)
    local controller = require(controller_prefix .. '.' .. controller)
    if type(controller) ~= 'table' then
        return nil, 'system error, controller not a table'
    end
    local action = controller[action]
    if action == nil then
        return nil, 'system error, this action function not exist'
    end
    return action, nil
end

function _M:run_middlewares(middlewares)
    for _, middleware in ipairs(middlewares) do
        local result, response_content, resposne_status = require(middleware_prefix .. '.' ..middleware):handle()
        if result == false then
            return result, response_content, resposne_status
        end
    end
end

function _M:dispatch(http_uri, http_method)
    for uri, route in pairs(self.routes) do
        local is_matched, route_params = self:route_match(uri, http_uri)
        if is_matched then
            if not route[http_method] then
                return nil, 405
            end
            -- run middlewares
            local result, response_content, resposne_status = self:run_middlewares(route[http_method].middlewares)
            if result == false then
                return response_content, resposne_status
            end
            -- run action
            local action = self:find_action(route[http_method]['controller'], route[http_method]['action'])
            if not action then
                return 'not found action in controller', 500
            end
            return action(nil, table.unpack(route_params)), ngx.OK
        end
    end
    return nil, 404
end

function _M:run()
    return self:dispatch(self:trim_uri(request:get_uri()), request:get_method())
end

function _M:init()
    self.middlewares = {}
    require('routes'):match(self)
end

function _M:trim_uri(uri)
    return '/' .. trim(trim(uri, ' '), '/') .. '/'
end

function _M:transform_uri(uri)
    local trimed_uri = self:trim_uri(uri)
    local new_router_url, n, err = ngx.re.gsub(trimed_uri, '\\{[\\w]+\\}', '(\\d+)')
    return '^' .. new_router_url .. '$'
end

function _M:add_route(method, uri, controller, action)
    local pattern_uri = self:transform_uri(uri)
    if not self.routes[pattern_uri] then
        self.routes[pattern_uri] = {}
    end
    self.routes[pattern_uri][method] = {
        controller = controller,
        action = action,
        middlewares = {table.unpack(self.middlewares)} -- deep copy self.middlewares
    }
end

function _M:get(uri, controller, action)
    self:add_route('GET', uri, controller, action)
end

function _M:post(uri, controller, action)
    self:add_route('POST', uri, controller, action)
end

function _M:put(uri, controller, action)
    self:add_route('PUT', uri, controller, action)
end

function _M:patch(uri, controller, action)
    self:add_route('PATCH', uri, controller, action)
end

function _M:delete(uri, controller, action)
    self:add_route('DELETE', uri, controller, action)
end

function _M:head(uri, controller, action)
    self:add_route('HEAD', uri, controller, action)
end

function _M:group(middlewares, func)
    -- append one by one tail
    for _,middleware in ipairs(middlewares) do
        table.insert(self.middlewares, middleware)
    end
    func()
    -- remove tail first
    for index,_ in ipairs(middlewares) do
        table.remove(self.middlewares, #self.middlewares)
    end
end

return _M