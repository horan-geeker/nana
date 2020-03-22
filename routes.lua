local route = require("lib.router")

route:get('/', 'index_controller', 'index')

return route