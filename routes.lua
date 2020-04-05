local route = require("lib.router")

route:get('/', 'index_controller', 'index')
route:get('/posts', 'post_controller', 'index')
route:group({
    -- 'locale',
    -- 'throttle'
}, function()
    route:get('/posts/count', 'post_controller', 'count')
    route:get('/tags', 'post_controller', 'tags')
    route:get('/users/top', 'user_controller', 'top')
    route:get('/users/count', 'user_controller', 'count')
    route:get('/users/{id}', 'user_controller', 'show')
    route:get('/users/{id}/posts', 'user_controller', 'posts')
    route:get('/users/{id}/comments', 'user_controller', 'comments')
    route:get('/posts/{id}', 'post_controller', 'show')
    route:post('/login', 'auth_controller', 'login')
    route:post('/send/sms', 'notify/sms_notify_controller', 'guest_send_sms')
    route:get('/oauth/wechat/web', 'oauth_controller', 'wechat_login')
    route:get('/oauth/github', 'oauth_controller', 'github_login')
    route:group({
        middleware = {'verify_guest_sms_code'}
    }, function()
        route:post('/register', 'auth_controller', 'register')
        route:patch('/forget-password', 'auth_controller', 'forget_password')
    end)
    route:group({
        middleware = {'authenticate'},
    }, function()
        route:put('/user', 'user_controller', 'update')
        route:get('/posts/drafts', 'post_controller', 'drafts')
        route:get('/posts/{post_id}/edit', 'post_controller', 'edit')
        route:post('/posts/{id}/comments', 'comment_controller', 'create')
        route:post('/posts/{id}/favor', 'post_controller', 'favor')
        route:post('/posts', 'post_controller', 'store')
        route:put('/posts/{id}', 'post_controller', 'update')
        route:delete('/posts/{id}', 'post_controller', 'delete')
        route:post('/users/send/sms', 'notify/sms_notify_controller', 'user_send_sms')
        route:post('/logout', 'auth_controller', 'logout')
        route:patch('/reset-password', 'auth_controller', 'reset_password')
        route:group({
            middleware = {'token_refresh'}
        }, function()
            route:get('/userinfo', 'user_controller', 'userinfo')
        end)
    end)
end)

return route