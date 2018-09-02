FROM openresty/openresty:1.13.6.1-trusty

MAINTAINER he jun wei "13571899655@163.com"

COPY . /app
COPY ./env.example.lua ./app/env.lua
COPY ./docker/nginx/conf/nginx.conf.prod /usr/local/openresty/nginx/conf/nginx.conf

WORKDIR /app

RUN apt-get update && apt-get install -y mysql-client

EXPOSE 80
