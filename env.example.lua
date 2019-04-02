return {
    APP_ENV = "dev", -- dev/prod

    mysql_config = {
        db_name = "nana",
        write = {host="10.200.10.1", port=3306, user="root", password="root"},
        read = {host="10.200.10.1", port=3307, user="root", password="root"},
    },

    redis_host = "10.200.10.1", -- redis host
    redis_port = 6379, -- redis port
    
    sendcloud = {
        SMSKEY = "",
        SMSUSER = "",
        TEMPLATEID = 13265
    }
}
