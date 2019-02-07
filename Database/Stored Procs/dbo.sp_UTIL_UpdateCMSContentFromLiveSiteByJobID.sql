





CREATE  proc sp_UTIL_UpdateCMSContentFromLiveSiteByJobID
	@UserID int = 0,
	@JobID int = 0
as
begin

/*
created by: Brian Gaines
created on: 11/29/2006
purpose:
	This procedure rolls back the content associated with a deployment batch job on the CMS tables from the LIVE tables. If 
	the content in the CMS tables match those on the LIVE tables, a rollback will not be issued.

usage syntax:
	declare @retval int
	exec @retval = sp_UTIL_UpdateCMSContentFromLiveSiteByJobID @UserID = 1, @JobID = 2

history:
	Brian Gaines (11/29/2006) - created initial stored procedure
	Brian Gaines (12/31/2006) - added code to handle deletions of content that has not yet beenn deployed
*/

if (@UserID = 0 or @UserID is null)
begin
	print 'A user id is required'
	return 0
end
else if (@JobId = 0 or @JobId is null)
begin
	print 'A job id is required'
	return 0
end
else
begin

	BEGIN TRANSACTION 

	DECLARE @tableName sysname,
		@queueSql varchar(8000),
		@keyValue int,
		@keyName varchar(50),
		@queueId int,
		@columnListWithAlias varchar(500),
		@columnListNoAlias varchar(500),
		@deployedBy varchar(150),
		@pk varchar(50),
		@deleted_new_data int

		select @deleted_new_data = 0

		-- get the user's name so we can add it to the deployment queue table (in case the user gets deleted in the future we have history of the name)
		select @deployedBy = FirstName + ' ' + LastName from tblAppUser where AppUserID = @UserID

		-- loop through all the CMS deployable tables
		DECLARE no_live_data_cursor CURSOR FOR
		SELECT 	TableName
		FROM 	tblPetrofermTableDefs_U
		WHERE	UPPER(TableType) = 'CMS'
		AND	IgnoreDeploy = 0
		AND 	exists (select 1 from information_schema.columns where column_name = 'WorkflowStatus')
		AND 	exists (select 1 from information_schema.columns where column_name = 'DeploymentJobId')
		ORDER BY DeploymentOrder asc

		OPEN no_live_data_cursor
	
		FETCH NEXT FROM no_live_data_cursor
		INTO @tableName
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
			select @pk = dbo.fn__GetPrimaryKey(@tableName)
			select @queueSql = 'delete ' + @tableName + ' from ' + @tableName + ' m where not exists (select 1 from ' + @tableName + '_LIVE l where l.' + @pk + ' = m.' + @pk + ') and m.DeploymentJobId = ' + cast(@JobId as varchar(10)) + ' and upper(WorkflowStatus) <> ''LIVE''; '
			--print @queuesql
			insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
			exec(@queueSql)

		        IF @@ERROR <> 0
			begin
			   select @deleted_new_data = 0
		           GOTO ENDPROC
			end
			ELSE
			begin
			   select @deleted_new_data = @deleted_new_data + 1
			end
	
		   FETCH NEXT FROM no_live_data_cursor
		   INTO @tableName
		END
		
		CLOSE no_live_data_cursor
		DEALLOCATE no_live_data_cursor
		
		SAVE TRANSACTION no_live_data

		-- create temporary table to store all table names which we need to rollback content for from the live tables
		create table #rollback_table (TableName varchar(100))

		-- loop through all the CMS deployable tables
		DECLARE record_deletion_cursor CURSOR FOR
		SELECT 	TableName
		FROM 	tblPetrofermTableDefs_U
		WHERE	UPPER(TableType) = 'CMS'
		AND	IgnoreDeploy = 0
		AND 	exists (select 1 from information_schema.columns where column_name = 'WorkflowStatus')
		AND 	exists (select 1 from information_schema.columns where column_name = 'DeploymentJobId')
		ORDER BY DeploymentOrder asc

		OPEN record_deletion_cursor
	
		FETCH NEXT FROM record_deletion_cursor 
		INTO @tableName
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- since we're rolling back changes, we need to mark each CMS table record to be deleted in preparation for 
			-- rolling back with the live content
			select @queueSql = ' update ' + @tableName + ' set MarkedForDeletion = 1'
			select @queueSql = @queueSql + ' where DeploymentJobId = ' + cast(@JobId as varchar(10))
			select @queueSql = @queueSql + ' and upper(WorkflowStatus) <> ''LIVE''; '
			--print @queuesql
			exec(@queueSql)

		        IF @@ERROR <> 0
		           GOTO ENDPROC

			-- if we do have a rollback on the current table, then update our rollback_table temp table to log the table name
			-- needing an update from the live content
			select @queueSql = 'declare @d bit;'
			select @queueSql = @queueSql + ' select @d = MarkedForDeletion from ' + @tableName 
			select @queueSql = @queueSql + ' where DeploymentJobId = ' + cast(@JobId as varchar(10))
			select @queueSql = @queueSql + ' and upper(WorkflowStatus) <> ''LIVE'';'
			select @queueSql = @queueSql + ' if (@d = 1) begin insert into #rollback_table (TableName) values (''' + @tableName + ''') end;'
			--print @queuesql
			exec(@queueSql)

		        IF @@ERROR <> 0
		           GOTO ENDPROC
	
		   FETCH NEXT FROM record_deletion_cursor
		   INTO @tableName
		END
		
		CLOSE record_deletion_cursor
		DEALLOCATE record_deletion_cursor	

		declare @rollbackTableCount int
		select @rollbackTableCount = count(*) from #rollback_table

		-- if we do have rollbacks, then continue; otherwise, don't issue a rollback
		if (@rollbackTableCount > 0)
		begin

			-- loop through all the tables needing a rollback
			DECLARE rollback_cursor CURSOR FOR
			SELECT 	TableName 
			from 	#rollback_table
		
			OPEN rollback_cursor
		
			FETCH NEXT FROM rollback_cursor 
			INTO @tableName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				select @keyName = dbo.fn__GetPrimaryKey(@tableName)
	
				--load all rollback records for current job id into our deployment queue table
				print 	'--load all rollback records for current job id into our deployment queue table'
				select 	@queueSql = 'insert into tblDeploymentQueue_U (TableName, KeyName, KeyNameValue, RecordAction, DeploymentJobID, DeploymentDate, DeployedBy, ActiveFlag) '
				select 	@queueSql = @queueSql + 'select ''' + @tableName + ''', ''' + @keyName + ''', ' + @keyName + ', case MarkedForDeletion when 1 then ''ROLLBACK'' else ''IGNORE'' end, '
				select 	@queueSql = @queueSql + cast(@JobID as varchar(10)) + ', getdate(), ''' + @deployedBy + ''', 1 from ' + @tableName + ' where DeploymentJobId = ' + cast(@JobId as varchar(10))
				print 	@queueSql 
				print ' '
				--print @queuesql
				exec(@queueSql)
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())

			        IF @@ERROR <> 0
			           GOTO ENDPROC
	
				--delete all records from the cms table where they exist for the current rollback deployment batch job in our deployment queue table
				print 	'--delete all records from the cms table where they exist for the current rollback deployment batch job in our deployment queue table'
				select 	@queueSql = 'delete ' + @tableName + ' from tblDeploymentQueue_U q, ' + @tableName + ' cms where q.KeyNameValue = cms.' + @keyName 
				select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10)) + ' and q.TableName = ''' + @tableName 
				select 	@queueSql = @queueSql + ''' and UPPER(q.RecordAction) = ''ROLLBACK'' and q.ActiveFlag = 1;'
				print 	@queueSql				
				print ' '
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
				exec(@queueSql)
				--print @queuesql
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
	
				--deploy all records marked with a RecordAction of [ROLLBACK] in our deployment queue table to the cms tables
				print	'--deploy all records marked with a RecordAction of [ROLLBACK] in our deployment queue table to the cms tables'
				select	@columnListWithAlias = dbo.fn__GetTableColumnList('' + @tableName + '',1)
				select 	@columnListNoAlias = dbo.fn__GetTableColumnList('' + @tableName + '',0)
				select 	@queueSql = 'SET IDENTITY_INSERT ' + @tableName + ' ON;'
				select 	@queueSql = @queueSql + 'INSERT INTO ' + @tableName + ' (' + @columnListNoAlias + ') SELECT ' + @columnListWithAlias + ' FROM '
				select	@queueSql = @queueSql + @tableName + '_LIVE fn_a, tblDeploymentQueue_U q WHERE q.KeyNameValue = fn_a.' + @keyName 
				select 	@queueSql = @queueSql + ' AND q.DeploymentJobID = ' + cast(@JobId as varchar(10)) + ' AND q.TableName = ''' + @tableName
				select 	@queueSql = @queueSql + ''' AND UPPER(q.RecordAction) = ''ROLLBACK'' AND q.ActiveFlag = 1; '
				select	@queueSql = @queueSql + 'SET IDENTITY_INSERT ' + @tableName + ' OFF;'
				print 	@queueSql
				print ' '
				exec(@queueSql)
				--print @queuesql
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
	
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				-- update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job	
				print 	'update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job'
				select 	@queueSql = 'update ' + @tableName + ' set ' 
				select 	@queueSql = @queueSql + 'MarkedForDeletion = 0, ' 
				select 	@queueSql = @queueSql + 'WorkflowStatus = ''LIVE'', ' 
				select 	@queueSql = @queueSql + 'DeploymentJobId = 0 ' 
				select 	@queueSql = @queueSql + 'from tblDeploymentQueue_U q, ' + @tableName + ' cms ' 
				select 	@queueSql = @queueSql + 'where q.KeyNameValue = cms.' + @keyName 
				select 	@queueSql = @queueSql + ' and q.TableName = ''' + @tableName + '''' 
				select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10))
				select 	@queueSql = @queueSql + ' and UPPER(q.RecordAction) = ''ROLLBACK''' 
				select 	@queueSql = @queueSql + ' and q.ActiveFlag = 1'
				print 	@queueSql
				print ' '
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
				exec(@queueSql)
				--print @queuesql
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
	
			   FETCH NEXT FROM rollback_cursor
			   INTO @tableName
			END
			
			CLOSE rollback_cursor
			DEALLOCATE rollback_cursor
	
			drop table #rollback_table

		        IF @@ERROR <> 0
		           GOTO ENDPROC
	
			print 'Delete records from tblBusinessAppUser where the business unit does not exist in the tblBusinessUnit table'
			delete from tblBusinessAppUser where BusinessUnitId not in (select BusinessUnitId from tblBusinessUnit)
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			print 'Transfer our deployment records into a history table that can be archived. We only keep the current information in our queue table.'
			insert into tblDeploymentQueueHistory_U select * from tblDeploymentQueue_U where DeploymentJobID = @JobID and ActiveFlag = 1
		
			IF @@ERROR <> 0
			   GOTO ENDPROC
		
			print 'Updating the history table with the final deployment date of the job'
			update tblDeploymentQueueHistory_U set DeploymentDate = getdate() where DeploymentJobID = @JobID
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
		
			print 'Remove the queue records for the current job'
			delete from tblDeploymentQueue_U where DeploymentJobID = @JobID and ActiveFlag = 1
	
			update 	tblDeploymentJobs 
			set 	WorkflowStatus = 'WORKING', 
				LastModifiedDate = getdate(), 
				LastModifiedBy = @UserID 
			where 	DeploymentJobID = @JobID
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
		
			COMMIT TRANSACTION
		
			PRINT 'The rollback scripts were run successfully. We are now going to update the Petroferm table statistics...'
			exec sp_UTIL_UpdatePetrofermTableDefs
	
			RETURN 1
		end
		else
		begin
			if (@deleted_new_data = 0)
			begin
				ROLLBACK TRANSACTION
				print 'All content associated with the current job matches the content on the LIVE website. A rollback will not be necessary.'
				return 0
			end
			else
			begin
				ROLLBACK TRANSACTION no_live_data
				COMMIT TRANSACTION
				print 'All content associated with the current job matches the content on the LIVE website. A rollback will not be necessary; however, all NEW data will be cleared out.'
				return 1
			end
		end	

	ENDPROC:
	    	BEGIN
	        	IF @@TRANCOUNT > 0
	        	BEGIN 
				PRINT 'The rollback script failed. The content deployment will be rolled back to the original state.'
				ROLLBACK TRANSACTION
	        	END

	        	CLOSE rollback_cursor
	        	DEALLOCATE rollback_cursor
		END
	end
end