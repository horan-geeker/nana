return {
    redis_prefix = 'NANA:',
    mysql = {
        db_name = env("mysql_config.db_name", "nana"),
        write = { -- mysql write database
            host=env("mysql_config.write.host", "10.200.10.1"),
            port=env("mysql_config.write.port", 3306),
            user=env("mysql_config.write.user", "root"),
            password=env("mysql_config.write.password", "root"),
        },
        read = { -- mysql read database
            host=env("mysql_config.read.host", "10.200.10.1"),
            port=env("mysql_config.read.port", 3307),
            user=env("mysql_config.read.user", "root"),
            password=env("mysql_config.read.password", "root"),
        },
        charset = 'utf8',
        pool_timeout = 1000, -- mysql pool timeout
        pool_size = 10000, -- mysql pool size
        timeout = 1000, -- mysql timeout
    },
    
}