local auth = require('lib.auth_service_provider')
local ip_location = require('services.location_service')
local UserLog = require('models.user_log')
local request = require('lib.request')

local _M = {}

function _M:verify_password(password, user_password)
    if ngx.md5(password) == user_password then
        return true
    end
    return false
end

function _M:notify(phone)
    -- you can send a message to message queue
    -- consider queue need a consumer but ngx.time_at is simple
    return true
end

function _M:authorize(user)
    -- login success
    auth:authorize(user)
    -- 每次ip定位都会有 IO 消耗，读ip二进制dat文件
    local ip_obj, err = ip_location:new(request:header('x-forwarded-for'))
    local location, err = ip_obj:location()
    if not location then
        location = {
            city = '',
            country = '',
        }
    end
    UserLog:create({
        ip = request:header('x-forwarded-for') or ngx.var.remote_addr,
        user_id = user.id,
        city = location.city,
        country = location.country,
        type = 'login'
    })
    return true
end

return _M
