local helpers = require("lib.helpers")
local env = helpers.env

return {
    redis_prefix = 'NANA:',
    mysql = {
        db_name = env("mysql.db_name", "nana"),
        write = { -- mysql write database
            host=env("mysql.write.host", "127.0.0.1"),
            port=env("mysql.write.port", 3306),
            user=env("mysql.write.user", "root"),
            password=env("mysql.write.password", "root"),
        },
        read = { -- mysql read database
            host=env("mysql.read.host", "127.0.0.1"),
            port=env("mysql.read.port", 3307),
            user=env("mysql.read.user", "root"),
            password=env("mysql.read.password", "root"),
        },
        charset = 'utf8',
        pool_timeout = 1000, -- mysql pool timeout
        pool_size = 10000, -- mysql pool size
        timeout = 1000, -- mysql timeout
    },
}