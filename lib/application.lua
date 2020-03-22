local request = require('lib.request')
local router = require('routes')
local database = require('lib.database')
local ngx = ngx

local _M = {}


-- process middlewares in order
local function run_middlewares(middlewares)
    for _, middleware in ipairs(middlewares) do
        local result, err_response = middleware:handle()
        if result == false then
            return result, err_response
        end
    end
end


-- process target action
local function handle(request, context, route_param)
    -- run middlewares
    local ok, err_response = run_middlewares(context.required_middlewares)
    if ok == false then
        return err_response
    end
    -- run controller action
    local controller = context.required_controller
    local action = context.action
    if #route_param ~= 0 then
        return controller[action](nil, table.unpack(route_param), request)
    end
    return controller[action](nil, request)
end


-- run application kernel
function _M:run()
    -- get http request infomation
    local request_capture = request:capture()
    -- match route, get target controller and action
    local context, route_param, err_response = router:match(request_capture.uri, request_capture.method)
    if err_response ~= nil then
        return err_response
    end
    -- process business
    return handle(request_capture, context, route_param)
end


function _M:terminate()
    database:close()
    ngx.exit(ngx.OK)
end


return _M