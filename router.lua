local route = require('providers.route_service_provider')

local _M = {}

function _M:init()
    ngx.ctx.middleware_group = {}
    self:routes()
    ngx.log(ngx.WARN, 'not find method, uri in router.lua or didn`t response in action, current method:'.. ngx.var.request_method ..' current uri:'..ngx.var.request_uri)
end

function _M:routes()
    route:group({
        'locale', 'throttle'
    }, function()
        route:get('/index', 'index_controller', 'index') -- route:http_method(uri, controller, action)
        route:post('/login', 'auth_controller', 'login')
        route:group({
            'verify_guest_sms_code'
        }, function()
            route:post('/register', 'auth_controller', 'register')
        end)
        route:post('/send/sms', 'notify/sms_notify_controller', 'guest_send_sms')
        route:get('/oauth/wechat/web', 'wechat_controller', 'webLogin')
        route:group({
                'verify_guest_sms_code'
            }, function()
            route:patch('/forget-password', 'auth_controller', 'forget_password')
        end)
        route:group({
            'authenticate',
        }, function()
            route:post('/user/send/sms', 'notify/sms_notify_controller', 'user_send_sms')
            route:post('/logout', 'auth_controller', 'logout')
            route:patch('/reset-password', 'auth_controller', 'reset_password')
            route:group({
                'token_refresh'
            }, function()
                route:get('/userinfo', 'user_controller', 'userinfo')
                route:get("/users/{user_id}/", 'user_controller', 'show')
                route:get("/users/{user_id}/comments/{comment_id}", 'user_controller', 'comments')
                -- test upsteam usage (suppose /home api write by Java or PHP) use nginx reverse proxy
                route:get('/home')
            end)
        end)
    end)
end

return _M