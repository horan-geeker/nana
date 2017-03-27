local tb = (require "resty.test_base").new({unit_name="controllers.index"})

function tb:init()
	self:log("init complete")
end

function tb:test_001()
	error("invalid input")
end

function tb:atest_002()
	self:log("never be called")
end

function tb:test_003()
	self:log("ok")
end

-- units test
tb:run()