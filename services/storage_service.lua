local http = require("lib.http")
local config = require('config.app')
local cjson = require('cjson')

local _M = {}

function _M:upload_by_url(url)
    local httpc = http.new()
    local res, err = httpc:request_uri(config.storage_service_url .. "/v1/cos/upload/url/cdn?file_url=" .. url, {ssl_verify = false})
    if not res then
        return nil, err
    end
    local data = cjson.decode(res.body)
    if data.status == 0 then
        return data.data.cdn_url
    end
    return nil, res.body
end

return _M