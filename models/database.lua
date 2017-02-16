local mysql = require('resty.mysql')
local conf = require('config.app')

local Database = {}

function Database:connect()
    local error_msg

    --全局变量实现单例模式
    DB = nil
    ngx.say('Database connect!!!')

    DB, error_msg = mysql:new()
    if not DB then
        ngx.log('fail to instantiate mysql: ', error_msg)
        return
    end
    
    DB:set_timeout(1000) --1 sec

    local ok, error_msg, error_code, sqlstate = DB:connect{
        host = conf['host'],
        port = conf['port'],
        database = conf['database'],
        user = conf['user'],
        password = conf['password'],
        max_packet_size = 1024*1024
    }

    if not ok then
        ngx.log('fail to connect: ', error_msg, ': ', error_code, sqlstate)
        return 
    end
    
    return true
end

function Database:query(sql)
    if not DB then
        self:connect()
    end
    local res, err, errno, sqlstate = DB:query(sql, 10)
    if not res then
        ngx.log(ngx.WARN,"bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    else
        return res
    end
end

return Database
