local cjson = require('cjson')
local conf = require('config.app')
local Model = require('models.model')

local User = Model:new('users')
ngx.say(cjson.encode(User:where('username','=','cgreen'):where('password','=','7c4a8d09ca3762af61e59520943dc26494f8941b'):get()))

local Admin = Model:new('admins')
ngx.say(cjson.encode(Admin:find(1)))


Admin:insert({
	id=3,
	password='123456',
	name='horanaaa',
	email='horangeeker@geeker.com',
})

