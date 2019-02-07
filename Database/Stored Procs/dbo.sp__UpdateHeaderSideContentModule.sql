





CREATE	proc sp__UpdateHeaderSideContentModule
		@HeaderSideContentModuleID int = null,
		@ModuleType varchar(50) = null,  
		@ModuleOrder int = null,
		@ShowTitle bit = 0,
		@Title varchar(50) = null,
		@LineText1 varchar(200) = null,
		@InternalLink1 int = null,
		@InternalLink1Type varchar(50) = null,
		@ExternalLink1 varchar(300) = null,
		@LineText2 varchar(200) = null,
		@InternalLink2 int = null,
		@InternalLink2Type varchar(50) = null,
		@ExternalLink2 varchar(300) = null,
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
created on: 12/10/2006
purpose:
	Updates a header side content module for a page (along with page module reln info)
	
history:
	Kelly Roe	(12/10/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblHeaderSideContentModule') > 0)
	begin
	
		if (@HeaderSideContentModuleID is null or @HeaderSideContentModuleID = 0)
		begin
			print 'A header side content id is required'
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
				update 	tblHeaderSideContentModule
				set	Title = @Title,
					LineText1 = @LineText1,
					InternalLink1 = @InternalLink1,
					InternalLink1Type = @InternalLink1Type,
					ExternalLink1 = @ExternalLink1,
					LineText2 = @LineText2,
					InternalLink2 = @InternalLink2,
					InternalLink2Type = @InternalLink2Type,
					ExternalLink2 = @ExternalLink2,
					PublishDate = @PublishDate,
					ExpirationDate = @ExpireDate,
					DeploymentJobID = @JobID,
					WorkflowStatus = @WorkflowStatus,
					LastModifiedDate = getdate(),
					LastModifiedBy = @UserID
				where	HeaderSideContentModuleID = @HeaderSideContentModuleID				

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
						DeploymentJobID = @JobID,	
						WorkflowStatus = @WorkflowStatus,
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where	SourceName = 'HEADER SIDE CONTENT'
					and	SourceID = @HeaderSideContentModuleID



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
					select @HeaderSideContentModuleID = 0
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