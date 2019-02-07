








--sp__UpdateImageModule 46, 30, 'NAVIGATION ON',1,NULL,NULL,NULL,NULL,57,'NAV ON IMAGE',1,0,NULL,NULL,0,'WORKING',14,2
CREATE	proc sp__UpdateImageModule
		@ImageModuleID int = null,
		@ImageID int = 0, -- may be adding image rec, will get this later
		@ImageType varchar(25) = null,
		@ImageOrder int = null,
		@ImagePath varchar(500) = null,
		@Alt varchar(200) = null,
		@Height int = 1,
		@Width int = 1,
		@PageID int = null,
		@ModuleType varchar(50) = null,
		@ModuleOrder int = null,
		@ShowTitle bit = 0,
		@SavePetrofermHomePageInfo bit = 0, -- used to determine whether to save welcome stuff
		@RelatedImageModuleID int = null,
		@WelcomeImageID int = null, -- may be adding image rec, will get this later
		@WelcomeImagePath varchar(500) = null,
		@WelcomeTitle varchar(50) = null,
		@WelcomeLinkPageID int = null,
		@WelcomeLinkPageIDList varchar(25) = null,
		@WelcomeLinkTextList varchar(200) = null,
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = null,
		@UserID int = null

as
begin
	declare @errorcode int
	
/*
created by: Kelly Roe
created on: 12/11/2006
purpose:
	Updates an image module for a page (along with page module reln info)
	
history:
	Kelly Roe	(12/11/2006) - created initial procedure
	Kelly Roe	(12/24/2006) - added imageid to update of image module
	Kelly Roe       (12/31/2006) - added stuff to manage Petroferm home page (task #56)
	Kelly Roe	(01/06/2007) - added @RelatedImageModuleID
*/

	if (dbo.fn__TableExists('tblImageModule') > 0)
	begin
	
		if (@ImageModuleID is null or @ImageModuleID = 0)
		begin
			print 'A module id is required'
			return 0
		end
		else if (@ModuleType is null or len(ltrim(rtrim(@ModuleType))) = 0)
		begin
			print 'An module type is required'
			return 0
		end
		else if (@UserID is null or @UserID = 0)
		begin
			print 'A user id is required'
			return 0
		end
		else if (@JobID is null or @JobId = 0)
		begin
			print 'a job id is required'
			return 0
		end
		else
		begin 


			if (@PublishDate is null)
			begin
				select @PublishDate = dbo.fn__GetDateOnly(getdate())
			end
			else
			begin
				select @Publishdate = dbo.fn__GetDateOnly(@PublishDate)
			end
			
			if (@ExpireDate is null)
			begin
				select @ExpireDate = dbo.fn__GetDateOnly(dateadd(year,30,@PublishDate))
			end
			else
			begin
				select @ExpireDate = dbo.fn__GetDateOnly(@ExpireDate)
			end
			
			begin tran
			
				
				-- may need to add a new img record if uploading a new file
				if (@ImageID = 0)
				begin
					insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
					values (@ImagePath, @Alt, @Height, @Width, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
					
					select @ImageID = @@identity
					select @errorcode = @@error

				end		


				-- may need to save an image record for the petroferm welcome image			
				if (@SavePetrofermHomePageInfo = 1)
				begin
					if (@WelcomeImageID is null)
					begin
						insert into tblImage (ImagePath, Alt, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
						values (@WelcomeImagePath, @Alt, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
						
						select @WelcomeImageID = @@identity
						select @errorcode = @@error
					end 
	
				end		

				
				-- update the image module record
				update 	tblImageModule
				set	ImageID = @ImageID,
					ImageType = @ImageType,
					ImageOrder = @ImageOrder,
					RelatedImageModuleID = @RelatedImageModuleID,
					WelcomeImageID = @WelcomeImageID,
					WelcomeTitle = @WelcomeTitle,
					WelcomeLinkPageID = @WelcomeLinkPageID,
					WelcomeLinkPageIDList = @WelcomeLinkPageIDList,
					WelcomeLinkTextList = @WelcomeLinkTextList,
					PublishDate = @PublishDate,
					ExpirationDate = @ExpireDate,
					DeploymentJobID = @JobID,
					WorkflowStatus = @WorkflowStatus,
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID
				where	ImageModuleID = @ImageModuleID				

				select @errorcode = @@error

				if (@errorcode = 0)
				begin
					
					
					-- now update page module reln
					update 	tblPageModuleReln
					set	SourceName = @ModuleType,
						ModuleOrder = @ModuleOrder,
						ShowTitle = @ShowTitle,
						PublishDate = @PublishDate,
						ExpirationDate = @ExpireDate,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobID = @JobID,
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where	SourceName = @ModuleType
					and	SourceID = @ImageModuleID
					
					select @errorcode = @@error


					-- now update the job to working
					if (@errorcode = 0)
					begin
						exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
						select @errorcode = @@error
					end					


					if (@errorcode = 0)
					begin
				
						commit tran
						print 'The module was updated'
						return 1
					end
					else
					begin
						rollback tran
						print 'An error occurred while attempting to update the module'
						return 0
					end
				end
				else
				begin
					select @ImageModuleID = 0
					return 0
				end
		end
	
	end
	else
	begin
		print 'Table is missing'
		return 0
	end

end