


CREATE  proc sp__DeleteDeploymentJob
	@UserID int = null,
	@JobId int = null
as
begin

	DECLARE @tableName sysname,
		@sql varchar(1000),
		@userName varchar(150),
		@part_of_other_job int

	create table #table_row_count (table_count int)

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
		select @sql = 'insert into #table_row_count '
		select @sql = @sql + ' select count(*) from ' + @tableName 
		select @sql = @sql + ' where DeploymentJobId = ' + cast(@JobID as varchar(10)) 
		select @sql = @sql + ' and upper(WorkflowStatus) <> ''LIVE'''
		print @sql
		print ''
		exec(@sql)

	   FETCH NEXT FROM job_status_cursor
	   INTO @tableName
	END
	
	CLOSE job_status_cursor
	DEALLOCATE job_status_cursor
		
	select @part_of_other_job = sum(table_count) from #table_row_count

	if (@part_of_other_job = 0)
	begin
		update 	tblDeploymentJobs 
		set 	ActiveFlag = 0,
			LastModifiedBy = @UserID,
			LastModifiedDate = getdate()
		where 	DeploymentJobId = @JobId
		
		if (@@error = 0)
		begin
			select sum(table_count) as 'TotalRecordsAttached' from #table_row_count
			drop table #table_row_count
			return 1
		end
		else
		begin
			select sum(table_count) as 'TotalRecordsAttached' from #table_row_count
			drop table #table_row_count
			return 0
		end
	end
	else
	begin
		return 0
	end

end