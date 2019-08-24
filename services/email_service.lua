local config = require("config.app")
local http = require('lib.http')
local cjson = require('cjson')

local _M = {}

function _M:notify_comment(to, author, commenter, content, post_id)
    local mail_content = "hi " .. author .. "<br><br>" .. content .. "<br><br>" .. commenter .. "<br><br><a href=\"" .. config.web_url .. "/posts/" .. post_id .. "\">点此链接跳转相应文章</a>"
    local params = {
        email = to,
        content = urlencode(mail_content),
        title = urlencode('Lua 中国 - 新评论通知'),
        from = urlencode('Lua 中国')
    }
    local query = '?'
    for k,v in pairs(params) do
        query = query .. k .. '=' .. v .. "&"
    end
    ngx.timer.at(0,
            function (premature, to, author, commenter, query, post_id)
                local httpc = http.new()
                -- urlencode
                local url = config.notify_service_url .. '/send/mail' .. query
                local response, err = httpc:request_uri(url)
                if err ~= nil then
                    ngx.log(ngx.ERR, err)
                    return
                end
                local data = cjson.decode(response.body)
                if data.status ~= 0 then
                    ngx.log(ngx.ERR, response.body)
                end
            end,
        to, author, commenter, query, post_id)
end

return _M