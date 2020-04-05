local http_request = require('lib.request')
local http_response = require('lib.response')
local router = require('routes')
local database = require('lib.database')
local ngx = ngx


-- process middlewares in order
local function run_middlewares(middlewares)
    if type(middlewares) ~= 'table' then
        return false, http_response:error(500, {}, 'system error: middleware is not a table, please read readme about middleware usage')
    end
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
    local response
    if #route_param ~= 0 then
        table.insert(route_param, request)
        response = controller[action](nil, table.unpack(route_param))
    else
        response = controller[action](nil, request)
    end
    if type(response) ~= 'table' then
        return http_response:error(500, {}, 'system error: controller return response is not a table, please read readme about controller usage')
    end
    return response
end


-- run application kernel
local function run()
    -- get http request infomation
    local request_capture = http_request:capture()
    -- match route, get target controller and action
    local context, route_param, err_response = router:match(request_capture.uri, request_capture.method)
    if err_response ~= nil then
        return err_response
    end
    -- process business
    return handle(request_capture, context, route_param)
end


local function terminate()
    database:close()
    ngx.exit(ngx.OK)
end


return {
    run = run,
    terminate = terminate,
}
