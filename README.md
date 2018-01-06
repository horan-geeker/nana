# nana

## Focus On User Authenticate & A lua framework for web API
A middleware to resolve user authenticate, you can use this to login or register and use other language(Java PHP) to process other business logic  
This framework start with bootstrap.lua, you can write your route in router.lua, not matched route will send free  

## ref some PHP framework style

#### middleware
middleware can be used in router.lua and you can write middleware in middlewares directory, there is a demo as example_middleware.lua  

#### service provider
there are auth_service and route_service in providers directory  

## install
* we already have a nginx.conf in project, you can see it
* there is a config file in config directory named app.lua, db_name is database name, user & password is database username and password, user_table_name is what table name you want store user data, login_id means username or email or phone no, that can be used to login in
* write routes in router.lua

## database structure
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
---| ---- | --- | --- | -------- | ------ | ---------- | ----------
 1 |horan | 13571899655@163.com|3be64**| http://avatar.com | 2017-11-28 07:46:46 | 2017-11-28 07:46:46

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

## 致力于用户通行证 & 为 api 设计的 lua 框架
使用中间件的模式解决用户登录注册等验证问题，你同时可以使用别的语言(Java PHP)来写项目的其他业务逻辑，项目的入口文件是 bootstrap.lua 你可以把你的路由写入 router.lua 文件，没有匹配到的路由会被放过（原因：如果这是一个网关，为下游别的服务提供用户认证，在不影响下游接口的情况下都会放过未匹配到的路由）。

## 参考PHP的框架规范设计（Laravel）

#### 中间件
路由中集成了中间件的模式，你可以把你的中间件写到 middlewares 的文件夹下, 该文件夹下已有了一个示例中间件 example_middleware.lua

#### 服务提供者
目前只有两个服务提供者，用户认证服务和路由服务

## 安装
* 配置 nginx 参考项目中的 nginx.conf
* 配置项目 config 目录下的 app.lua, db_name 是数据库名, user password 是数据库的用户名密码, user_table_name 是用户表名, login_id 是用于登录的列名
* router.lua 里写入特定路由以及下游需要验证的路由

## 项目还在开发中，目前以及完善的是登录，注册，注销，获取用户基本信息的功能

## 继续开发的 DEMO
these content also in controller index.lua

```
validator:check 方法支持对数据的校验和反馈
'id' 表示只校验是否存在该值（结合request）
也可以带着条件 max,min,表示校验的字符串长度，included={1,2,3}表示校验该值在此范围内
```
local validator = require('lib.validator')
local ok,msg = validator:check({
	name = {max=6,min=4},
	'password',
	'id'
	},request)

if not ok then
	ngx.say(msg)
end
```
Model 对象支持灵活的数据库操作
where方法可以结合get方法链式调用来取一条或多条数据
update结合where方法来更新一条或多条数据
```
local Model = require('models.model')
local User = Model:new('users')
ngx.say('where demo:\n',cjson.encode(User:where('username','=','cgreen'):where('password','=','7c4a8d09ca3762af61e59520943dc26494f8941b'):get()))
-- {"password":"7c4a8d09ca3762af61e59520943dc26494f8941b","gender":"?","id":99,"username":"cgreen","email":"jratke@yahoo.com"}

ngx.say('orwhere demo:\n',cjson.encode(User:where('id','=','1'):orwhere('id','=','2'):get()))
-- {"password":"7c4a8d09ca3762af61e59520943dc26494f8941b","gender":"?","id":1,"username":"hejunwei","email":"hejunweimake@gmail.com"},
-- {"password":"7c4a8d09ca3762af61e59520943dc26494f8941b","gender":"?","id":2,"username":"ward.antonina","email":"hegmann.bettie@wolff.biz"}

local Admin = Model:new('admins')
local admin = Admin:find(1)
ngx.say('find demo:\n',cjson.encode(admin))
-- {"password":"d033e22ae348aeb5660fc2140aec35850c4da997","id":1,"email":"hejunwei@gmail.com","name":"admin"}
--Admin:update({name='update demo'}):where('id','=','3'):query()
Admin:update({
		name='update test',
		password="111111"
	}):where('id','=',3):query()

Admin:create({
	id=3,
	password='123456',
	name='horanaaa',
	email='horangeeker@geeker.com',
})
```
