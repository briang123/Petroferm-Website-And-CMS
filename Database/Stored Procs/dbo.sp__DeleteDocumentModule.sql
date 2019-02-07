









CREATE         proc sp__DeleteDocumentModule
		@DocumentModuleID int = null, 
		@UserID int = null,
		@JobID int = null,
		@WorkflowStatus varchar(50) = 'WORKING'
as
begin

/*
created by: Kelly Roe
created on: 12/24/2006
purpose:
	Delete a document module

history:
	Kelly Roe    (12/24/2006) - created initial procedure
*/

	if (@DocumentModuleID is null or @DocumentModuleID = 0)
	begin
		print 'A module id is required'
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

	if (dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0)
	begin
		if exists(select 1 from tblPageModuleReln_LIVE 
			  where SourceID = @DocumentModuleID
			  and	UPPER(SourceName) = 'DOCUMENT')
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

				-- delete the module
				delete from tblDocumentModule 
				where DocumentModuleID = @DocumentModuleID

				-- delete the page module reln
				delete from tblPageModuleReln 
				where 	SourceID = @DocumentModuleID
				and	UPPER(SourceName) in ('NAV ON IMAGE','NAV OFF IMAGE','HEADER IMAGE','HEADER SIDE CONTENT IMAGE')

			end
			else
			begin
				-- update module
				update 	tblDocumentModule
				set 	MarkedForDeletion = 1, 
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID,
					WorkflowStatus = @WorkflowStatus,
					DeploymentJobId = @JobID
				where	DocumentModuleID = @DocumentModuleID

				-- update page module reln
				update 	tblPageModuleReln
				set 	MarkedForDeletion = 1, 
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID,
					WorkflowStatus = @WorkflowStatus,
					DeploymentJobId = @JobID
				where	SourceID = @DocumentModuleID
				and	UPPER(SourceName) = 'DOCUMENT'


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

end