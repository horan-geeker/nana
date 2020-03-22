local route = require("lib.router")

route:get('/', 'index_controller', 'index')
route:post('/', 'index_controller', 'index')

route:group({
    'locale',
    'throttle'
}, function()
    route:post('/login', 'auth_controller', 'login')
    route:get('/users/{id}', 'user_controller', 'show')
    route:group({
        'verify_guest_sms_code'
    }, function()
        route:post('/register', 'auth_controller', 'register')
        route:patch('/forget-password', 'auth_controller', 'forget_password')
    end)
    route:group({
        'authenticate',
    }, function()
        route:post('/logout', 'auth_controller', 'logout')
        route:patch('/reset-password', 'auth_controller', 'reset_password')
        route:group({
            'token_refresh'
        }, function()
            route:get('/userinfo', 'user_controller', 'userinfo')
        end)
    end)
end)

return route