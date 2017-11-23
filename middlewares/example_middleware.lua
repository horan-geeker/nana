local _M = {}

-- function name should use `handle()`
function _M:handle()
    ngx.log(ngx.ERR, 'this is example middleawre')
end

return _M