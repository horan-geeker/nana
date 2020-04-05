-- Github Document: https://github.com/horan-geeker/nana
-- Author:          hejunwei
-- Version:         v0.8.0

-- openresty use their own luajit not official luajit at 1.15 version
-- use ngx api instead of lua api as much as possible

local application = require("lib.application")
local http_response = require("lib.response")

-- Run our application
local response = application:run()

-- send response to user
http_response:send(response)

-- process terminate business
application:terminate()
