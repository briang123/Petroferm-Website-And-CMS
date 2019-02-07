



--drop proc sp_UTIL_TruncateDataFromNonLiveTables 0

CREATE PROC sp_NLT_TruncateDataFromNonLiveTables
	@are_you_sure bit = 0
as
begin
	
	DECLARE @tableName sysname,
		@tableType varchar(50),
		@canTruncate bit,
		@sql varchar(1000)

	DECLARE truncate_table_cursor CURSOR FOR
	SELECT 	TableName, TableType, CanTruncate
	FROM 	tblPetrofermTableDefs_U
	WHERE	CanTruncate = 1
	ORDER BY DeploymentOrder asc
	
	OPEN truncate_table_cursor

	FETCH NEXT FROM truncate_table_cursor 
	INTO @tableName, @tableType, @canTruncate
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if (@are_you_sure = 0)
		begin
			if (@canTruncate = 1 and UPPER(@tableType) <> 'LIVE')
			begin
				if exists(select 1 from information_schema.tables where lower(table_name) = lower(@tableName))
				begin
					select @sql = 'command NOT executed: truncate table ' + @tableName 
					print @sql
				end
			end

		end
		else
		begin
			if (@canTruncate = 1 and UPPER(@tableType) <> 'LIVE')
			begin

				select @sql = ''
				if exists(select 1 from information_schema.tables where lower(table_name) = lower(@tableName))
				begin
					select @sql = 'truncate table ' + @tableName 
					print @sql
				end
				
				if (@sql <> '')
				begin
					exec(@sql)
				end
			end
		end

	   FETCH NEXT FROM truncate_table_cursor
	   INTO @tableName, @tableType, @canTruncate
	END
	
	CLOSE truncate_table_cursor
	DEALLOCATE truncate_table_cursor	

	exec sp_UTIL_UpdatePetrofermTableDefs
end