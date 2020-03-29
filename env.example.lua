return {
    APP_ENV = "dev", -- dev/prod

    MYSQL = { -- mysql read/write config
        DB_NAME = "",
        WRITE = { -- mysql write config
            HOST = "127.0.0.1",
            PORT = 3306,
            USER = "",
            PASSWORD = ""
        },
        READ = { -- mysql read config(if only one host the same as write)
            HOST = "127.0.0.1",
            PORT = 3306,
            USER = "",
            PASSWORD = ""
        },
    },

    REDIS = {
        HOST = "127.0.0.1", -- redis host
        PORT = 6379, -- redis port
        PASSWORD = nil -- redis password
    }
}
