local redis = require("models.redis")

redis:set('he','junwei')

ngx.say(redis:get('he'))