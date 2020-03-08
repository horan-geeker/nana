# Nana

[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)
[中文文档](README.md)

`Nana` is a `MVC http restful api framework` written using Lua which need be used in `openresty` platform.

## Contents

* [Status](#Status)
* [Synopsis](#Synopsis)
* [Install](#Install)
  * [Install by docker](#Install-by-docker)
  * [Manual install](#Manual-install)
* [Getting started](#Getting-started)
  * [Use docker](#Use-docker)
  * [Normal install](#Normal-install)
* [Description](#Document)
  * [Config](#Config)
  * [Localization](#Localization)
  * [Route](#Route)
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
  * [Other](#Other)
    * [Random](#Random)
  * [Helper Function](#Helper-Function)
  * [Code specification](#Code-specification)
* [Auth API instruction](#Auth-API-instruction)
* [Telegram](#Telegram)
* [Contact author](#Contact-author)

## Status

This library is considered production ready.

## Synopsis

> routes.lua

```lua

function _M:match(route)
    -- add below
    route:get('/index', 'index_controller', 'index')
end
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

### Install by docker

* execute `cp env.example.lua env.lua`, project use this file to manage environment variable and `env.lua` is ignored by git, it can distinguish Test/Prod or Local env convenience.
* build docker `docker build -t nana .`
* run docker `docker run -p 80:80 --name=nana -v /host/path/nana:/app -d nana` mount /app to docker container can help us easier to debug in development environment, at production environment you don't need to mount it to docker container

### Manual install

* `git clone https://github.com/horan-geeker/nana.git`
* execute `cp env.example.lua env.lua` and config anything else
* at `nginx/conf/nginx.conf` set `content_by_lua_file` point to project `bootstrap.lua`

## Getting started

### Use docker

you can use `Dockerfile` to build nana that located
 in project root directory

* `docker build -t nana .`
* `docker run -p 80:80 --name=nana -v /host/path/nana:/app -d nana`, only develop environment need mount volume to `/app` and set `lua_code_cache off` in `docker/nginx/conf/nginx.conf` file

### Normal install

* `git clone https://github.com/horan-geeker/nana.git`
* execute `cp env.example.lua env.lua` configure `mysql redis`
* config `content_by_lua_file` point to `bootstrap.lua`(at project root directory) in your `nginx conf file` and run nginx.

> Note: if you want to use login/register function in nana framework, you need to configure `config/app.lua`: `users` is the name of user table in database, `phone` of user table's column for login as username and execute `chmod 755 install.sh && ./install.sh` to migrate database structure.

## Description

### Config

* All of your configuration files for Nana Framework are stored in the app.lua, and it has many config keys in that file, such as `db_name` which represents the database name, `user & password` that represents database username and password, `users` that represents the table name which you want store user data, `phone` is a column name which is used for authentication.
* Write your routes in router.lua.

### middleware

It is a middleware to resolve user authenticate, you can use this to login or register user, and use other language(Java PHP) as downstream program to process other business logic at the same time.
The entrance of this framework is bootstrap.lua, and you can write your routes in `router.lua`. if URL doesn't match any route, it will be processed by downstream program

Middleware can be used in `router.lua` and you can write middleware in `middleware` directory, there is a demo as `example_middleware.lua`

#### service provider

There are auth_service and route_service in `providers` directory.

## database schema

users
```
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `nickname` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `avatar` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '''''',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
```

id | nickname | email | password | avatar | created_at | updated_at
---| -------- | ----- | -------- | ------ | ---------- | ----------
 1 | horan | 13571899655@163.com|3be64**| http://avatar.com | 2017-11-28 07:46:46 | 2017-11-28 07:46:46

user_logs
```
CREATE TABLE `user_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `ip` varchar(255) NOT NULL DEFAULT '',
  `city` varchar(10) NOT NULL DEFAULT '',
  `type` varchar(255) NOT NULL DEFAULT '',
  `time_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
```

id | ip | city | type | time_at
---| ---| ---- | ---- | -------
 1 | 1.80.146.218 | Xian | login | 2018-01-04 04:01:02

## Telegram

https://t.me/joinchat/LsEGyxV0FBGJmNbnxDn9jQ

## Contact author

fb: https://www.facebook.com/profile.php?id=100004896017774