local auth = require('providers.auth_service_provider')
local ip_location = require('lib.ip_location')
local AccountLog = require('models.account_log')
local redis = require('lib.redis')
local common = require('lib.common')

local _M = {}

function _M:verify_sms_code(phone, sms_code)
    local cache_code = redis:get('phone:'..phone)
    if cache_code ~= nil and cache_code == sms_code then
        return true
    end
    return false
end

function _M:verify_password(password, user_password)
    if common:hash(password) == user_password then
        return true
    else
        return false
    end
end

function _M:notify(login_id)
    -- you can send a message to message queue
    -- consider queue need a consumer but ngx.time_at is simple
    return true
end

function _M:authorize(user)
    -- login success
    auth:authorize(user)
    -- 每次ip定位都会有 IO 消耗，读ip二进制dat文件
    local ip_obj, err = ip_location:new(ngx.var.remote_addr)
    local location, err = ip_obj:location()
    if not location then
        return false, err
    end
    AccountLog:create(
        {
            ip = ngx.var.remote_addr,
            city = location.city,
            country = location.country,
            type = 'login'
        }
    )
    return true
end

return _M
