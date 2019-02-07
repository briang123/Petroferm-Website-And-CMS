










CREATE  proc sp__DeleteBusinessUnit
	@BusUnitID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Brian Gaines
created on: 11/26/2006
purpose:
	delete the business unit, but first check to see if we have a record for this business unit on the LIVE tables
	
script usage syntax:
	exec sp__DeleteBusinessUnit
		@BusUnitID = 3,
		@UserID = 1,
		@JobID = 1,
		@WorkflowStatus = 'WORKING'
history:
	Brian Gaines (11/27/2006) - Created initial stored procedure
	Brian Gaines (11/28/2006) - Updated to remove the @purge, @publishdate, @expiredate parameters and adjusted affected sql
	Kelly Roe    (12/15/2006) - don't delete the image if it's being used by another bu
	Kelly Roe    (12/28/2006) - added SIDE CONTENT to check of tblContentModule
	Brian Gaines (1/4/2007) - updated product blurb
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
	else if (@BusUnitID is null or @BusUnitID = 0)
	begin
		print 'A business unit is required.'
		return 0
	end
	else 
	begin
	


	if exists(select 1 from tblBusinessUnit where BusinessUnitId = @BusUnitID)
	begin	
	
		declare @mark_for_deletion bit
	
		if (dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0)
		begin
			if exists(select 1 from tblBusinessUnit_LIVE where BusinessUnitID = @BusUnitID)
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

		-- check to see if the logo is being used elsewhere (will be used further down)
		declare @logo_in_use int	

		select @logo_in_use = count(*) from tblBusinessUnit b 
		where b.LogoImageID in (select LogoImageID from tblBusinessUnit where BusinessUnitId = @BusUnitID)
		and b.BusinessUnitId <> @BusUnitID

	
		DECLARE @tableName sysname,
			@sql varchar(1000),
			@part_of_other_job int
	
		select @part_of_other_job = 0
	
		if (@part_of_other_job = 0)
		begin
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblDocumentModuleReln d
			where p.PageId = r.PageId and r.SourceId = d.DocumentModuleRelnId
			and upper(r.SourceName) = 'DOCUMENT' and p.BusinessUnitId = @BusUnitID
			and upper(d.WorkflowStatus) <> 'LIVE' and d.DeploymentJobId <> @JobID
			
		end
/*	
		if (@part_of_other_job = 0)
		begin
	
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m, tblQuestions q
			where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
			and m.QuestionnaireModuleId = q.QuestionnaireModuleId
			and r.SourceName = 'QUESTIONNAIRE' and p.BusinessUnitId = @BusUnitID
			and upper(q.WorkflowStatus) <> 'LIVE' and q.DeploymentJobId <> @JobID
			
		end

		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m
			where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
			and r.SourceName = 'QUESTIONNAIRE' and p.BusinessUnitId = @BusUnitID
			and upper(m.WorkflowStatus) <> 'LIVE' and m.DeploymentJobId <> @JobID
	
		end
*/	
		if (@part_of_other_job = 0)
		begin

			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblContentModule c
			where p.PageId = r.PageId and r.SourceId = c.ContentId
			and upper(r.SourceName) IN ('CONTENT','SIDE CONTENT') and p.BusinessUnitId = @BusUnitID
			and upper(c.WorkflowStatus) <> 'LIVE' and c.DeploymentJobId <> @JobID
	
		end

		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
			where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
			and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.BusinessUnitId = @BusUnitID
			and upper(h.WorkflowStatus) <> 'LIVE' and h.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin

			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
			and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
			and p.BusinessUnitId = @BusUnitID
			and upper(i.WorkflowStatus) <> 'LIVE' and i.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblBusinessUnit b, tblImage i
			where b.LogoImageID = i.ImageId
			and b.BusinessUnitId = @BusUnitID
			and upper(i.WorkflowStatus) <> 'LIVE' and i.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
 
			select @part_of_other_job = count(*)
			from tblPage p, tblPageModuleReln r, tblImageModule im
			where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
			and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
			and p.BusinessUnitId = @BusUnitID
			and upper(im.WorkflowStatus) <> 'LIVE' and im.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProductGrid pg, tblProductGridModule pgm
			where pg.ProductGridId = pgm.ProductGridId and pg.BusinessUnitId = @BusUnitID
			and upper(pgm.WorkflowStatus) <> 'LIVE' and pgm.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProductGrid pg, tblProductGridRowDef pgr
			where pg.ProductGridId = pgr.ProductGridId and pg.BusinessUnitId = @BusUnitID
			and upper(pgr.WorkflowStatus) <> 'LIVE' and pgr.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProductGrid pg, tblProductGridColDef pgc
			where pg.ProductGridId = pgc.ProductGridId and pg.BusinessUnitId = @BusUnitID
			and upper(pgc.WorkflowStatus) <> 'LIVE' and pgc.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
	
			select @part_of_other_job = count(*)
			from tblProductBlurbModule pbm, tblPageModuleReln r, tblPage p
			where p.BusinessUnitID = @BusUnitID and p.PageId = r.PageId 
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
			where p.BusinessUnitID = @BusUnitID and p.PageId = r.PageId 
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
			from tblProduct p, tblProductSearchAttribReln sr
			where p.ProductId = sr.ProductId and p.BusinessUnitId = @BusUnitID
			and upper(sr.WorkflowStatus) <> 'LIVE' and sr.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
			
			select @part_of_other_job = count(*)
			from tblProduct p, tblProductAttributeReln ar
			where p.ProductId = ar.ProductId and p.BusinessUnitId = @BusUnitID
			and upper(ar.WorkflowStatus) <> 'LIVE' and ar.DeploymentJobId <> @JobID
	
		end
	
		if (@part_of_other_job = 0)
		begin
	
			create table #table_row_count (table_count int)
	
			DECLARE remove_bus_cursor_validate CURSOR FOR
		
			-- we only want our CMS content tables with deployment capabilities to be iterated through
			SELECT 	TableName
			from 	tblPetrofermTableDefs_U
			where 	BusinessUnitTable = 1
		
			OPEN remove_bus_cursor_validate
		
			FETCH NEXT FROM remove_bus_cursor_validate
			INTO @tableName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
				select @sql = ''
				select @sql = ' insert into #table_row_count '
				select @sql = @sql + ' select count(*) from ' + @tableName 
				select @sql = @sql + ' where BusinessUnitId = ' + cast(@BusUnitID as varchar(5)) 
				select @sql = @sql + ' and upper(WorkflowStatus) <> ''LIVE'' and DeploymentJobId <> ' + cast(@JobID as varchar(5))
				print @sql
				print ''
				exec(@sql)
	
			   FETCH NEXT FROM remove_bus_cursor_validate
			   INTO @tableName
			END
			
			CLOSE remove_bus_cursor_validate
			DEALLOCATE remove_bus_cursor_validate
		
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
				and upper(r.SourceName) = 'DOCUMENT' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
/*				
				update tblQuestions
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m, tblQuestions q
				where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
				and m.QuestionnaireModuleId = q.QuestionnaireModuleId
				and r.SourceName = 'QUESTIONNAIRE' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				update tblQuestionnaireModule
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m
				where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
				and r.SourceName = 'QUESTIONNAIRE' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
*/

				update tblContentModule
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblPage p, tblPageModuleReln r, tblContentModule c
				where p.PageId = r.PageId and r.SourceId = c.ContentId
				and upper(r.SourceName) IN ('CONTENT','SIDE CONTENT') and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				update tblHeaderSideContentModule
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
				where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
				and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				update tblImage
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
				where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
				and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE')
				and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				if (@logo_in_use = 0)
				begin
					update tblImage 
					set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
					from tblBusinessUnit b, tblImage i
					where b.LogoImageID = i.ImageId
					and b.BusinessUnitId = @BusUnitID
				end
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				update tblImageModule
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblPage p, tblPageModuleReln r, tblImageModule im
				where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
				and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE')
				and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				update tblProductGridModule 
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProductGrid pg, tblProductGridModule pgm
				where pg.ProductGridId = pgm.ProductGridId and pg.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				update tblProductGridRowDef 
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProductGrid pg, tblProductGridRowDef pgr
				where pg.ProductGridId = pgr.ProductGridId and pg.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				update tblProductGridColDef 
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProductGrid pg, tblProductGridColDef pgc
				where pg.ProductGridId = pgc.ProductGridId and pg.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				update tblProductBlurbModule
				set LastModifiedBy = @UserId, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProductBlurbModule pbm, tblPageModuleReln r, tblPage p
				where p.BusinessUnitID = @BusUnitID and p.PageId = r.PageId 
				and r.SourceId = pbm.ProductBlurbModuleId
				and UPPER(pbm.ProductSelection) = 'INDIVIDUAL'
				and UPPER(r.SourceName) = 'PRODUCT BLURB'
	
			        IF @@ERROR <> 0
			           GOTO ENDPROC
	
				update tblProductBlurbModuleReln
				set LastModifiedBy = @UserId, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblPageModuleReln r, tblPage p
				where p.BusinessUnitID = @BusUnitID and p.PageId = r.PageId 
				and r.SourceId = pbm.ProductBlurbModuleId
				and pbm.SourceId = pbmr.ProductBlurbModuleId
				and UPPER(pbm.ProductSelection) = 'MULTIPLE'
				and UPPER(r.SourceName) = 'PRODUCT BLURB'
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
	
				update tblProductSearchAttribReln 
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProduct p, tblProductSearchAttribReln sr
				where p.ProductId = sr.ProductId and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				update tblProductAttributeReln 
				set LastModifiedBy = @UserID, MarkedForDeletion = 1, WorkflowStatus = 'WORKING', DeploymentJobId = @JobID, LastModifiedDate = getdate()
				from tblProduct p, tblProductAttributeReln ar
				where p.ProductId = ar.ProductId and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
			end
			else if (@mark_for_deletion = 0)
			begin
		
				delete tblDocumentModuleReln
				from tblPage p, tblPageModuleReln r, tblDocumentModuleReln d
				where p.PageId = r.PageId and r.SourceId = d.DocumentModuleRelnId
				and upper(r.SourceName) = 'DOCUMENT' and p.BusinessUnitId = @BusUnitID
				
			        IF @@ERROR <> 0
			           GOTO ENDPROC
/*		
				delete tblQuestions
				from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m, tblQuestions q
				where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
				and m.QuestionnaireModuleId = q.QuestionnaireModuleId
				and r.SourceName = 'QUESTIONNAIRE' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				delete tblQuestionnaireModule
				from tblPage p, tblPageModuleReln r, tblQuestionnaireModule m
				where p.PageId = r.PageId and r.SourceId = m.QuestionnaireModuleId 
				and r.SourceName = 'QUESTIONNAIRE' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
*/
				delete tblContentModule
				from tblPage p, tblPageModuleReln r, tblContentModule c
				where p.PageId = r.PageId and r.SourceId = c.ContentId
				and upper(r.SourceName) IN ('CONTENT','SIDE CONTENT') and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				delete tblHeaderSideContentModule
				from tblPage p, tblPageModuleReln r, tblHeaderSideContentModule h
				where p.PageId = r.PageId and r.SourceId = h.HeaderSideContentModuleId
				and upper(r.SourceName) = 'HEADER SIDE CONTENT' and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				delete tblImage
				from tblPage p, tblPageModuleReln r, tblImageModule im, tblImage i
				where p.PageId = r.PageId and r.SourceId = im.ImageModuleId and im.ImageId = i.ImageId
				and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE')
				and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				-- don't delete the image if it's being used by another bu
				if (@logo_in_use = 0)
				begin
					delete tblImage
					from tblBusinessUnit b, tblImage i
					where b.LogoImageID = i.ImageId
					and b.BusinessUnitId = @BusUnitID
				end
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				delete tblImageModule
				from tblPage p, tblPageModuleReln r, tblImageModule im
				where p.PageId = r.PageId and r.SourceId = im.ImageModuleId
				and upper(r.SourceName) IN ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE') 
				and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				delete tblProductGridModule
				from tblProductGrid pg, tblProductGridModule pgm
				where pg.ProductGridId = pgm.ProductGridId and pg.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				delete tblProductGridRowDef
				from tblProductGrid pg, tblProductGridRowDef pgr
				where pg.ProductGridId = pgr.ProductGridId and pg.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				delete tblProductGridColDef
				from tblProductGrid pg, tblProductGridColDef pgc
				where pg.ProductGridId = pgc.ProductGridId and pg.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				delete from tblProductBlurbModule
				from tblProductBlurbModule pbm, tblPageModuleReln r, tblPage p
				where p.BusinessUnitID = @BusUnitID and p.PageId = r.PageId 
				and r.SourceId = pbm.ProductBlurbModuleId
				and UPPER(pbm.ProductSelection) = 'INDIVIDUAL'
				and UPPER(r.SourceName) = 'PRODUCT BLURB'
	
			        IF @@ERROR <> 0
			           GOTO ENDPROC
	
				delete from tblProductBlurbModuleReln
				from tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblPageModuleReln r, tblPage p
				where p.BusinessUnitID = @BusUnitID and p.PageId = r.PageId 
				and r.SourceId = pbm.ProductBlurbModuleId
				and pbm.SourceId = pbmr.ProductBlurbModuleId
				and UPPER(pbm.ProductSelection) = 'MULTIPLE'
				and UPPER(r.SourceName) = 'PRODUCT BLURB'
	
			        IF @@ERROR <> 0
			           GOTO ENDPROC

				delete tblProductSearchAttribReln
				from tblProduct p, tblProductSearchAttribReln sr
				where p.ProductId = sr.ProductId and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
				
				delete tblProductAttributeReln
				from tblProduct p, tblProductAttributeReln ar
				where p.ProductId = ar.ProductId and p.BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
			
				delete from tblBusinessAppUser where BusinessUnitId = @BusUnitID
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
			end
			
			DECLARE remove_bus_cursor CURSOR FOR
		
			-- we only want our CMS content tables with deployment capabilities to be iterated through
			SELECT 	TableName
			from 	tblPetrofermTableDefs_U
			where 	BusinessUnitTable = 1
		
			OPEN remove_bus_cursor
		
			FETCH NEXT FROM remove_bus_cursor
			INTO @tableName
			
			WHILE @@FETCH_STATUS = 0
			BEGIN
		
				if (@mark_for_deletion = 0)
				begin
					select @sql = 'delete from ' + @tableName + ' where BusinessUnitId = ' + cast(@BusUnitID as varchar(5))
				end
				else if (@mark_for_deletion = 1)
				begin
					select @sql = 'update ' + @tableName + ' set LastModifiedBy = ' + cast(@UserID as varchar(5))
					select @sql = @sql + ', MarkedForDeletion = 1, WorkflowStatus = ''WORKING'', '
					select @sql = @sql + 'DeploymentJobId = ' + cast(@JobID as varchar(5)) + ' where BusinessUnitId = ' + cast(@BusUnitID as varchar(5))
				end
		
				exec(@sql)
		
			        IF @@ERROR <> 0
			           GOTO ENDPROC
		
			   FETCH NEXT FROM remove_bus_cursor
			   INTO @tableName
			END
			
			CLOSE remove_bus_cursor
			DEALLOCATE remove_bus_cursor
		
			COMMIT TRANSACTION
		
			PRINT 'The business was removed successfully.'
		
			RETURN 1
		
			ENDPROC:
				BEGIN
			        IF @@TRANCOUNT > 0
			        	BEGIN 
				   		PRINT 'The script to remove a business unit failed. The content will be rolled back to the original state.'
			           		ROLLBACK TRANSACTION
			            	END
			            	CLOSE remove_bus_cursor
			            	DEALLOCATE remove_bus_cursor
			        END
		
		end
		else
		begin
			print 'It was verified that there is content for this business unit that is part of another deployment job process. You must deploy this content first before deleting anything in order to maintain data integrity.'
			return 0
		end

	end
	else
	begin
		print 'The business unit does not exist in the CMS table'
		return 0
	end
	end

end