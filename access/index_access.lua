local validator = require('lib.validator')
local common = require('lib.common')
local request = ngx.req.get_uri_args()

local ok,msg = validator:check({
    'sex',
    'age',
	name = {max=6,min=4,included={'fooba','hejunwei'}},
	},request)

if not ok then
	common:response(1, msg)
end
