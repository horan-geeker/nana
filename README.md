# Nana

[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)  

[English Document](README_en.md)

`openresty` 是一个为高并发设计的异步非阻塞架构，而 `nana` 是基于 `openresty` 的 `restful api` 的 `MVC` 框架，项目集成了多个组件，目前支持丰富的功能。

目录

====

* [安装](#安装)
  * [使用 docker 安装](#使用-docker-安装)
  * [手动安装](#手动安装)
* [快速上手](#快速上手)
* [压力测试](#压力测试)
* [文档](#文档)
  * [配置](#配置)
  * [本地化](#本地化)
  * [路由](#路由)
  * [中间件](#中间件)
  * [控制器](#控制器)
    * [Service](#Service)
  * [Request](#Request)
    * [参数获取](#参数获取)
    * [发起 http 请求](#发起-http-请求)
  * [Response](#Response)
    * [定义全局 response 结构](#定义全局-response-结构)
  * [Cookie](#Cookie)
  * [数据库操作 ORM](#数据库操作-ORM)
    * [CURD](#CURD)
    * [排序](#排序)
    * [分页](#分页)
    * [使用原生 sql](#使用原生-sql)
  * [Redis](#Redis)
  * [综合](#综合)
    * [Random](#Random)
  * [Helper Function](#Helper-Function)
  * [代码规范](#代码规范)
* [用户 Auth API 接口说明](#用户-Auth-API-接口说明)
* [qq群 284519473](#qq群-284519473)
* [联系作者](#联系作者)

## 安装

### 使用 docker 安装

* 执行 `cp env.example.lua env.lua` 其中 `mysql_host` 是数据库地址，`db_name` 是数据库名， `mysql_user` 是数据库的用户名，`mysql_password` 数据库密码，`env` 用来在项目里判断环境，`env.lua` 不随版本库提交，可以帮助区分线上和本地环境的不同配置
* 构建 `docker build -t nana .`
* 运行 `docker run -p 80:80 --name=nana -v /host/path/nana:/app -d nana` 生产环境不需要 `mount` 到 `/app`，开发环境这样做较方便调试

### 手动安装

* `git clone https://github.com/horan-geeker/nana.git`
* 同上执行 `cp env.example.lua env.lua` 并配置其中的 `mysql redis`
* 配置 `nginx`，将 `content_by_lua_file` 指到框架的入口文件 `bootstrap.lua`，项目中的 `nginx/conf/nginx.conf` 文件主要用于 `docker` 环境，你可以参考来配置 `openresty`

> 如果你需要使用项目自带的登录注册等功能，需配置 `config/app.lua`：`user_table_name` 用户表名，`login_id` 用于登录的列名，并且在根目录执行 `chmod 755 install.sh && ./install.sh` 迁移数据库结构。

## 快速上手

> router.lua

```lua

function _M:routes()
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
    response:json(0, 'request args', args) -- return response 200 and json content
end

return _M

```

## 压力测试

### 单次 mysql 数据库查询

#### mac 4核 i7 16G 内存 固态硬盘

```shell
ab -c 100 -n 10000 -k http://nana/user/1

---
Requests per second:    3125.76 [#/sec] (mean)
Time per request:       31.992 [ms] (mean)
---
```

## 文档

### 项目配置

* 项目的配置文件主要放在 `config/app.lua`
* 状态码的配置文件主要放在 `config/status.lua`

### 本地化

通过给 `ngx.ctx.locale` 赋值来更换语言环境，如：
`ngx.ctx.locale = zh`

### 路由

#### 支持 http 请求类型

* GET
* POST
* PATCH
* PUT
* DELETE
* HEAD

> 路由文件在项目根目录 `router.lua`，如使用`POST`请求访问 `/login` 的 uri 时，交给 `auth_controller` 下的 `login()` 函数来处理：

```lua
route:post('/login', 'auth_controller', 'login')
```

#### 路由群组

路由群组目前主要的作用是使用中间件来解决一些问题，比如下边需要在 `注销` 和 `重置密码` 的时候验证用户需要处于登录态，利用路由中间件只需要在路由群组的地方写一句就ok了，这样就会在调用 `controller` 之前先调用 `middleware > authenticate.lua` 的 `handle()` 方法：

```lua
route:group({
        'authenticate',
    }, function()
        route:post('/logout', 'auth_controller', 'logout') -- http_method/uri/controller/action
        route:post('/reset-password', 'user_controller', 'resetPassword')
    end)
```

#### 动态路由

使用花括号来代表传递的参数，如：  
`route:get("/users/{user_id}/comments/{comment_id}", 'user_controller', 'comments')`
可匹配`/users/1/comments/2`，在`comments action`里，直接写上两个参数即可，命名不进行约束

```lua
function _M:comments(user_id, comment_id)
    ngx.log(ngx.ERR, user_id, comment_id)
    common:response(0, 'comments', {user_id=user_id, comment_id=comment_id})
end
```

可以参考`router.lua`里边已有的路由，也可以任意修改里边已有的东西

### 中间件

> 中间件都需要写在 `middleware` 文件夹下，并且需要写上命名为 `handle()` 的方法
`中间件` 的设计模式解决了代码的复用，我们可以在中间件中自定义自己的东西，如`middleware > authenticate.lua`

```lua
function _M:handle()
    if not auth_service:check() then
        common:response(4,'no authorized in authenticate')
    end
end

```
你可以把你自定义的中间件写到 `middleware` 的文件夹下, 该文件夹下已有了一个示例中间件 `example_middleware.lua`

### 控制器

在路由匹配的`uri`，第二个参数就是控制器的路径，默认都是在`controllers`文件夹下的文件名称，第三个参数是对应该文件的方法，可在方法中返回 response 响应。

#### Service

在项目逻辑较为复杂的情况下，可复用的情况也比较普遍，`controller`里如果有可以抽离出来的逻辑，我们可以把这部分写在`service`里（对应项目中`services文件夹`），其实如果严格规范的开发`controller`只对http请求进行处理，例如对参数的验证，返回`json`的格式等，而不用去处理商业逻辑，商业逻辑可以写在 `service` 里，再从 `controller` 中调用，可以写出更清晰的代码，也方便将来单元测试

### Request

#### 参数获取

```
local request = require("lib.request")
local args = request:all() -- 拿到所有参数，同时支持 get post 以及其他 http 请求
args.username -- 拿到username参数
```

#### 发起 http 请求

使用了这个开源组件 https://github.com/pintsized/lua-resty-http

```lua
local http = require('lib.http')
local httpc = http.new()
local res, err = httpc:request_uri(url, {ssl_verify=false}) -- https 的请求出现异常可以带上这个参数，但是确保你是安全的
if not res then
    ngx.log(ngx.ERR, res, err)
    return res, err
end
local data = cjson.decode(res.body)
```

### Response

框架使用的 `lib/response.lua` 中的 `json` 方法通过定义数字来代表不同的`response`类型，该方法支持三四个参数

1. 第一个参数是状态码，16进制状态码对应 `config/status.lua`
2. 第二个参数是错误码文案，文案根据第一个参数对应 `config/status.lua` 中的文案
3. 第三个参数是需要向前端返回的数据，可省略
4. 第四个参数是返回的 `http 状态码`，可省略，默认是200

```lua
response:json(0x000000, 'success message', data, 200)
--[[
{
"msg": "success message",
"status": 0,
"data": {}
}
--]]
```

或者返回错误信息

```lua
response:json(0x000001)
--[[
{
"msg": "验证错误",
"status": 1,
"data": {}
}
--]]
```

当然你可以在 `config > status.lua` 中可以增加返回状态码

#### 定义全局 response 结构

在 `config` 目录下的 `status.lua` 定义了返回的 `status` 和 `msg` 内容，默认返回的格式是 `{"status":0,"message":"ok","data":{}}` 你可以通过修改 `lib/response.lua` 的 `json` 方法来自定义不同的结构

### 验证数据

```lua
local validator = require('lib.validator')
local request = require("lib.request")
local args = request:all() -- 拿到所有参数
local ok,msg = validator:check(args, {
    name = {max=6,min=4}, -- 验证 name 参数长度为4-6位
    'password', -- 验证 password 参数需要携带
    id = {included={1,2,3}} -- 验证 id 参数需要携带且是 1, 2, 3 中的某一个
    })
```

### Cookie

在 `helper.lua` 中包含了 `cookie` 的辅助方法，全局已经引用了该文件，可以直接使用函数

```lua
set_cookie(key, value, expire) -- expire 是可选参数，单位是时间戳，精确到秒
get_cookie(key)
```

### 数据库操作 ORM

> 默认的数据库操作都使用了 `ngx.quote_sql_str` 处理了 `sql注入问题`
以下增删改查都需要先获取模型 `table` 可类比 `class`

```lua
-- 获取模型，模型的表名对应 `models/user.lua` 中 `Model:new()` 的第一个参数 `users`  
local User = require("models.user")
```

#### 检索

```lua
-- 拿到 users 表 `id` 为 1 的用户
local user = User:find(1)

-- 获取表中所有数据
local users = User:all()

-- 返回 users 表中 username 字段的值是 `cgreen` 的，`password` 字段的值是 `xxxxxx` 的多条数据，注意此处返回是 table 数组，`first()` 方法返回的是单条数据
local user = User:where('username','=','cgreen'):where('password','=','xxxxxxx'):get()

-- 返回 `name` 为 `xxx` 或者 `yyy` 的所有用户 table 数组
local users = User:where('name','=','xxx'):orwhere('name','=','yyy'):get()
```

#### 新增

```lua
-- 创建一个用户
User:create({
    id=3,
    password='xxxxxx',
    name='hejunwei',
    email='heunweimake@gmail.com',
})
```

#### 更新

```lua
-- 更新 id = 1 的 user 的 name 为 test, avatar 为 NULL
local ok, err = User:where('id', '=', 1):update({
        name='test',
        avatar='null'
  })
if not ok then
    ngx.log(ngx.ERR, err)
end
```

#### 删除

```lua
-- 删除 id = 1 的用户
local ok, err = User:where('id','=','1'):delete()
if not ok then
    ngx.log(ngx.ERR, err)
end

-- 软删除
local ok, err = User:where('id','=','1'):soft_delete()
if not ok then
    ngx.log(ngx.ERR, err)
end
```

> 软删除将 deleted_at 字段置为当前时间，字段名在 `models/model.lua` 中配置

#### 排序

`orderby(column, option)`方法，第一个参数传入排序的列名，第二个参数默认为`ASC` 也可以传入 `ASC 正序 或 DESC 倒序`(不区分大小写)，`Post:orderby('created_at'):get()`

#### 分页

```lua
local userPages = User:paginate(1)
-- 返回如下结构：
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

当不存在上一页（下一页）时，`prev_page`（`next_page`）为 `null`

#### 使用原生 sql

> 使用原生 sql 时需要注意自己去处理 `sql 注入`  
`local Database = require('lib.database')`

* local res = Database:query(sql) -- 执行数据查询语言DQL,返回结果集
* local affected_rows, err = Database:execute(sql) -- 执行数据操纵语言DML,返回`受影响的行`或`false`和`错误信息`

### 模型间关系

> 目前只支持一层关系，单个模型进行关联，之后会进行完善，该方法只是对开发友好，完全可以用 where 条件限定替代

#### 一对多

以 user 关联 post 为例，在 user 模型中定义关系 `has_many`，参数：

1. 关联模型
2. 外表 id
3. 本表 id

```lua
-- user.lua
local Model = require("models.model")
local Post = require('models.post')

local User = Model:new('users')

function User:posts()
    return User:has_many(Post, 'user_id', 'id')
end

return User

-- post.lua
local Model = require("models.model")
local config = require("config.app")

local Post = Model:new('posts')

return Post

-- controller 调用
local user_and_post = User:where('id', '=', user_id):with('posts'):get()
--[[
[
    {
        "name":"horan",
        // 返回值会带上 post 为 key 的对象
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

#### 多对一

以 post 关联 tag 为例，在 post 模型中定义关系 `belongs_to`，参数：

1. 关联模型
2. 外表 id
3. 本表 id

```lua
-- post.lua
local Model = require("models.model")
local Tag = require('models.tag')
local config = require("config.app")

local Post = Model:new('posts')

function Post:tag()
    return Post:belongs_to(Tag, 'id', 'tag_id')
end

return Post

-- tag.lua
local Model = require("models.model")
local config = require("config.app")

local Tag = Model:new('tags')

return Tag

-- controller 调用
local posts_with_tag = Post:where('id', '=', 1):with('tag'):first()
--[[
{
    "id":1,
    "post_tag_id":1,
    "user_id":1,
    "title":"article title",
    "tag":{
        "id":1,
        "type":"openresty"
    },
    "content":"article content"
}
--]]
```

### Redis

```lua
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

#### resty redis

系统也引用了`resty redis`
`local restyRedis = require('lib.resty_redis')`

### 综合

#### Random

`local random = require('lib.random')`

##### 字母 + 数字

`random.token(10)` -- 长度为10的

##### 纯数字

`random.number(1000, 9999)`

### Helper Function

系统在 `bootstrap.lua` 默认已经全局加载 `Core:helpers()`

#### 反转 table

可以反转 array 类型的 table

```lua
table_reverse(tab) -- return reverse table
```

#### table 按值删除

```lua
table_remove(tab, {'item1', 'item2'})
```

#### 按 key 排序的迭代器

> lua 中的`hash table`按`key`排序与其他语言不同，我们需要自己实现一个迭代器来遍历排好序的`table`

```lua
for k,v in pairsByKeys(hashTable) do
    ...
end
```

## 代码规范

* 变量名和函数名均使用下划线风格
* 与数据库相关模型变量名采用大写字母开头的驼峰

## 用户 Auth API 接口说明

> 所有接口均返回json数据，第一次会有二到三个参数

```json
{
    "msg":"ok",
    "status":0,
    "data":{}
}
```

> 其中 data 可不存在

### 注册

```shell
curl -X "POST" "http://localhost:8888/register" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "phone": "135xxxxxxxx",
  "sms_code": "9492",
  "password": "123456"
}'
```

#### 参数说明

* phone 手机号
* sms_code 手机验证码
* password 密码

#### 返回响应

```json
{
    "msg":"ok",
    "status":0
}
```

### 登录

```shell
curl -X "POST" "http://localhost:8888/login" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "phone": "135xxxxxxxx",
  "password": "123456"
}'
```

#### 参数说明

* phone 手机号
* password 密码

#### 返回响应

```json
{
    "msg":"ok",
    "status":0,
    "data":{
        "nickname":"HDC1kxzk",
        "created_at":"2018-06-28 06:39:24","updated_at":"2018-07-02 13:51:49",
        "id":2,
        "avatar":"",
        "phone":"13571899655",
        "email":""
    }
}
```

### 发送短信(未登录)

```shell
curl -X "POST" "http://localhost:8888/send/sms" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "phone": "135********"
}'
```

#### 参数说明

* phone 手机号

#### 返回响应

```json
{
    "msg":"ok",
    "status":0
}
```

### 重置密码

```shell
curl -X "PATCH" "http://localhost:8888/reset-password" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "old_password": "1234567",
  "new_password": "123456"
}'
```

#### 参数说明

* old_password 旧密码
* new_password 新密码
* 需要携带 cookie token

#### 返回响应

```json
{
    "msg":"ok",
    "status":0
}
```

### 退出登录

```shell
curl -X "POST" "http://localhost:8888/logout" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{}'
```

#### 参数说明

* 需要携带 cookie token

#### 返回响应

```json
{
    "msg":"ok",
    "status":0
}
```

### 获取用户信息

```shell
curl "http://localhost:8888/userinfo"
```

#### 参数说明

* 需要携带 cookie token

#### 返回响应

```json
{
    "msg":"ok",
    "status":0,
    "data":{
        "nickname":"HDC1kxzk",
        "created_at":"2018-06-28 06:39:24","updated_at":"2018-07-02 13:51:49",
        "id":2,
        "avatar":"",
        "phone":"13571899655",
        "email":""
    }
}
```

## qq群 284519473

## 联系作者

### mail

#### 13571899655@163.com

### wechat

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)
