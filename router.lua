local common = require('lib.common')

local _M = {}
local controller_prefix = 'controllers.'
local middleware_prefix = 'middlewares.'
local middleware_group = {}

local function call_action(uri, controller, action)
    if uri == ngx.var.request_uri then
        if middleware_group then
            for _,middleware in ipairs(middleware_group) do
                common:log('use middleware: '..middleware)
                require(middleware_prefix..middleware):handle()
            end
        end
        require(controller_prefix..controller)[action]()
    end
end

local function get(uri, controller, action)
    if 'GET' == ngx.var.request_method then
        call_action(uri, controller, action)
    end
end

local function post(uri, controller, action)
    if 'POST' == ngx.var.request_method then
        call_action(uri, controller, action)
    end
end

local function group(middlewares, func)
    for _,middleware in ipairs(middlewares) do
        table.insert(middleware_group, middleware)
    end
    func()
end

function _M:init()
    post('/login', 'auth_controller', 'login')
    -- group middleware should in order
    group({
        'authenticate',
        -- 'example_middleware'
    }, function()
        post('/logout', 'auth_controller', 'logout') -- http_method/uri/controller/action
        group({
            'token_refresh'
        }, function()
            get('/hosts', 'host_controller', 'index')
        end)
    end)
    ngx.log(ngx.ERR, 'not find method or uri in router.lua, current method:'.. ngx.var.request_method ..' current uri:'..ngx.var.request_uri)
end

return _M