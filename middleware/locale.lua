local _M = {}

-- function name should use `handle()`
function _M:handle()
    ngx.ctx.locale = locale
end

return _M