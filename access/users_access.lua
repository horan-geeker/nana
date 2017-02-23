local validator = require('lib.validator')
local request = require('lib.request')

validator:check({id={required=1}},request)
