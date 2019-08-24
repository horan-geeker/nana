local config = require("config.app")
local http = require('lib.http')
local cjson = require('cjson')

local _M = {}

function _M:notify_comment(to, author, commenter, content, post_id)
    ngx.timer.at(0,
            function (premature, to, author, commenter, content, post_id)
                local httpc = http.new()
                -- urlencode
                local content = "hi " .. author .. "\n    " .. content .. "\n" .. commenter .. "\n\n点击链接跳转相应文章：" .. config.web_url .. "/posts/" .. post_id
                local response, err = httpc:request_uri(config.notify_service_url .. '/send/mail?email=' .. to .. '&content=' .. content .. '&title=' .. 'Lua 中国 - 新评论通知' .. '&from=' .. 'Lua 中国')
                if err ~= nil then
                    ngx.log(ngx.ERR, err)
                    return
                end
                local data = cjson.decode(response.body)
                if data.status ~= 0 then
                    ngx.log(ngx.ERR, response.body)
                end
            end,
        to, author, commenter, content, post_id)
end

return _M