return {
    APP_ENV = "production", -- dev/production
    APP_DOMAIN = 'api.lua-china.com',

    mysql_config = {
        db_name = "lua_china",
        write = {host="10.31.231.178", port=3306, user="root", password="root"}, -- mysql write database
        read = {host="10.31.231.178", port=3307, user="root", password="root"}, -- mysql read database
    },

    redis_host = "10.31.231.178", -- redis host
    redis_port = 6379, -- redis port

    sendcloud = {
        SMSKEY = "",
        SMSUSER = "LuaChina",
        TEMPLATEID = 13265,
        EMAIL_API_KEY = ""
    },
    github = {
        CLIENT_ID = "6162c14c3b7a50abf8ce",
        CLIENT_SECRET = "6f145c75740b7c674c6429bf88b670d0ed5023ae",
        REDIRECT_URL = "https://api.lua-china.com/oauth/github",
    }
}
