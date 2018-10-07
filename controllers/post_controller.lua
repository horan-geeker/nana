local cjson = require('cjson')
local conf = require('config.app')
local Post = require('models.post')
local User = require('models.user')
local validator = require('lib.validator')
local request = require("lib.request")
local response = require('lib.response')
local Comment = require('models.comment')
local Favor = require('models.favor')
local Tag = require('models.tag')
local Auth = require("providers.auth_service_provider")

local _M = {}

function _M:index()
	local args = request:all()
	local page = args.page or 1
	response:json(0, 'ok', Post:orderby('created_at', 'desc'):with('user'):paginate(page))
end

function _M:store()
	local args = request:all() -- 拿到所有参数
	local ok, msg = validator:check(args, {
        'title',
        'content',
        'tag_id',
        })
    if not ok then
        response:json(0x000001, msg)
	end
	local tag = Tag:find(args.tag_id)
	if not tag then
		response:json(0x030001)
    end
	local user = Auth:user()
	if not user then
		response:json(0x000001, 'internal error, user is empty')
    end
    local data = {
		post_tag_id=tag.id,
		user_id=user.id,
		title=args.title,
		content=args.content,
		thumbnail='',
    }
	local post = Post:create(data)
    if not post then
        response:json(0x000005)
    end
	response:json(0,'ok', args)
end

function _M:show(id)
	local post = Post:with('user'):find(id)
	if not post then
		post = nil
		response:json(0x030001)
	else
		post.comments = Comment:where('post_id', '=', id):get()
		post.favor_count = Favor:where('post_id', '=', id):count()
		Post:where('id', '=', post.id):update({read_count = post.read_count+1})
		response:json(0, 'ok', post)
	end
end

function _M:tags()
	local tags = Tag:all()
	response:json(0, 'ok', tags)
end

function _M:count()
	response:json(0, 'ok', Post:count())
end

function _M:favor(id)
	local post = Post:find(id)
	if not post then
		post = nil
		response:json(0x030001)
	else
		local auth = Auth:user()
		local favor = Favor:where('user_id', '=', auth.id):where('post_id','=', post.id):first()
		if not favor then
			local ok = Favor:create({
				user_id=auth.id,
				post_id=post.id,
			})
			if not ok then
				return response:json(0x000005)
			end
		else
			local ok = Favor:delete(favor.id)
			if not ok then
				return response:json(0x000005)
			end
		end
		return response:json(0)
	end
end

return _M