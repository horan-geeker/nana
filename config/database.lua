local env = require('env')

return {
    user_table_name = "users",
    
    redis = {
        host = env.redis_host,
        port = env.redis_port
    },

    mysql = {
        db_name = env.mysql_config.db_name,
        write = { -- mysql write database
            host=env.mysql_config.write.host,
            port=env.mysql_config.write.port,
            user=env.mysql_config.write.user,
            password=env.mysql_config.write.password,
        },
        read = { -- mysql read database
            host=env.mysql_config.read.host,
            port=env.mysql_config.read.port,
            user=env.mysql_config.read.user,
            password=env.mysql_config.read.password,
        },
        charset = 'utf8',
        pool_timeout = 1000, -- mysql pool timeout
        pool_size = 10000, -- mysql pool size
        timeout = 1000, -- mysql timeout
    },
}