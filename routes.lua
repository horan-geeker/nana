local route = require("lib.router")

route:get('/index', 'index_controller', 'index')
route:post('/', 'index_controller', 'store')

route:group({
    middlewares = {'throttle'},
}, function()
    route:post('/auth/login', 'auth_controller', 'login')
    route:get('/users/{id}/posts/{post_id}', 'user_controller', 'show')
    route:group({
    }, function()
        route:post('/register', 'auth_controller', 'register')
        route:patch('/forget-password', 'auth_controller', 'forget_password')
    end)
    route:group({
        middlewares = {'authenticate'},
    }, function()
        route:patch('/auth/user/reset-password', 'auth_controller', 'reset_password')
        route:group({
            middlewares = {'token_refresh'}
        }, function()
            route:get('/userinfo', 'user_controller', 'userinfo')
        end)
    end)
end)

return route