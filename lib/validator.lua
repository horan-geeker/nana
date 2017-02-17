local cjson = require('cjson')

local Validator = {}

function Validator:check(rules,data)
	for var,rule in pairs(rules) do
		for condition,info in pairs(rule) do
			ngx.say(condition)
			if condition == 'require' then
				if not data[var] then
					return false,var..' arg not exists'
				end
			elseif condition == 'max' then
				if #data[var] > info then
					return false,var..' arg max length need '..info..' current is '..#data[var]
				end
			elseif condition == 'min' then
				if #data[var] < info then
					return false,var..' arg min length need '..info..' current is '..#data[var]
				end
			else
				return false,'check() function params error'
			end
		end
	end
	return true,'ok'
end

return Validator