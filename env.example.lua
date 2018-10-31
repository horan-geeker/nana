return {
    env = "dev", -- dev/prod
    mysql_host = "10.31.231.178", -- mysql host
    mysql_port = 3306, -- mysql port
    mysql_user = "root", -- mysql user
    mysql_password = "root", -- mysql password
    mysql_pool_timeout = 10000, -- mysql pool timeout
    mysql_pool_size = 10000, -- mysql pool size
    db_name = "lua_china", -- mysql database name
    db_timeout = 10000, -- mysql timeout
    redis_host = "10.31.231.178", -- redis host
    redis_port = 6379, -- redis port
    sendcloud = {
        SMSKEY = "",
        SMSUSER = "LuaChina",
        TEMPLATEID = 13265
    }
}
