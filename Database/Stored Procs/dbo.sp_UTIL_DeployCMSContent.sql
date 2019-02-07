








CREATE             proc sp_UTIL_DeployCMSContent 
	@UserID int = 0,
	@JobID int = 0
as
begin

BEGIN TRANSACTION

	DECLARE @tableName sysname,
		@queueSql varchar(1000),
		@keyValue int,
		@keyName varchar(50),
		@queueId int,
		@columnList varchar(500),
		@deployedBy varchar(150)

	select @deployedBy = FirstName + ' ' + LastName from tblAppUser where AppUserId = @UserID

	DECLARE deploy_cursor CURSOR FOR
	SELECT 	TableName 
	FROM 	tblPetrofermTableDefs_U
	where 	TableType = 'CMS'
	and 	IgnoreDeploy = 0
	order by DeploymentOrder asc

	/*
	Deployment Queue Table:
	ID, TableName, KeyName, KeyNameValue, RecordAction, DeploymentJobID, DeploymentDate, DeployedBy, ActiveFlag

	NOTES: For any particular deployment of CMS content to the LIVE website we care about the following:
	1) First of all, the reason we have CMS tables and LIVE tables with the same schema is for the purpose 
	of only having the website query against the LIVE data without having to sift through all of the working 
	data the CMS has in it. Basically, it's for performance purposes and keeping the LIVE content separated 
	from the development content.

	2) Avoiding concurrent changes across multiple deployment batch jobs. In other words, if content has 
	been modified and was assigned to job 1, then we don't want someone else to make a modification, 
	assign that change to job 2, then deploy to the LIVE website before job 1 was deployed, otherwise, 
	it would be likely that content would become out-of-sync on the LIVE website. To prevent this, we 
	enforce the CMS to prompt for a job name before allowing the CMS user to make any changes to the website 
	content. If content is attempted to be modified under the context of a different job name, then we alert 
	the user that the content has not been deployed and currently locked under a different job name. The 
	CMS user must then open the correct deployment job and make the change under that job context.
	
	3) LIVE tables do not have identity columns on their tables. In other words, we turned off the auto-
	generated number capability for the primary key value. This was so that our IDs from the CMS system and
	the production system are kept in-sync.

	4) Active Flag Indicator - We expect this value to be equal to 1 (or True); This is an extra field that 
	is in place in case we need to override the deployment process.

	5) Source Table Primary Key and Value so we can move the records from the source tables to the LIVE tables
	*/

	OPEN deploy_cursor

	FETCH NEXT FROM deploy_cursor 
	INTO @tableName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		select @keyName = dbo.fn__GetPrimaryKey(@tableName)

		-- load all records pending deployment into our deployment queue table
		print 	'--load all records pending deployment into our deployment queue table'
		select 	@queueSql = 'insert into tblDeploymentQueue_U (TableName, KeyName, KeyNameValue, RecordAction, DeploymentJobID, DeploymentDate, DeployedBy, ActiveFlag) '
		select 	@queueSql = @queueSql + 'select ''' + @tableName + ''', ''' + @keyName + ''', ' + @keyName + ', ' 
		select 	@queueSql = @queueSql + 'case MarkedForDeletion when 1 then ''DELETE'' else ''INSERT'' end '
		select 	@queueSql = @queueSql + ', ' + cast(@JobID as varchar(10)) + ', getdate(), ''' + @deployedBy + ''', 1 from ' + @tableName + ' where UPPER(WorkflowStatus) = ''PENDING DEPLOYMENT'''
		print 	@queueSql 
		print ' '
		exec(@queueSql)
		insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())

	        IF @@ERROR <> 0
	           GOTO ENDPROC

		-- delete all records from the live table where they exist for the current deployment batch job in our deployment queue table
		print 	'--delete all records from the live table where they exist for the current deployment batch job in our deployment queue table'
		select 	@queueSql = 'delete ' + @tableName + '_LIVE from tblDeploymentQueue_U q, ' + @tableName + '_LIVE l where q.KeyNameValue = l.' + @keyName 
		select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10)) + ' and q.TableName = ''' + @tableName 
		select 	@queueSql = @queueSql + ''' and UPPER(q.RecordAction) in (''DELETE'',''INSERT'') and q.ActiveFlag = 1'
		print 	@queueSql				
		print ' '
		insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())
		exec(@queueSql)

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
		exec(@queueSql)
		insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())

	        IF @@ERROR <> 0
	           GOTO ENDPROC

		-- update records on current LIVE table. We will reset some of the values since they do not apply in that environment
		print 	'update records on current LIVE table. We will reset some of the values since they do not apply in that environment'
		select 	@queueSql = 'update ' + @tableName + '_LIVE set '
		select 	@queueSql = @queueSql + 'MarkedForDeletion = 0, '
		select 	@queueSql = @queueSql + 'WorkflowStatus = ''LIVE'', ' 
		select 	@queueSql = @queueSql + 'DeploymentJobId = ' + cast(@JobID as varchar(10)) + '' 
		select 	@queueSql = @queueSql + ' from tblDeploymentQueue_U q, ' + @tableName + '_LIVE l' 
		select 	@queueSql = @queueSql + ' where q.KeyNameValue = l.' + @keyName 
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

		-- reset the current cms table settings now that we have deployed the changes to the live website instance.
		print 'reset the current cms table settings now that we have deployed the changes to the live website instance.'
		print ' '

		-- delete all records from the current CMS table. We do not need these any longer since we deployed them.
		print 	'--delete all records from the current CMS table. We do not need these any longer since we deployed them.'
		select 	@queueSql = 'delete ' + @tableName + ' from tblDeploymentQueue_U q, ' + @tableName + ' cms where q.KeyNameValue = cms.' + @keyName 
		select 	@queueSql = @queueSql + ' and q.DeploymentJobID = ' + cast(@JobID as varchar(10)) + ' and q.TableName = ''' + @tableName + ''''
		select 	@queueSql = @queueSql + ' and UPPER(q.RecordAction) = ''DELETE'' and q.ActiveFlag = 1'
		print 	@queueSql				
		print ' '
		exec(@queueSql)
		insert into tblDeploymentSqlLog_U (DeploymentJobID, SqlStatement, ExecuteDate) values (@JobID, @queueSql, getdate())

	        IF @@ERROR <> 0
	           GOTO ENDPROC

		-- update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job	
		print 	'update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job'
		select 	@queueSql = 'update ' + @tableName + ' set ' 
		select 	@queueSql = @queueSql + 'MarkedForDeletion = 0, ' 
		select 	@queueSql = @queueSql + 'WorkflowStatus = ''LIVE'', ' 
		select 	@queueSql = @queueSql + 'DeploymentJobId = 0, ' 
		select 	@queueSql = @queueSql + 'LastModifiedDate = getdate() ' 
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

        IF @@ERROR <> 0
           GOTO ENDPROC

	update tblDeploymentJobs set WorkflowStatus = 'LIVE', DeploymentDate = getdate() where DeploymentJobId = @JobID

        IF @@ERROR <> 0
           GOTO ENDPROC

	DECLARE @userName varchar(150)
	select @userName = FirstName + ' ' + LastName from tblAppUser where AppUserId = @UserID

	INSERT INTO tblWorkflowAudit_U (DeploymentJobId, WorkflowStatus, StatusChangedBy, StatusChangeDate, LastModifiedBy) 
	VALUES (@JobId, 'LIVE', @userName, getdate(), @UserId)

        IF @@ERROR <> 0
           GOTO ENDPROC

	COMMIT TRANSACTION

	PRINT 'The deployment scripts were run successfully. We are now going to update the Petroferm table statistics...'
	exec sp_UTIL_UpdatePetrofermTableDefs

	RETURN

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