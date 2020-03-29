local _M = {}

function _M:new()
    return setmetatable({
        children = {},
    }, {__index = self})
end

function _M:append_child(child_key, hash_table)
    self.children[child_key] = hash_table
end

function _M:set_value(value)
    self.value = value
end

function _M:find_child_by_key(key)
    if not self.children[key] then
        for child_key, child in pairs(self.children) do
            if string.char(string.byte(child_key)) == '{' then
                return child, key
            end
        end
        return nil
    end
    return self.children[key]
end
return _M