



--sp__DeleteSearchAttribute 2, 1, 
CREATE   proc sp__DeleteSearchAttribute
	@SearchAttribTypeID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Kelly Roe
created on: 12/04/2006
purpose:
	Delete a search attribute

usage syntax:

history:
	Kelly Roe    (12/04/2006) - created initial procedure
	Kelly Roe    (12/05/2006) - added update of deployment job record
	Kelly Roe    (12/06/2006) - added check to see if data is part of other job
*/

	if (@SearchAttribTypeID is null or @SearchAttribTypeID = 0)
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



	-- check to make sure that this reln wasn't added as part of another job
	DECLARE @part_of_other_job int

	select @part_of_other_job = 0
	if (@part_of_other_job = 0)
	begin
		select @part_of_other_job = count(*)
		from  tblSearchAttribType 
		where SearchAttribTypeID = @SearchAttribTypeID
		and upper(WorkflowStatus) <> 'LIVE' and DeploymentJobId <> @JobId
	end

 	if (@part_of_other_job = 0)
	begin


		declare @mark_for_deletion bit
	
		if (dbo.fn__TableExists('tblSearchAttribType_LIVE') > 0)
		begin
			if exists(select 1 from tblSearchAttribType_LIVE where SearchAttribTypeID = @SearchAttribTypeID)
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
	
			-- delete the attribute's distinct values list for auto-text
			if (@errorcode = 0)
			begin
				if (@mark_for_deletion = 0)
				begin
					delete from tblProductSearchAttribReln where SearchAttribTypeID = @SearchAttribTypeID
				end
				else
				begin
					update 	tblProductSearchAttribReln
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	SearchAttribTypeID = @SearchAttribTypeID
				end
	
				select @errorcode = @@error
			end 		
	
			-- delete from the searchable attributes associated with the product attribute types
			if (@errorcode = 0)
			begin

				if (@mark_for_deletion = 0)
				begin
					delete from tblSearchAttribType where SearchAttribTypeID = @SearchAttribTypeID
				end
				else
				begin
					update 	tblSearchAttribType
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	SearchAttribTypeID = @SearchAttribTypeID
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
				print 'The search attribute was successfully removed from the system'
				commit tran
				return 1
			end
			else
			begin
				print 'An error occurred while deleting the search attribute from the system'
				rollback tran
				return 0
			end		

	end
	else
	begin
		print 'There is content for this search attribute is part of another deployment job process. You must deploy this content first before deleting anything in order to maintain data integrity.'
		return 0

	end


	end

end