local Model = require('models.model')
local Tag = require('models.tag')

local Post = Model:new('posts')

function Post:tag()
    return Post:belongs_to(Tag, 'id', 'post_tag_id')
end

return Post