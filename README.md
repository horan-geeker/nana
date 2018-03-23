# Nana

## 为 api 设计的 lua 框架

`openresty` 是一个为高并发设计的异步非阻塞架构，而 `nana` 为了更好的使用 `openresty` 而诞生，项目集成了多个组件，目前支持丰富的功能。

## 安装

* `git clone https://github.com/horan-geeker/nana.git`
* 项目的入口文件是 `bootstrap.lua` 你可以把你的路由写入 `router.lua` 文件,参考项目中的 `nginx.conf` 配置 `openresty` 
* 项目的配置文件都在 `config` 目录下 `app.lua`,其中 `db_name` 是数据库名, `user` `password` 是数据库的用户名密码, 如果你需要使用项目自带的登录注册等功能，需配置：`user_table_name` 用户表名, `login_id` 用于登录的列名，并且根据下边的数据库结构进行设计。

### 非必要的配置

* 项目跟目录执行 `cp env.example.lua env.lua`，复制 `env.example.lua` 到项目根目录下，命名为 `env.lua`，这个文件不包含在版本库里，密码等相关敏感信息可以写在这个文件。

## 文档

### 路由

> 路由文件在项目根目录 `router.lua`，如使用`POST`请求访问 `/login` 的 uri 时，交给 `auth_controller` 下的 `login()` 函数来处理：

```
route:post('/login', 'auth_controller', 'login')
```

同时也支持路由群组，使用中间件来解决问题，比如下边需要在 `注销` 和 `重置密码` 的时候验证用户需要处于登录态，利用路由中间件只需要在路由群组的地方写一句就ok了，这样就会在调用 `controller` 之前先调用 `middleware > authenticate.lua` 的 `handle()` 方法：

```
route:group({
        'authenticate',
    }, function()
        route:post('/logout', 'auth_controller', 'logout') -- http_method/uri/controller/action
        route:post('/reset-password', 'user_controller', 'resetPassword')
    end)
```

可以参考`router.lua`里边已有的路由，也可以任意修改里边已有的东西

### 中间件

> 中间件都需要写在 `middleware` 文件夹下，并且需要写上命名为 `handle()` 的方法
`中间件` 的设计模式解决了代码的复用，我们可以在中间件中自定义自己的东西，如`middleware > authenticate.lua`

```
function _M:handle()
    if not auth_service:check() then
        common:response(4,'no authorized in authenticate')
    end
end

```
你可以把你自定义的中间件写到 `middleware` 的文件夹下, 该文件夹下已有了一个示例中间件 `example_middleware.lua`

### 获取参数

```
local request = require("lib.request")
local args = request:all() -- 拿到所有参数，同时支持 get post 以及其他 http 请求
args.username -- 拿到username参数
```

### 验证数据

```
local validator = require('lib.validator')
local request = require("lib.request")
local args = request:all() -- 拿到所有参数
local ok,msg = validator:check(args, {
    name = {max=6,min=4}, -- 验证 name 参数长度为4-6位
    'password', -- 验证 password 参数需要携带
    id = {included={1,2,3}} -- 验证 id 参数需要携带且是 1, 2, 3 中的某一个
    })
```

### 数据库操作 ORM
默认的数据库操作都使用了 `ngx.quote_sql_str` 处理了 `sql注入问题`
```
local Model = require('models.model')
local User = Model:new('users') -- 初始化 `User` 模型,约定俗成 `User` 的模型对应 `users` 表名,当然你也可以修改 `new()` 的参数为其他名称
local user = User:where('username','=','cgreen'):where('password','=','xxxxxxx'):get() -- 拿到 username 字段的值是 `cgreen` 的，`password` 字段的值是 `xxxxxx` 的多条数据，注意返回是数组，`first()` 方法返回的是一条数据
local user = User:find(1) -- 拿到 `id` 为 1 的用户
User:where('name','=','xxx'):orwhere('name','=','yyy'):get() -- 获取 `name` 为 `xxx` 的或者 `yyy` 的 `user`
-- 创建一个用户
User:create({
	id=3,
	password='123456',
	name='horanaaa',
	email='horangeeker@geeker.com',
})
-- 更新一个用户
local ok, err = User:where('id', '=', user.id):update({
		name='test',
  })
if not ok then
    ngx.log(ngx.ERR, err)
end
-- 删除操作
ok,err = User:where('id','=','1'):delete()
	if not ok then
		ngx.log(ngx.ERR, err)
	end
```

#### 使用原生 sql 执行

> 注意需要自己去处理sql注入

* local res = Database:query(sql) -- 执行数据查询语言DQL,返回结果集
* local affected_rows, err = Database:execute(sql) -- 执行数据操纵语言DML,返回`受影响的行`或`false`和`错误信息`

### cookie

```
local cookie_obj = require("lib.cookie")
local cookie, err = cookie_obj:new()
config.time_zone -- 取到cookie里的属性，'UTF8'
-- 封装cookie对象来写入
local cookie_payload = {
    key = token_name, value = ''
}
cookie_payload.value = 'xxx'
local ok, err = cookie:set(cookie_payload)
if not ok then
    ngx.log(ngx.ERR, err)
    return false
end
```

### redis

```
local redis = require("lib.redis")
local ok,err = redis:set('key', 'value', 60) --seconds
if not ok then
    return false, err
end
local ok,err = redis:expire('key',60) --seconds 延长过期时间
if not ok then
    return false, err
end
local data, err = redis:get('key') --get
local ok,err = redis:del('key') --delete
if not ok then
    return false, err
end
```

### response

框架使用的 `common` 中的 `response` 方法通过定义数字来代表不同的`response`类型，你也可以直接写 ngx.say('') ngx.exit(ngx.OK),
在 `config > status.lua` 中可以增加返回类型
```
local common = require("lib.common")
common:response(1) -- 会去 `status.lua` 中找到 `1` 的错误信息，连同错误码 `1` 返回给前端
common:response(0,'ok') -- 如果你传了第二个参数，会覆盖 `status.lua` 中的原有错误码对应的错误信息
common:response(0, 'ok', data) -- 第三个参数用来传送数据,默认会进行 cjson.encode 所以只需要传数据即可
```

### http请求

使用了这个开源组件 https://github.com/pintsized/lua-resty-http

```
local http = require('lib.http')
local httpc = http.new()
local res, err = httpc:request_uri(url, {ssl_verify=false}) -- https 的请求出现异常可以带上这个参数，但是确保你是安全的
if not res then
    ngx.log(ngx.ERR, res, err)
    return res, err
end
local data = cjson.decode(res.body)
```

### random

#### 字母 + 数字

`random.token(10)` -- 长度为10的

#### 纯数字

`random.number(1000, 9999)`

### 根据ip获取地理位置

```
local ipLocation = require("lib.ip_location")
local ipObj, err = ipLocation:new(ngx.var.remote_addr)
local location, err = ipObj:location()
location.city
location.country
```

### 返回 response

在`config`目录下的`status.lua`定义了返回的状态码和`msg`内容,你可以在这里新增或修改你想要的状态码，在系统中使用 `common:response(status)`的方式返回响应内容，默认的格式是`{"status":0,"message":"ok","data":{}}`你可以通过修改`common.lua`的`response`方法来自定义不同的结构

## 推荐的编码风格

推荐在写一些中大型项目时，`controller` （对应项目中的`controllers文件夹`）里只对http请求进行处理，例如对参数的验证，返回`json`的格式等，而不要去处理商业逻辑，商业逻辑可以写在 `service` 里（对应项目中`services文件夹`），再从 `controller` 中调用，可以写出更清晰的代码，也方便将来单元测试

## 使用范例：内置用户认证，包含登录注册等功能

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/Nana%20%E6%9E%B6%E6%9E%84%E8%AE%BE%E8%AE%A1.png?raw=true)
使用中间件的模式解决用户登录注册等验证问题，你同时可以使用别的语言(Java PHP)来写项目的其他业务逻辑，

### qq群 284519473

### 联系作者 wechat

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)

## Lua framework for web API

It is a middleware to resolve user authenticate, you can use this to login or register user, and use other language(Java PHP) as downstream program to process other business logic at the same time.
The entrance of this framework is bootstrap.lua, and you can write your routes in `router.lua`. if URL doesn't match any route, it will be processed by downstream program

## reference Laravel framework styles

### middleware

Middleware can be used in `router.lua` and you can write middleware in `middleware` directory, there is a demo as `example_middleware.lua`

#### service provider

There are auth_service and route_service in `providers` directory.

## install

* We already have a nginx.conf in project, you can see it.
* All of your configuration files for Nana Framework are stored in the app.lua, and it has many config keys in that file, such as `db_name` which represents the database name, `user & password` that represents database username and password, `user_table_name` that represents the table name which you want store user data, `login_id` is a column name which is used for authentication.
* Write your routes in router.lua.

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

account_log
```
CREATE TABLE `account_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
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
