return {
    env = "dev", -- dev/prod
    mysql_host = "127.0.0.1", -- mysql host
    mysql_port = 3306, -- mysql port
    mysql_user = "root", -- mysql user
    mysql_password = "root", -- mysql password
    mysql_pool_timeout = 10000, -- mysql pool timeout
    mysql_pool_size = 10000, -- mysql pool size
    db_name = "nana", -- mysql database name
    db_timeout = 10000, -- mysql timeout
    redis_host = "127.0.0.1", -- redis host
    redis_port = 6379, -- redis port
    sendcloud = {           -- (options)sendcloud sms service
        SMSKEY = "xxxxx",
        SMSUSER = "xxx",
        TEMPLATEID = 13265
    }
}
