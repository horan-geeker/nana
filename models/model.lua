local Database = require('models.database')

Model = {table = nil,query_sql = nil}

function Model:all()
    return Database:query('select * from '..self.table)
end

function Model:where(column,operator,value)
	if not self.query_sql then
		self.query_sql = 'select * from '..self.table..' where '..column..operator..ngx.quote_sql_str(value)
	else
		self.query_sql = self.query_sql..' and '..column..operator..ngx.quote_sql_str(value)
	end
	return self
end

function Model:get()
	if not self.query_sql then
		ngx.log(ngx.ERROR,'do not have query sql str')
		return
	end
	return Database:query(self.query_sql) or ''
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

function Model:new(table)
	Model.table = table
	return self
end

return Model
