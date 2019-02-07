



CREATE     proc sp__UpdateJobStatus
	@UserID int = null,
	@JobId int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

begin transaction

	DECLARE @tableName sysname,
		@sql varchar(1000),
		@userName varchar(150)

	select @userName = FirstName + ' ' + LastName from tblAppUser where AppUserId = @UserID

	DECLARE job_status_cursor CURSOR FOR
	SELECT 	TableName
	FROM 	tblPetrofermTableDefs_U
	WHERE	UPPER(TableType) = 'CMS'
	AND	IgnoreDeploy = 0
	AND 	exists (select 1 from information_schema.columns where column_name = 'WorkflowStatus')
	AND 	exists (select 1 from information_schema.columns where column_name = 'DeploymentJobId')
	ORDER BY DeploymentOrder asc
	
	OPEN job_status_cursor

	FETCH NEXT FROM job_status_cursor 
	INTO @tableName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		select @sql = 'update ' + @tableName + ' set WorkflowStatus = ''' + @WorkflowStatus
		select @sql = @sql + ''', LastModifiedBy = ' + cast(@UserID as varchar(5))
		select @sql = @sql + ', LastModifiedDate = ''' + cast(getdate() as varchar(25)) + ''''
		select @sql = @sql + ' where DeploymentJobId = ' + cast(@JobId as varchar(10))
		select @sql = @sql + ' and upper(WorkflowStatus) <> ''LIVE''; '
		exec(@sql)

	        IF @@ERROR <> 0
	           GOTO ENDPROC

	   FETCH NEXT FROM job_status_cursor
	   INTO @tableName
	END
	
	CLOSE job_status_cursor
	DEALLOCATE job_status_cursor	

	update 	tblDeploymentJobs 
	set 	WorkflowStatus = @WorkflowStatus, 
		LastModifiedBy = @UserId, 
		LastModifiedDate = getdate() 
	where 	DeploymentJobId = @JobId 
	and 	WorkflowStatus <> 'LIVE'
	
        IF @@ERROR <> 0
           GOTO ENDPROC

	-- update the workflow audit table so we can track the path a deployment job takes to get to a live state
	INSERT INTO tblWorkflowAudit_U (DeploymentJobId, WorkflowStatus, StatusChangedBy, StatusChangeDate, LastModifiedBy) 
	VALUES (@JobId, @WorkflowStatus, @userName, getdate(), @UserId)

        IF @@ERROR <> 0
           GOTO ENDPROC

	commit transaction

	exec sp_UTIL_UpdatePetrofermTableDefs

	RETURN 1

ENDPROC:
	BEGIN
    		IF @@TRANCOUNT > 0
        	BEGIN 
		   	PRINT 'The changing of the workflow status failed. All changes will be rolled back to their original state'
        	   	ROLLBACK TRANSACTION
            	END
            	CLOSE job_status_cursor
            	DEALLOCATE job_status_cursor
	END

	RETURN 0

end