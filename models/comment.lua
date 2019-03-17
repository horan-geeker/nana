local Model = require("lib.model")
local config = require("config.app")
local User = require('models.user')

local Comment = Model:new('comments')

function Comment:user()
    return Comment:belongs_to(User, 'id', 'user_id')
end

function Comment:post()
    return Comment:belongs_to(Model:new('posts'), 'id', 'post_id')
end

return Comment