local User = require('models.user')
local common = require('lib.common')
local cjson = require('cjson')
common:response(User:find(1))
