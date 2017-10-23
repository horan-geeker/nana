local function test1()
    return true
end

local function test2()
    return true
end

if test1()==true then
    ngx.say('test1')
    return 'test1'
end

if test2()==true then
    ngx.say('test2')
    return 'test2'
end
