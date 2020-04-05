describe('test', function()
    require('lib.helpers'):init(_G)
    assert.same(table_remove({'a'}, {0,1,2,3,4,'a'}), {0,1,2,3,4})
end)