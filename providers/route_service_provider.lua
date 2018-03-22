local common = require('lib.common')

local _M = {}
local controller_prefix = 'controllers.'
local middleware_prefix = 'middlewares.'
local middleware_group = {}

function _M:call_action(uri, controller, action)
    if common:purge_uri(uri) == common:purge_uri(ngx.var.request_uri) then
        if middleware_group then
            for _,middleware in ipairs(middleware_group) do
                local result, status, message = require(middleware_prefix..middleware):handle()
                if result == false then
                    middleware_group = {}
                    common:response(status, message)
                end
            end
        end
        if controller then
            middleware_group = {}
            require(controller_prefix..controller)[action]()
        else
            ngx.log(ngx.WARN, 'upsteam api')
        end
    end
    middleware_group = {}
end

function _M:get(uri, controller, action)
    if 'GET' == ngx.var.request_method then
        _M:call_action(uri, controller, action)
    end
end

function _M:post(uri, controller, action)
    if 'POST' == ngx.var.request_method then
        _M:call_action(uri, controller, action)
    end
end

function _M:group(middlewares, func)
    for _,middleware in ipairs(middlewares) do
        table.insert(middleware_group, middleware)
    end
    func()
end

return _M