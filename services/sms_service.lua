local config = require("config.app")
local http = require('lib.http')
local cjson = require('cjson')
local random = require('lib.random')
local redis = require('lib.redis')

local _M = {}

local function generateSendCloudSignature(phone, code)
    local conf = config.sendcloud
    local signStr = ''
    local params = {smsUser=conf['smsUser'],templateId=conf['templateId'],phone=phone,vars={code=code}}
    for k,v in pairsByKeys(params) do
        local val = ''
        if type(v) == 'table' then
            val = cjson.encode(v)
        else
            val = v
        end
        signStr = signStr .. k .. '=' .. val .. '&'
    end
    local signature = conf['smsKey'] .. '&' .. signStr .. conf['smsKey']
    return ngx.md5(signature), signStr
end

local function sendMessageToSendCloud(phone, code, signature, signStr)
    local url = config['sendcloud']['url'] .. '?' .. signStr .. 'signature='..signature
    local httpClient = http.new()
    local res, err = httpClient:request_uri(url, {ssl_verify=false})
    if not res then
        ngx.log(ngx.ERR, res, err)
        return res, err
    end
    if res.status ~= 200 then
        return false, res.reason
    else
        local response = cjson.decode(res.body)
        if response.statusCode ~= 200 then
            return false, response.message
        else
            return true
        end
    end
end

function _M:sendSMS(phone)
    local key = 'phone:' .. phone
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
    local ok, err = ngx.timer.at(0, function (premature, phone, smscode)
                                        local signature, signStr = generateSendCloudSignature(tonumber(phone), smscode)
                                        local ok, err = sendMessageToSendCloud(tonumber(phone), smscode, signature, signStr)
                                        if not ok then
                                            ngx.log(ngx.ERR, err)
                                        end
                                    end,
                                phone, smscode)
        if not ok then
            common:response(0x00000B, err)
        end
    return true
end

return _M