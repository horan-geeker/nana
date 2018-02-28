local cjson = require('cjson')
local conf = require('config.app')
local User = require('models.user')
local validator = require('lib.validator')
local request = require("lib.request")
local common = require("lib.common")

local _M = {}

function _M:index()
	local args = request:all() -- 拿到所有参数
	-- local data = User:where('nickname','=','37zFHoGj'):where('password','=','321'):first()
	-- if data then
	-- 	ngx.say('\nwhere demo:\n',cjson.encode(data))
	-- end
	
	-- ngx.say('\norwhere demo:\n',cjson.encode(User:where('id','=','1'):orwhere('id','=','2'):get()))
	
	-- local user = User:find(1)
	-- ngx.say('\nfind demo:\n',cjson.encode(user))
	-- local result = User:where('id','=','2'):update({nickname='update demo', password='54321'})
	
	-- if result then
	-- 	ngx.say('update success', result)
	-- else
	-- 	ngx.say('update fail', result)
	-- end
	
	-- local ok,err = User:create({
	-- 	password='123456',
	-- 	nickname='horanaaa',
	-- 	email='horangeeker@geeker.com',
	-- 	})
	-- if not ok then
	-- 	ngx.log(ngx.ERR, err)
	-- end

	-- ok,err = User:where('id','=','1'):delete()
	-- if not ok then
	-- 	ngx.log(ngx.ERR, err)
	-- end
	common:response(0,'request args', args)
end

return _M