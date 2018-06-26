return {
    login_id = "phone", -- login method use email/username/phone...etc
    time_zone = "UTC+8",
    session_lifetime = 3600 * 24 * 365, --sec, here means a year
    max_request_per_second = 3000, -- throttle flow request per second
    user_table_name = "users",
    phone_code_len = 4,
    wechat = {
        web = {
            app_id = "xxxxxxxxxxx",
            secret = "xxxxxxxxxxxxxx",
            redirect_uri = "http://api.nana.local"
        }
    },
    sendcloud = {
        url = "http://www.sendcloud.net/smsapi/send",
        smsUser = "LuaChina",
        smsKey = "Pq2UMOlJFpQC1ghZwW08v9REsWyn9ax7",
        templateId = 13265
    }
}