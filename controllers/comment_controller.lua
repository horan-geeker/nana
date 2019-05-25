local request = require('lib.request')
local response = require('lib.response')
local Comment = require('models.comment')
local Post = require('models.post')
local User = require('models.user')
local validator = require('lib.validator')
local Auth = require('lib.auth_service_provider')
local email_service = require('services.email_service')

local _M = {}

function _M:create(post_id)
    local args = request:all()
    local ok, msg =
        validator:check(
        args,
        {
            'content',
        }
    )
    if not ok then
        return response:json(0x000001, msg)
    end
    local user = Auth:user()
    local post = Post:find(post_id)
    local post_author = User:find(post.user_id)
    if not post then
        return response:json(0x040002)
    end
    local comment = Comment:create({
        user_id = user.id,
        post_id = post.id,
        content = args.content
    })
    if not comment then
        return response:error('database create error')
    end
    -- 本人评论自己的文章不发邮件通知
    if post_author.id ~= user.id then
        email_service:notify_comment(post_author.email, post_author.name, user.name, args.content)
    end
    return response:json(0)
end

return _M