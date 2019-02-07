

create proc sp_UTIL_DeleteAllMembershipInfo
	@are_you_sure bit = 0
as
begin

begin transaction

	DECLARE @userId uniqueidentifier,
		@sql varchar(1000)

	DECLARE petroferm_cursor CURSOR FOR

	select 	userid
	from 	aspnet_Users

	OPEN petroferm_cursor

	FETCH NEXT FROM petroferm_cursor
	INTO @userId
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select 	@sql = 'sp__DeleteUser ''' + cast(@userId as varchar(50)) + ''''
		print @sql
		exec(@sql)
		
	        IF @@ERROR <> 0
	           GOTO ENDPROC

	   FETCH NEXT FROM petroferm_cursor
	   INTO @userId
	END
	
	CLOSE petroferm_cursor
	DEALLOCATE petroferm_cursor

        IF @@ERROR <> 0
           GOTO ENDPROC

	COMMIT TRANSACTION

	RETURN

ENDPROC:
    BEGIN
        IF @@TRANCOUNT > 0
           BEGIN 
	   PRINT 'The script failed. The membership users will be rolled back to the original state.'
           ROLLBACK TRANSACTION
            END
            CLOSE petroferm_cursor
            DEALLOCATE petroferm_cursor
        END

end