local helpers = require("lib.helpers")
local env = helpers.env

return {
    env = env('APP_ENV', 'production'),

    locale = 'en',
    fallback_locale = 'zh',

    time_zone = "+8:00", -- UTC + 8

    session_lifetime = 3600 * 24 * 30, --sec, here means a month
    session_refresh_time = 3600 * 24 * 7, --sec, here means a week
    max_request_per_second = 3000, -- throttle flow request per second

    phone_code_len = 4,
    per_page = env('per_page', 10),
}