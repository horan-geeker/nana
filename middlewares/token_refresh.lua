local auth_service = require('services.auth_service')

local _M = {}

function _M:handle()
    local ok,err = auth_service.token_refresh()
    if not ok then
        ngx.log(ngx.ERR, err)
    end
end

return _M