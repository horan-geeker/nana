local mysql_c = require("resty.mysql")

local _M = { _VERSION = '0.01' }

local mt = { __index = _M }

--[[    先从连接池取连接,如果没有再建立连接.
        返回:
        false,出错信息.
        true,数据库连接
--]]

function _M.get_connect(self)

    if ngx.ctx.MYSQL then
        return true, ngx.ctx.MYSQL
    end
    
    local client, errmsg = mysql_c:new()
    if not client then
        return false, "mysql.socket_failed: " .. (errmsg or "nil")
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
        return false, errmsg
    end

    local query = "SET NAMES "..self.db_charset
    local result, errmsg, errno, sqlstate = client:query(query)
    if not result then
        return false, errmsg
    end

    ngx.ctx.MYSQL = client
    ngx.log(ngx.INFO,'mysql connect')
    return true, ngx.ctx.MYSQL

end

--[[    把连接返回到连接池
        用set_keepalive代替close() 将开启连接池特性,可以为每个nginx工作进程，指定连接最大空闲时间，和连接池最大连接数
--]]

function _M.close(self)
    if ngx.ctx.MYSQL then
        ngx.ctx.MYSQL:set_keepalive(self.db_pool_timeout,self.db_pool_size)
        ngx.ctx.MYSQL = nil
        ngx.log(ngx.INFO,'mysql pooled')
    end
end

-- --[[    查询有结果数据集时返回结果数据集
--         无数据数据集时返回查询影响返回:
--         false,出错信息,sqlstate结构.
--         true,结果集,sqlstate结构.
-- --]]

function _M.mysql_query(self, sql)
    local ret, client = self:get_connect()
    if not ret then
        return false, client, nil
    end

    local result, errmsg, errno, sqlstate = client:query(sql)

    if not result then
        errmsg = concat_db_errmsg("mysql.query_failed:", errno, errmsg, sqlstate)
        return false, errmsg, sqlstate
    end

    self:close()

    return true, result, sqlstate
end

function _M.query(self, sql)

    local ret, res, _ = self:mysql_query(sql)
    if not ret then
        ngx.log(ngx.ERR, "query db error. res: " .. (res or "nil"))
        return nil
    end
    return res[1]
end

function _M.execute(self, sql)

    local ret, res, sqlstate = self:mysql_query(sql)
    if not ret then
        ngx.log(ngx.ERR, "mysql.execute_failed. res: " .. (res or 'nil') .. ",sql_state: " .. (sqlstate or 'nil'))
        return -1
    end

    return res.affected_rows

end

function _M.new(self, opts)
    opts = opts or {}
    local db_host = opts.host or '127.0.0.1'
    local db_port = opts.port or 3306
    local db_user = opts.user or 'root'
    local db_password = opts.password or ' '
    local db_name = opts.db_name or 'test'
    local db_timeout =  opts.db_timeout or 10000
    local db_pool_timeout = opts.pool_timeout or 1000
    local db_pool_size = opts.pool_size or 1000
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
