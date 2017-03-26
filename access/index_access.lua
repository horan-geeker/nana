local validator = require('lib.validator')
local request = ngx.req.get_uri_args()

local ok,msg = validator:check({
    'sex',
    'age',
	name = {max=6,min=4,included={'fooba','hejunwei'}},
	},request)

if not ok then
	ngx.say('\nvalidate result: ',msg)
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end
