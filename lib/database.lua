local mysql_c = require("resty.mysql")
local config = require('config.app')

local _M = {}

local mt = { __index = _M }

--[[    
    Get mysql connection from connection pool
        
    return bool, mysql_context, err
    bool: if success or fail
    mysql_context: if success return mysql handle
    err: if fail return reason
--]]

function _M.get_connect(self)
    if ngx.ctx.MYSQL then
        return ngx.ctx.MYSQL, nil
    end
    
    local client, errmsg = mysql_c:new()
    if not client then
        return nil, "mysql.socket_failed: " .. (errmsg or "nil")
    end

    client:set_timeout(self.db_timeout)

    local options = {
        host = self.db_host,
        port = self.db_port,
        user = self.db_user,
        password = self.db_password,
        database = self.db_name
    }

    local result, errmsg, errno, sqlstate = client:connect(options)
    if not result then
        return nil, errmsg
    end

    -- set character code UTF-8
    local query = "SET NAMES "..self.db_charset
    local result, errmsg, errno, sqlstate = client:query(query)
    if not result then
        ngx.log(ngx.ERR, errmsg)
        return nil, errmsg
    end
    -- set time zone
    local query = 'SET time_zone = "'..config.time_zone..'"'
    local result, errmsg, errno, sqlstate = client:query(query)
    if not result then
        ngx.log(ngx.ERR, errmsg, query)
        return nil, errmsg
    end

    ngx.ctx.MYSQL = client
    ngx.log(ngx.DEBUG,'mysql connect')
    return ngx.ctx.MYSQL, nil
end

--[[    
    把连接返回到连接池
    用set_keepalive代替close() 将开启连接池特性,可以为每个nginx工作进程，指定连接最大空闲时间，和连接池最大连接数
--]]
function _M.close(self)
    if ngx.ctx.MYSQL then
        ngx.ctx.MYSQL:set_keepalive(self.db_pool_timeout,self.db_pool_size)
        ngx.ctx.MYSQL = nil
        ngx.log(ngx.DEBUG,'mysql pooled')
    end
end

--[[
    return bool, data, err
    data: if success return query data
    err: if fail return reason
--]]
function _M.mysql_query(self, sql)
    local client, err = self:get_connect()
    if err ~= nil then
        return nil, err
    end

    local result, errmsg, errno, sqlstate = client:query(sql)
    if not result then
        errmsg = errno .. errmsg .. sqlstate
        return nil, errmsg
    end

    self:close()

    return result, nil
end

function _M.new(self, opts)
    opts = opts or {}
    local db_host = opts.mysql_host or '127.0.0.1'
    local db_port = opts.mysql_port or 3306
    local db_user = opts.mysql_user or 'root'
    local db_password = opts.mysql_password or ' '
    local db_name = opts.db_name or 'test'
    local db_timeout =  opts.db_timeout or 1000
    local db_pool_timeout = opts.mysql_pool_timeout or 1000
    local db_pool_size = opts.mysql_pool_size or 1000
    local db_charset = opts.charset or 'utf8'

    return setmetatable({
            db_host = db_host,
            db_port = db_port,
            db_user = db_user,
            db_password = db_password,
            db_name = db_name,
            db_timeout = db_timeout,
            db_charset = db_charset, 
            db_pool_timeout = db_pool_timeout, 
            db_pool_size = db_pool_size, 
            }, mt)
end

return _M
