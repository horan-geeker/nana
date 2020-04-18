local test = require('tests.test')
local router = require('lib.router')

router.controller_prefix = 'tests.controllers'
router.middleware_prefix = 'tests.middleware'

router:get('index', 'index_controller', 'index')
router:get('users', 'user_controller', 'index')
router:post('users', 'user_controller', 'store')
router:get('/users/{id}/posts/', 'user_controller', 'posts')
router:get('/users/{id}/posts/{id}', 'user_controller', 'post_detail')
router:group({
    middleware = {'authenticate'}
}, function()
    router:put('users/{id}', 'user_controller', 'update')
    router:delete('users/{id}', 'user_controller', 'delete')
    router:group({
        middleware = {'refresh_token'}
    }, function()
        router:get('users/{id}', 'user_controller', 'show')
    end)
end)

test.equal(router.routes['GET'].children['index'].value.controller, 'index_controller')
test.equal(router.routes['GET'].children['index'].value.action, 'index')

test.equal(router.routes['GET'].children['users'].value.controller, 'user_controller')
test.equal(router.routes['GET'].children['users'].value.action, 'index')

test.equal(router.routes['GET'].children['users'].children['{id}'].value.controller, 'user_controller')
test.equal(router.routes['GET'].children['users'].children['{id}'].value.action, 'show')

test.equal(router.routes['POST'].children['users'].value.controller, 'user_controller')
test.equal(router.routes['POST'].children['users'].value.action, 'store')

test.equal(router.routes['PUT'].children['users'].children['{id}'].value.controller, 'user_controller')
test.equal(router.routes['PUT'].children['users'].children['{id}'].value.action, 'update')

test.equal(router.routes['DELETE'].children['users'].children['{id}'].value.controller, 'user_controller')
test.equal(router.routes['DELETE'].children['users'].children['{id}'].value.action, 'delete')

test.is_true(not router:match('/', 'GET'))
local route, params = router:match('index', 'GET')
test.equal(route.controller, 'index_controller')
test.equal(route.action, 'index')
test.is_true(not next(params))

route, params = router:match('/index', 'GET')
test.equal(route.controller, 'index_controller')
test.equal(route.action, 'index')
test.is_true(not next(params))

route, params = router:match('index/', 'GET')
test.equal(route.controller, 'index_controller')
test.equal(route.action, 'index')
test.is_true(not next(params))

route, params = router:match('/index/', 'GET')
test.equal(route.controller, 'index_controller')
test.equal(route.action, 'index')
test.is_true(not next(params))

route, params = router:match('users/1', 'GET')
test.equal(route.controller, 'user_controller')
test.equal(route.action, 'show')
test.equal(route.middlewares[1], 'authenticate')
test.equal(route.middlewares[2], 'refresh_token')
test.equal(params[1], '1')

route = router:match('users', 'POST')
test.equal(route.controller, 'user_controller')
test.equal(route.action, 'store')

route, params = router:match('users/1', 'PUT')
test.equal(route.controller, 'user_controller')
test.equal(route.action, 'update')
test.equal(route.middlewares[1], 'authenticate')
test.equal(params[1], '1')

route, params = router:match('users/1', 'DELETE')
test.equal(route.controller, 'user_controller')
test.equal(route.action, 'delete')
test.equal(route.middlewares[1], 'authenticate')
test.equal(params[1], '1')

route, params = router:match('users/1/posts', 'GET')
test.equal(route.controller, 'user_controller')
test.equal(route.action, 'posts')
test.equal(params[1], '1')

route, params = router:match('users/1/posts/2', 'GET')
test.equal(route.controller, 'user_controller')
test.equal(route.action, 'post_detail')
test.equal(params[1], '1')
test.equal(params[2], '2')