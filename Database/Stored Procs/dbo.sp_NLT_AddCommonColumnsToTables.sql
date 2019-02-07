



CREATE   proc sp_NLT_AddCommonColumnsToTables 
	@execute bit = 0
as
begin

	DECLARE @tableName sysname,
		@sql varchar(1000)

	DECLARE add_columns_cursor CURSOR FOR
	SELECT 	TableName
	FROM 	tblPetrofermTableDefs_U
	WHERE	IgnoreDeploy = 0

	print 'UTILITY SCRIPT:'
	print 'The following sql scripts will add the required fields to the user tables.'

	if (@execute = 1)
	begin
		print 'The following alter table commands will be executed'
	end
	else
	begin
		print 'The following alter table commands will only be printed (not executed)'
	end
	print ''

	OPEN add_columns_cursor

	FETCH NEXT FROM add_columns_cursor 
	INTO @tableName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		if not exists(
			select 	1
			from 	information_schema.columns 
			where 	lower(column_name) = 'deploymentjobid'
			and	table_name = @tableName) 
		begin

			/*
			-- changing the default value of a table
			select 	@sql = 'ALTER TABLE ' + @tableName + ' DROP CONSTRAINT [DF_' + @tableName + '_DeploymentJobID];'
			select 	@sql = @sql + 'ALTER TABLE ' + @tableName + ' DROP COLUMN [DeploymentJobID];'
			select 	@sql = @sql + 'ALTER TABLE ' + @tableName + ' ADD [DeploymentJobID] [int] NOT NULL CONSTRAINT [DF_' + @tableName + '_DeploymentJobID] DEFAULT ((0)) WITH VALUES'
			*/

			select	@sql = 'ALTER TABLE ' + @tableName + ' ADD '
			select 	@sql = @sql + '[PublishDate] [datetime] NOT NULL CONSTRAINT [DF_' + @tableName + '_PublishDate] DEFAULT (getdate()), '
			select 	@sql = @sql + '[ExpirationDate] [datetime] NULL, '
			select 	@sql = @sql + '[WorkflowStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_' + @tableName + '_WorkflowStatus] DEFAULT (''WORKING''), '
			select 	@sql = @sql + '[LastModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_' + @tableName + '_LastModifiedDate] DEFAULT (getdate()), '
			select 	@sql = @sql + '[LastModifiedBy] [int] NOT NULL CONSTRAINT [DF_' + @tableName + '_LastModifiedBy] DEFAULT (0), '
			select 	@sql = @sql + '[ActiveFlag] [bit] NOT NULL CONSTRAINT [DF_' + @tableName + '_ActiveFlag] DEFAULT (1), '
			select 	@sql = @sql + '[MarkedForDeletion] [bit] NOT NULL CONSTRAINT [DF_' + @tableName + '_MarkedForDeletion] DEFAULT (0), '
			select 	@sql = @sql + '[DeploymentJobID] [int] NOT NULL CONSTRAINT [DF_' + @tableName + '_DeploymentJobID] DEFAULT ((0))'
			print 	@sql
			
			if (@execute = 1)
			begin
				exec(@sql)
			end
		end

	   FETCH NEXT FROM add_columns_cursor
	   INTO @tableName
	END
	
	CLOSE add_columns_cursor
	DEALLOCATE add_columns_cursor

	if (@execute = 1)
	begin
		print ''
		print 'The above alter table commands have been executed'
	end

end