#!/bin/bash
# env_file="env.lua"
# if !(test -e "$env_file")
# then
#     echo "file not found"
# fi
# cat $env_file|grep "mysql_host"|while read line
# do
#     echo $line
# done
MYSQL_HOST="mysql-host"
MYSQL_USER="root"
MYSQL_PASSWORD="root"
mysql -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASSWORD -e "\
CREATE DATABASE IF NOT EXISTS lua_china;
USE lua_china;
CREATE TABLE IF NOT EXISTS \`users\` (\
  \`id\` int(10) unsigned NOT NULL AUTO_INCREMENT,\
  \`nickname\` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',\
  \`phone\` varchar(255) COLLATE utf8_unicode_ci NOT NULL,\
  \`email\` varchar(255) COLLATE utf8_unicode_ci NOT NULL,\
  \`password\` varchar(255) COLLATE utf8_unicode_ci NOT NULL,\
  \`avatar\` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',\
  \`created_at\` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,\
  \`updated_at\` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,\
  PRIMARY KEY (\`id\`)\
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
CREATE TABLE IF NOT EXISTS \`user_logs\` (
  \`id\` int(11) NOT NULL AUTO_INCREMENT,
  \`ip\` varchar(255) NOT NULL DEFAULT '',
  \`city\` varchar(10) NOT NULL DEFAULT '',
  \`country\` varchar(10) NOT NULL DEFAULT '',
  \`type\` varchar(255) NOT NULL DEFAULT '',
  \`time_at\` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (\`id\`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
"