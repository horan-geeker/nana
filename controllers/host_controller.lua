local Host = require('models.host')
local request = require('lib.request')
local common = require('lib.common')
local validator = require('lib.validator')

_M = {}

function _M:index()
    common:response(0,'ok',Host:all())
end

function _M:store()
    local ok,err = validator:check(request,{
        'hostname',
        'ip',
        'hack_method',
        'level',
        'country',
        'city',
        'hacked_at',
    })
    if not ok then
        common:response(1, err)
    end
    ok, err = Host:create({
        hostname = request.hostname,
        domain = request.domain,
        ip = request.ip,
        hack_method = request.hack_method,
        level = request.level,
        country = request.country,
        city = request.city,
        hacked_at = request.hacked_at,
        remark = request.remark
    })
    ngx.log(ngx.ERR, ok, err)
    if not ok then
        common:response(1, err)
    end
    common:response(0)
end

return _M