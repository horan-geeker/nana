local route = require('providers.route_service_provider')

local _M = {}

function _M:init()
    route:post('/register', 'auth_controller', 'register')
    route:post('/login', 'auth_controller', 'login')
    -- group middleware should in order
    route:group({
        'authenticate',
        -- 'example_middleware'
    }, function()
        route:post('/logout', 'auth_controller', 'logout') -- http_method/uri/controller/action
        route:group({
            'token_refresh'
        }, function()
            route:get('/userinfo', 'auth_controller', 'userinfo')
            route:get('/hosts', 'host_controller', 'index')
            route:post('/hosts', 'host_controller', 'store')
        end)
    end)
    ngx.log(ngx.WARN, 'not find method or uri in router.lua, current method:'.. ngx.var.request_method ..' current uri:'..ngx.var.request_uri)
end

return _M