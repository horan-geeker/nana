local config = require("config.app")
local http = require('lib.http')
local cjson = require('cjson')
local random = require('lib.random')
local redis = require('lib.redis')

local _M = {
    SMS_KEY = 'SMS:PHONE:%s'
}

function _M:send_sms(phone)
    local key = string.format(self.SMS_KEY, phone)
    local data, err = redis:get(key)
    if err then
        ngx.log(ngx.ERR, err)
        return 0x000007
    end
    if data ~= nil then
        local ttl, err = redis:ttl(key)
        if not ttl then
            ngx.log(ngx.ERR, err)
            return 0x000007
        end
        if ttl > (300 - 60) then
            -- 没过60秒
            return 0x020001
        end
    end
    local smscode = random.number(math.pow(10, config.phone_code_len - 1), math.pow(10, config.phone_code_len) - 1)
    local ok, err = redis:set(key, smscode, 300)
    if not ok then
        ngx.log(ngx.ERR, err)
        return 0x000007
    end
    local httpClient = http.new()
    local res, err = httpClient:request_uri(config.notify_service_url .. '/send/sms?phone='..tonumber(phone) .. '&code=' .. smscode)
    if err ~= nil then
        ngx.log(ngx.ERR, res, err)
        return 0x000007
    end
    local response = cjson.decode(res.body)
    if response.status ~= 0 then
        log(response.message)
        return 0x000007
    end
    return true
end

function _M:verify_sms_code(phone, sms_code)
    local key = string.format(self.SMS_KEY, phone)
    local cache_code = redis:get(key)
    if cache_code ~= nil and cache_code == sms_code then
        redis:del(key)
        return true
    end
    return false
end

return _M