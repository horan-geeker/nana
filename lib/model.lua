local Database = require('lib.database')
local config = require('config.app')
local database_config = require('config.database')

local _M = {}

local mt = { __index = _M }

local WRITE = 'WRITE'
local READ = 'READ'

local database_write = Database:new({
	host = database_config.mysql.write.host,
	port = database_config.mysql.write.port,
	user = database_config.mysql.write.user,
	password = database_config.mysql.write.password,
	db_name = database_config.mysql.db_name,
	charset = database_config.mysql.charset,
	timeout = database_config.mysql.timeout,
	db_pool_timeout = database_config.mysql.pool_timeout,
	db_pool_size = database_config.mysql.pool_size,
	db_type = WRITE
})

local database_read = Database:new({
	host = database_config.mysql.read.host,
	port = database_config.mysql.read.port,
	user = database_config.mysql.read.user,
	password = database_config.mysql.read.password,
	db_name = database_config.mysql.db_name,
	charset = database_config.mysql.charset,
	timeout = database_config.mysql.timeout,
	db_pool_timeout = database_config.mysql.pool_timeout,
	db_pool_size = database_config.mysql.pool_size,
	db_type = READ
})

local function transform_value(value)
	if value == ngx.null then
		value = ''
	end
	value = value or ''
	if string.lower(value) == 'null' then
		return 'NULL'
	end
	return ngx.quote_sql_str(value)
end

-- return whole relations keys
function _M:get_relation_local_index(parents)
	local ids = {}
	for key,parent in pairs(parents) do
		table.insert( ids, parent[self.relation.local_key] )
	end
	return ids
end

-- return whole relation models
function _M:retrieve_relations(ids)
	-- if table is empty
	if next(ids) == nil then
		return {}
	end
	local ids_str = implode(unique(ids))
	self.relation_sql = 'select * from '..self.relation.model.table..' where ' .. self.relation.foreign_key .. ' in (' .. ids_str .. ')'
	return table_remove(self:query(self.relation_sql, READ), self.relation.model:get_hidden())
end

-- return current parent node
function _M:merge_one_relation(parent, relations)
	for index, item in pairs(relations) do
		if (parent[self.relation.local_key] == item[self.relation.foreign_key]) then
			parent[self.relation.key_name] = item
		end
	end
	return parent
end

function _M:merge_many_relations(parent, relations)
	for index, item in pairs(relations) do
		if (parent[self.relation.local_key] == item[self.relation.foreign_key]) then
			if not parent[self.relation.key_name] then
				parent[self.relation.key_name] = {}
			end
			table.insert(parent[self.relation.key_name], item)
		end
	end
	return parent
end

function _M:make_relations(parents)
	if self.relation.mode ~= 0 then
		local relations = self:retrieve_relations(self:get_relation_local_index(parents))
		for key, parent in pairs(parents) do
			if self.relation.mode == 1 then
				-- belongs to
				if table.getn(relations) > 0 then
					parents[key] = self:merge_one_relation(parent, relations)
				else
					parents[key][self.relation.key_name] = nil
				end
			elseif self.relation.mode == 2 then
				-- has many
				parents[key] = self:merge_many_relations(parent, relations)
			end
		end
	end
	return parents
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
	id = transform_value(id)
	local sql = 'select * from '..self.table..' where '..column..'='..id..' limit 1'
	local res = self:query(sql, READ)
	if table.getn(res) > 0 then
		res = self:make_relations(res)
		return res[1]
	else
		return false
	end
end

function _M:all()
	if self.query_sql ~= nil then
		ngx.log(ngx.ERR, 'cannot use all() with other query sql ', self.query_sql)
		return nil
	end
	local res = self:query('select * from '..self.table, READ)
	return self:make_relations(res)
end


function _M:where(column,operator,value)
	value = transform_value(value)
	if not self.query_sql then
		self.query_sql = 'where '..column.. ' ' .. operator .. ' ' .. value
	else
		self.query_sql = self.query_sql..' and '..column..' '..operator..' '..value
	end
	return self
end

function _M:orwhere(column,operator,value)
	value = transform_value(value)
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
		self.query_sql = 'order by '.. self.table .. '.' .. column .. ' ' ..operator
	else
		if self.has_order_by then
			self.query_sql = self.query_sql .. ',' .. column.. ' ' ..operator
		else
			self.query_sql = self.query_sql .. ' order by ' .. column.. ' ' ..operator
		end
	end
	self.has_order_by = true
	return self
end

function _M:count()
	local sql = self.query_sql
	if not sql then
		sql = 'select count(*) from '..self.table
	else
		sql = 'select count(*) from '..self.table..' '..self.query_sql
	end
	local res = self:query(sql, READ)
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
	local res = self:query(sql, READ)
	if self.relation.local_key ~= nil then
		return self:make_relations(res)
	end
	return res
end

function _M:paginate(page_num, per_page)
	page_num = page_num or 1
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
	total = self:query(count_sql, READ)
	if not total then
	else
		data['total'] = tonumber(total[1]['count(*)'])
		data['data'] = self:make_relations(self:query(sql, READ))
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
	local res = self:query(sql, READ)
	if next(res) ~= nil then
		res = self:make_relations(res)
		return res[1]
	else
		return false
	end
end

function _M:create(data)
	local columns,values
	for column,value in pairs(data) do
		value = transform_value(value)
		if not columns then
			columns = column
			values = value
		else
			columns = columns..','..column
			values = values..','..value
		end
	end
	return self:query('insert into '..self.table..'('..columns..') values('..values..')', WRITE)
end

function _M:with(relation)
	self.relation.key_name = relation
	if self[relation] == nil then
		ngx.log(ngx.ERR, self.table .. ' dont have ' .. relation .. ' function')
	end
	return self[relation]()
end

-- consider use array to store relation model
function _M:has_many(model, foreign_key, local_key)
	self.relation.model = model
	self.relation.local_key = local_key
	self.relation.foreign_key = foreign_key
	self.relation.mode = 2
	return self
end

function _M:belongs_to(model, foreign_key, local_key)
	self.relation.model = model
	self.relation.local_key = local_key
	self.relation.foreign_key = foreign_key
	self.relation.mode = 1
	return self
end

function _M:delete(id)
	id = id or nil
	if not id then
		-- 拼接需要delete的字段
		if self.query_sql then
			local sql = 'delete from '..self.table..' '..self.query_sql..' limit 1'
			return self:query(sql, WRITE)
		end
		ngx.log(ngx.ERR,'delete function need prefix sql')
		ngx.exit(500)
	else
		return self:query('delete from '..self.table..' where id=' .. id .. ' limit 1', WRITE)
	end
	return false
end

function _M:soft_delete()
	if self.query_sql then
		local sql = 'update '..self.table..' set '..self.soft_delete_column..' = now() '.. self.query_sql ..' limit 1'
		return self:query(sql, WRITE)
	end
	ngx.log(ngx.ERR,'soft_delete function cannot called without restriction')
	ngx.exit(500)
	return false
end

function _M:update(data)
	-- 拼接需要update的字段
	local str = nil
	for column,value in pairs(data) do
		clean_value = transform_value(value)
		if not str then
			str = column..'='..clean_value
		else
			str = str..','..column..'='..clean_value
		end
	end
	-- 判断是模型自身执行update还是数据库where限定执行
	if self.query_sql then
		local sql = 'update '..self.table..' set '..str..' '..self.query_sql..' limit 1'
		return self:query(sql, WRITE)
	end
	ngx.log(ngx.ERR,'update function cannot called without restriction')
	ngx.exit(500)
	return false
end

function _M:query(sql, type)
	if not sql then
		return ngx.log(ngx.ERR,'query() function need sql to query')
	end
	self.query_sql = nil
	self.has_order_by = false
	if type == READ then
		local result, err = database_read:mysql_query(sql)
		if err ~= nil then
			ngx.log(ngx.ERR, "read db error. res: " .. (err or "no reason"))
			ngx.exit(500)
			return
		end
		return result
	elseif type == WRITE then
		local result, err = database_write:mysql_query(sql)
		if err ~= nil then
			ngx.log(ngx.ERR, "write db error. res: " .. (err or "no reason"))
			ngx.exit(500)
			return
		end
		return result.affected_rows
	else
		ngx.log(ngx.ERR, 'type invalid, need ' .. READ .. ' or '..WRITE)
		ngx.exit(500)
		return
	end
end

function _M:get_hidden()
	return self.hidden
end

function _M:new(table, attributes, hidden)
	return setmetatable({
		table = table,
		attributes = attributes or {},
		hidden = hidden or {},
		query_sql = nil,
		has_order_by = false,
		relation = {
			mode = 0
		},
		relation_sql = nil,
		soft_delete_column = 'deleted_at'
		},mt)
end

return _M