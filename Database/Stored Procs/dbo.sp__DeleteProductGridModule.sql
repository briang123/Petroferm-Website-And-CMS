







--sp__DeleteProductBlurbModule 2, 1, 2
create   proc sp__DeleteProductGridModule
	@ProductGridModuleID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Kelly Roe
created on: 12/12/2006
purpose:
	Delete a product grid module 

usage syntax:

history:
	Kelly Roe   (12/12/2006) - created initial procedure
*/


	if (@ProductGridModuleID is null or @ProductGridModuleID = 0)
	begin
		print 'An product grid module id is required'
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
	
		if (dbo.fn__TableExists('tblProductGridModule_LIVE') > 0)
		begin
			if exists(select 1 from tblProductGridModule_LIVE where 
				ProductGridModuleID = @ProductGridModuleID)
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
	
	
			declare @ProductGridID int
			-- get the product grid id
			select @ProductGridID = ProductGridID 
			from tblProductGridModule 
			where ProductGridModuleID = @ProductGridModuleID

			declare @GridInUse int 
			-- also, find out if this grid is being used by another module
			-- if so, do not delete /mark for deletion
			select @GridInUse = count(ProductGridModuleID)  from tblProductGridModule 
			where 	ProductGridModuleID <> @ProductGridModuleID
			and	ProductGridID = @ProductGridID
			
		
			
	
			-- delete the reln
			if (@errorcode = 0)
			begin
	
				if (@mark_for_deletion = 1)
				begin
					if (@GridInUse = 0) -- can delete the product grid, too
					begin
						if (@errorcode = 0)
						begin
							update 	tblProductGrid
							set 	MarkedForDeletion = 1, 
								LastModifiedDate = getdate(),
								LastModifiedBy = @UserID,
								WorkflowStatus = @WorkflowStatus,
								DeploymentJobId = @JobID
							where	ProductGridID = @ProductGridID
							select @errorcode = @@error
	
						end
			
						if (@errorcode = 0)
						begin
	
							update 	tblProductGridColDef
							set 	MarkedForDeletion = 1, 
								LastModifiedDate = getdate(),
								LastModifiedBy = @UserID,
								WorkflowStatus = @WorkflowStatus,
								DeploymentJobId = @JobID
							where	ProductGridID = @ProductGridID
							select @errorcode = @@error
						end
			
						if (@errorcode = 0)
						begin
							update 	tblProductGridRowDef
							set 	MarkedForDeletion = 1, 
								LastModifiedDate = getdate(),
								LastModifiedBy = @UserID,
								WorkflowStatus = @WorkflowStatus,
								DeploymentJobId = @JobID
							where	ProductGridID = @ProductGridID
		
		
							select @errorcode = @@error
	
						end

					end
			

	

	
					if (@errorcode = 0)
					begin
						update 	tblProductGridModule
						set 	MarkedForDeletion = 1, 
							LastModifiedDate = getdate(),
							LastModifiedBy = @UserID,
							WorkflowStatus = @WorkflowStatus,
							DeploymentJobId = @JobID
						where	ProductGridModuleID = @ProductGridModuleID
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
						where	SourceID = @ProductGridModuleID
						and	UPPER(SourceName) = 'PRODUCT GRID'
					end
		
					select @errorcode = @@error
	
				end
				else
				begin
					if (@GridInUse = 0) -- can delete the product grid, too
					begin


						if (@errorcode = 0)
						begin
							delete from tblProductGridColDef 
							where	ProductGridID = @ProductGridID
							select @errorcode = @@error
						end
	
						if (@errorcode = 0)
						begin
							delete from tblProductGridRowDef 
							where	ProductGridID = @ProductGridID
							select @errorcode = @@error
						end
	
						if (@errorcode = 0)
						begin
							delete from tblProductGrid 
							where	ProductGridID = @ProductGridID
							select @errorcode = @@error
						end

					end


	
					if (@errorcode = 0)
					begin
						delete from tblProductGridModule where ProductGridModuleID = @ProductGridModuleID
						select @errorcode = @@error
					end
	
					if (@errorcode = 0)
					begin
						delete from tblPageModuleReln where SourceId = @ProductGridModuleID and upper(SourceName) = 'PRODUCT GRID'
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
					print 'The product grid was successfully removed from the system'
					commit tran
					return 1
				end
				else
				begin
					print 'An error occurred while deleting the product grid from the system'
					rollback tran
					return 0
				end		


			end		
		end
	end

end