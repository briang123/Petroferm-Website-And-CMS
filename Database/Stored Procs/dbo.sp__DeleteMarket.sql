

CREATE        proc sp__DeleteMarket
	@MarketID int = null,
	@UserID int = null,
	@JobId int = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@MarkedForDeletion bit = 1
as
begin

/*
created by: Brian Gaines
created on: 11/28/2006
purpose:
	Deletes a market and all related content. This procedure also enables for the market to be un-marked for deletion
	by toggling the @MarkForDeletion parameter value between 0/1.

parameters:
	@MarketID - The market Id to delete
	@UserID - The current user id deleting the market
	@JobId - The deployment job id this deletion process will be part of
	@WorkflowStatus - The workflow status of the record

script usage syntax:
	exec sp__DeleteBusinessUnit
		@MarketID = 3,
		@UserID = 1,
		@JobID = 1,
		@WorkflowStatus = 'WORKING',
		@MarkedForDeletion = 1

history:
	Brian Gaines (11/28/2006) - Created initial stored procedure
	Kelly Roe    (12/06/2006) - Fixed @part_of_other_job logic -- need to add page to get to the related market
	Kelly Roe    (12/28/2006) - added SIDE CONTENT to check of tblContentModule
	Brian Gaines (1/4/2007) - added product blurb sql and updated page module reln sourceName values
*/

declare @mark_for_deletion bit

if (dbo.fn__TableExists('tblMarket_LIVE') > 0)
begin
	if exists(select 1 from tblMarket_LIVE where MarketID = @MarketID)
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
else if (@MarketID is null or @MarketID = 0)
begin
	print 'A market is required.'
	return 0
end
else 
begin

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
		and upper(r.SourceName) = 'DOCUMENT' and p.MarketID = @MarketID
		and upper(d.WorkflowStatus) <> 'LIVE' and d.DeploymentJobId <> @JobId
		
	end
/*
	if (@part_of_other_job = 0)
	begin

		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m, tblQuestions q
		where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
		and m.QuestionnaireModuleId = q.QuestionnaireModuleId
		and r.SourceName = 'QUESTIONNAIRE' and p.MarketID = @MarketID
		and upper(q.WorkflowStatus) <> 'LIVE' and q.DeploymentJobId <> @JobId
		
	end

	if (@part_of_other_job = 0)
	begin
		
		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m
		where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
		and r.SourceName = 'QUESTIONNAIRE' and p.MarketID = @MarketID
		and upper(m.WorkflowStatus) <> 'LIVE' and m.DeploymentJobId <> @JobId

	end
*/
	if (@part_of_other_job = 0)
	begin
		
		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblContentModule c
		where p.PageId = r.PageId and r.SourceId = c.ContentId
		and upper(r.SourceName) in ('CONTENT','SIDE CONTENT') and p.MarketID = @MarketID
		and upper(c.WorkflowStatus) <> 'LIVE' and c.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin
		
		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
		where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
		and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.MarketID = @MarketID
		and upper(h.WorkflowStatus) <> 'LIVE' and h.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin
		
		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
		where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
		and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
		and p.MarketID = @MarketID and upper(i.WorkflowStatus) <> 'LIVE' and i.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin
		
		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblImageModule im
		where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
		and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
		and p.MarketID = @MarketID and upper(im.WorkflowStatus) <> 'LIVE' and im.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin

		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblProductGrid pg, tblProductGridModule pgm
		where p.MarketID = @MarketID
		and p.PageId = r.PageId and r.SourceId = pgm.ProductGridModuleID
		and pg.ProductGridId = pgm.ProductGridId 
		and upper(r.SourceName) = 'PRODUCT GRID'
		and upper(pgm.WorkflowStatus) <> 'LIVE' and pgm.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin

		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblProductGridModule pgm, tblProductGrid pg, tblProductGridRowDef pgr 
		where p.MarketID = @MarketID and p.PageId = r.PageId and r.SourceId = pgm.ProductGridModuleID
		and pg.ProductGridId = pgm.ProductGridId and pg.ProductGridId = pgr.ProductGridId 	
		and upper(r.SourceName) = 'PRODUCT GRID'
		and upper(pgr.WorkflowStatus) <> 'LIVE' 
		and pgr.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin

		select @part_of_other_job = count(*)
		from tblPage p, tblPageModuleReln r, tblProductGridModule pgm, tblProductGrid pg, tblProductGridColDef pgc
		where p.MarketID = @MarketID and p.PageId = r.PageId and r.SourceId = pgm.ProductGridModuleID 
		and pg.ProductGridId = pgm.ProductGridId and pg.ProductGridId = pgc.ProductGridId 
		and upper(r.SourceName) = 'PRODUCT GRID'
		and upper(pgc.WorkflowStatus) <> 'LIVE' 
		and pgc.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin
		select @part_of_other_job = count(*)
		from tblProductBlurbModule pbm, tblPageModuleReln r, tblPage p
		where p.MarketID = @MarketID and p.PageId = r.PageId 
		and r.SourceId = pbm.ProductBlurbModuleId
		and UPPER(pbm.ProductSelection) = 'INDIVIDUAL'
		and UPPER(r.SourceName) = 'PRODUCT BLURB'
		and UPPER(pbm.WorkflowStatus) <> 'LIVE'
		and pbm.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin

		select @part_of_other_job = count(*)
		from tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblPageModuleReln r, tblPage p
		where p.MarketId = @MarketId and p.PageId = r.PageId 
		and r.SourceId = pbm.ProductBlurbModuleId
		and pbm.SourceId = pbmr.ProductBlurbModuleId
		and UPPER(pbm.ProductSelection) = 'MULTIPLE'
		and UPPER(r.SourceName) = 'PRODUCT BLURB'
		and UPPER(pbmr.WorkflowStatus) <> 'LIVE' 
		and pbmr.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin

		select @part_of_other_job = count(*)
		from tblProductSearchAttribReln sr, tblSearchAttribType sa
		where sa.MarketID = @MarketID and sr.SearchAttribTypeID = sa.SearchAttribTypeID
		and upper(sr.WorkflowStatus) <> 'LIVE' and sr.DeploymentJobId <> @JobId

	end

	if (@part_of_other_job = 0)
	begin

		create table #table_row_count (table_count int)

		DECLARE remove_mkt_cursor_validate CURSOR FOR
	
		-- we only want our CMS content tables with deployment capabilities to be iterated through
		SELECT 	TableName
		from 	tblPetrofermTableDefs_U
		where 	MarketTable = 1
	
		OPEN remove_mkt_cursor_validate
	
		FETCH NEXT FROM remove_mkt_cursor_validate
		INTO @tableName
		
		WHILE @@FETCH_STATUS = 0
		BEGIN

			select @sql = ''
			select @sql = ' insert into #table_row_count '
			select @sql = @sql + ' select count(*) from ' + @tableName 
			select @sql = @sql + ' where MarketId = ' + cast(@MarketID as varchar(5)) 
			select @sql = @sql + ' and upper(WorkflowStatus) <> ''LIVE'' and DeploymentJobId <> ' + cast(@JobId as varchar(5))
			print @sql
			print ''
			exec(@sql)

		   FETCH NEXT FROM remove_mkt_cursor_validate
		   INTO @tableName
		END
		
		CLOSE remove_mkt_cursor_validate
		DEALLOCATE remove_mkt_cursor_validate

		select @part_of_other_job = sum(table_count) from #table_row_count
		drop table #table_row_count
	
	END

	if (@part_of_other_job = 0)
	begin

		if (@mark_for_deletion = 1)
		begin
		
			update tblDocumentModuleReln 
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblDocumentModuleReln d
			where p.PageId = r.PageId and r.SourceId = d.DocumentModuleRelnId
			and upper(r.SourceName) = 'DOCUMENT' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
/*			
			update tblQuestions
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m, tblQuestions q
			where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
			and m.QuestionnaireModuleId = q.QuestionnaireModuleId
			and r.SourceName = 'QUESTIONNAIRE' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			update tblQuestionnaireModule
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m
			where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
			and r.SourceName = 'QUESTIONNAIRE' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
*/					
			update tblContentModule
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblContentModule c
			where p.PageId = r.PageId and r.SourceId = c.ContentId
			and upper(r.SourceName) IN ('CONTENT','SIDE CONTENT') and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			update tblHeaderSideContentModule
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
			where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
			and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			update tblImage
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
			and upper(r.SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
			and p.MarketID = @MarketID
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			update tblImageModule
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblImageModule im
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
			and upper(r.SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
			and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			update tblProductGridModule 
			set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblPage p, tblPageModuleReln r, tblProductGridModule pgm
			where p.PageId = r.PageId and r.SourceId = pgm.ProductGridModuleId
			and upper(r.SourceName) = 'PRODUCT GRID' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC

			update tblProductBlurbModule
			set LastModifiedBy = @UserId, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblProductBlurbModule pbm, tblPageModuleReln r, tblPage p
			where p.MarketID = @MarketID and p.PageId = r.PageId 
			and r.SourceId = pbm.ProductBlurbModuleId
			and UPPER(pbm.ProductSelection) = 'INDIVIDUAL'
			and UPPER(r.SourceName) = 'PRODUCT BLURB'

		        IF @@ERROR <> 0
		           GOTO ENDPROC

			update tblProductBlurbModuleReln
			set LastModifiedBy = @UserId, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
			from tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblPageModuleReln r, tblPage p
			where p.MarketId = @MarketId and p.PageId = r.PageId 
			and r.SourceId = pbm.ProductBlurbModuleId
			and pbm.SourceId = pbmr.ProductBlurbModuleId
			and UPPER(pbm.ProductSelection) = 'MULTIPLE'
			and UPPER(r.SourceName) = 'PRODUCT BLURB'
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC

		end
		else if (@mark_for_deletion = 0)
		begin
	
			delete from tblDocumentModuleReln 
			from tblPage p, tblPageModuleReln r, tblDocumentModuleReln d
			where p.PageId = r.PageId and r.SourceId = d.DocumentModuleRelnId
			and upper(r.SourceName) = 'DOCUMENT' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
/*			
			delete from tblQuestions
			from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m, tblQuestions q
			where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
			and m.QuestionnaireModuleId = q.QuestionnaireModuleId
			and r.SourceName = 'QUESTIONNAIRE' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			delete from tblQuestionnaireModule
			from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m
			where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
			and r.SourceName = 'QUESTIONNAIRE' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
*/					
			delete from tblContentModule
			from tblPage p, tblPageModuleReln r, tblContentModule c
			where p.PageId = r.PageId and r.SourceId = c.ContentId
			and upper(r.SourceName) in ('CONTENT','SIDE CONTENT') and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			delete from tblHeaderSideContentModule
			from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
			where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
			and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			delete from tblImage
			from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
			and upper(r.SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
			and p.MarketID = @MarketID
		
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			delete from tblImageModule
			from tblPage p, tblPageModuleReln r, tblImageModule im
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
			and upper(r.SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
			
			delete from tblProductGridModule 
			from tblPage p, tblPageModuleReln r, tblProductGridModule pgm
			where p.PageId = r.PageId and r.SourceId = pgm.ProductGridModuleId
			and upper(r.SourceName) = 'PRODUCT GRID' and p.MarketID = @MarketID
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
	
			delete from tblProductBlurbModule
			from tblProductBlurbModule pbm, tblPageModuleReln r, tblPage p
			where p.MarketID = @MarketID and p.PageId = r.PageId 
			and r.SourceId = pbm.ProductBlurbModuleId
			and UPPER(pbm.ProductSelection) = 'INDIVIDUAL'
			and UPPER(r.SourceName) = 'PRODUCT BLURB'

		        IF @@ERROR <> 0
		           GOTO ENDPROC

			delete from tblProductBlurbModuleReln
			from tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblPageModuleReln r, tblPage p
			where p.MarketId = @MarketId and p.PageId = r.PageId 
			and r.SourceId = pbm.ProductBlurbModuleId
			and pbm.SourceId = pbmr.ProductBlurbModuleId
			and UPPER(pbm.ProductSelection) = 'MULTIPLE'
			and UPPER(r.SourceName) = 'PRODUCT BLURB'

		        IF @@ERROR <> 0
		           GOTO ENDPROC

		end
		
		DECLARE remove_mkt_cursor CURSOR FOR

		-- we only want our CMS content tables with deployment capabilities to be iterated through
		SELECT 	TableName
		from 	tblPetrofermTableDefs_U
		where 	MarketTable = 1
	
		OPEN remove_mkt_cursor
	
		FETCH NEXT FROM remove_mkt_cursor
		INTO @tableName
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			if (@mark_for_deletion = 0)
			begin
				select @sql = 'delete from ' + @tableName + ' where MarketId = ' + cast(@MarketID as varchar(5))
			end
			else 
			begin
				select @sql = 'update ' + @tableName + ' set LastModifiedBy = ' + cast(@UserID as varchar(5))
				select @sql = @sql + ', MarkedForDeletion = ' + cast(@MarkedForDeletion as char(1)) + ', WorkflowStatus = ''' + @WorkflowStatus + ''', '
				select @sql = @sql + 'DeploymentJobId = ' + cast(@JobId as varchar(5)) + ' where MarketID = ' + cast(@MarketID as varchar(5))
			end
	
			exec(@sql)
	
		        IF @@ERROR <> 0
		           GOTO ENDPROC
	
		   FETCH NEXT FROM remove_mkt_cursor
		   INTO @tableName
		END
		
		CLOSE remove_mkt_cursor
		DEALLOCATE remove_mkt_cursor
	
		COMMIT TRANSACTION
	
		PRINT 'The market was removed successfully.'
	
		RETURN 1
	
		ENDPROC:
			BEGIN
		        IF @@TRANCOUNT > 0
		        	BEGIN 
			   		PRINT 'The script to remove a market unit failed. The content will be rolled back to the original state.'
		           		ROLLBACK TRANSACTION
		            	END

		            	CLOSE remove_mkt_cursor
		            	DEALLOCATE remove_mkt_cursor
		        END

	end
	else
	begin
	        IF (@@trancount > 0)
        	BEGIN 
			print 'There is content for this market that is part of another deployment job process. You must deploy this content first before deleting anything in order to maintain data integrity.'
           		ROLLBACK TRANSACTION

			if (@part_of_other_job = 0)
			begin

				CLOSE remove_mkt_cursor_validate
				DEALLOCATE remove_mkt_cursor_validate
			end
            	END

		return 0
	end
end

end