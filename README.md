# nana

## A lua framework for web API
start with bootstrap.lua, you can write your route in router.lua, not matched route will send free  
项目的入口文件是 bootstrap.lua 你可以把你的路由写入 router.lua 文件，没有匹配到的路由会被放过（原因：如果这是一个网关，为下游别的服务提供用户认证，在不影响下游接口的情况下都会放过未匹配到的路由）。

## ref some PHP framework style

## 参考PHP的框架规范设计（Laravel）

#### middleware

#### 中间件
middleware can be used in router.lua and you can write middleware in middlewares directory, there is a demo as example_middleware.lua  
路由中集成了中间件的模式，你可以把你的中间件写到 middlewares 的文件夹下, 该文件夹下已有了一个示例中间件 example_middleware.lua

## DEMO

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

Admin:insert({
	id=3,
	password='123456',
	name='horanaaa',
	email='horangeeker@geeker.com',
})
```
