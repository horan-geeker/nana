-- Github Document: https://github.com/horan-geeker/nana
-- Author:          hejunwei
-- Version:         v0.3.0

local cjson = require("cjson")
local config = require("config.app")
local cookie_obj = require("lib.cookie")

local Core = {}

function Core:helpers()
    -- here you need use . not :
    function _G.table_reverse(tbl)
        for i=1, math.floor(#tbl / 2) do
            tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
        end
        return tbl
    end
    -- remove item in table
    function _G.table_remove(tab, rm)
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
    function _G.unique(arr)
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
    function _G.implode(arr, symbol)
        local implode_str = ''
        symbol = symbol or ','
        for key, value in pairs(arr) do
            implode_str = implode_str .. value .. symbol
        end
        return string.sub(implode_str, 1, #implode_str - 1)
    end
    -- sort a hashTable by key
    -- use example: for k,v in pairsByKeys(hashTable)
    function _G:pairsByKeys(f)
        local a = {}
        for n in pairs(self) do
            table.insert(a, n)
        end
        table.sort(a, f)
        local i = 0 -- iterator variable
        local iter = function()
            -- iterator function
            i = i + 1
            if a[i] == nil then
                return nil
            else
                return a[i], self[a[i]]
            end
        end
        return iter
    end

    function _G.set_cookie(key, value, expires)
        local cookie, err = cookie_obj:new()
        if not cookie then
            ngx.log(ngx.ERR, err)
            return false, err
        end
        local cookie_payload = {
            key = key,
            value = value
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

    function _G:get_cookie()
        local key = self
        local cookie, err = cookie_obj:new()
        if not cookie then
            ngx.log(ngx.ERR, err)
            return false
        end
        return cookie:get(key)
    end

    function _G:get_local_time()
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

    function _G.purge_uri(uri)
        local uri = string.gsub(uri, "?.*", "")
        local uri_without_slash = remove_slash(uri)
        return uri_without_slash
    end

    function _G.remove_slash(target)
        local len = string.len(target)
        if string.find(target,'/', len) then
            return string.sub(target, 1, len-1)
        end
        return target
    end

    function _G.hash(password)
        return ngx.md5(password)
    end
    
    -- data not in order
    function _G.log(...)
        local args = {}
        if #{...}>1 then
            args = {...}
        else
            args = ...
        end
        ngx.log(ngx.WARN, cjson.encode(args))
    end
end

function Core:bootstrap()
    --get helper function
    self.helpers()
    require('router'):init()
end

Core:bootstrap()