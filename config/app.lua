local env = require('../env')

return {
    env = env.APP_ENV or 'production',
    locale = 'zh',
    fallback_locale = 'en',
    time_zone = "UTC+8",
    session_lifetime = 3600 * 24 * 30, --sec, here means a month
    session_refresh_time = 3600 * 24 * 7, --sec, here means a week
    max_request_per_second = 3000, -- throttle flow request per second
    per_page = env.per_page or 10,
    redis_prefix = 'NANA:',
    -- auth
    user_table_name = "users",
    login_id = "phone", -- login colunm name use email/username/phone...
    phone_code_len = 4,
    -- oauth
    wechat = {
        web = {
            app_id = "xxxxxxxxxxx",
            secret = "xxxxxxxxxxxxxx",
            redirect_uri = "http://api.nana.local"
        }
    },
    sendcloud = {
        url = "http://www.sendcloud.net/smsapi/send",
        smsUser = env.sendcloud.SMSUSER,
        smsKey = env.sendcloud.SMSKEY,
        templateId = env.sendcloud.TEMPLATEID
    }
}