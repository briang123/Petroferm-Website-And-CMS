


CREATE proc sp_NLT_GenericProcWithCursor
	@parameters_here1 int = null,
	@parameters_here2 int = null
as
begin

/*
Here is a generic cursor procedure to iterate through whatever records are obtained from the select statement

NOTE: uncomment the begin transaction/commit transaction/rollback transaction stuff if not performing multiple execute statements.
*/

/*
BEGIN TRANSACTION
*/
	DECLARE @tableName sysname,
		@sql varchar(1000)

	DECLARE petroferm_cursor CURSOR FOR

	select 	TableName
	from 	tblPetrofermTableDefs_U
	where	TableType = 'CMS'
	order by DeploymentOrder asc

	OPEN petroferm_cursor

	FETCH NEXT FROM petroferm_cursor
	INTO @tableName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select 	@sql = 'select * from ' + @tableName
		print @sql
		exec(@sql)
		
/*
	        IF @@ERROR <> 0
	           GOTO ENDPROC
*/
	   FETCH NEXT FROM petroferm_cursor
	   INTO @tableName
	END
	
	CLOSE petroferm_cursor
	DEALLOCATE petroferm_cursor

/*
        IF @@ERROR <> 0
           GOTO ENDPROC

	COMMIT TRANSACTION

	RETURN

ENDPROC:
    BEGIN
        IF @@TRANCOUNT > 0
           BEGIN 
	   PRINT 'The script failed. The information will be rolled back to the original state.'
           ROLLBACK TRANSACTION
            END
            CLOSE petroferm_cursor
            DEALLOCATE petroferm_cursor
        END

*/
end