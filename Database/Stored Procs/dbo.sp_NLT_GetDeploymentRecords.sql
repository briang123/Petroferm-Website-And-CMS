
--select * from tblTest1
--select * from DeploymentQueue
CREATE  proc sp_NLT_GetDeploymentRecords
	@job varchar(50) = ' ',
	@deployedBy varchar(100) = ' '
as
begin

begin tran

	DECLARE @tableName sysname,
		@queueSql varchar(1000),
		@keyValue int,
		@keyName varchar(50)

	DECLARE deploy_cursor CURSOR FOR
	SELECT 	table_name FROM information_schema.tables 
	where 	lower(table_catalog) = 'petroferm'
	and 	lower(table_type) = 'base table'
	and	lower(table_name) like 'tblTest%' 
	and	right(lower(table_name),5) <> '_live'

	/*
	Deployment Queue Table:
	ID, TableName, KeyName, KeyNameValue, RecordAction, JobName, DeploymentDate, DeployedBy, ActiveFlag

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

		print 'table: ' + @tableName
		print '================================='
		exec('select * from ' + @tableName)		

		print 'table: ' + @tableName + '_LIVE'
		print '================================='
		exec('select * from ' + @tableName + '_LIVE')

		print 'table: DeploymentQueue'
		print '================================='
		select * from DeploymentQueue

		-- load all records pending deployment into our deployment queue table
		print 	'--load all records pending deployment into our deployment queue table'
		select 	@queueSql = 'insert into DeploymentQueue (TableName, KeyName, KeyNameValue, RecordAction, JobName, DeploymentDate, DeployedBy, ActiveFlag) '
		select 	@queueSql = @queueSql + 'select ''' + @tableName + ''', ''' + @keyName + ''', ' + @keyName + ', ' 
		select 	@queueSql = @queueSql + 'case MarkedForDeletion when 1 then ''DELETE'' else ''INSERT'' end '
		select 	@queueSql = @queueSql + ', ''' + @job + ''', getdate(), ''' + @deployedBy + ''', 1 from ' + @tableName + ' where UPPER(WFStatus) = ''PENDING DEPLOYMENT'' and ActiveFlag = 1'
		print 	@queueSql 
		print ' '
--		exec(@queueSql)

		-- delete all records from the live table where they exist for the current deployment batch job in our deployment queue table
		print 	'--delete all records from the live table where they exist for the current deployment batch job in our deployment queue table'
		select 	@queueSql = 'delete ' + @tableName + '_LIVE l from DeploymentQueue q where q.KeyNameValue = l.' + @keyName 
		select 	@queueSql = @queueSql + ' and q.JobName = ''' + @job + ''' and q.TableName = ''' + @tableName 
		select 	@queueSql = @queueSql + ''' and UPPER(q.RecordAction) in (''DELETE'',''INSERT'') and q.ActiveFlag = 1'
		print 	@queueSql				
		print ' '
--		exec(@queueSql)

		-- deploy all records marked with a RecordAction of [insert] in our deployment queue table to the live tables 
		print	'--deploy all records marked with a RecordAction of [insert] in our deployment queue table to the live tables'
		select 	@queueSql = 'select into ' + @tableName + '_LIVE from ' + @tableName + ' cms, DeploymentQueue q where q.KeyName = cms.' + @keyName 
		select 	@queueSql = @queueSql + ' and q.JobName = ''' + @job + ''' and q.TableName = ''' + @tableName
		select 	@queueSql = @queueSql + ''' and UPPER(q.RecordAction) = ''INSERT'' and q.ActiveFlag = 1'
		print 	@queueSql
		print ' '
--		exec(@queueSql)

		-- update records on current LIVE table. We will reset some of the values since they do not apply in that environment
		print 	'update records on current LIVE table. We will reset some of the values since they do not apply in that environment'
		select 	@queueSql = 'update ' + @tableName + '_LIVE l set '
		select 	@queueSql = @queueSql + 'l.MarkedForDeletion = NULL, '
		select 	@queueSql = @queueSql + 'l.WFStatus = ''LIVE'', '
		select 	@queueSql = @queueSql + 'l.DeploymentJobID = NULL ' 
		select 	@queueSql = @queueSql + 'from DeploymentQueue q '
		select 	@queueSql = @queueSql + 'where q.' + @keyName + ' = l.' + @keyName
		select 	@queueSql = @queueSql + ' and q.TableName = ''' + @tableName + ''''
		select 	@queueSql = @queueSql + ' and q.JobName = ''' + @job + ''''
		select 	@queueSql = @queueSql + ' and UPPER(q.RecordAction) = ''INSERT'''
		select 	@queueSql = @queueSql + ' and q.ActiveFlag = 1'
		print 	@queueSql
		print ' '

		-- reset the current cms table settings now that we have deployed the changes to the live website instance.
		print 'reset the current cms table settings now that we have deployed the changes to the live website instance.'
		print ' '

		-- delete all records from the current CMS table. We do not need these any longer since we deployed them.
		print 	'--delete all records from the current CMS table. We do not need these any longer since we deployed them.'
		select 	@queueSql = 'delete ' + @tableName + ' cms from DeploymentQueue q where q.KeyNameValue = cms.' + @keyName 
		select 	@queueSql = @queueSql + ' and q.JobName = ''' + @job + ''' and q.TableName = ''' + @tableName 
		select 	@queueSql = @queueSql + ''' and UPPER(q.RecordAction) = ''DELETE'' and q.ActiveFlag = 1'
		print 	@queueSql				
		print ' '
--		exec(@queueSql)

		-- update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job	
		print 	'update all records on current CMS table. We will reset them to where they can now be modified by someone else with a different deployment job'
		select 	@queueSql = 'update ' + @tableName + ' cms set '
		select 	@queueSql = @queueSql + 'cms.MarkedForDeletion = 0, '
		select 	@queueSql = @queueSql + 'cms.WFStatus = ''LIVE'', '
		select 	@queueSql = @queueSql + 'cms.DeploymentJobID = NULL ' 
		select 	@queueSql = @queueSql + 'from DeploymentQueue q '
		select 	@queueSql = @queueSql + 'where q.' + @keyName + ' = cms.' + @keyName
		select 	@queueSql = @queueSql + ' and q.TableName = ''' + @tableName + ''''
		select 	@queueSql = @queueSql + ' and q.JobName = ''' + @job + ''''
		select 	@queueSql = @queueSql + ' and UPPER(q.RecordAction) = ''INSERT'''
		select 	@queueSql = @queueSql + ' and q.ActiveFlag = 1'
		print 	@queueSql
		print ' '

		print 'table: ' + @tableName
		print '================================='
		exec('select * from ' + @tableName)		

		print 'table: ' + @tableName + '_LIVE'
		print '================================='
		exec('select * from ' + @tableName + '_LIVE')

		print 'table: DeploymentQueue'
		print '================================='
		select * from DeploymentQueue

	   FETCH NEXT FROM deploy_cursor
	   INTO @tableName
	END
	
	CLOSE deploy_cursor
	DEALLOCATE deploy_cursor


	insert into DeploymentQueueHistory select * from DeploymentQueue where JobName = @job and ActiveFlag = 1
	update DeploymentQueueHistory set DeploymentDate = getdate() where JobName = @job
	delete from DeploymentQueue where JobName = @job and ActiveFlag = 1

if (@@error = 0)
begin
	commit tran
end
else
begin
	rollback tran
end


SELECT * FROM DeploymentQueue
SELECT * FROM DeploymentQueueHistory
--truncate table DeploymentQueue
end