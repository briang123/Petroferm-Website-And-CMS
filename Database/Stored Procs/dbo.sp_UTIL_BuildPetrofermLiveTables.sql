



CREATE         PROC sp_UTIL_BuildPetrofermLiveTables
	@remove bit = 0
as
begin
	
begin transaction

	DECLARE @tableName sysname,
		@tableType varchar(50),
		@ignoreDeploy bit,
		@sql varchar(1000)

	declare @CRLF char(2)		
	select 	@CRLF = char(10) + char(13)

	DECLARE build_table_cursor CURSOR FOR
	SELECT 	TableName, TableType, IgnoreDeploy
	FROM 	tblPetrofermTableDefs_U
	WHERE	UPPER(TableType) IN ('CMS','LIVE')
	ORDER BY DeploymentOrder asc
	
	OPEN build_table_cursor

	FETCH NEXT FROM build_table_cursor 
	INTO @tableName, @tableType, @ignoreDeploy
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		/* adding primary key constraints on the cms tables (non-version and non-live tables)
		declare @firstColumn varchar(50)
		select @firstColumn = column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE lower(TABLE_NAME) = @tableName and ORDINAL_POSITION = 1
		EXEC('ALTER TABLE ' + @tableName + ' ADD CONSTRAINT Pk_' + @tableName + ' PRIMARY KEY (' + @firstColumn + ')')
		*/

		if (@remove = 0)
		begin
			if (upper(@tableType) = 'CMS')
			begin
				if (@ignoreDeploy = 0)
				begin

					select @sql = 'if not exists(select 1 from information_schema.tables where lower(table_name) = ''' + lower(@tableName) + '_live'') '
					select @sql = @sql + 'select * into ' + @tableName + '_LIVE from ' + @tableName + ' where 1 = 2'
					print @sql
					exec(@sql)
	
					declare @firstColumn varchar(50)
					select @firstColumn = column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE lower(TABLE_NAME) = @tableName and ORDINAL_POSITION = 1
	
					exec('alter table ' + @tableName + '_LIVE add id_new int not null default (0)')
	
				        IF @@ERROR <> 0
				           GOTO ENDPROC
				
					exec('update ' + @tableName + '_LIVE set id_new = ' + @firstColumn + '; ') 
	
				        IF @@ERROR <> 0
				           GOTO ENDPROC
	
					exec('alter table ' + @tableName + '_LIVE drop column ' + @firstColumn + '; ') 
	
				        IF @@ERROR <> 0
				           GOTO ENDPROC
	
					exec('sp_rename ''' + @tableName + '_LIVE.id_new'', ' + @firstColumn + ';')
	
				        IF @@ERROR <> 0
				           GOTO ENDPROC
				end
			end

		end
		else
		begin

			-- BE VERY CAREFUL ABOUT REMOVING A LIVE TABLE. IF YOU DO, IT'S SIMPLE ENOUGH TO RE-ADD, BUT YOU'LL LOSE ALL YOUR DATA
			if (upper(@tableType) = 'LIVE')
			begin

				select @sql = ''
				if exists(select 1 from information_schema.tables where lower(table_name) = lower(@tableName))
				begin
					select @sql = 'drop table ' + @tableName 
					print @sql
				end
				
				if (@sql <> '')
				begin
					exec(@sql)
				end
				

/*
				select @sql = 'if not exists(select 1 from information_schema.tables where lower(table_name) = ''' + lower(@tableName) + ''') begin '
				select @sql = @sql + 'drop table ' + @tableName + ' end;'
				print @sql
				exec(@sql)
*/
			end

		end

	   FETCH NEXT FROM build_table_cursor
	   INTO @tableName, @tableType, @ignoreDeploy
	END
	
	CLOSE build_table_cursor
	DEALLOCATE build_table_cursor	

	commit transaction

	exec sp_UTIL_UpdatePetrofermTableDefs

	RETURN

ENDPROC:
    BEGIN
        IF @@TRANCOUNT > 0
           BEGIN 
	   PRINT 'The deployment of the new live tables failed. The conversion will be rolled back.'
           ROLLBACK TRANSACTION
            END
            CLOSE build_table_cursor
            DEALLOCATE build_table_cursor
        END



end