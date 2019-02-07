




CREATE    proc sp__DeleteSideNavProdCategory
	@ProdCatID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Kelly Roe
created on: 12/14/2006
purpose:
	Delete a product category (used in side nav)
	and deletes the side nav reln

usage syntax:

history:
	Kelly Roe    (12/14/2006) - created initial procedure
*/

	if (@ProdCatID is null or @ProdCatID = 0)
	begin
		print 'An product category id is required'
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
	
		if (dbo.fn__TableExists('tblSideNavProdCategory_LIVE') > 0)
		begin
			if exists(select 1 from tblSideNavProdCategory_LIVE where ProdCatID = @ProdCatID)
			begin
				-- the table and record exists, so we need to flag the record as one to be deleted, but don't delete it until it's deployed
				select @mark_for_deletion = 1
			end
			else
			begin
				-- the table exists, but the record is not there, meaning it's a new product attribute; so we can just delete it from the cms table
				select @mark_for_deletion = 0
			end
		end
		else
		begin
			-- the live table does not, so we can just go ahead and delete the record from the cms table
			select @mark_for_deletion = 0
		end

		begin tran

			declare @errorcode int
			select @errorcode = @@error
	
			-- delete the side nav item (pages that are assoc with the prod cat)
			if (@errorcode = 0)
			begin
				if (@mark_for_deletion = 0)
				begin
					delete from tblSideNav where ProdCatID = @ProdCatID
				end
				else
				begin
					update 	tblSideNav
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	ProdCatID = @ProdCatID
				end
	
				select @errorcode = @@error
			end 		
	
			-- delete from the searchable attributes associated with the product attribute types
			if (@errorcode = 0)
			begin

				if (@mark_for_deletion = 0)
				begin
					delete from tblSideNavProdCategory where ProdCatID = @ProdCatID
				end
				else
				begin
					update 	tblSideNavProdCategory
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where ProdCatID = @ProdCatID
				end
	
				select @errorcode = @@error
				
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


			end 

		
			if (@errorcode = 0)
			begin
				print 'The product category was successfully removed from the system'
				commit tran
				return 1
			end
			else
			begin
				print 'An error occurred while deleting the product category from the system'
				rollback tran
				return 0
			end		


	end

end