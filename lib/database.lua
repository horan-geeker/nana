local mysql_c = require("resty.mysql")

local _M = {}
local READ = 'READ'
local WRITE = 'WRITE'

local mt = { __index = _M }

--[[    
    Get mysql connection from connection pool
        
    @return bool, mysql_context, err
--]]

function _M:get_connection()
    if ngx.ctx.MYSQL and ngx.ctx.MYSQL[self.db_type] then
        return ngx.ctx.MYSQL[self.db_type], nil
    end
    local db, err = mysql_c:new()
    if not db then
        ngx.log(ngx.ERR, "failed to instantiate mysql: ", err)
        return nil, err
    end

    db:set_timeout(self.timeout or 1000)
    local ok, err, errcode, sqlstate = db:connect({
        host = self.host,
        port = self.port,
        user = self.user,
        password = self.password,
        database = self.db_name,
        charset = self.charset,
        max_packet_size = 1024 * 1024,
    })
    if not ok then
        ngx.log(ngx.ERR, "failed to connect: ", err, ": ", errcode, " ", sqlstate)
        return nil, err
    end
    ngx.log(ngx.WARN, self.db_type, ' mysql connect')
    -- set time zone
    local query = 'SET time_zone = "'..self.time_zone..'"'
    local res, err, errcode, sqlstate = db:query(query)
    if not res then
        ngx.log(ngx.ERR, res, err, errcode, sqlstate)
        return nil, err
    end
    ngx.ctx.MYSQL = {
        [self.db_type] = db
    }
    return db, nil
end

--[[    
    把连接返回到连接池
    用set_keepalive代替close() 将开启连接池特性,可以为每个nginx工作进程，指定连接最大空闲时间，和连接池最大连接数

    @return void
--]]
function _M.close(self)
    if ngx.ctx.MYSQL and ngx.ctx.MYSQL[READ] then
        ngx.ctx.MYSQL[READ]:set_keepalive(self.db_pool_timeout,self.db_pool_size)
        ngx.log(ngx.WARN,'read mysql close')
    end
    if ngx.ctx.MYSQL and ngx.ctx.MYSQL[WRITE] then
        ngx.ctx.MYSQL[WRITE]:set_keepalive(self.db_pool_timeout,self.db_pool_size)
        ngx.log(ngx.WARN,'write mysql close')
    end
    ngx.ctx.MYSQL = nil
end

--[[
    执行数据库语句

    @param sql
    @return bool, data, err
--]]
function _M.mysql_query(self, sql)
    log(self.db_type, sql)
    local db, err = self:get_connection()
    if err ~= nil then
        return nil, err
    end

    local res, err, errcode, sqlstate = db:query(sql)
    if not res then
        ngx.log(ngx.ERR, err, errcode, sqlstate)
        return nil, err
    end

    return res, nil
end

function _M.new(self, opts)
    return setmetatable({
            host = opts.host or '127.0.0.1',
            port = opts.port or 3306,
            user = opts.user or 'root',
            password = opts.password or ' ',
            db_name = opts.db_name or 'test',
            charset = opts.charset or 'utf8',
            timeout = opts.timeout,
            max_packet_size = 1024 * 1024,
            db_pool_timeout = opts.pool_timeout or 1000,
            db_pool_size = opts.pool_size or 1000,
            time_zone = opts.time_zone or '+8:00',
            db_type = opts.db_type,
            }, mt)
end

return _M
