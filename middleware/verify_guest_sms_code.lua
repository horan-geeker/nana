local request = require('lib.request')
local validator = require('lib.validator')
local response = require('lib.response')

local _M = {}

function _M:handle()
    local args = request:all()
    local ok, msg = validator:check(args,{'sms_code', 'phone'})
    if not ok then
        return false, response:json(0x000001, msg)
    end
    return true
end

return _M