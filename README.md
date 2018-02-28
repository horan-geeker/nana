# nana

## 为 api 设计的 lua 框架
`openresty` 是一个为高并发设计的异步非阻塞架构，而 `nana` 为了更好的使用 `openresty` 而诞生，项目集成了多个组件，目前支持丰富的功能。

## 安装
* 项目的入口文件是 `bootstrap.lua` 你可以把你的路由写入 `router.lua` 文件,参考项目中的 `nginx.conf` 配置 `nginx` 
* 复制 `env.example.lua` 到项目根目录下，命名为 `env.lua`，项目中的配置需要使用这个文件，这个文件不包含在版本库里，密码等相关敏感信息可以写在这个文件。 
* 项目的配置文件都在 `config` 目录下，其中的 `app.lua` 包含多个 key, `db_name` 是数据库名, `user` `password` 是数据库的用户名密码, 如果你需要使用项目自带的登录注册等功能，需要配置：`user_table_name` 用户表名, `login_id` 用于登录的列名。
* `router.lua` 里写入特定路由以及下游需要验证的路由,当然你需要创建自己的 `controller` 文件。。

## 文档

#### 路由
如使用`POST`请求访问 `/login` 的 uri 时，交给 `auth_controller` 下的 `login()` 函数来处理：`route:post('/login', 'auth_controller', 'login')`, 同时也支持路由群组，使用中间件来解决问题，项目的路由文件在根目录下的`router.lua`可以参考里边已有的功能，也可以任意修改里边已有的东西。

#### 中间件
`中间件` 的设计模式解决了代码的复用，比如说我们的项目中很多地方需要验证用户是否登录，普通情况下我们把验证的代码写在每一个处理`http`请求的`action()`方法里，显得很冗余修改起来也较为困难，比如下边需要在 `注销` 和 `重置密码` 的时候验证用户需要处于登录态，利用中间件只需要在路由的地方写一句就ok了，这样就会在调用 `controller` 之前先调用 `middlewares > authenticate.lua` 的 `handle()` 方法：
```
route:group({
        'authenticate',
    }, function()
        route:post('/logout', 'auth_controller', 'logout') -- http_method/uri/controller/action
        route:post('/reset-password', 'user_controller', 'resetPassword')
    end)
```
我们在路由中集成了中间件的模式，你可以把你自定义的中间件写到 `middlewares` 的文件夹下, 该文件夹下已有了一个示例中间件 `example_middleware.lua`

#### 获取参数
```
local request = require("lib.request")
local args = request:all() -- 拿到所有参数，同时支持 get post 以及其他 http 请求
args.username -- 拿到username参数
```

#### 验证数据
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

#### 数据库操作 ORM
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

#### cookie
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
#### redis
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
local data = redis:get('key') --get
local ok,err = redis:del('key') --delete
if not ok then
    return false, err
end
```
#### response
框架使用的 `common` 中的 `response` 方法通过定义数字来代表不同的`response`类型，你也可以直接写 ngx.say ngx.exit(ngx.OK),
在 `config > status.lua` 中可以增加返回类型
```
local common = require("lib.common")
common:response(1, msg)
```
#### 根据ip获取地理位置
```
local ipLocation = require("lib.ip_location")
local ipObj, err = ipLocation:new(ngx.var.remote_addr)
local location, err = ipObj:location()
location.city
location.country
```

## 推荐的编码风格
推荐在写一些中大型项目时，`controller` （对应项目中的`controllers文件夹`）里只对http请求进行处理，例如对参数的验证，返回`json`的格式等，而不要去处理商业逻辑，商业逻辑可以写在 `service` 里（对应项目中`services文件夹`），再从 `controller` 中调用，可以写出更清晰的代码，也方便将来单元测试

## 使用范例：内置用户认证，包含登录注册等功能
![img](https://github.com/horan-geeker/hexo/blob/master/imgs/Nana%20%E6%9E%B6%E6%9E%84%E8%AE%BE%E8%AE%A1.png?raw=true)  
使用中间件的模式解决用户登录注册等验证问题，你同时可以使用别的语言(Java PHP)来写项目的其他业务逻辑，

#### qq群 284519473

#### 联系作者 wechat
![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)

## Lua framework for web API
It is a middleware to resolve user authenticate, you can use this to login or register user, and use other language(Java PHP) as downstream program to process other business logic at the same time. 
The entrance of this framework is bootstrap.lua, and you can write your routes in `router.lua`. if URL doesn't match any route, it will be processed by downstream program  

## reference some PHP framework styles

#### middleware
Middleware can be used in `router.lua` and you can write middleware in `middlewares` directory, there is a demo as `example_middleware.lua`  

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
