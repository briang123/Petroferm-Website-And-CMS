






--sp__DeleteProductBlurbModule 2, 1, 2
CREATE  proc sp__DeleteProductBlurbModule
	@ProductBlurbModuleID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Brian Gaines
created on: 12/10/2006
purpose:
	Delete a product blurb 

usage syntax:

history:
	Brian Gaines (12/10/2006) - created initial procedure
*/


	if (@ProductBlurbModuleID is null or @ProductBlurbModuleID = 0)
	begin
		print 'An product blurb module id is required'
		return 0
	end
	else if (@UserID is null or @UserID = 0)
	begin
		print 'A user id is required.'
		return 0
	end
	else if (@JobID is null or @JobID = 0)
	begin
		print 'A deployment job id is required.'
		return 0
	end	
	else
	begin
	
		declare @mark_for_deletion bit
	
		if (dbo.fn__TableExists('tblProductBlurbModule_LIVE') > 0)
		begin
			if exists(select 1 from tblProductBlurbModule_LIVE where 
				ProductBlurbModuleID = @ProductBlurbModuleID)
			begin
				-- the table and record exists, so we need to flag the record as one to be deleted, but don't delete it until it's deployed
				select @mark_for_deletion = 1
			end
			else
			begin
				-- the table exists, but the record is not there, meaning it's a new product attribute; so we can just delete it from the cms table
				select @mark_for_deletion = 0
			end
			

			-- the live table does not, so we can just go ahead and delete the record from the cms table
			select @mark_for_deletion = 0
	
			begin tran
	
			declare @errorcode int
			select @errorcode = @@error
	
	
			-- delete the reln
			if (@errorcode = 0)
			begin
	
				if (@mark_for_deletion = 1)
				begin
	
					update 	tblProductBlurbModuleReln
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	ProductBlurbModuleID = @ProductBlurbModuleID
		
					select @errorcode = @@error
		
					if (@errorcode = 0)
					begin
						update 	tblProductBlurbModule
						set 	MarkedForDeletion = 1, 
							LastModifiedDate = getdate(),
							LastModifiedBy = @UserID,
							WorkflowStatus = @WorkflowStatus,
							DeploymentJobId = @JobID
						where	ProductBlurbModuleID = @ProductBlurbModuleID
					end
		
					select @errorcode = @@error
		
		
					if (@errorcode = 0)
					begin
						update 	tblPageModuleReln
						set 	MarkedForDeletion = 1, 
							LastModifiedDate = getdate(),
							LastModifiedBy = @UserID,
							WorkflowStatus = @WorkflowStatus,
							DeploymentJobId = @JobID
						where	SourceID = @ProductBlurbModuleID
						and	UPPER(SourceName) = 'PRODUCT BLURB'
					end
		
					select @errorcode = @@error
	
				end
				else
				begin
					if (@errorcode = 0)
					begin
						delete from tblProductBlurbModuleReln where ProductBlurbModuleId = @ProductBlurbModuleId
						select @errorcode = @@error
					end
	
					if (@errorcode = 0)
					begin
						delete from tblProductBlurbModule where ProductBlurbModuleID = @ProductBlurbModuleId
						select @errorcode = @@error
					end
	
					if (@errorcode = 0)
					begin
						delete from tblPageModuleReln where SourceId = @ProductBlurbModuleId and upper(SourceName) = 'PRODUCT BLURB'
						select @errorcode = @@error
					end
			
				end
	
				-- now update the job to working
				if (@errorcode = 0)
				begin
			
					update 	tblDeploymentJobs
					set 	WorkflowStatus = 'WORKING',
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where 	DeploymentJobID = @JobID
			
					select @errorcode = @@error
				end
			
		
				if (@errorcode = 0)
				begin
					print 'The product blurb was successfully removed from the system'
					commit tran
					return 1
				end
				else
				begin
					print 'An error occurred while deleting the product blurb from the system'
					rollback tran
					return 0
				end		


			end		
		end
	end

end