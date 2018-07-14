# Nana
[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)
[English Document](README_en.md)

目录
====

* [介绍](#介绍)
  * [为 api 设计的 lua 框架](#为-api-设计的-lua-框架)
  * [中间件模式](#中间件模式)
* [安装](#安装)
  * [使用 docker 安装](#使用-docker-安装)
  * [手动安装](#手动安装)
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
  * [Helper Function](#Helper-Function)
  * [综合](#综合)
    * [Random](#Random)
    * [IP 定位](#IP-定位)
* [用户通行证 API 接口说明](#用户通行证-API-接口说明)
* [TODO list](#TODO-list)
* [qq群 284519473](#qq群-284519473)
* [联系作者](#联系作者)

## 介绍

### 为 api 设计的 lua 框架

`openresty` 是一个为高并发设计的异步非阻塞架构，而 `nana` 为了更好的使用 `openresty` 而诞生，项目集成了多个组件，目前支持丰富的功能。如果你单纯使用 lua 来做 http 服务器的话，在 nginx 配置中使用 content_by_lua 来指定入口文件，否则按照项目默认的模式进行安装

### 中间件模式

通过 `access_by_lua` 阶段使得 lua 成为中间件，再通过 `proxy_pass` 指定下游主机，一个 api 请求会先通过 nana，如果匹配到了路由则执行对应控制器里的逻辑，如果没有匹配到路由则会直接执行 `proxy_pass` 指定的下游主机，如果匹配到了路由，但是控制器没有返回 body（也即是代码没有执行`common:response()` 或 `ngx.say()`）仍然会是在执行完 nana 的逻辑之后并且执行下游主机的逻辑，所以说，`nana` 在这里是一个系统层面的中间件

## 安装

### 使用 docker 安装

* 执行 `cp env.example.lua env.lua` 其中 `mysql_host` 是数据库地址，`db_name` 是数据库名， `mysql_user` 是数据库的用户名，`mysql_password` 数据库密码，`env` 用来在项目里判断环境，`env.lua` 不随版本库提交，可以帮助区分线上和本地环境的不同配置
* 执行 `cp .env.example .env` 这是 docker 配置的环境变量，通过修改 `PROXY_PASS_URL` 来指定下游的主机（实际上直接替换了 `nginx` 中的 `proxy_pass`），`API_SERVER_NAME` 是替换了 `nginx` 中的 `server_name`
* 执行 `docker-compose up`

### 手动安装

* `git clone https://github.com/horan-geeker/nana.git`
* 同上执行 `cp env.example.lua env.lua` 并配置其中的数据库
* 执行 `sudo chmod 755 install.sh && ./install.sh` 来生成数据库结构
* 配置 `nginx`，项目的入口文件是 `bootstrap.lua` 配置的时候指到这里就好，项目中的 `nginx/conf/nginx.conf.raw` 文件主要用于 `docker` 环境，你可以参考来配置 `openresty`

> 如果你需要使用项目自带的登录注册等功能，需配置：`user_table_name` 用户表名，`login_id` 用于登录的列名，并且在根目录执行 `chmod 755 install.sh && ./install.sh` 迁移数据库结构。

## 文档

### 配置

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

```
route:post('/login', 'auth_controller', 'login')
```

#### 路由群组

路由群组目前主要的作用是使用中间件来解决一些问题，比如下边需要在 `注销` 和 `重置密码` 的时候验证用户需要处于登录态，利用路由中间件只需要在路由群组的地方写一句就ok了，这样就会在调用 `controller` 之前先调用 `middleware > authenticate.lua` 的 `handle()` 方法：

```
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

```
function _M:comments(user_id, comment_id)
    ngx.log(ngx.ERR, user_id, comment_id)
    common:response(0, 'comments', {user_id=user_id, comment_id=comment_id})
end
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

### 控制器

在路由匹配的`uri`，第二个参数就是控制器的路径，默认都是在`controllers`文件夹下的文件名称，第三个参数是对应该文件的方法，你可以在方法中返回 response 响应，也可以在处理完业务逻辑之后不返回响应，交由下游继续处理

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

### Response

框架使用的 `common` 中的 `response` 方法通过定义数字来代表不同的`response`类型，你也可以直接写 ngx.say('') ngx.exit(ngx.OK),
在 `config > status.lua` 中可以增加返回类型
```
local common = require("lib.common")
common:response(1) -- 会去 `status.lua` 中找到 `1` 的错误信息，连同错误码 `1` 返回给前端
common:response(0,'ok') -- 如果你传了第二个参数，会覆盖 `status.lua` 中的原有错误码对应的错误信息
common:response(0, 'ok', data) -- 第三个参数用来传送数据,默认会进行 cjson.encode 所以只需要传数据即可
```

#### 定义全局 response 结构

在`config`目录下的`status.lua`定义了返回的状态码和`msg`内容,你可以在这里新增或修改你想要的状态码，在系统中使用 `common:response(status)`的方式返回响应内容，默认的格式是`{"status":0,"message":"ok","data":{}}`你可以通过修改`common.lua`的`response`方法来自定义不同的结构

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

### Cookie

在 `helper.lua` 中包含了 `cookie` 的辅助方法，全局已经引用了该文件，可以直接使用函数
```
set_cookie(key, value, expire) -- expire 是可选参数，单位是时间戳，精确到秒
get_cookie(key)
```

### 数据库操作 ORM

默认的数据库操作都使用了 `ngx.quote_sql_str` 处理了 `sql注入问题`

#### CURD

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

#### 排序

`orderby(column, option)`方法，第一个参数传入排序的列名，第二个参数默认为`ASC` 也可以传入 `ASC 正序 或 DESC 倒序`(不区分大小写)，`Post:orderby('created_at'):get()`

#### 分页

模型支持`paginate(per_page)`方法，需要传入当前页码,`User:paginate(1)`,返回值如下结构：

```
{
    "prev_page": null,
    "total": 64,
    "data": [
        {...},
        {...},
    ],
    "next_page": 2
}
```

当不存在下一页时，`next_page`为`null`

#### 使用原生 sql

> 使用原生 sql 是需要注意自己去处理sql注入  
`local Database = require('lib.database')`

* local res = Database:query(sql) -- 执行数据查询语言DQL,返回结果集
* local affected_rows, err = Database:execute(sql) -- 执行数据操纵语言DML,返回`受影响的行`或`false`和`错误信息`

### Redis

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

#### IP 定位

目前使用离线的 dat 文件(`lib/17monipdb.dat`)进行 ip 定位，长时间后可能会有误差问题

```
local ip_location = require("lib.ip_location")
local ipObj, err = ip_location:new(ngx.var.remote_addr)
local location, err = ipObj:location()
location.city
location.country
```

### Helper Function

系统在 `bootstrap.lua` 默认已经全局加载 `Core:helpers()`

#### 反转 table

可以反转 array 类型的 table

```
table_reverse(tab) -- return reverse table
```

#### table 按值删除

```
table_remove(tab, {'item1', 'item2'})
```

#### 按 key 排序的迭代器

> lua 中的`hash table`按`key`排序与其他语言不同，我们需要自己实现一个迭代器来遍历排好序的`table`

```
for k,v in pairsByKeys(hashTable) do
    ...
end
```

## 用户通行证 API 接口说明

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/Nana%20%E6%9E%B6%E6%9E%84%E8%AE%BE%E8%AE%A1.png?raw=true)  
使用中间件的模式解决用户登录注册等验证问题，你同时可以使用别的语言(Java PHP)来写项目的其他业务逻辑，

### 接口总体格式
> 所有接口均返回json数据，第一次会有二到三个参数

```
{
    "msg":"ok",
    "status":0,
    "data":{}
}
```

> 其中 data 可不存在

### 注册

```
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

```
{
    "msg":"ok",
    "status":0
}
```

### 登录

```
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

```
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

```
curl -X "POST" "http://localhost:8888/send/sms" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{
  "phone": "135********"
}'
```

#### 参数说明

* phone 手机号

#### 返回响应

```
{
    "msg":"ok",
    "status":0
}
```

### 重置密码

```
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

```
{
    "msg":"ok",
    "status":0
}
```

## 退出登录

```
curl -X "POST" "http://localhost:8888/logout" \
     -H 'Content-Type: application/json; charset=utf-8' \
     -d $'{}'
```

#### 参数说明

* 需要携带 cookie token

#### 返回响应

```
{
    "msg":"ok",
    "status":0
}
```

### 获取用户信息

```
curl "http://localhost:8888/userinfo"
```

#### 参数说明

* 需要携带 cookie token

#### 返回响应

```
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

## TODO list

* 解析 multipart/form-data 请求
* 增加阿里云短信服务
* 登录增加失败次数限制
* 集成国际短信验证码业务，twilio
* 密码加密

## qq群 284519473

## 联系作者

### mail

#### 13571899655@163.com

### wechat

![img](https://github.com/horan-geeker/hexo/blob/master/imgs/wechat-avatar.jpeg?raw=true)