local env = require('env')

return {
    redis_prefix = 'NANA:',
    mysql = {
        db_name = env.MYSQL.DB_NAME,
        write = { -- mysql write database
            host = env.MYSQL.WRITE.HOST,
            port = env.MYSQL.WRITE.PORT,
            user = env.MYSQL.WRITE.USER,
            password = env.MYSQL.WRITE.PASSWORD,
        },
        read = { -- mysql read database
            host = env.MYSQL.READ.HOST,
            port = env.MYSQL.READ.PORT,
            user = env.MYSQL.READ.USER,
            password = env.MYSQL.READ.PASSWORD,
        },
        charset = 'utf8',
        pool_timeout = 1000, -- mysql pool timeout
        pool_size = 10000, -- mysql pool size
        timeout = 1000, -- mysql timeout
    },
    redis = {
        host = env.REDIS.HOST,
        port = env.REDIS.PORT,
        password = env.REDIS.PASSWORD
    },
}