local _M = {}

function _M:match(route)
    route:get('/index', 'index_controller', 'index')
    route:group({
        'locale',
        'throttle'
    }, function()
        route:post('/login', 'auth_controller', 'login')
        route:post('/send/sms', 'notify/sms_notify_controller', 'guest_send_sms')
        route:get('/oauth/wechat/web', 'wechat_controller', 'webLogin')
        route:get('/users/{id}', 'user_controller', 'show')
        route:group({
            -- 'verify_guest_sms_code'
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
end

return _M