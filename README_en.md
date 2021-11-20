# Nana

[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)
[中文文档](README.md)

`Nana` is a `api framework` written using Lua which need be used in `openresty` platform.

## Contents

* [Synopsis](#Synopsis)
* [Benchmark](#Benchmark)
* [Install](#Install)
  * [Manual install](#Manual-install)
* [Description](#Document)
  * [Config](#Config)
  * [Routing](#Routing)
  * [Middleware](#Middleware)
  * [Controller](#Controller)
    * [Service](#Service)
  * [Request](#Request)
    * [Http request args](#Http-request-args)
    * [Http client request](#Http-client-request)
  * [Response](#Response)
    * [Global response structure](#Global-response-structure)
  * [Cookie](#Cookie)
  * [Database ORM](#Database-ORM)
    * [Retrieve Models](#Retrieve-Models)
    * [Inserting & Updating Models](#Inserting-&-Updating-Models)
    * [Sort](#Sort)
    * [Pagination](#Pagination)
    * [Raw sql](#Raw-sql)
  * [Model Relationships](#Model-Relationships)
    * [One to Many](#One-to-Many)
    * [Many to One](#Many-to-One)
  * [Redis](#Redis)
  * [Other](#Other)
    * [Random](#Random)
  * [Helper Function](#Helper-Function)
  * [Code specification](#Code-specification)
* [Contact author](#Contact-author)


## Synopsis

> routes.lua

```lua
-- add below
route:get('/index', 'index_controller', 'index')
```

> controllers/index_controller.lua

```lua
local response = require("lib.response")

local _M = {}

function _M:index(request)
    return response:json(0, 'request args', request.params) -- return response 200 and json content
end

return _M

```

> request this api

```shell
curl https://api.lua-china.com/index?id=1&foo=bar

{
    "msg": "request args",
    "status": 0,
    "data": {
        "foo": "bar",
        "id": "1"
    }
}
```

## Benchmark

### one cpu

worker_cpu_affinity 0001;

wrk -t1 -c 100 -d10s http://localhost:60000/index

```shell
Running 10s test @ http://localhost:60000/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     3.70ms    4.23ms  29.84ms   82.74%
    Req/Sec    43.31k     2.63k   48.61k    82.00%
  431043 requests in 10.02s, 97.01MB read
Requests/sec:  43024.54
Transfer/sec:      9.68MB
```

#### compare with lor framework

wrk -t1 -c 100 -d10s http://localhost:60004/hello

```
Running 10s test @ http://localhost:60004/hello
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     5.01ms  621.83us  14.66ms   92.35%
    Req/Sec    20.02k     0.96k   21.35k    78.00%
  199275 requests in 10.01s, 46.94MB read
Requests/sec:  19898.67
Transfer/sec:      4.69MB
```

#### compare with golang gin framework

```shell
wrk -t1 -c 100 -d10s http://localhost:60002/ping

Running 10s test @ http://localhost:60002/ping
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     8.05ms   10.04ms  78.14ms   85.71%
    Req/Sec    20.39k     3.19k   26.53k    68.00%
  203091 requests in 10.02s, 27.31MB read
Requests/sec:  20260.14
Transfer/sec:      2.72MB
```

## Install

### Manual install

* `git clone https://github.com/horan-geeker/nana.git`
* execute `cp env.example.lua env.lua` look up `Config` chapter for more detail
* nginx config file `nginx.conf` set `lua_package_path '/path/to/nana/?.lua;;';` point to nana dir, set `content_by_lua_file` point to project `/path/to/nana/bootstrap.lua` file location

## Description

### Config

* `config/app.lua` for project config
* `config/database.lua` for database config
* `config/status.lua` for http response data custom by yourself


> Your `env.lua` file should not be committed to your application's source control, since each Test/Prod using your application could require a different environment configuration. Furthermore, this would be a security risk in the event an intruder gains access to your source control repository, since any sensitive credentials would get exposed.

If you are developing with a team, you may wish to continue including a `env.example.lua` file with your application. By putting placeholder values in the example configuration file, other developers on your team can clearly see which environment variables are needed to run your application.

### Routing

The default route file located at root directory named `routes.lua`.

For most applications, you will begin by defining routes in your routes.lua file.

For example, you may access the following route by navigating to http://your-app.test/users api

```lua
route:get('/users', 'user_controller', 'index')
```

#### Available Router Methods

* GET
* POST
* PATCH
* PUT
* DELETE
* HEAD

The router allows you to register routes that respond to any HTTP verb:

```lua
route:get(uri, controller, action)
route:post(uri, controller, action)
route:patch(uri, controller, action)
route:put(uri, controller, action)
route:delete(uri, controller, action)
route:options(uri, controller, action)
```

#### Route Parameters

Sometimes you will need to capture segments of the URI within your route. For example, you may need to capture a user's ID from the URL. You may do so by defining route parameters:

```lua
route:get('/users/{id}', 'user_controller', 'show')
```
to use it at `user_controller`:
```lua
function _M:show(user_id)
    ...
end
```

#### Route Groups

Route groups allow you to share route attributes, such as middleware, across a large number of routes without needing to define those attributes on each individual route. Shared attributes are specified in an array format as the first parameter to the route::group method.

```lua
route:group({
        middleware = 'authenticate',
    }, function()
        route:post('/logout', 'auth_controller', 'logout') -- http_method/uri/controller/action
        route:post('/reset-password', 'user_controller', 'resetPassword')
    end)
```

### middleware

Middleware provide a convenient mechanism for filtering HTTP requests entering your application. For example, Nana includes a middleware that verifies the user of your application is authenticated. If the user is not authenticated, the middleware will terminate request and return response with error message. However, if the user is authenticated, the middleware will allow the request to proceed further into the application.

Additional middleware can be written to perform a variety of tasks besides authentication. A CORS middleware might be responsible for adding the proper headers to all responses leaving your application. A logging middleware might log all incoming requests to your application.

 There are several middleware included in the Nana framework, example middleware for authentication. All of these middleware are located in the middleware directory.

```lua
function _M:handle()
    if not auth_service:check() then
        return false, response:json(4,'no authorized in authenticate')
    end
end
```
you should define a function named `handle()` at your custom middleware.lua file in middleware dir, return `false` to stop run controller and replace by the second parameter of return response to user

### Controller

all controllers are located in `controllers` dir，when router match `uri`，the second param is controller name, the third param is action name in this controller，we should return response:json() or response:raw() to render output

### Request

nana will inject request as last param to controller action function, we can retrieve this props

* request.params
* request.headers
* request.method
* request.uri

#### request params

```lua
local request = require("lib.request")
local args = request:all() -- get all params，not only uri args but also post json body
args.username -- get username prop
```

### Response

framework return response to bootstrap by `lib/response.lua` > `json()` function, `response` structure has status,message,data, http status code most four parameter

1. status are in `config/status.lua`
2. message will match status code in `config/status.lua`
3. data should return response by api

```lua
return response:json(0x000000, 'success message', data, 200)
--[[
{
    "msg": "success message",
    "status": 0,
    "data": {}
}
--]]
```

return error message:

```lua
return response:json(0x000001)
--[[
{
    "msg": "arguments invalid",
    "status": 1,
    "data": {}
}
--]]
```

#### custom response json protocol

you can custom response `{"status":0,"message":"ok","data":{}}` key in `lib/response.lua` > `json` function, or other error code in `config/status.lua`

### validate data

```lua
local validator = require('lib.validator')
local request = require("lib.request")
local args = request:all() -- get all arguments
local ok,msg = validator:check(args, {
    name = {max=6,min=4}, -- validate name should in 4-6 length
    'password', -- validate password cannot empty
    id = {included={1,2,3}} -- validate id should be 1 or 2 or 3
    })
```


### Cookie

`lib/helpers.lua` contain `set_cookie` `get_cookie` function to operator cookie

```lua
helpers.set_cookie(key, value, expire) -- expire option parameter, sec
helpers.get_cookie(key)
```

### Database ORM

> by default sql use `ngx.quote_sql_str` to prevent `sql reject`

```lua
-- define a Model at models dir which table named users
local Model = require("lib.model")
local User = Model:new('users')
return User
```

#### Retrieve Models

```lua
-- retrieve `id` = 1
local user = User:find(1)

-- retrieve all data at users table
local users = User:all()

-- retrieve `username` column which value equel to `cgreen` and `password` column which value equel to `xxxxxx` many rows, use first() function at last to limit 1 row
local user = User:where('username','=','cgreen'):where('password','=','xxxxxxx'):get()

-- return `name` = `xxx` or `yyy` result
local users = User:where('name','=','xxx'):orwhere('name','=','yyy'):get()
```

#### Inserting & Updating Models

```lua
-- create a user
User:create({
    id=3,
    password='xxxxxx',
    name='hejunwei',
    email='heunweimake@gmail.com',
})

-- update user's name=test and avatar set to NULL which id = 1
local ok, err = User:where('id', '=', 1):update({
        name='test',
        avatar='null'
  })
if not ok then
    ngx.log(ngx.ERR, err)
end
```

#### Deleting Models

```lua
-- delete user id = 1
local ok, err = User:where('id','=','1'):delete()
if not ok then
    ngx.log(ngx.ERR, err)
end

-- soft delete
local ok, err = User:where('id','=','1'):soft_delete()
if not ok then
    ngx.log(ngx.ERR, err)
end
```

> you should create a datetime column named `deleted_at` at your table, soft_delete() will set current time to that row, if you want to change column name, config at `models/model.lua`

#### Sort

`orderby(column, option)`
first param is column name which want to sort, second param is sort type default is `ASC` you can set `ASC or DESC`(case insensitive)
for example:
`Post:orderby('created_at'):get()`

#### Pagination

```lua
local userPages = User:paginate(1)
-- return response：
{
    "prev_page": null,
    "total": 64,
    "data": [
        {user1_obj},
        {user2_obj},
        ...
    ],
    "next_page": 2
}
```

if it is first or last page, `prev_page` or `next_page`is `null`

#### Raw SQL

> raw sql should resolve `sql reject` by yourself
`local Database = require('lib.database')`

* local res, err = Database:mysql_query(sql) -- execute SQL, read operation(SELECT) return data set，write operation(INSERT,UPDATE,DELETE) return effective rows count

### Model Relationships

#### One to Many

for example one user has many posts set `has_many` at `user.lua` model:

```lua
-- user.lua
local Model = require("models.model")
local Post = require('models.post')
local User = Model:new('users')
function User:posts()
    return User:has_many(Post, 'user_id', 'id') -- target model, target table id, our table foreign key
end
return User


-- post.lua
local Model = require("models.model")
local Post = Model:new('posts')
return Post

-- controller
local user_and_post = User:where('id', '=', user_id):with('posts'):get()
--[[
[
    {
        "name":"horan",
        "posts":{
            "id":67,
            "user_id":1,
            "title":"article title",
            "content":"article content"
        },
        "email":"hejunweimake@gmail.com"
    }
]
--]]
```

#### Many to One

For example one user has many posts, you can set `belongs_to` at `post.lua` model：

```lua
-- post.lua
local Model = require("models.model")
local User = require('models.user')
local Post = Model:new('posts')

function Post:user()
    return Post:belongs_to(User, 'id', 'user_id') -- target model, target table id, our table foreign key
end

return Post

-- user.lua
local Model = require("models.model")
local User = Model:new('users')
return User

-- controller
local posts_with_user = Post:where('id', '=', 1):with('user'):first()
--[[
{
    "id":1,
    "user_id":1,
    "title":"article title",
    "user":{
        "id":1,
        "name":"openresty"
    },
    "content":"article content"
}
--]]
```

#### Read and Write separation

At `config/database.lua` file `mysql.read` and `mysql.write` to config database, if you don't want to separation, can config the same

> only can config one read instance and one write instance, if you have many read instance, you can use tcp proxy to your read cluster

### Redis

```lua
local redis = require("lib.redis")
local ok,err = redis:set('key', 'value', 60) --seconds
if not ok then
    return false, err
end
local ok,err = redis:expire('key',60) --seconds delay expire time
if not ok then
    return false, err
end
local data, err = redis:get('key') --get
local ok,err = redis:del('key') --delete
if not ok then
    return false, err
end
```

#### resty redis

framework use `resty redis`
```lua
local resty_redis = require('lib.resty_redis')
```

### Others

#### Random

```lua
local random = require('lib.random')
```

##### character and number

```lua
random.token(10) -- length 10
```

##### only number

```lua
random.number(1000, 9999)
```

### Helper Function

#### reverse table

only for array table

```lua
table_reverse(tab) -- return reverse table
```

#### table delete by value

```lua
table_remove(tab, {'item1', 'item2'})
```

#### sort by key

> lua `hash table` `key` sort is different with other language

```lua
sort_by_key(hashTable)
```

## Contact author

fb: https://www.facebook.com/profile.php?id=100004896017774

### wechat

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)
