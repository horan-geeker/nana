#!/usr/bin/env lua
local ngx = require('ngx')
local config = require("config.app")

local setmetatable = setmetatable
local byte = string.byte
local match = string.match
local rawget = rawget
local cjson = require "cjson"

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function(narr, nrec) return {} end
end

local _M = new_tab(0, 54)

local mt = { __index = _M }

_M._VERSION = '0.01'

-- 测试TOKEN 及 地址
local token = "cc87f3c77747bccbaaee35006da1ebb65e0bad57"
local ipIpUrl = "http://freeapi.ipip.net/"

-- 切割字符串
local function split(s, p)
    local rt = {}
    string.gsub(s, '[^' .. p .. ']+', function(w) table.insert(rt, w) end)
    return rt
end

-- 拓展
string.split = function(str, pattern)
    pattern = pattern or "[^%s]+"
    if pattern:len() == 0 then pattern = "[^%s]+" end
    local parts = { __index = table.insert }
    setmetatable(parts, parts)
    str:gsub(pattern, parts)
    setmetatable(parts, nil)
    parts.__index = nil
    return parts
end


-- 转成整型
local function bit32lshift(b, disp)
    return (b * 2 ^ disp) % 2 ^ 32
end

-- 转换ip
local function byteToUint32(a, b, c, d)
    local _int = 0
    if a then
        _int = _int + bit32lshift(a, 24)
    end
    _int = _int + bit32lshift(b, 16)
    _int = _int + bit32lshift(c, 8)
    _int = _int + d
    if _int >= 0 then
        return _int
    else
        return _int + math.pow(2, 32)
    end
end

-- 返回数据模版
local response_template = {
    "country", -- // 国家
    "city", -- // 省会或直辖市（国内）
    "region", -- // 地区或城市 （国内）
    "place", -- // 学校或单位 （国内）
    "operator", -- // 运营商字段（只有购买了带有运营商版本的数据库才会有）
    "latitude", -- // 纬度     （每日版本提供）
    "longitude", -- // 经度     （每日版本提供）
    "timeZone", -- // 时区一, 可能不存在  （每日版本提供）
    "timeZoneCode", -- // 时区二, 可能不存在  （每日版本提供）
    "administrativeAreaCode", -- // 中国行政区划代码    （每日版本提供）
    "internationalPhoneCode", -- // 国际电话代码        （每日版本提供）
    "countryTwoDigitCode", -- // 国家二位代码        （每日版本提供）
    "worldContinentCode" -- // 世界大洲代码        （每日版本提供）
}

-- 转成 table类型
local function toTable(location)
    local response = {}
    for k, v in ipairs(location) do
        response[response_template[k]] = v
    end

    return response
end

-- 发送请求
local function sendRequest(url, method, body, headers)
    local http = require "resty.http"
    local httpc = http.new()
    local res, err = httpc:request_uri(url, {
            method = method,
            body = body,
            headers = headers
        })

    if not res then
        ngx.log(ngx.ERR, "failed to request: " .. err .. url)
        return nil, err
    end

    if 200 ~= res.status then
        ngx.log(ngx.ERR, res.status)
        return nil, res.status
    end

    return res.body
end

-- 初始化
function _M.new(self, address, token)
    -- @todo fix file path
    -- ngx.log(ngx.ERR, cjson.encode(ngx.var.realpath_root))
    return setmetatable({ _ipAddress = address, _token = token, _ipBinaryFilePath = '/var/www/nana/lib/17monipdb.dat' }, mt)
end

-- 从文件获取地区信息
function _M.ipLocation(self, ipstr)
    local ipBinaryFilePath = rawget(self, "_ipBinaryFilePath")
    if not ipBinaryFilePath then
        ngx.log(ngx.ERR, ipBinaryFilePath)
        return nil, " file ptah not initialized"
    end

    local ip1, ip2, ip3, ip4 = match(ipstr, "(%d+).(%d+).(%d+).(%d+)")
    local ip_uint32 = byteToUint32(ip1, ip2, ip3, ip4)
    local file = io.open(ipBinaryFilePath)
    if file == nil then
        return nil
    end

    local str = file:read(4)
    local offset_len = byteToUint32(byte(str, 1), byte(str, 2), byte(str, 3), byte(str, 4))

    local indexBuffer = file:read(offset_len - 4)

    local tmp_offset = ip1 * 4
    local start_len = byteToUint32(byte(indexBuffer, tmp_offset + 4), byte(indexBuffer, tmp_offset + 3), byte(indexBuffer, tmp_offset + 2), byte(indexBuffer, tmp_offset + 1))

    local max_comp_len = offset_len - 1028
    local start = start_len * 8 + 1024 + 1
    local index_offset = -1
    local index_length = -1
    while start < max_comp_len do
        local find_uint32 = byteToUint32(byte(indexBuffer, start), byte(indexBuffer, start + 1), byte(indexBuffer, start + 2), byte(indexBuffer, start + 3))
        if ip_uint32 <= find_uint32 then
            index_offset = byteToUint32(0, byte(indexBuffer, start + 6), byte(indexBuffer, start + 5), byte(indexBuffer, start + 4))
            index_length = byte(indexBuffer, start + 7)
            break
        end
        start = start + 8
    end

    if index_offset == -1 or index_length == -1 then
        return nil
    end

    local offset = offset_len + index_offset - 1024

    file:seek("set", offset)

    return file:read(index_length)
end

-- 获取所有信息
function _M.location(self)
    local ipAddress = rawget(self, "_ipAddress")
    if not ipAddress then
        return nil, "not initialized"
    end

    local address = self:ipLocation(ipAddress)
    if not address then
        ngx.log(ngx.ERR, "ip address data nil")
        return nil, "ip address data nil"
    end

    if type(address) == "string" then
        return toTable(split(address, "%s+"))
    end

    return address
end

-- 通过api获取
function _M.locationApi(self, sid, uid)
    local ipAddress = rawget(self, "_ipAddress")
    if not ipAddress then
        return nil, "not initialized"
    end

    local _token = rawget(self, "_token")

    local myToken = (_token and _token) or token

    local sign, err = ngx.md5("addr=" .. ipAddress .. "&token=" .. myToken)

    if not sign then
        return nil, err
    end

    local url = ipIpUrl .. "find"

    local headers = {
        ["Token"] = myToken
    }

    local params = "addr=" .. ipAddress .. "&sid=" .. sid .. "&uid=" .. uid .. "&sig=" .. sign

    local body, err = sendRequest(url, "GET", params, headers)

    if not body or #body < 1 then
        return nil, err
    end

    --    local body = [[{"ret":"ok","data":["中国","天津","天津","","鹏博士","39.128399","117.185112","Asia/Shanghai","UTC+8","120000","86","CN","AP"]}]]
    local response = cjson.decode(body)

    if not response.data then
        return response
    end

    return toTable(response.data)
end

-- 通过免费的api获取
function _M.locationApiFree(self)
    local ipAddress = rawget(self, "_ipAddress")
    if not ipAddress then
        return nil, "not initialized"
    end

    local url = ipIpUrl .. ipAddress

    local headers = {
        ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        ["Cache-Control"] = "no-cache",
        ["Connection"] = "keep-alive",
        ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36",
        ["Content-Type"] = "application/x-www-form-urlencoded",
    }

    local body, err = sendRequest(url, "GET", "", headers)

    if not body then
        return nil, err
    end

    return toTable(cjson.decode(body))
end

-- 获取当前可访问状态
function _M.apiStatus(self, token)
    if not token then
        local token = rawget(self, "_token")
        if not token then
            return nil, "not initialized"
        end
    end

    local url = ipIpUrl .. "find_status"

    local headers = {
        ["Token"] = token
    }

    local body, err = sendRequest(url, "GET", "", headers)

    if not body then
        return nil, err
    end

    return cjson.decode(body)
end

return _M