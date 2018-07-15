local cjson = require('cjson')
local conf = require('config.app')
local Post = require('models.post')
local validator = require('lib.validator')
local request = require("lib.request")
local common = require("lib.common")
local request = require('lib.request')
local Comment = require('models.comment')
local Favor = require('models.favor')
local Tag = require('models.tag')
local Auth = require("providers.auth_service_provider")

local _M = {}

function _M:index()
	local args = request:all()
	local page = args.page or 1
	common:response(0, 'ok', Post:orderby('created_at', 'desc'):paginate(page))
end

function _M:store()
	local args = request:all() -- 拿到所有参数
	local ok, msg = validator:check(args, {
        'title',
        'content',
        'tag_id',
        'thumbnail',
        })
    if not ok then
        common:response(0x000001, msg)
	end
	local tag = Tag:find(args.tag_id)
	if not tag then
		common:response(0x030001)
    end
	local user = Auth:user()
	if not user then
		common:response(0x000001, 'internal error, user is empty')
    end
    local data = {
		tag_id=tag.id,
		user_id=user.id,
		title=args.title,
		content=args.content,
		thumbnail=args.thumbnail,
    }
	local post = Post:create(data)
    if not post then
        common:response(0x000005)
    end
	common:response(0,'ok', args)
end

function _M:show(id)
	local post = Post:find(id)
	if not post then
		post = nil
	else
		post.comments = Comment:where('post_id', '=', id):get()
		post.favor_count = Favor:where('post_id', '=', id):count()
	end
	common:response(0, 'ok', {
		post = post,
	})
end

return _M