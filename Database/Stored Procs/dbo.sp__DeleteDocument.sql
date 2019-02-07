




CREATE    proc sp__DeleteDocument
	@DocumentID int = null,
	@UserID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Kelly Roe
created on: 12/07/2006
purpose:
	Delete a product document

usage syntax:

history:
	Kelly Roe    (12/07/2006) - created initial procedure
*/

	if (@DocumentID is null or @DocumentID = 0)
	begin
		print 'A document id is required'
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
		from  tblDocument 
		where DocumentID = @DocumentID
		and upper(WorkflowStatus) <> 'LIVE' and DeploymentJobId <> @JobId
	end

 	if (@part_of_other_job = 0)
	begin


		declare @mark_for_deletion bit
	
		if (dbo.fn__TableExists('tblDocument_LIVE') > 0)
		begin
			if exists(select 1 from tblDocument_LIVE where DocumentID = @DocumentID)
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
	

			-- delete from the document table
			if (@errorcode = 0)
			begin

				if (@mark_for_deletion = 0)
				begin
					delete from tblDocument where DocumentID = @DocumentID
				end
				else
				begin
					update 	tblDocument
					set 	MarkedForDeletion = 1, 
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobId = @JobID
					where	DocumentID = @DocumentID
				end
	
				select @errorcode = @@error
				
				-- now update the job to working
				if (@errorcode = 0)
				begin
					exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
					select @errorcode = @@error
				end


			end 

		
			if (@errorcode = 0)
			begin
				print 'The item was successfully removed from the system'
				commit tran
				return 1
			end
			else
			begin
				print 'An error occurred while deleting the item from the system'
				rollback tran
				return 0
			end		

	end
	else
	begin
		print 'There is content for this item is part of another deployment job process. You must deploy this content first before deleting anything in order to maintain data integrity.'
		return 0

	end


	end

end