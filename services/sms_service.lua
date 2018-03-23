local config = require("config.app")
local http = require('lib.http')
local cjson = require('cjson')

local _M = {}

local function generateSendCloudSignature(phone, code)
    local conf = env['sendcloud']
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
    local url = env['sendcloud']['url'] .. '?' .. signStr .. 'signature='..signature
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
    return true
end

function _M:sendSms(phone, code)
    local signature, signStr = generateSendCloudSignature(tonumber(phone), code)
    return sendMessageToSendCloud(tonumber(phone), code, signature, signStr)
end

return _M