local Database = require('models.database')

local Model = {table = nil,query_sql = nil}

function Model:all()
    return Database:query('select * from '..self.table)
end

function Model:where(column,operator,value)
	if not self.query_sql then
		self.query_sql = 'select * from '..self.table..' where '..column..operator..ngx.quote_sql_str(value)
	elseif string.sub(self.query_sql,1,6) == 'update' then
		self.query_sql = self.query_sql..' where '..column..operator..ngx.quote_sql_str(value)
	else
		self.query_sql = self.query_sql..' and '..column..operator..ngx.quote_sql_str(value)
	end
	return self
end

function Model:orwhere(column,operator,value)
	if not self.query_sql then
		return ngx.log(ngx.ERROR,'orwhere function need a query_sql prefix')
	else
		self.query_sql = self.query_sql..' or '..column..operator..ngx.quote_sql_str(value)
	end
	return self
end

function Model:get()
	if not self.query_sql then
		ngx.log(ngx.ERROR,'do not have query sql str')
		return
	end
	local sql = self.query_sql
	self.query_sql = nil
	return Database:query(sql) or ''
end

function Model:find(id,column)
    column = column or 'id'
    return Database:query('select * from '..self.table..' where '..column..'='..ngx.quote_sql_str(id)..' limit 1')
end

function Model:insert(data)
	local columns,values
	for column,value in pairs(data) do
		if not columns then
			columns = column
			values = ngx.quote_sql_str(value)
		else
			columns = columns..','..column
			values = values..','..ngx.quote_sql_str(value)
		end
	end
	return Database:query('insert ignore into '..self.table..'('..columns..') values('..values..')')
end

function Model:update(data)
	local str = nil
	if not self.query_sql then
		for column,value in pairs(data) do
			if not str then
				str = column..'='..ngx.quote_sql_str(value)
			else
				str = str..','..column..'='..ngx.quote_sql_str(value)
			end
		end
		self.query_sql = 'update '..self.table..' set '..str
		return self
	end
	return ngx.log(ngx.ERROR,'update function have to called first')
end

function Model:query(sql)
	if not sql then
		if not self.query_sql then
			return ngx.log(ngx.ERROR,'query() function need sql to query')
		end
		return Database:query(self.query_sql)
	end
	return Database:query(sql)
end

function Model:new(table)
	Model.table = table
	return self
end

return Model
