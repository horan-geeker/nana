local Model = require("models.model")
local config = require("config.app")
local common = require("lib.common")

local Post = Model:new('posts')

function Post:comments()
    return Post:has_many('comments', 'post_id', 'id')
end

function Post:users()
    return Post:belonyto('users', 'id', 'user_id')
end

return Post