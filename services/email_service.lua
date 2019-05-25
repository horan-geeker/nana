local config = require("config.app")
local http = require('lib.http')
local cjson = require('cjson')

local _M = {}

function _M:notify_comment(to, author, commenter, content, post_id)
    ngx.timer.at(0,
            function (premature, to, author, commenter, content, post_id)
                local httpc = http.new()
                -- urlencode
                str = '{"to": ["' .. to .. '"],"sub":{"%id%": ["' .. post_id .. '"], "%author_name%": ["' .. author .. '"], "%comment_content%": ["' .. content .. '"], "%commenter_name%": ["' .. commenter .. '"]}}'
                str = string.gsub (str, "\n", "\r\n")
                str = string.gsub (str, "([^%w ])",
                    function (c) return string.format ("%%%02X", string.byte(c)) end)
                str = string.gsub (str, " ", "+")
                -- end
                local body = 'apiUser=' .. config.sendcloud.email_api_user .. '&apiKey=' .. config.sendcloud.email_api_key .. '&from=support@mail.lua-china.com&templateInvokeName=comment_notify&subject=Lua 中国 - 新评论通知&to=' .. to .. '&xsmtpapi=' .. str
                local response, err = httpc:request_uri(config.sendcloud.email_url, {
                    ssl_verify=false,
                    method = "POST",
                    body = body,
                    headers = {
                        ["Content-Type"] = "application/x-www-form-urlencoded",
                    },
                })
                if err ~= nil then
                    ngx.log(ngx.ERR, err)
                    return
                end
                local data = cjson.decode(response.body)
                if data.statusCode ~= 200 then
                    ngx.log(ngx.ERR, response.body)
                end
            end,
        to, author, commenter, content, post_id)
end

return _M