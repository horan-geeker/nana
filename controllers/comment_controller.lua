local request = require('lib.request')
local response = require('lib.response')
local Comment = require('models.comment')
local Post = require('models.post')
local validator = require('lib.validator')
local Auth = require('providers.auth_service_provider')

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
        response:json(0x000001, msg)
    end
    local user = Auth:user()
    local post = Post:find(post_id)
    if not post then
        response:json(0x030002)
    end
    local comment = Comment:create({
        user_id = user.id,
        post_id = post.id,
        content = args.content
    })
    if not comment then
        return response:json(0x000005, nil, nil, 500)
    end
    return response:json(0)
end

return _M