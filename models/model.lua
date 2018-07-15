local Database = require('lib.database')
local Validator = require('lib.validator')
local common = require("lib.common")
local cjson = require('cjson')
local env = require('env')
local config = require('config.app')

local _M = {}

local mt = { __index = _M }

Database = Database:new(env)

function _M:merge_hidden()
	if #self.attributes == 0 then
		return '*'
	else
		local result = table_remove(self.attributes, self.hidden)
		return table.concat(result, ", ")
	end
end

function _M:all()
    return Database:query('select ' .. self:merge_hidden() .. ' from '..self.table)
end

function _M:where(column,operator,value)
	if not self.query_sql then
		self.query_sql = 'where '..column..operator..ngx.quote_sql_str(value)
	else
		self.query_sql = self.query_sql..' and '..column..operator..ngx.quote_sql_str(value)
	end
	return self
end

function _M:orwhere(column,operator,value)
	if not self.query_sql then
		return ngx.log(ngx.ERROR,'orwhere function need a query_sql prefix')
	else
		self.query_sql = self.query_sql..' or '..column..operator..ngx.quote_sql_str(value)
	end
	return self
end


function _M:count()
	local sql = self.query_sql, res
	if not sql then
		sql = 'select count(*) from '..self.table
	else
		sql = 'select count(*) from '..self.table..' '..self.query_sql
	end
	self.query_sql = nil
	res = Database:query(sql)
	if table.getn(res) > 0 then
		return tonumber(res[1]['count(*)'])
	else
		return 0
	end
end

function _M:orderby(column,operator)
	local operator = operator or 'asc'
	if not self.query_sql then
		self.query_sql = 'order by '..column.. ' ' ..operator
	else
		self.query_sql = self.query_sql..' order by '..column..' '..operator
	end
	return self
end

function _M:paginate(page_num, per_page)
	per_page = per_page or config.per_page
	local sql, count_sql, total
	local data={
		data = {},
		next_page = cjson.null,
		prev_page = cjson.null,
		total = 0
	}
	if not self.query_sql then
		sql = 'select * from '..self.table..' limit '..per_page*page_num..','..per_page
		count_sql = 'select count(*) from '..self.table
	else
		sql = 'select * from '..self.table..' '..self.query_sql..' limit '..per_page*(page_num-1)..','..per_page
		count_sql = 'select count(*) from '..self.table..' '..self.query_sql
	end
	self.query_sql = nil
	total = Database:query(count_sql)
	if not total then
	else
		data['total'] = tonumber(total[1]['count(*)'])
		data['data'] = Database:query(sql)
	end
	if (table.getn(data['data']) + ((page_num - 1)* per_page)) < data['total'] then
		data['next_page'] = page_num + 1
	end
	if tonumber(page_num) ~= 1 then
		data['prev_page'] = page_num - 1
	end

	return data
end

function _M:first()
	if not self.query_sql then
		ngx.log(ngx.ERROR,'do not have query sql str')
		return
	end
	local sql = 'select ' .. self:merge_hidden() .. ' from '..self.table..' '..self.query_sql..' limit 1'
	self.query_sql = nil
	local res = Database:query(sql)
	if table.getn(res) > 0 then
		return res[1]
	else
		return false
	end
end

function _M:get()
	if not self.query_sql then
		ngx.log(ngx.ERROR,'do not have query sql str')
		return
	end
	local sql = 'select ' .. self:merge_hidden() .. ' from '..self.table..' '..self.query_sql
	self.query_sql = nil
	local res = Database:query(sql)
	if table.getn(res) > 0 then
		return res
	else
		return false
	end
end

function _M:find(id,column)
    column = column or 'id'
    return Database:query('select ' .. self:merge_hidden() .. ' from '..self.table..' where '..column..'='..ngx.quote_sql_str(id)..' limit 1')
end

function _M:create(data)
	local columns,values
	for column,value in pairs(data) do
		value = value or '' -- convert nil to ''
		if not columns then
			columns = column
			values = ngx.quote_sql_str(value)
		else
			columns = columns..','..column
			values = values..','..ngx.quote_sql_str(value)
		end
	end
	return Database:execute('insert ignore into '..self.table..'('..columns..') values('..values..')')
end

function _M:delete()
	-- 拼接需要delete的字段
	if self.query_sql then
		local sql = 'delete from '..self.table..' '..self.query_sql..' limit 1'
		self.query_sql = nil
		return Database:execute(sql)
	end
	ngx.log(ngx.ERR,'delete function have to called first')
	return false
end

function _M:update(data)
	-- 拼接需要update的字段
	local str = nil
	for column,value in pairs(data) do
		if not str then
			str = column..'='..ngx.quote_sql_str(value)
		else
			str = str..','..column..'='..ngx.quote_sql_str(value)
		end
	end
	-- 判断是模型自身执行update还是数据库where限定执行
	if self.query_sql then
		local sql = 'update '..self.table..' set '..str..' '..self.query_sql..' limit 1'
		self.query_sql = nil
		return Database:execute(sql)
	end
	ngx.log(ngx.ERR,'update function have to called first')
	return false
end

function _M:query(sql)
	if not sql then
		if not self.query_sql then
			return ngx.log(ngx.ERROR,'query() function need sql to query')
		end
		return Database:execute(self.query_sql)
	end
	return Database:execute(sql)
end

function _M:new(table, attributes, hidden)
	return setmetatable({
		table = table,
		attributes = attributes or {},
		hidden = hidden or {},
		query_sql = nil,
		},mt)
end

return _M
