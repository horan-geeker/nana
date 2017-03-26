local mysql = require('resty.mysql')
local conf = require('config.app')

local Database = {}

function Database:connect()
    local client, error_msg = mysql:new()
    if not client then
        ngx.log('fail to instantiate mysql: ', error_msg)
        return
    end
    
    client:set_timeout(1000) --1 sec

    local ok, error_msg, error_code, sqlstate = client:connect{
        host = conf['host'],
        port = conf['port'],
        database = conf['database'],
        user = conf['user'],
        password = conf['password'],
        max_packet_size = 1024*1024
    }

    if not ok then
        ngx.log(ngx.ERR,'fail to connect: ', error_msg, ': ', error_code, sqlstate)
        return 
    end
    
    --ctx变量实现单例模式
    ngx.ctx.MYSQL = client
    return true
end

function Database:query(sql)
    if not ngx.ctx.MYSQL then
        self:connect()
    end
    local res, err, errno, sqlstate = ngx.ctx.MYSQL:query(sql, 10)
    if not res then
        ngx.log(ngx.WARN,"bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return nil
    else
        return res
    end
end

return Database
