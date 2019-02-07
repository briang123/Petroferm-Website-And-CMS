





CREATE    proc sp__AddDocumentModule
		@DocumentID int = null, -- must already exist
		@LinkText varchar(100) = null,
		@SectionID int = null,
		@PageID int = null,
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = null,
		@UserID int = null,
		@DocumentModuleRelnID int OUTPUT,
		@PageModuleRelnID int OUTPUT
as
begin

declare @errorcode int
select @errorcode = 0

/*
created by: Kelly Roe
created on: 12/24/2006
purpose:
Adds a new document module for a page

history:
Kelly Roe (12/24/2006) - created initial procedure
Brian Gaines (1/5/2007) - removed commented out @errorcode
*/

if (dbo.fn__TableExists('tblDocumentModuleReln') > 0)
begin

	if (@PageID is null or @PageID = 0)
	begin
		print 'A page id is required'
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
		
			
			-- insert the module record
			if (@errorcode = 0)
			begin
				insert into tblDocumentModuleReln (DocumentID, LinkText, SectionID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@DocumentID, @LinkText, @SectionID, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
				select @DocumentModuleRelnID = @@identity
				select @errorcode = @@error
			end
	
			if (@errorcode = 0)
			begin
			
				-- now add page module reln
				insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@PageID, @DocumentModuleRelnID, 'DOCUMENT', 0, 0, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
				
				select @errorcode = @@error
			end
			
			-- now update the job to working
			if (@errorcode = 0)
			begin
			
				select @PageModuleRelnID = @@identity
				
				exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
				select @errorcode = @@error
			end
		end
	
		if (@errorcode = 0)
		begin
		
			commit tran
			print 'The image module was added'
			return 1
		end
		else
		begin
		
			rollback tran
			print 'An error occurred while attempting to add the image module'
			return 0
		end
	end
	else
	begin
		print 'The table is missing'
		return 0
	end
end