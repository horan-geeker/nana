local ngx = ngx
local ngx_re = require('ngx.re')
local cjson = require("cjson.safe")
local _M = {}


-- here you need use . not :
local function table_reverse(tbl)
    for i=1, math.floor(#tbl / 2) do
        tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
    end
    return tbl
end


-- remove item in table
local function table_remove(tab, rm)
    local result = tab
    for k, v in pairs(rm) do
        for a_k, a_v in pairs(result) do
            -- array
            if type(a_k) == 'number' then
                -- object
                if type(a_v) == 'table' then
                    result[a_k][v] = nil
                elseif v == a_v then
                    table.remove(result, a_k)
                end
            else
            -- hash array
                if v == a_k then
                    result[a_k] = nil
                end
            end
        end
    end
    return result
end


-- unique a array
local function unique(arr)
    local hash = {}
    local res = {}
    for _,v in ipairs(arr) do
        if not hash[v] then
            hash[v] = true
            table.insert(res, v)
        end
    end
    return res
end


-- make up a string from array
local function implode(arr, symbol)
    local implode_str = ''
    symbol = symbol or ','
    for key, value in pairs(arr) do
        implode_str = implode_str .. value .. symbol
    end
    return string.sub(implode_str, 1, #implode_str - 1)
end


-- sort a hashTable by key
local function sort_by_key(tab)
    local a = {}
    for n in pairs(tab) do
        table.insert(a, n)
    end
    table.sort(a)
    local i = 0 -- iterator variable
    local iter = function()
        -- iterator function
        i = i + 1
        if a[i] then
            return a[i], tab[a[i]]
        else
            return nil
        end
    end
    return iter
end


local function set_cookie(key, value, expires)
    local config = require("config.app")
    local cookie, err = require("lib.cookie"):new()
    if not cookie then
        ngx.log(ngx.ERR, err)
        return false, err
    end
    local cookie_payload = {
        key = key,
        value = value,
        path = '/',
        domain = config.app_domain,
        httponly = true,
    }
    if expires ~= nil then
        cookie_payload.expires = ngx.cookie_time(expires)
    end
    local ok, err = cookie:set(cookie_payload)
    if not ok then
        ngx.log(ngx.ERR, err)
        return false, err
    end
    return true
end


local function get_cookie(key)
    local cookie, err = require("lib.cookie"):new()
    if not cookie then
        ngx.log(ngx.ERR, err)
        return false
    end
    return cookie:get(key)
end


local function get_local_time()
    local config = require("config.app")
    local time_zone = ngx.re.match(config.time_zone, "[0-9]+")
    if time_zone == nil then
        local err = "not set time zone or format error, time zone should look like `+8:00` current is: " .. config.time_zone
        ngx.log(ngx.ERR, err)
        return false, err
    end
    -- ngx.time() return UTC+0 timestamp
    -- time_zone * 60(sec) * 60(min) + UTC+0 time = current time
    return time_zone[0] * 3600 + ngx.time()
end


local function trim(str, symbol)
    symbol = symbol or '%s' -- %s default match space \t \n etc..
    return (string.gsub(string.gsub(str, '^' .. symbol .. '*', ""), symbol .. '*$', ''))
end


-- data not in order
local function log(...)
    local args
    if #{...}>1 then
        args = {...}
    else
        args = ...
    end
    ngx.log(ngx.WARN, cjson.encode(args))
end

_M.log = log
_M.trim = trim
_M.get_cookie = get_cookie
_M.set_cookie = set_cookie
_M.get_local_time = get_local_time
_M.sort_by_key = sort_by_key
_M.implode = implode
_M.unique = unique
_M.table_reverse = table_reverse
_M.table_remove = table_remove

return _M
