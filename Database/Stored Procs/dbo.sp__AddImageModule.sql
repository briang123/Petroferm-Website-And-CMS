





CREATE    proc sp__AddImageModule
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
		@UserID int = null,
		@ImageModuleID int OUTPUT,
		@PageModuleRelnID int OUTPUT
as
begin
declare @errorcode int

/*
created by: Kelly Roe
created on: 12/11/2006
purpose:
Adds a new image module for a page

history:
Kelly Roe    (12/11/2006) - created initial procedure
Kelly Roe    (12/31/2006) - added stuff to manage Petroferm home page (task #56)
Kelly Roe    (01/06/2007) - added RelatedImageModuleID column/parm
*/

if (dbo.fn__TableExists('tblImageModule') > 0)
begin

	if (@PageID is null or @PageID = 0)
	begin
		print 'A page id is required'
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
		
			-- if imageid = 0 then insert image record first
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

			-- insert the module record
			if (@errorcode = 0)
			begin
				insert into tblImageModule (ImageID, ImageType, ImageOrder, RelatedImageModuleID, WelcomeImageID,
					WelcomeTitle, WelcomeLinkPageID, WelcomeLinkPageIDList, WelcomeLinkTextList,
					PublishDate, ExpirationDate, WorkflowStatus, 
					LastModifiedDate, LastModifiedBy, ActiveFlag, 
					MarkedForDeletion, DeploymentJobId)
				values (@ImageID, @ImageType, @ImageOrder, @RelatedImageModuleID, @WelcomeImageID,  
					@WelcomeTitle, @WelcomeLinkPageID, @WelcomeLinkPageIDList, @WelcomeLinkTextList,
					@PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 
					1, @MarkedForDeletion, @JobID)
				select @ImageModuleID = @@identity
				select @errorcode = @@error
			end
	
			if (@errorcode = 0)
			begin
			
				-- now add page module reln
				insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@PageID, @ImageModuleID, @ModuleType, @ModuleOrder, @ShowTitle, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
				
				select @errorcode = @@error
			end
			
			-- now update the job to working
			if (@errorcode = 0)
			begin
			
				select @PageModuleRelnID = @@identity
				
				exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
				select @errorcode = @@error
			end
		end
	
		if (@errorcode = 0)
		begin
		
			commit tran
			print 'The image module was added'
			return 1
		end
		else
		begin
		
			rollback tran
			print 'An error occurred while attempting to add the image module'
			return 0
		end
	end
	else
	begin
		print 'The table is missing'
		return 0
	end
end