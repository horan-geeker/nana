local _M = {}

function _M:new(k)
    return setmetatable({
        key = k,
        children = {},
    }, {__index = self})
end

function _M:append_child(hash_table)
    table.insert(self.children, hash_table)
end

function _M:set_value(value)
    self.value = value
end

function _M:find_child_by_key(key)
    for _, child in ipairs(self.children) do
        if string.char(string.byte(child.key)) == '{' then
            return child, key
        end
        if child.key == key then
            return child
        end
    end
    return nil
end
return _M