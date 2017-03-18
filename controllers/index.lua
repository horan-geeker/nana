local cjson = require('cjson')
local conf = require('config.app')
local Model = require('models.model')
local validator = require('lib.validator')

local request = ngx.req.get_uri_args()
--use request to get all http args
ngx.say('request args: ',cjson.encode(request))
--curl "localhost:8001?id=1" -d name=foo     
--{"name":"foo","id":"1"}


local User = Model:new('users')
ngx.say('\nwhere demo:\n',cjson.encode(User:where('username','=','cgreen'):where('password','=','7c4a8d09ca3762af61e59520943dc26494f8941b'):get()))
-- {"password":"7c4a8d09ca3762af61e59520943dc26494f8941b","gender":"?","id":99,"username":"cgreen","email":"jratke@yahoo.com"}

ngx.say('\norwhere demo:\n',cjson.encode(User:where('id','=','1'):orwhere('id','=','2'):get()))
-- {"password":"7c4a8d09ca3762af61e59520943dc26494f8941b","gender":"?","id":1,"username":"hejunwei","email":"hejunweimake@gmail.com"},
-- {"password":"7c4a8d09ca3762af61e59520943dc26494f8941b","gender":"?","id":2,"username":"ward.antonina","email":"hegmann.bettie@wolff.biz"}

local Admin = Model:new('admins')
local admin = Admin:find(1)
ngx.say('\nfind demo:\n',cjson.encode(admin))
-- {"password":"d033e22ae348aeb5660fc2140aec35850c4da997","id":1,"email":"hejunwei@gmail.com","name":"admin"}
--Admin:update({name='update demo'}):where('id','=','3'):query()
Admin:update({
		name='update test',
		password="111111"
	}):where('id','=',3):query()

Admin:insert({
	id=3,
	password='123456',
	name='horanaaa',
	email='horangeeker@geeker.com',
})
