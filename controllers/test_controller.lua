local request = require('lib.request')
local response = require('lib.response')

ngx.say(cjson.encode({
    status = 0,
    message = 'request args',
    data = args}))
ngx.exit(ngx.OK)