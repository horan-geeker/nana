local Model = require("models.model")
local User = require('models.user')
local config = require("config.app")

local Post = Model:new('posts')

function Post:comments()
    return Post:hasMany(Comment:new(), 'id', 'post_id')
end

function Post:user()
    return Post:belongsTo(User:new(), 'user_id', 'id')
end

return Post