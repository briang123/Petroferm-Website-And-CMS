

CREATE proc sp__DeletePage
	@PageID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin
/*
created by: Brian Gaines
created on: 12/28/2006
purpose: 
	delete the page and all related records

history:
	Brian Gaines (12/28/2006) - Created initial stored procedure
	Brian Gaines (1/4/2006) - Updated procedure to loop through all page modules
				- Removed duplicate entry product grid sql
				- Updated how we close and deallocate cursors
*/
	-- validate the input parameters
	if (@UserID is null or @UserID = 0)
	begin
		print 'A user id is required.'
		return 0
	end
	else if (@JobID is null or @JobID = 0)
	begin
		print 'A deployment job id is required.'
		return 0
	end	
	else if (@PageID is null or @PageID = 0)
	begin
		print 'A page is required.'
		return 0
	end
	else 
	begin
	
	declare @deleted_page_modules int,
		@deleted_page_record int

	-- do not close/deallocate cursor if error occurs and we never get into the cursor
	select 	@deleted_page_modules = -1,
		@deleted_page_record = -1

	if exists(select 1 from tblPage where PageID = @PageID)
	begin	
	
		declare @mark_for_deletion bit
	
		if (dbo.fn__TableExists('tblPage_LIVE') > 0)
		begin
			if exists(select 1 from tblPage_LIVE where PageID = @PageID)
			begin
				select @mark_for_deletion = 1
			end
			else
			begin
				select @mark_for_deletion = 0
			end
		end
		else
		begin
			select @mark_for_deletion = 0
		end

		BEGIN TRANSACTION
	
		DECLARE @tableName sysname,
			@sql varchar(1000),
			@part_of_other_job int
	
		select @part_of_other_job = 0
	
		if (@part_of_other_job = 0)
		begin
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblDocumentModuleReln d
			where p.PageId = r.PageId and r.SourceId = d.DocumentModuleRelnId
			and upper(r.SourceName) = 'DOCUMENT' and p.PageID = @PageID
			and upper(d.WorkflowStatus) <> 'LIVE' and d.DeploymentJobId <> @JobID
			
		end

		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblContentModule c
			where p.PageId = r.PageId and r.SourceId = c.ContentId
			and upper(r.SourceName) in ('CONTENT','SIDE CONTENT') and p.PageID = @PageID
			and upper(c.WorkflowStatus) <> 'LIVE' and c.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
			where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
			and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.PageID = @PageID
			and upper(h.WorkflowStatus) <> 'LIVE' and h.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin			
	
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
			and upper(r.SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') and p.PageID = @PageID
			and upper(i.WorkflowStatus) <> 'LIVE' and i.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin

			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblImageModule im
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
			and upper(r.SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') and p.PageID = @PageID
			and upper(im.WorkflowStatus) <> 'LIVE' and im.DeploymentJobId <> @JobID

		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProductGrid pg, tblProductGridModule pgm, tblPageModuleReln r
			where pg.ProductGridId = pgm.ProductGridId and r.SourceID = pgm.ProductGridModuleID 
			and upper(r.SourceName) = 'PRODUCT GRID' and r.PageID = @PageID 
			and upper(pgm.WorkflowStatus) <> 'LIVE' and pgm.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProductGrid pg, tblProductGridRowDef pgr, tblProductGridModule pgm, tblPageModuleReln r
			where pg.ProductGridId = pgr.ProductGridId and pg.ProductGridId = pgm.ProductGridId 
			and r.SourceID = pgm.ProductGridModuleID 
			and upper(r.SourceName) = 'PRODUCT GRID' and r.PageID = @PageID
			and upper(pgr.WorkflowStatus) <> 'LIVE' and pgr.DeploymentJobId <> @JobID
	
		end

		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProductGrid pg, tblProductGridColDef pgc, tblProductGridModule pgm, tblPageModuleReln r
			where pg.ProductGridId = pgc.ProductGridId and pg.ProductGridId = pgm.ProductGridId 
			and r.SourceID = pgm.ProductGridModuleID 
			and upper(r.SourceName) = 'PRODUCT GRID' and r.PageID = @PageID
			and upper(pgc.WorkflowStatus) <> 'LIVE' and pgc.DeploymentJobId <> @JobID
	
		end

		if (@part_of_other_job = 0)
		begin
			
			select	@part_of_other_job = count(*)
			from 	tblProductBlurbModule pbm, tblPageModuleReln r
			where 	r.SourceId = pbm.ProductBlurbModuleId and r.PageID = @PageID
			and 	upper(pbm.ProductSelection) = 'INDIVIDUAL' 
			and	upper(r.SourceName) = 'PRODUCT BLURB'
			and 	upper(pbm.WorkflowStatus) <> 'LIVE' and pbm.DeploymentJobId <> @JobID
	
		end

		if (@part_of_other_job = 0)
		begin

			select	@part_of_other_job = count(*)
			from 	tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblPageModuleReln r
			where 	r.SourceId = pbm.ProductBlurbModuleId and pbm.SourceId = pbmr.ProductBlurbModuleId
			and	r.PageID = @PageID 
			and 	upper(pbm.ProductSelection) = 'MULTIPLE'
			and	upper(r.SourceName) = 'PRODUCT BLURB'			
			and 	upper(pbm.WorkflowStatus) <> 'LIVE' and upper(pbmr.WorkflowStatus) <> 'LIVE' 
			and 	pbm.DeploymentJobId <> @JobID

		end

		if (@part_of_other_job = 0)
		begin	
			create table #table_row_count (table_count int)
	
			DECLARE remove_page_cursor_validate CURSOR FOR
		
			-- we only want our CMS content tables with deployment capabilities to be iterated through
			SELECT 	TableName
			from 	tblPetrofermTableDefs_U
			where 	PageTable = 1
		
			OPEN remove_page_cursor_validate
		
			FETCH NEXT FROM remove_page_cursor_validate
			INTO @tableName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				select @sql = ''
				select @sql = ' insert into #table_row_count '
				select @sql = @sql + ' select count(*) from ' + @tableName 
				select @sql = @sql + ' where PageID = ' + cast(@PageID as varchar(5)) 
				select @sql = @sql + ' and upper(WorkflowStatus) <> ''LIVE'' and DeploymentJobId <> ' + cast(@JobID as varchar(5))
				print @sql
				print ''
				exec(@sql)
	
			   FETCH NEXT FROM remove_page_cursor_validate
			   INTO @tableName
			END
			
			CLOSE remove_page_cursor_validate
			DEALLOCATE remove_page_cursor_validate
		
			select @part_of_other_job = sum(table_count) from #table_row_count
			drop table #table_row_count
		
		END
	
		if (@part_of_other_job = 0)
		begin
			declare @sourceName varchar(100),
				@sourceId int

			DECLARE remove_page_module_cursor CURSOR FOR
		
			SELECT 	SourceId, SourceName
			from 	tblPageModuleReln
			where 	PageID = @PageID
			order by SourceName asc
		
			OPEN remove_page_module_cursor
		
			FETCH NEXT FROM remove_page_module_cursor
			INTO @sourceId, @sourceName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN

				if (upper(@sourceName) = 'NAV ON IMAGE' or upper(@sourceName) = 'NAV OFF IMAGE' or upper(@sourceName) = 'HEADER IMAGE' or upper(@sourceName) = 'HEADER SIDE IMAGE')
				begin
					exec sp__DeleteImageModule @sourceId, @UserID, @JobID, 'WORKING'
				end
				else if (upper(@sourceName) = 'HEADER SIDE CONTENT')
				begin
					exec sp__DeleteHeaderSideContentModule @sourceId, @UserID, @JobID, 'WORKING'
				end
				else if (upper(@sourceName) = 'CONTENT' or upper(@sourceName) = 'SIDE CONTENT')
				begin
					exec sp__DeleteContentModule @sourceId, @UserID, @JobID, 'WORKING'
				end
				else if (upper(@sourceName) = 'DOCUMENT')
				begin
					exec sp__DeleteDocumentModule @sourceId, @UserID, @JobID, 'WORKING'
				end
				else if (upper(@sourceName) = 'PRODUCT GRID')
				begin
					exec sp__DeleteProductGridModule @sourceId, @UserID, @JobID, 'WORKING'
				end
				else if (upper(@sourceName) = 'PRODUCT BLURB')
				begin
					exec sp__DeleteProductBlurbModule @sourceId, @UserID, @JobID, 'WORKING'
				end
				
			        IF @@ERROR <> 0
				begin
				   select @deleted_page_modules = 0
			           GOTO ENDPROC
				end
				ELSE
				begin
				   select @deleted_page_modules = @deleted_page_modules + 1
				end
	
			   FETCH NEXT FROM remove_page_module_cursor
			   INTO @sourceId, @sourceName
			END
			
			CLOSE remove_page_module_cursor
			DEALLOCATE remove_page_module_cursor

			DECLARE remove_page_cursor CURSOR FOR
		
			-- we only want our CMS content tables with deployment capabilities to be iterated through
			SELECT 	TableName
			from 	tblPetrofermTableDefs_U
			where 	PageTable = 1
		
			OPEN remove_page_cursor
		
			FETCH NEXT FROM remove_page_cursor
			INTO @tableName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				if (@mark_for_deletion = 0)
				begin
					select @sql = 'delete from ' + @tableName + ' where PageID = ' + cast(@PageID as varchar(5))
				end
				else if (@mark_for_deletion = 1)
				begin
					select @sql = 'update ' + @tableName + ' set LastModifiedBy = ' + cast(@UserID as varchar(5))
					select @sql = @sql + ', MarkedForDeletion = 1, WorkflowStatus = ''WORKING'', '
					select @sql = @sql + 'DeploymentJobId = ' + cast(@JobID as varchar(5)) + ' where PageID = ' + cast(@PageID as varchar(5))
				end
		
				exec(@sql)
		
			        if (@@error <> 0)
				begin
				   select @deleted_page_record = 0
			           goto ENDPROC
				end
				else
				begin
				   select @deleted_page_record = @deleted_page_record + 1
				end
		
			   FETCH NEXT FROM remove_page_cursor
			   INTO @tableName
			END
			
			CLOSE remove_page_cursor
			DEALLOCATE remove_page_cursor
		
			-- clean up the domain mapping table so that a domain that MAY be pointing to this page doesn't fail
			-- IS person will need to go into this table and update the entry with a new page id
			update tblDomainMapping_U set PageID = 1 where PageID = @PageID

			COMMIT TRANSACTION
		
			PRINT 'The page was removed successfully.'
		
			RETURN 1
		
			ENDPROC:
				begin
				        if (@@trancount > 0)
			        	begin 
				   		print 'The script to remove a page failed. The content will be rolled back to the original state.'
			           		ROLLBACK TRANSACTION
			            	end

					if (@deleted_page_record > -1)
					begin
				            	close remove_page_cursor
				            	deallocate remove_page_cursor
					end
					if (@deleted_page_modules > -1)
					begin
						close remove_page_module_cursor
						deallocate remove_page_module_cursor
					end
			        END

		end
		else
		begin
			print 'It was verified that there is content for this page that is part of another deployment job process. You must deploy this content first before deleting anything in order to maintain data integrity.'
			return 0
		end

	end
	else
	begin
		print 'The page does not exist in the CMS table'
		return 0
	end
	end

end