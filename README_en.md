# Nana

[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)
[中文文档](README.md)

`Nana` is a `MVC http restful api framework` written using Lua which need be used in `openresty` platform.

## Contents

* [Status](#Status)
* [Synopsis](#Synopsis)
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
local request = require("lib.request")
local response = require("lib.response")

local _M = {}

function _M:index()
    local args = request:all() -- get all args
    return response:json(0, 'request args', args) -- return response 200 and json content
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

 There are several middleware included in the Nana framework, including middleware for authentication and throttle fuse protection. All of these middleware are located in the middleware directory.

## Contact author

fb: https://www.facebook.com/profile.php?id=100004896017774

### wechat

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)
