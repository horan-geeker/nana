local function pass(sign)
    print('pass:', sign)
end

local function fail(target, expect)
    print('fail:', target, ' ', expect)
end

local function is_true(result)
    if result then
        pass(result)
    else
        fail(result)
    end
end

local function equal(a, b)
    if a == b then
        pass(a)
    else
        fail(a, b)
    end
end

return {
    pass = pass,
    fail = fail,
    equal = equal,
    is_true = is_true,
}