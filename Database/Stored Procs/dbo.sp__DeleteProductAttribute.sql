




CREATE   proc sp__DeleteProductAttribute
	@AttribTypeID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Brian Gaines
created on: 11/30/2006
purpose:
	Delete a product attribute

usage syntax:

history:
	Brian Gaines (11/30/2006) - created initial procedure
	Kelly Roe    (12/01/2006) - added the delete for tblProductAttributeType
	Kelly Roe    (12/06/2006) - update job to working status
*/

	if (@AttribTypeID is null or @AttribTypeID = 0)
	begin
		print 'An attribute id is required'
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
	
		if (dbo.fn__TableExists('tblProductAttributeType_LIVE') > 0)
		begin
			if exists(select 1 from tblProductAttributeType_LIVE where AttribTypeID = @AttribTypeID)
			begin
				if exists(select 1 from tblProductAttributeType_LIVE where AttribTypeID = @AttribTypeID and IsReadOnly = 1)
				begin
					print 'You cannot delete a read-only product attribute'
					return 0
				end
				else
				begin
					-- the table and record exists, so we need to flag the record as one to be deleted, but don't delete it until it's deployed
					select @mark_for_deletion = 1
				end
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
	
			-- delete the product attribute from the product grids which have a reference to this attribute type
			if (@errorcode = 0)
			begin
	
				if (@mark_for_deletion = 0) 
				begin 
					delete from tblProductGridColDef where AttribTypeID = @AttribTypeID
				end
				else 
				begin
					update 	tblProductGridColDef 
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	AttribTypeID = @AttribTypeID
				end
	
				select @errorcode = @@error
			end 
	
			-- delete the attribute's distinct values list for auto-text
			if (@errorcode = 0)
			begin
				if (@mark_for_deletion = 0)
				begin
					delete from tblProductAttributeReln where AttribTypeID = @AttribTypeID
				end
				else
				begin
					update 	tblProductAttributeReln
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	AttribTypeID = @AttribTypeID
				end
	
				select @errorcode = @@error
			end 		
	

			-- delete from the searchable attributes associated with the product attribute types
			-- THE SEARCH ATTRIB IS NOT RELATED TO A PRODUCT ATTRIB TYPE
			-- THE ATTRIBTYPEID COLUMN WILL BE REMOVED FROM THE TBLSEARCHATTRIBTYPE TABLE
			/*if (@errorcode = 0)
			begin

				if (@mark_for_deletion = 0)
				begin
					delete from tblSearchAttribType where AttribTypeID = @AttribTypeID
				end
				else
				begin
					update 	tblSearchAttribType
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	AttribTypeID = @AttribTypeID
				end
	
				select @errorcode = @@error
			end */

			-- lastly, delete from the tblProductAttributeType table 
			if (@errorcode = 0)
			begin

				if (@mark_for_deletion = 0)
				begin
					delete from tblProductAttributeType where AttribTypeID = @AttribTypeID
				end
				else
				begin
					update 	tblProductAttributeType
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	AttribTypeID = @AttribTypeID
				end
	
				select @errorcode = @@error
			end 

			
			-- now update the job to working status
			if (@errorcode = 0)
			begin
				exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
				select @errorcode = @@error
			end

		
			if (@errorcode = 0)
			begin
				print 'The product attribute was successfully removed from the system'
				commit tran
				return 1
			end
			else
			begin
				print 'An error occurred while deleting the product attribute from the system'
				rollback tran
				return 0
			end		
	end

end