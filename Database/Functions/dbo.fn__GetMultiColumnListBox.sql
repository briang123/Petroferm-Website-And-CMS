
CREATE  function fn__GetMultiColumnListBox()
returns varchar(100)
as
begin
DECLARE @ColumnList varchar(100) 
select @ColumnList = column_name + replicate(' ',30-len(column_name)) + table_name
from 	information_schema.columns 
where 	table_name like 'tbl%'
order by table_name, ordinal_position asc

return @ColumnList
end