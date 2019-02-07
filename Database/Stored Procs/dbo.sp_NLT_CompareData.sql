




create proc sp_NLT_CompareData
as
begin
/*
created by: Brian Gaines
created on: 12/30/2006
purpose: Display LIVE content discrepancies between the CMS and LIVE tables. We look for
	records that exist in the CMS, but not in the LIVE table. If there is a 
	discrepancy, then we pull back the entire record with the table name attached.

	We would use this procedure in the event that we're not seeing our changes deployed
	to the live environment. This script is not current executed from the CMS. An
	enhancement would be to add some utilities to the CMS to allow for some data checking

history:
	Brian Gaines (12/30/2006) - created initial stored procedure
*/
	DECLARE @tableName sysname,
		@sql varchar(1000),
		@pk varchar(100)

	DECLARE petroferm_cursor CURSOR FOR

	select 	TableName
	from 	tblPetrofermTableDefs_U
	where	TableType = 'CMS'
	and	IgnoreDeploy = 0
	order by DeploymentOrder asc

	OPEN petroferm_cursor

	FETCH NEXT FROM petroferm_cursor
	INTO @tableName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @pk = dbo.fn__GetPrimaryKey(@tableName)
		
		select 	@sql = 'select ''' + @tableName + ''' as TableName, * from ' + @tableName + ' where ' + @pk + ' not in (select ' + @pk + ' from ' + @tableName + '_LIVE) and workflowstatus = ''LIVE'''
		print @sql
		exec(@sql)
		
	   FETCH NEXT FROM petroferm_cursor
	   INTO @tableName
	END
	
	CLOSE petroferm_cursor
	DEALLOCATE petroferm_cursor

end