






CREATE	proc sp__UpdateDocumentModule
		@DocumentModuleRelnID int = null,
		@DocumentID int = null,
		@LinkText varchar(100) = null,
		@SectionID int = null,
		@PageID int = null,
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = null,
		@UserID int = null

as
begin
	declare @errorcode int
	
/*
created by: Kelly Roe
created on: 12/24/2006
purpose:
	Updates a document module for a page (along with page module reln info)
	
history:
	Kelly Roe	(12/24/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblDocumentModule') > 0)
	begin
	
		if (@DocumentModuleRelnID is null or @DocumentModuleRelnID = 0)
		begin
			print 'A module id is required'
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
			
		
				-- update the image module record
				update 	tblDocumentModule
				set	DocumentID = @DocumentID,
					LinkText = @LinkText,
					SectionID = @SectionID,
					PublishDate = @PublishDate,
					ExpirationDate = @ExpireDate,
					WorkflowStatus = @WorkflowStatus,
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID
				where	ImageModuleID = @DocumentModuleRelnID				

				select @errorcode = @@error

				if (@errorcode = 0)
				begin
					
					
					-- now update page module reln
					update 	tblPageModuleReln
					set	--SourceName = @ModuleType,
						--ModuleOrder = @ModuleOrder,
						--ShowTitle = @ShowTitle,
						PublishDate = @PublishDate,
						ExpirationDate = @ExpireDate,
						WorkflowStatus = @WorkflowStatus,
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where	SourceName = 'DOCUMENT'
					and	SourceID = @DocumentModuleRelnID



					-- now update the job to working
					if (@errorcode = 0)
					begin
						exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
						select @errorcode = @@error
					end					


					if (@errorcode = 0)
					begin
				
						commit tran
						print 'The module was updated'
						return 1
					end
					else
					begin
						rollback tran
						print 'An error occurred while attempting to update the module'
						return 0
					end
				end
				else
				begin
					select @DocumentModuleRelnID = 0
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