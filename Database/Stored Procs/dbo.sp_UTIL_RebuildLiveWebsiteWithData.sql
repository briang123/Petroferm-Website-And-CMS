


CREATE    proc sp_UTIL_RebuildLiveWebsiteWithData
	@are_you_sure bit = 0,
	@UserID int = null,
	@JobName varchar(100) = 'REBUILD LIVE WEBSITE WITH DATA',
	@JobDescription varchar(500) = 'Rebuild of the Petroferm website tables and content. All tables will be deleted, rebuilt, then loaded with all content from the CMS tables marked with a LIVE workflow status code.',
	@DeploymentDate datetime = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

	if (@are_you_sure = 1)
	begin
		if (@UserId is null or @UserId = 0)
		begin
		  print 'A UserId is required.'
		  return 0
		end
		
		-- evaluate input parameters, manipulate values if a null value is passed into proc, or format dates
		if (@DeploymentDate is null)
		begin
			select @DeploymentDate = dbo.fn__GetDateOnly(getdate())
		end
		else
		begin
			select @DeploymentDate = dbo.fn__GetDateOnly(@DeploymentDate)
		end
		
		BEGIN TRANSACTION
		
		
			DECLARE @tableName sysname,
				@queueSql varchar(1000),
				@keyValue int,
				@keyName varchar(50),
				@queueId int,
				@result int,
				@columnList varchar(500),
				@deployedBy varchar(200),
				@jobId int
		
			-- get the name of the user who is performing this deployment, we will add this user name to the deployment queue/history table	
			select @deployedBy = FirstName + ' ' + LastName from tblAppUser where AppUserId = @UserId
		
			-- MAKE SURE WE HAVE A JOB THAT GETS CREATED FOR THIS DEPLOYMENT PROCESS
			-- log our deployment process by inserting a record into the deployment log table
			insert into tblDeploymentJobs (JobName, JobDescription, ReviewBy, ApprovedBy, DeploymentDate, DeployedBy, WorkflowStatus)
			values (@JobName, @JobDescription, @UserID, @UserID, @DeploymentDate, @UserID, @WorkflowStatus)
		
			-- get the job id associated with this deployment (will be used in our Queue table)
			select @jobId = @@identity

		        IF @@ERROR <> 0
		           GOTO ENDPROC
		
			INSERT INTO tblWorkflowAudit_U (DeploymentJobId, WorkflowStatus, StatusChangedBy, StatusChangeDate, LastModifiedBy) 
			VALUES (@jobID, @WorkflowStatus, @deployedBy, getdate(), @UserID)

		        IF @@ERROR <> 0
		           GOTO ENDPROC

			-- drop the live tables from the system so they can be re-built (use 1 as the parameter to un-install)
			exec @result = sp_UTIL_BuildPetrofermLiveTables 1
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
		
			-- re-install the live tables
			exec @result = sp_UTIL_BuildPetrofermLiveTables
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
		
			DECLARE deploy_cursor CURSOR FOR
		
			-- we only want our CMS content tables that we have marked as ones to deploy from to be iterated through
			SELECT 	TableName 
			FROM 	tblPetrofermTableDefs_U
			where 	TableType = 'CMS'
			and 	IgnoreDeploy = 0
			order by DeploymentOrder asc
		
			OPEN deploy_cursor
		
			FETCH NEXT FROM deploy_cursor 
			INTO @tableName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				select @keyName = dbo.fn__GetPrimaryKey(@tableName)
		
				-- load all "live" records into our deployment queue table
				print 	'--load all records pending deployment into our deployment queue table'
				select 	@queueSql = 'insert into tblDeploymentQueue_U (TableName, KeyName, KeyNameValue, RecordAction, DeploymentJobID, DeploymentDate, DeployedBy, ActiveFlag) '
				select 	@queueSql = @queueSql + 'select ''' + @tableName + ''', ''' + @keyName + ''', ' + @keyName + ', ''INSERT''' 
				select 	@queueSql = @queueSql + ', ' + cast(@JobID as varchar(10)) + ', getdate(), ''' + @deployedBy + ''', 1 from ' + @tableName + ' where UPPER(WorkflowStatus) = ''LIVE'''
				print 	@queueSql 
				print ' '
				exec(@queueSql)
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
				-- deploy all records marked with a RecordAction of [insert] in our deployment queue table to the live tables 
				print	'--deploy all records marked with a RecordAction of [insert] in our deployment queue table to the live tables'
				select	@columnList = dbo.fn__GetTableColumnList('' + @tableName + '_LIVE',1)
				select 	@queueSql = 'insert into ' + @tableName + '_LIVE select ' + @columnList + ' from ' + @tableName + ' fn_a, tblDeploymentQueue_U q where q.KeyNameValue = fn_a.' + @keyName 
				select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10)) + ' and q.TableName = ''' + @tableName
				select 	@queueSql = @queueSql + ''' and UPPER(q.RecordAction) = ''INSERT'' and q.ActiveFlag = 1'
				print 	@queueSql
				print ' '
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
				exec(@queueSql)
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
				-- update records on current LIVE table. We will reset some of the values since they do not apply in that environment
				print 	'update records on current LIVE table. We will reset some of the values since they do not apply in that environment'
				select 	@queueSql = 'update ' + @tableName + '_LIVE set '
				select 	@queueSql = @queueSql + 'MarkedForDeletion = 0, '
				select 	@queueSql = @queueSql + 'WorkflowStatus = ''LIVE'', '
				select 	@queueSql = @queueSql + 'DeploymentJobID = 0 ' 
				select 	@queueSql = @queueSql + 'from tblDeploymentQueue_U q, ' + @tableName + '_LIVE l '
				select 	@queueSql = @queueSql + 'where q.KeyNameValue = l.' + @keyName
				select 	@queueSql = @queueSql + ' and q.TableName = ''' + @tableName + ''''
				select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10)) + ''
				select 	@queueSql = @queueSql + ' and UPPER(q.RecordAction) = ''INSERT'''
				select 	@queueSql = @queueSql + ' and q.ActiveFlag = 1'
				print 	@queueSql
				print ' '
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
				exec(@queueSql)
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
				-- update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job	
				print 	'update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job'
				select 	@queueSql = 'update ' + @tableName + ' set '
				select 	@queueSql = @queueSql + 'MarkedForDeletion = 0, '
				select 	@queueSql = @queueSql + 'WorkflowStatus = ''LIVE'', '
				select 	@queueSql = @queueSql + 'DeploymentJobID = 0 ' 
				select 	@queueSql = @queueSql + 'from tblDeploymentQueue_U q, ' + @tableName + ' cms '
				select 	@queueSql = @queueSql + 'where q.KeyNameValue = cms.' + @keyName
				select 	@queueSql = @queueSql + ' and q.TableName = ''' + @tableName + ''''
				select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10)) + ''
				select 	@queueSql = @queueSql + ' and UPPER(q.RecordAction) = ''INSERT'''
				select 	@queueSql = @queueSql + ' and q.ActiveFlag = 1'
				print 	@queueSql
				print ' '
				insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
				exec(@queueSql)
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
			   FETCH NEXT FROM deploy_cursor
			   INTO @tableName
			END
			
			CLOSE deploy_cursor
			DEALLOCATE deploy_cursor
		
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
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
		
			print 'Update our deployment job table'
			update tblDeploymentJobs set WorkflowStatus = 'LIVE' where DeploymentJobId = @jobId

		        IF @@ERROR <> 0
		           GOTO ENDPROC
				
			COMMIT TRANSACTION
		
			PRINT 'The deployment scripts were run successfully. We are now going to update the Petroferm table statistics...'
		
			-- update the petroferm table statistics
			exec sp_UTIL_UpdatePetrofermTableDefs
		
			RETURN 1
		
		ENDPROC:
		    BEGIN
		        IF @@TRANCOUNT > 0
		           BEGIN 
			   PRINT 'The deployment script failed. The content deployment will be rolled back to the original state.'
		           ROLLBACK TRANSACTION
		            END
		            CLOSE deploy_cursor
		            DEALLOCATE deploy_cursor
		        END
	end
	else
	begin
		print 'You indicated that you were not sure you wanted to Rebuild the live website with data. Please specify @are_you_sure = 1 if you want to perform this operation.'
		return 0
	end

end