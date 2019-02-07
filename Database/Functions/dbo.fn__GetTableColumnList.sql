



CREATE    FUNCTION fn__GetTableColumnList(
	@tableName varchar(100),
	@addAlias bit = 0
)
RETURNS VARCHAR(500)
AS
BEGIN

/* 
created by: Brian Gaines
created on: 11/24/2006
purpose:
	To return a comma separated list of columns for a particular passed in table. We also have the option 
	of adding a "pre-determined" alias as part of the column list so it can be used in a dynamic sql join
	condition.

	This is a special function in that it takes the first column in the table and moves it to the last. The 
	reason for this is that there are situations when we want to copy data from one set of tables (CMS tables) 
	to another set of tables (LIVE tables), but the schema has changed as a result of removing the identity 
	attribute of the primary key field. The workaround for this is to:
	
	1) create new column (last column -- soon to be our "primary key" column without the constraint)
	2) move data from PK column with identity to new column
	3) delete PK column
	4) rename new column

	...these steps are the reason for this function.
parameters:
	@tableName - A table name to return the column

Usage Syntax: 
	select dbo.fn__GetTableColumnList('tblSideNav_Live',1) 

history:
	Brian Gaines (11/24/2006) - Created initial UDF
*/

	DECLARE @ColumnList varchar(500) 
	
	if (@addAlias = 0)
	begin
		SELECT 	@ColumnList = COALESCE(@ColumnList + ',','') + CAST(column_name AS nvarchar(128)) 
		FROM 	information_schema.columns
		WHERE 	table_name = @tableName
	end
	else
	begin		

	   	declare @temp_column_list TABLE (
			column_name nvarchar(128), 
			ordinal_position smallint
		)

		if (upper(right(@tableName,5)) = '_LIVE')
		begin

			insert into @temp_column_list (column_name, ordinal_position)
			select	column_name, ordinal_position
			from 	information_schema.columns 
			where 	lower(table_name) = lower(@tableName)
	
			update 	@temp_column_list
			set 	column_name = 'fn_a.' + column_name,
				ordinal_position = ordinal_position - 1
	
			declare @maxOrdinal int
			select 	@maxOrdinal = max(ordinal_position) + 1 from @temp_column_list
	
			update 	@temp_column_list
			set 	ordinal_position = @maxOrdinal
			where 	ordinal_position = 0
	
			SELECT 	@ColumnList = COALESCE(@ColumnList + ', ','') + CAST(column_name AS nvarchar(128)) 
			FROM 	@temp_column_list
			ORDER BY ordinal_position asc

		end
		else
		begin
	
			insert into @temp_column_list (column_name, ordinal_position)
			select	column_name, ordinal_position
			from 	information_schema.columns 
			where 	lower(table_name) = lower(@tableName)
	
			update 	@temp_column_list
			set 	column_name = 'fn_a.' + column_name
		
			SELECT 	@ColumnList = COALESCE(@ColumnList + ', ','') + CAST(column_name AS nvarchar(128)) 
			FROM 	@temp_column_list
			ORDER BY ordinal_position asc

		end

	end
	RETURN @ColumnList
END