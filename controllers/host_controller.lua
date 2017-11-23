local Host = require('models.host')
local common = require('lib.common')

_M = {}

function _M:index()
    common:response(0,'ok',Host:all())
end

return _M