FROM openresty/openresty:1.13.6.1-trusty

MAINTAINER junwei he "13571899655@163.com"

COPY . /app
COPY ./docker/nginx/conf/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

WORKDIR /app

EXPOSE 80
