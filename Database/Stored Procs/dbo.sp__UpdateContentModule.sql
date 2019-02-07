




CREATE  proc sp__UpdateContentModule
		@ContentID int = null,
		@PageModuleRelnID int = null,
		@ModuleType varchar(50) = null,  -- this could be updated (SIDE CONTENT or CONTENT)
		@ModuleOrder int = null,
		@ShowTitle bit = 0,
		@Title varchar(50) = null,
		@Content text = null,
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
created on: 12/08/2006
purpose:
	Updates a content module for a page (along with page module reln info)
	
history:
	Kelly Roe	(12/08/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblContentModule') > 0)
	begin
	
		if (@ContentID is null or @ContentID = 0)
		begin
			print 'A content id is required'
			return 0
		end
		else if (@PageModuleRelnID is null or @PageModuleRelnID = 0)
		begin
			print 'A page module reln id is required'
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
			
				-- update the content module record
				update 	tblContentModule
				set	Title = @Title,
					Content = @Content,
					PublishDate = @PublishDate,
					ExpirationDate = @ExpireDate,
					WorkflowStatus = @WorkflowStatus,
					DeploymentJobID = @JobID,
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID
				where	ContentID = @ContentID				

				select @errorcode = @@error

				if (@errorcode = 0)
				begin
					
					
					-- now update page module reln
					update 	tblPageModuleReln
					set	SourceName = @ModuleType,
						ModuleOrder = @ModuleOrder,
						ShowTitle = @ShowTitle,
						PublishDate = @PublishDate,
						ExpirationDate = @ExpireDate,
						WorkflowStatus = @WorkflowStatus,
						DeploymentJobID = @JobID,
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where	PageModuleRelnID = @PageModuleRelnID		

					-- now update the job to working
					if (@errorcode = 0)
					begin
						exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
						select @errorcode = @@error
					end					


					if (@errorcode = 0)
					begin
				
						commit tran
						print 'The content module was updated'
						return 1
					end
					else
					begin
						rollback tran
						print 'An error occurred while attempting to update the content module'
						return 0
					end
				end
				else
				begin
					select @ContentID = 0
					return 0
				end
		end
	
	end
	else
	begin
		print 'The tblContentModule table is missing'
		return 0
	end

end