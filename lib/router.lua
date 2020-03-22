local new_tab = require('table.new')
local helpers = require("lib.helpers")
local response = require("lib.response")
local trim = helpers.trim
local ngx = ngx

local CONTROLLER_PREFIX = 'controllers'
local MIDDLEWARE_PREFIX = 'middleware'

local _M = {
    routes = new_tab(0, 1000),
    middlewares = new_tab(1000, 0) -- table.new performance better than `{}` dynamic array at most case
}

local function trim_uri(uri)
    return trim(trim(uri, ' '), '/')
end


local function route_match(route_uri, http_uri)
    local captures, err = ngx.re.match(http_uri, route_uri, 'jo') -- ngx.re.* performence better than lua api
    if captures then
        captures[0] = nil; -- todo change table
        return true, captures
    end
    return false, err
end


local function options_http_process()
    return nil, nil, response:raw(200)
end


function _M:match(http_uri, http_method)
    http_uri = trim_uri(http_uri)
    for uri, route in pairs(self.routes) do
        local is_matched, route_params = route_match(uri, http_uri)
        if is_matched then
            if http_method == 'OPTIONS' then
                return options_http_process()
            end
            if not route[http_method] then
                return nil, nil, response:error(405, {}, 'method not allow')
            end
            -- return find context
            return route[http_method], route_params
        end
    end
    return nil, nil, response:error(404, {}, 'not found uri')
end


local function transform_uri(uri)
    local trimed_uri = trim_uri(uri)
    local new_router_url, n, err = ngx.re.gsub(trimed_uri, '\\{[\\w]+\\}', '(\\d+)')
    return '^' .. new_router_url .. '$'
end


-- below function process only once in a worker
function _M:add_route(method, uri, controller, action)
    local pattern_uri = transform_uri(uri)
    if not self.routes[pattern_uri] then
        self.routes[pattern_uri] = {}
    end
    -- require controller
    local controller_path = CONTROLLER_PREFIX .. '.' .. controller
    local required_controller = require(controller_path)
    if type(required_controller) ~= 'table' then
        ngx.log(ngx.ERR, 'system error, controller ', controller_path,' not a table')
        ngx.exit(ngx.ERR)
        return
    end
    if required_controller[action] == nil then
        ngx.log(ngx.ERR, 'system error, this action ', action,' function not exist', ' in ', controller_path)
        ngx.exit(ngx.ERR)
        return
    end
    local required_middlewares = {}
    -- require middlewares
    for _, middleware in ipairs(self.middlewares) do
        local middleware_path = MIDDLEWARE_PREFIX .. '.' .. middleware
        local required_middleware = require(middleware_path)
        if type(required_middleware) ~= 'table' then
            ngx.log(ngx.ERR, 'system error, middleware ', middleware_path,' not a table')
            ngx.exit(ngx.ERR)
            return
        end
        table.insert(required_middlewares, required_middleware)
    end
    self.routes[pattern_uri][method] = {
        required_controller = required_controller,
        controller = controller,
        action = action,
        middlewares = {table.unpack(self.middlewares)}, -- deep copy self.middlewares
        required_middlewares = required_middlewares,
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


function _M:group(current_middlewares, func)
    -- append tail one by one
    for _,middleware in ipairs(current_middlewares) do
        table.insert(self.middlewares, middleware)
    end
    func()
    -- remove tail one by one
    for _ in ipairs(current_middlewares) do
        table.remove(self.middlewares, #self.middlewares)
    end
end

return _M