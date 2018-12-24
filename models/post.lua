local Model = require("models.model")
local User = require('models.user')
local config = require("config.app")

local Post = Model:new('posts')

function Post:comments()
    return Post:has_many(Comment, 'post_id', 'id')
end

function Post:user()
    return Post:belongs_to(User, 'id', 'user_id')
end

return Post