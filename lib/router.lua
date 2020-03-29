local ngx_re = require("ngx.re")
local ngx = ngx
local new_tab = require('table.new')
local response = require("lib.response")
local trie = require("lib.trie")

local CONTROLLER_PREFIX = 'controllers'
local MIDDLEWARE_PREFIX = 'middleware'

local _M = {
    routes = {
        GET = trie:new(),
        POST = trie:new(),
        PUT = trie:new(),
        DELETE = trie:new(),
        PATCH = trie:new(),
        OPTIONS = trie:new(),
    },
    middlewares = new_tab(1000, 0) -- table.new performance better than `{}` dynamic array at most case
}

local function split_uri(uri)
    if uri == '/' or uri == '' then
        return {'/'}
    end
    local uris, err = ngx_re.split(uri, '/')
    if err ~= nil then
        ngx.log(ngx.ERR, err)
        return {}
    end
    return uris
end

local function route_match(route_tree, http_uris)
    local params = {}
    for _, uri in ipairs(http_uris) do
        local tree, param = route_tree:find_child_by_key(uri)
        if params ~= nil then
            table.insert(params, param)
        end
        if not tree then
            return false
        end
        route_tree = tree
    end
    if next(route_tree.children) == nil then
        return true, route_tree.value, params
    end
    return false
end


local function options_http_process()
    return nil, nil, response:raw(200)
end


function _M:match(http_uri, http_method)
    local uris = split_uri(http_uri)
    local ok, route, route_params = route_match(self.routes[http_method], uris)
    if ok then
        if http_method == 'OPTIONS' then
            return options_http_process()
        end
        -- return find route with context
        return route, route_params
    end
    return nil, nil, response:error(404, {}, 'not found uri')
end

-- below function process only once in a worker

-- require controller
local function require_controller(controller, action)
    local controller_path = CONTROLLER_PREFIX .. '.' .. controller
    local required_controller = require(controller_path)
    if type(required_controller) ~= 'table' then
        return nil, 'system error, controller ' .. controller_path .. ' not a table'
    end
    if required_controller[action] == nil then
        return nil, 'system error, this action ' .. action .. ' function not exist' .. ' in ' .. controller_path
    end
    return required_controller
end

-- require middlewares
local function require_middleware(middlewares)
    local required_middlewares = {}
    for _, middleware in ipairs(middlewares) do
        local middleware_path = MIDDLEWARE_PREFIX .. '.' .. middleware
        local required_middleware = require(middleware_path)
        if type(required_middleware) ~= 'table' then
            return 'system error, middleware ' .. middleware_path .. ' not a table'
        end
        table.insert(required_middlewares, required_middleware)
    end
    return required_middlewares
end

-- list table route
local function generate_route(root_tree, route_uri, route_info)
    local sub_uris = split_uri(route_uri)
    local current_tree = root_tree
    for _, uri in ipairs(sub_uris) do
        local node = current_tree:find_child_by_key(uri)
        if node == nil then
            node = trie:new()
            current_tree:append_child(uri, node)
        end
        current_tree = node
    end
    current_tree:set_value(route_info)
end

function _M:add_route(method, uri, controller, action)
    local required_controller, required_middlewares, err
    required_controller, err = require_controller(controller, action)
    if err ~= nil then
        ngx.log(ngx.ERR, err)
        return
    end
    required_middlewares, err = require_middleware(self.middlewares)
    if err ~= nil then
        ngx.log(ngx.ERR, err)
        return
    end
    local route_info = {
        required_controller = required_controller,
        controller = controller,
        action = action,
        middlewares = {table.unpack(self.middlewares)}, -- deep copy self.middlewares
        required_middlewares = required_middlewares,
    }
    generate_route(self.routes[method], uri, route_info)
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


function _M:group(group_property, func)
    local current_middlewares = {}
    if group_property.middlewares then
        current_middlewares = group_property.middlewares
    end
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