local request = require('lib.request')
local response = require('lib.response')

local args = request:all() -- 拿到所有参数
response:json(0,'request args', args)