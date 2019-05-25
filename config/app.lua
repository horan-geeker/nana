return {
    env = env('APP_ENV', 'production'),
    app_domain = env('APP_DOMAIN', 'https://api.lua-china.com'),
    web_url = 'https://lua-china.com',
    
    locale = 'zh',
    fallback_locale = 'en',

    time_zone = "+8:00", -- UTC + 8
    
    session_lifetime = 3600 * 24 * 30, --sec, here means a month
    session_refresh_time = 3600 * 24 * 7, --sec, here means a week
    max_request_per_second = 3000, -- throttle flow request per second
    
    phone_code_len = 4,
    per_page = env('per_page', 20),

    wechat = {
        web = {
            app_id = "xxxxxxxxxxx",
            secret = "xxxxxxxxxxxxxx",
            redirect_uri = "http://api.nana.local/"
        }
    },
    github = {
        client_id = "6162c14c3b7a50abf8ce",
        client_secret = env('github.CLIENT_SECRET'),
        redirect_uri = "https://api.lua-china.com/oauth/github"
    },
    sendcloud = {
        url = "http://www.sendcloud.net/smsapi/send",
        smsUser = env('sendcloud.SMSUSER'),
        smsKey = env('sendcloud.SMSKEY'),
        templateId = env('sendcloud.TEMPLATEID'),
        email_url = 'http://api.sendcloud.net/apiv2/mail/sendtemplate',
        email_api_user = 'luachina',
        email_api_key = env('sendcloud.EMAIL_API_KEY')
    }
}