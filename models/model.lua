local Database = require('lib.database')
local Validator = require('lib.validator')
local cjson = require('cjson')
local env = require('env')
local config = require('config.app')

local _M = {}

local mt = { __index = _M }

Database = Database:new(env)

local function transformValue(value)
	value = value or ''
	if string.lower(value) == 'null' then
		return 'NULL'
	end
	return ngx.quote_sql_str(value)
end

-- function _M:merge_hidden()
-- 	if #self.attributes == 0 then
-- 		return '*'
-- 	else
-- 		local result = table_remove(self.attributes, self.hidden)
-- 		return table.concat(result, ", ")
-- 	end
-- end

function _M:find(id,column)
	if self.query_sql ~= nil then
		ngx.log(ngx.ERR, 'cannot use find() with other query sql')
		return nil
	end
	column = column or 'id'
	id = transformValue(id)
	local sql = 'select * from '..self.table..' where '..column..'='..id..' limit 1'
	local res = self:query(sql)
	if table.getn(res) > 0 then
		if self.relation.mode ~= 0 then
			local relation = self:fetchRelation({res[1][self.relation.local_key]})
			if self.relation.mode == 1 then
				if table.getn(relation) > 0 then
					res[1][self.relation.key_name] = relation[1]
				else
					res[1][self.relation.key_name] = relation
				end
			elseif self.relation.mode == 2 then
				res[1][self.relation.key_name] = relation
			end
		end
		return res[1]
	else
		return false
	end
end

function _M:all()
	if self.query_sql ~= nil then
		ngx.log(ngx.ERR, 'cannot use all() with other query sql')
		return nil
	end
    return self:query('select * from '..self.table)
end


function _M:where(column,operator,value)
	value = transformValue(value)
	if not self.query_sql then
		self.query_sql = 'where '..column.. ' ' .. operator .. ' ' .. value
	else
		self.query_sql = self.query_sql..' and '..column..' '..operator..' '..value
	end
	return self
end

function _M:orwhere(column,operator,value)
	value = transformValue(value)
	if not self.query_sql then
		return ngx.log(ngx.ERR,'orwhere function need a query_sql prefix')
	else
		self.query_sql = self.query_sql..' or '..column..operator..value
	end
	return self
end


function _M:orderby(column,operator)
	local operator = operator or 'asc'
	if not self.query_sql then
		self.query_sql = 'order by '.. self.table ..'.'.. column.. ' ' ..operator
	else
		self.query_sql = self.query_sql..' order by '..column..' '..operator
	end
	return self
end

function _M:count()
	local sql = self.query_sql
	if not sql then
		sql = 'select count(*) from '..self.table
	else
		sql = 'select count(*) from '..self.table..' '..self.query_sql
	end
	local res = self:query(sql)
	if table.getn(res) > 0 then
		return tonumber(res[1]['count(*)'])
	else
		return 0
	end
end

-- params: (option)int num
-- return: table
function _M:get(num)
	num = num or nil
	local limit_sql = ''
	if num ~= nil then
		limit_sql = 'limit ' .. num
	end
	if not self.query_sql then
		ngx.log(ngx.ERR,'do not have query sql str')
		return
	end
	local sql = 'select * from '..self.table..' '..self.query_sql .. ' ' .. limit_sql
	local res = self:query(sql)
	if self.relation.local_key ~= nil then
		local ids = {}
		for key,value in pairs(res) do
			table.insert( ids, value[self.relation.local_key] )
		end
		local relations = self:fetchRelation(ids)
		for key, value in pairs(res) do
			for index, item in pairs(relations) do
				if (value[self.relation.local_key] == item[self.relation.foreign_key]) then
					res[key][self.relation.key_name] = item
				end
			end
		end
	end
	return res
end

function _M:paginate(page_num, per_page)
	per_page = per_page or config.per_page
	local sql, count_sql, total
	local data={
		data = {},
		next_page = 1,
		prev_page = 1,
		total = 0
	}
	if not self.query_sql then
		sql = 'select * from '..self.table..' limit '..per_page*page_num..','..per_page
		count_sql = 'select count(*) from '..self.table
	else
		sql = 'select * from '..self.table .. ' '..self.query_sql .. ' limit '..per_page*(page_num-1)..','..per_page
		count_sql = 'select count(*) from '..self.table..' '..self.query_sql
	end
	total = self:query(count_sql)
	if not total then
	else
		data['total'] = tonumber(total[1]['count(*)'])
		data['data'] = self:query(sql)
		local ids = {}
		for key,value in pairs(data['data']) do
			table.insert( ids, value[self.relation.local_key] )
		end
		local relations = self:fetchRelation(ids)
		for key, value in pairs(data['data']) do
			for index, item in pairs(relations) do
				if (value[self.relation.local_key] == item[self.relation.foreign_key]) then
					data['data'][key][self.relation.key_name] = item
				end
			end
		end
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
		ngx.log(ngx.ERR,'do not have query sql str')
		return
	end
	local sql = 'select * from '..self.table..' '..self.query_sql..' limit 1'
	local res = self:query(sql)
	if next(res) ~= nil then
		if self.relation.mode ~= 0 then
			local relation = self:fetchRelation({res[1][self.relation.local_key]})
			if self.relation.mode == 1 then
				if table.getn(relation) > 0 then
					res[1][self.relation.key_name] = relation[1]
				else
					res[1][self.relation.key_name] = relation
				end
			elseif self.relation.mode == 2 then
				res[1][self.relation.key_name] = relation
			end
		end
		return res[1]
	else
		return false
	end
end

function _M:create(data)
	local columns,values
	for column,value in pairs(data) do
		value = transformValue(value)
		if not columns then
			columns = column
			values = value
		else
			columns = columns..','..column
			values = values..','..value
		end
	end
	return self:execute('insert into '..self.table..'('..columns..') values('..values..')')
end

function _M:with(relation)
	self.relation.key_name = relation
	if self[relation] == nil then
		ngx.log(ngx.ERR, self.table .. ' dont have ' .. relation .. ' function')
	end
	return self[relation]()
end

function _M:hasMany(model, local_key, foreign_key)
	self.relation.model = model
	self.relation.local_key = local_key
	self.relation.foreign_key = foreign_key
	self.relation.mode = 2
	return self
end

function _M:belongsTo(model, local_key, foreign_key)
	self.relation.model = model
	self.relation.local_key = local_key
	self.relation.foreign_key = foreign_key
	self.relation.mode = 1
	return self
end

function _M:fetchRelation(ids)
	-- if table is empty
	if next(ids) == nil then
		return {}
	end
	local ids_str = implode(ids)
	self.relation_sql = 'select * from '..self.relation.model.table..' where ' .. self.relation.foreign_key .. ' in (' .. ids_str .. ')'
	return table_remove(Database:query(self.relation_sql), self.relation.model:getHidden())
end

function _M:delete(id)
	id = id or nil
	if not id then
		-- 拼接需要delete的字段
		if self.query_sql then
			local sql = 'delete from '..self.table..' '..self.query_sql..' limit 1'
			return self:execute(sql)
		end
		ngx.log(ngx.ERR,'delete function need prefix sql')
		ngx.exit(500)
	else
		return self:execute('delete from '..self.table..' where id=' .. id .. ' limit 1')
	end
	return false
end

function _M:soft_delete()
	if self.query_sql then
		local sql = 'update '..self.table..' set '..self.soft_delete_column..' = now() '.. self.query_sql ..' limit 1'
		return self:execute(sql)
	end
	ngx.log(ngx.ERR,'soft_delete function cannot called without restriction')
	ngx.exit(500)
	return false
end

function _M:update(data)
	-- 拼接需要update的字段
	local str = nil
	for column,value in pairs(data) do
		clean_value = transformValue(value)
		if not str then
			str = column..'='..clean_value
		else
			str = str..','..column..'='..clean_value
		end
	end
	-- 判断是模型自身执行update还是数据库where限定执行
	if self.query_sql then
		local sql = 'update '..self.table..' set '..str..' '..self.query_sql..' limit 1'
		return self:execute(sql)
	end
	ngx.log(ngx.ERR,'update function cannot called without restriction')
	ngx.exit(500)
	return false
end

function _M:query(sql)
	if not sql then
		return ngx.log(ngx.ERR,'query() function need sql to query')
	end
	self.query_sql = nil
	return Database:query(sql)
end

function _M:execute(sql)
	if not sql then
		return ngx.log(ngx.ERR,'execute() function need sql to execute')
	end
	self.query_sql = nil
	return Database:execute(sql)
end

function _M:getHidden()
	return self.hidden
end

function _M:new(table, attributes, hidden)
	return setmetatable({
		table = table,
		attributes = attributes or {},
		hidden = hidden or {},
		query_sql = nil,
		relation = {
			mode = 0
		},
		relation_sql = nil,
		soft_delete_column = 'deleted_at'
		},mt)
end

return _M
