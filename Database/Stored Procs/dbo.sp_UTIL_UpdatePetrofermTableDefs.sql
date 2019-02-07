













CREATE              PROC sp_UTIL_UpdatePetrofermTableDefs
as
begin


	-- PURPOSE: Provides an at a glance view of the Petroferm stored procedure names and parameters
	delete from tblPetrofermSqlDefs_U
	where specific_name not in (
		select specific_name
		from information_schema.parameters 
		where specific_name like 'sp_%'
		and lower(specific_catalog) = 'petroferm') 

	insert into tblPetrofermSqlDefs_U (specific_name, ordinal_position, parameter_mode, parameter_name, data_type, character_maximum_length)
	select specific_name, ordinal_position, parameter_mode, parameter_name, data_type, isnull(character_maximum_length,'')
	from information_schema.parameters 
	where specific_name like 'sp_%'
	and lower(specific_catalog) = 'petroferm'
	and specific_name not in (select specific_name from tblPetrofermSqlDefs_U) -- don't re-add the procedures after they already exist
	order by specific_name, ordinal_position asc

	-- PURPOSE: Provides an at a glance view for monitoring record counts and deployment counts by table
	delete from tblPetrofermTableDefs_U
	where TableName not in (
		select table_name 
		from information_schema.tables 
		where lower(table_catalog) = 'petroferm')

	insert into tblPetrofermTableDefs_U (TableName, DeploymentOrder, TableType, TablePurpose, StagingRecords, VersionRecords, LiveRecords, DeploymentCounts)
	select 	table_name,0,null,null,0,0,0,0
	from	information_schema.tables
	where 	lower(table_catalog) = 'petroferm' -- only for the petroferm database
	and	left(lower(table_name),3) = 'tbl' -- only look for our naming convention
	and 	table_name <> 'tblPetrofermTableDefs_U' -- don't include the table name in the table itself
	and	table_name <> 'tblPetrofermSqlDefs_U'
	and	table_name not in (select TableName from tblPetrofermTableDefs_U) -- don't re-add the tables after they already exist.

	update tblPetrofermTableDefs_U set TableType = 'LIVE' where lower(right(TableName,5)) = '_live' and TableType is null

	-- update all live table values to NULL so they don't affect deployment.


	update 	tblPetrofermTableDefs_U set MarketTable = 1  from information_schema.columns c, tblPetrofermTableDefs_U t 
	where c.table_name = t.TableName and lower(right(t.TableName,5)) <> '_live' and upper(c.column_name) = 'MARKETID' and t.MarketTable is null
	
	update 	tblPetrofermTableDefs_U set BusinessUnitTable = 1 from information_schema.columns c, tblPetrofermTableDefs_U t
	where 	c.table_name = t.TableName and lower(right(t.TableName,5)) <> '_live' and upper(c.column_name) = 'BUSINESSUNITID' and t.BusinessUnitTable is null
	
	update 	tblPetrofermTableDefs_U set PageTable = 1 from information_schema.columns c, tblPetrofermTableDefs_U t
	where 	c.table_name = t.TableName and lower(right(t.TableName,5)) <> '_live' and upper(c.column_name) = 'PAGEID' and t.PageTable is null


	-- we need to exclude the deletion of the records by page id for the domain mappings table since this is a domain needs to go somewhere. 
	-- when a page id deleted and there is an associated domain mapped to it, we default the domain to go to the petroferm home page (pageid=1); 
	-- however, in order to do this, the PageTable value must be null.
	update 	tblPetrofermTableDefs_U 
	set 	markettable = null, 
		businessunittable=null, 
		pagetable=null 
	where 	tablename like '%_LIVE'
	or lower(tablename) in ('tbldomainmapping_u','tbldomainmapping_u_backup')


	DECLARE @tableName sysname,
		@tableType varchar(50),
		@ignoreDeploy bit,
		@sql varchar(1000)

	DECLARE update_table_def_cursor CURSOR FOR
	SELECT 	TableName, TableType, IgnoreDeploy
	FROM 	tblPetrofermTableDefs_U
	
	OPEN update_table_def_cursor

	FETCH NEXT FROM update_table_def_cursor 
	INTO @tableName, @tableType, @ignoreDeploy
	
	WHILE @@FETCH_STATUS = 0
	BEGIN

		select @sql = ''		
		if (upper(@tableType) = 'CMS')
		begin
			select @sql = 'declare @count int;select @count = count(*) from ' + @tableName + '; '
			select @sql = @sql + 'declare @c2 int;select @c2 = count(distinct(DeploymentJobId)) from tblDeploymentQueueHistory_U where TableName = ''' + @tableName + '''; '
			IF (@ignoreDeploy = 1)
			begin
				select @sql = @sql + 'update tblPetrofermTableDefs_U set LastModifiedDate = getdate(), LiveRecords = NULL, VersionRecords = NULL, StagingRecords = @count, DeploymentCounts = NULL where TableName = ''' + @tableName + '''; '
			end
			else
			begin
				select @sql = @sql + 'update tblPetrofermTableDefs_U set LastModifiedDate = getdate(), LiveRecords = NULL, VersionRecords = NULL, StagingRecords = @count, DeploymentCounts = @c2 where TableName = ''' + @tableName + '''; '
			end
		end
		else if (upper(@tableType) = 'VERSION')
		begin
			select @sql = 'declare @count int;select @count = count(*) from ' + @tableName + '; '
			select @sql = @sql + 'update tblPetrofermTableDefs_U set LastModifiedDate = getdate(), DeploymentOrder = NULL, LiveRecords = NULL, StagingRecords = NULL, VersionRecords = @count, DeploymentCounts = NULL where TableName = ''' + @tableName + '''; '
		end
		else if (upper(@tableType) = 'LIVE')
		begin
			select @sql = 'declare @count int;select @count = count(*) from ' + @tableName + '; '
			select @sql = @sql + 'update tblPetrofermTableDefs_U set LastModifiedDate = getdate(), LiveRecords = @count, DeploymentOrder = NULL, DeploymentCounts = NULL, VersionRecords = NULL where TableName = ''' + @tableName + '''; '

		end	
		else if (upper(@tableType) = 'UTILITY' or upper(@tableType) = 'TEST')
		begin
			select @sql = 'update tblPetrofermTableDefs_U set LastModifiedDate = getdate(), DeploymentOrder = NULL, LiveRecords = NULL, StagingRecords = NULL, VersionRecords = NULL, DeploymentCounts = NULL  where TableName = ''' + @tableName + '''; '
		end


		if (@sql <> '')
		begin
			print @sql
			exec(@sql)
		end

	   FETCH NEXT FROM update_table_def_cursor
	   INTO @tableName, @tableType, @ignoreDeploy
	END
	
	CLOSE update_table_def_cursor
	DEALLOCATE update_table_def_cursor	

end