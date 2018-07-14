local _M = {}

-- function name should use `handle()`
function _M:handle()
    local locale = get_cookie('locale')
    ngx.ctx.locale = locale
end

return _M