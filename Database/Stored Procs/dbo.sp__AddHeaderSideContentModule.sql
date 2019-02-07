






CREATE proc sp__AddHeaderSideContentModule
		@PageID int = null,
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
		@UserID int = null,
		@HeaderSideContentModuleID int OUTPUT,
		@PageModuleRelnID int OUTPUT
as
begin
	
/*
created by: Kelly Roe
created on: 12/10/2006
purpose:
	Adds a new header side content module for a page
	
history:
	Kelly Roe	(12/10/2006) - created initial procedure
	Brian Gaines 	(1/5/2007) - updated the if..endif blocks
*/

declare @errorcode int
select @errorcode = @@error

if (dbo.fn__TableExists('tblHeaderSideContentModule') > 0)
begin

	if (@PageID is null or @PageID = 0)
	begin
		print 'A page id is required'
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

		-- insert the content module record
		insert into tblHeaderSideContentModule (Title, LineText1, InternalLink1, InternalLink1Type, ExternalLink1, LineText2, InternalLink2, InternalLink2Type, ExternalLink2, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
		values (@Title, @LineText1, @InternalLink1, @InternalLink1Type, @ExternalLink1, @LineText2, @InternalLink2, @InternalLink2Type, @ExternalLink2, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)

		select @errorcode = @@error

		if (@errorcode = 0)
		begin
			select @HeaderSideContentModuleID = @@identity
			
			-- now add page module reln
			insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId) 
			values (@PageID, @HeaderSideContentModuleID, @ModuleType, @ModuleOrder, @ShowTitle, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)

			select @errorcode = @@error

		end

		-- now update the job to working
		if (@errorcode = 0)
		begin

			select @PageModuleRelnID = @@identity		
			exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
			select @errorcode = @@error
		end					


		if (@errorcode = 0)
		begin
	
			commit tran
			print 'The header side content module was added'
			return 1
		end
		else
		begin
			select @HeaderSideContentModuleID = 0
			rollback tran
			print 'An error occurred while attempting to add the header side content module'
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