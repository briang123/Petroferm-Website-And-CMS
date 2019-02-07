

CREATE proc sp__UpdateProductBlurbModule
	@ProductBlurbModuleID int = null,
	@ProductID int = 0,
	@ProductIDList varchar(100) = '',
	@ProductSelection varchar(20) = 'INDIVIDUAL',
	@ProductBlurb varchar(2000) = null,
	@ModuleOrder int = null,
	@ShowTitle bit = 0,
	@Title varchar(50) = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null
as
begin
	declare @errorcode int
	
/*
created by: Brian Gaines
created on: 12/10/2006
purpose:
	Updates a product blurb module for a page (along with page module reln info)
	
history:
	Brian Gaines (12/10/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblProductBlurbModuleReln') > 0)
	begin
	
		if (@ProductBlurbModuleID is null or @ProductBlurbModuleID = 0)
		begin
			print 'A product blurb module id is required'
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
					
				update 	tblProductBlurbModule
				set 	SourceID = @ProductID,
					ProductSelection = @ProductSelection,
					Title = @Title,
					ProductBlurb = @ProductBlurb,
					MarkedForDeletion = 0, 
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID,
					WorkflowStatus = @WorkflowStatus,
					DeploymentJobId = @JobID
				where	ProductBlurbModuleID = @ProductBlurbModuleID

				select @errorcode = @@error

				if (@errorcode = 0)
				begin					
					update 	tblProductBlurbModuleReln
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	ProductBlurbModuleID = @ProductBlurbModuleID

					select @errorcode = @@error

				end

				if (@ProductSelection = 'MULTIPLE')
				begin
	
					if (@errorcode = 0)
					begin
	
						update 	tblProductBlurbModule 
						set 	SourceID = ProductBlurbModuleId 
						where 	ProductBlurbModuleId = @ProductBlurbModuleID
	
						select @errorcode = @@error
					end

					if (@errorcode = 0)
					begin

						insert into tblProductBlurbModuleReln (ProductBlurbModuleID, ProductID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
						select @ProductBlurbModuleID, str, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, 0, @JobID
						from dbo.fn__CharListToTable(@ProductIDList,',')

						select @errorcode = @@error	

					end
	
				end

				if (@errorcode = 0)
				begin
					
					-- now update page module reln
					update 	tblPageModuleReln
					set	ModuleOrder = @ModuleOrder,
						ShowTitle = @ShowTitle,
						PublishDate = @PublishDate,
						ExpirationDate = @ExpireDate,
						WorkflowStatus = @WorkflowStatus,
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where	SourceID = @ProductBlurbModuleID
					and	SourceName = 'PRODUCT BLURB'

					-- now update the job to working
					if (@errorcode = 0)
					begin
						exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
						select @errorcode = @@error
					end					

				end

				if (@errorcode = 0)
				begin
			
					commit tran
					print 'The  module was updated'
					return 1
				end
				else
				begin
					rollback tran
					print 'An error occurred while attempting to update the module'
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