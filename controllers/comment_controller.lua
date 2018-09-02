local request = require('lib.request')
local response = require('lib.response')
local Comment = require('model.comment')

local _M = {}

function _M:index(post_id)
    local comments = Comment:where('post_id',post_id):get()
    response:json(0, nil, comments)
end