# Nana

[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)
[中文文档](README.md)

`Nana` is a `MVC http restful api framework` written using Lua which need be used in `openresty` platform.

## Contents

* [Status](#Status)
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
    * [CURD](#CURD)
    * [Sort](#Sort)
    * [Pagination](#Pagination)
    * [Original sql](#Original-sql)
  * [Redis](#Redis)
  * [Localization](#Localization)
  * [Other](#Other)
    * [Random](#Random)
  * [Helper Function](#Helper-Function)
  * [Code specification](#Code-specification)
* [Contact author](#Contact-author)

## Status

This project is considered production ready.

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

### ab test

```shell
ab -c 100 -n 10000 api.lua-china.com/index

---
Requests per second:    4621.10 [#/sec] (mean)
Time per request:       21.640 [ms] (mean)
---
```

## Install

### Manual install

* `git clone https://github.com/horan-geeker/nana.git`
* execute `cp env.example.lua env.lua` and make sure right config
* at `nginx/conf/nginx.conf` set `lua_package_path '/path/to/nana/?.lua;;';` point to nana dir, set `content_by_lua_file` point to project `/path/to/nana/bootstrap.lua` file location

## Description

### Config

All of your configuration files for Nana Framework are stored in the `config` directory. Each option is documented, so feel free to look through the files and get familiar with the options available to you.

Your `env.lua` file should not be committed to your application's source control, since each Test/Prod using your application could require a different environment configuration. Furthermore, this would be a security risk in the event an intruder gains access to your source control repository, since any sensitive credentials would get exposed.

If you are developing with a team, you may wish to continue including a `env.example.lua` file with your application. By putting placeholder values in the example configuration file, other developers on your team can clearly see which environment variables are needed to run your application.

### Routing

The default route file located at root directory named `routes.lua`.

For most applications, you will begin by defining routes in your routes.lua file.

For example, you may access the following route by navigating to http://your-app.test/users api

```lua
route:get('/users', 'user_controller', 'index')
```

#### Available Router Methods

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

#### Route Groups

Route groups allow you to share route attributes, such as middleware, across a large number of routes without needing to define those attributes on each individual route. Shared attributes are specified in an array format as the first parameter to the route::group method.

```lua
route:group({
        'authenticate',
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

framework return response to bootstrap by `lib/response.lua` > `json()` function, `response` structure has status,message,data three args

1. status are in `config/status.lua`
2. message will match status code in `config/status.lua`
3. data can custom by yourself

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

you can custom `{"status":0,"message":"ok","data":{}}` key in `lib/response.lua` > `json` function, or other error code in `config/status.lua`

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

## Contact author

fb: https://www.facebook.com/profile.php?id=100004896017774

### wechat

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)
