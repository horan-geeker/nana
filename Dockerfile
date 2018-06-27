FROM openresty/openresty:1.13.6.1-trusty

MAINTAINER he jun wei "13571899655@163.com"

RUN apt-get update && apt-get install -y mysql-client

ENV WORK_DIR /var/www/nana

WORKDIR ${WORK_DIR}
EXPOSE 80
