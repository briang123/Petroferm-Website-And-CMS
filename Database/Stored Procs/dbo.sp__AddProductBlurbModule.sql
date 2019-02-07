





CREATE  proc sp__AddProductBlurbModule
		@PageID int = null,
		@ProductID int = 0,
		@ProductIDList varchar(100) = '',
		@ProductSelection varchar(20) = 'INDIVIDUAL',
		@ProductBlurb varchar(2000) = null,
		@ModuleType varchar(50) = 'PRODUCT BLURB',
		@ModuleOrder int = null,
		@ShowTitle bit = 0,
		@Title varchar(50) = null,
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = null,
		@UserID int = null,
		@ProductBlurbModuleID int OUTPUT,
		@PageModuleRelnID int OUTPUT
as
begin
	declare @errorcode int
	
/*
created by: Brian Gaines
created on: 12/10/2006
purpose:
	Adds a new product blurb module for a page
	
history:
	Brian Gaines (12/10/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblProductBlurbModule') > 0)
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
		else if (@Title is null or len(ltrim(rtrim(@Title))) = 0)
		begin
			print 'a blurb title is required'
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
			
			if (upper(@ProductSelection) = 'INDIVIDUAL')
			begin

				insert into tblProductBlurbModule (SourceID, ProductSelection, Title, ProductBlurb, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@ProductID, @ProductSelection, @Title, @ProductBlurb, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID )
				select @errorcode = @@error

				if (@errorcode = 0)
				begin
					select @ProductBlurbModuleID = @@identity

					-- now add page module reln
					insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
					values (@PageID, @ProductBlurbModuleID, @ModuleType, @ModuleOrder, @ShowTitle, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID)

					select @errorcode = @@error
					
					if (@errorcode = 0)
					begin
						select @PageModuleRelnId = @@identity
					end
					
				end
				else
				begin
					select @ProductBlurbModuleID = 0					
				end
			end
			else -- productselection='MULTIPLE'
			begin

				insert into tblProductBlurbModule (SourceID, ProductSelection, Title, ProductBlurb, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@ProductID, @ProductSelection, @Title, @ProductBlurb, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID )
				select @errorcode = @@error

				if (@errorcode = 0)
				begin
					select @ProductBlurbModuleID = @@identity

					update 	tblProductBlurbModule 
					set 	SourceID = ProductBlurbModuleId 
					where 	ProductBlurbModuleId = @ProductBlurbModuleID

					select @errorcode = @@error

					if (@errorcode = 0)
					begin

						insert into tblProductBlurbModuleReln (ProductBlurbModuleID, ProductID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
						select @ProductBlurbModuleID, str, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID
						from dbo.fn__CharListToTable(@ProductIDList,',')

						select @errorcode = @@error

						if (@errorcode = 0)
						begin
							-- now add page module reln
							insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
							values (@PageID, @ProductBlurbModuleID, @ModuleType, @ModuleOrder, @ShowTitle, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID)
	
							select @errorcode = @@error
							
							if (@errorcode = 0)
							begin
								select @PageModuleRelnId = @@identity
							end															
						end

													
					end						
				end
				else
				begin
					select @ProductBlurbModuleID = 0					
				end

			end

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
				select @PageModuleRelnID = 0
				rollback tran
				print 'An error occurred while attempting to add the module'
				return 0
			end

		end	
	end
	else
	begin
		print 'A table is missing'
		return 0
	end

end