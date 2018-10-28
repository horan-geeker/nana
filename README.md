# lua-china-api

[![GitHub release](https://img.shields.io/github/release/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/releases/latest)
[![license](https://img.shields.io/github/license/horan-geeker/nana.svg)](https://github.com/horan-geeker/nana/blob/master/LICENSE)
![Build status](https://travis-ci.org/luaChina/lua-china-api.svg?branch=master)  
[English Document](README_en.md)

## 技术选型

* openresty nana
* mysql 5.7
* redis

## 自动化部署

* travis-ci
* docker-hub

## 监控系统

### 系统资源监控

* Grafana + prometheus + redis_exporter

### 站点监控

* 阿里云监控系统

## todo list

* 增加文件上传功能，用户可以上传头像
* 增加验证码（选型：coinhive挖矿验证/极验），目前短信在裸奔
* 集成区块链技术，对每篇文章和评论进行积分token激励，并把文章和评论内容上链，记录所有修改历史并可回溯(在站内用户稳定后作为一个大版本迭代)