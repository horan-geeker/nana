return {
    APP_ENV = "dev", -- dev/prod

    mysql = {
        db_name = "nana",
        write = {host="127.0.0.1", port=3306, user="root", password="root"},
        read = {host="127.0.0.1", port=3306, user="root", password="root"},
    },

    redis = {
        host = "127.0.0.1", -- redis host
        port = 6379, -- redis port
    }
}
