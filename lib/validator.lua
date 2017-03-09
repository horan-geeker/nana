local cjson = require('cjson')

local Validator = {}

function Validator:in_table(item,table)
	for k,v in pairs(table) do
		if v == item then
			return true
		end
	end
	return false
end

function Validator:check(rules,data)
	for var,rule in pairs(rules) do
        if type(var) == 'number' then
            if not data[rule] or data[rule]=="" then
            	return false,rule..' arg not exists'
            end
        else
			for condition,info in pairs(rule) do
				if not data[var] then
					return false,var..' arg not exists'
				end
	            if condition == 'required' then
	                if data[var] == '' or data[var] == {} or data[var]== true then
	                    return false,var..' arg value is empty'
	                end
	            elseif condition == 'max' then
					if #data[var] > info then
						return false,var..' arg max length need '..info..' current is '..#data[var]
					end
				elseif condition == 'min' then
					if #data[var] < info then
						return false,var..' arg min length need '..info..' current is '..#data[var]
					end
				elseif condition == 'included' then
					if not self:in_table(data[var],info) then
						return false,var..' arg not included provide table'
					end
				else
					return false,'check() function params error'
				end
	        end
		end
	end
	return true,'ok'
end

function Validator:is_empty(t) 
    return _G.next(t) == nil
end

return Validator
