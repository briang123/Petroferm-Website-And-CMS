

create  proc sp_NLT_GetLIVERecordsIfNotLiveWorkflowStatus
as
begin
	DECLARE @tableName sysname,
		@sql varchar(1000)

	DECLARE petroferm_cursor CURSOR FOR
	select 	TableName
	from 	tblPetrofermTableDefs_U
	where	TableType = 'LIVE'

	OPEN petroferm_cursor

	FETCH NEXT FROM petroferm_cursor
	INTO @tableName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN		
		select 	@sql = 'select ''' + @tableName + ''' as TableName, * from ' + @tableName + ' where workflowstatus <> ''LIVE'''
		print @sql
		exec(@sql)
		
	   FETCH NEXT FROM petroferm_cursor
	   INTO @tableName
	END
	
	CLOSE petroferm_cursor
	DEALLOCATE petroferm_cursor

end