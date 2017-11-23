local request = require("lib.request")
local common = require("lib.common")
local User = require("models.user")
local validator = require("lib.validator")
local config = require("config.app")
local auth_service = require("services.auth")
local cjson = require("cjson")

local args = request:all()

local ok,user = User:verifyPassword(args[config.login_id],args.password)
if not ok then
	-- login fail
	common:response(2, config.login_id..' or password error')
else
	-- login success
	auth_service:authorize(user)
end

common:response(0)
