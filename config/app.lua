local helpers = require("lib.helpers")
local env = helpers.env

return {
    env = env('APP_ENV', 'production'),

    locale = 'en',
    fallback_locale = 'zh',

    time_zone = "+8:00", -- UTC + 8
}