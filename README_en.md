# Nana

[中文文档](README.md)

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
