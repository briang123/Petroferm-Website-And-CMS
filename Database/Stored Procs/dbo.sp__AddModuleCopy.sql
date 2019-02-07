




CREATE  proc sp__AddModuleCopy
		@PageID int = null,
		@ModuleID int = null, -- the pk of the specific module table, not pgmodreln
		@ModuleType varchar(50) = null,
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = null,
		@UserID int = null,
		@PageModuleRelnID int OUTPUT
as
begin
	declare @errorcode int
	declare @NewModuleID int
	
/*
created by: Kelly Roe
created on: 01/11/2007
purpose:
	Copies an existing module -- one of the following types which are allowed to be copied:
	 - CONTENT/SIDE CONTENT
	 - HEADER SIDE CONTENT
	 - PRODUCT BLURB
	
history:
	Kelly Roe	(01/11/2007) - created initial procedure
*/


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
		

			if (upper(@ModuleType) = 'CONTENT' or upper(@ModuleType) = 'SIDE CONTENT')
			begin
				-- add a new content/side content based on the existing one				
				insert into tblContentModule (Title, Content, PublishDate, 
					ExpirationDate, WorkflowStatus, LastModifiedDate, 
					LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
					 select 'Copy of ' + Title, Content, @PublishDate, 
						@ExpireDate, @WorkflowStatus, getdate(), 
						@UserID, 1, @MarkedForDeletion, @JobID from tblContentModule 
						where ContentID = @ModuleID

				select @errorcode = @@error
				select @NewModuleID = @@identity

			end
			else if (upper(@ModuleType) = 'HEADER SIDE CONTENT')
			begin 
				-- add a new header side content based on the existing one	
				insert into tblHeaderSideContentModule (Title, LineText1, InternalLink1, InternalLink1Type, ExternalLink1,
					LineText2, InternalLink2, InternalLink2Type, ExternalLink2,
					PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, 
					LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
					 select 'Copy of ' + Title, LineText1, InternalLink1, InternalLink1Type, ExternalLink1,
						LineText2, InternalLink2, InternalLink2Type, ExternalLink2,
	  				        @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), 
						@UserID, 1, @MarkedForDeletion, @JobID from tblHeaderSideContentModule 
						where HeaderSideContentModuleID = @ModuleID

				select @errorcode = @@error
				select @NewModuleID = @@identity


			end
			else if (upper(@ModuleType) = 'PRODUCT BLURB')
			begin
				-- add a new product blurb based on the existing one								
				insert into tblProductBlurbModule (SourceID, ProductSelection, Title, ProductBlurb, 
					PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, 
					LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
					select SourceID, ProductSelection, 'Copy of ' + Title, ProductBlurb,
						@PublishDate, @ExpireDate, @WorkflowStatus, getdate(), 
						@UserID, 1, @MarkedForDeletion, @JobID from tblProductBlurbModule
						where ProductBlurbModuleID = @ModuleID
				select @errorcode = @@error
				select @NewModuleID = @@identity

				-- add blurb reln records (if applicable)
				if (@errorcode = 0)
				begin
					insert into tblProductBlurbModuleReln (ProductBlurbModuleID, ProductID,
						PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, 
						LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
						select @NewModuleID, ProductID, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), 
						@UserID, 1, @MarkedForDeletion, @JobID from tblProductBlurbModuleReln
						where ProductBlurbModuleID = @ModuleID
				end 
			end


			-- insert the module record
			if (@errorcode = 0)
			begin
				
				
				-- just put 1 as the module order (user can change it) and showtitle = 1

				-- now add page module reln
				insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
				values (@PageID, @NewModuleID, @ModuleType, 999, 1, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)

				

				-- now update the job to working
				if (@errorcode = 0)
				begin

					select @PageModuleRelnID = @@identity
		
					exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
					select @errorcode = @@error
				end					


				if (@errorcode = 0)
				begin
			
					commit tran
					print 'The module was added'
					return 1
				end
				else
				begin
					rollback tran
					print 'An error occurred while attempting to add the module'
					return 0
				end
			end
	end
	


end