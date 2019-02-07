





create    PROC sp__UpdateDocument
		@DocumentID int = null,
		@ProductID int = null,
		@RegionID int = null,	
		@DocTitle varchar(100) = null,
		@DocPath varchar(500) = null,
		@ContentType varchar(20) = null,
		@DocumentType varchar(50) = null,
		@UploadDate datetime = null,
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@WorkflowStatus varchar(50) = 'WORKING',
		@UserID int = null,
		@ActiveFlag bit = 1,
		@MarkedForDeletion bit = 0,
		@JobID int = null
AS

BEGIN
declare @errorcode int

/*
created by: Kelly Roe
created on: 12/07/2006

purpose:
	Update a product document, also update job 

history:
	Kelly Roe    (12/07/2006) - created initial procedure
*/

if (@DocumentID is null or @DocumentID = 0)
begin
	print 'A document id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblDocument') > 0)
	begin tran
		update 	tblDocument
		set	ProductID = @ProductID,
			RegionID = @RegionID,
			DocTitle = @DocTitle,
			DocPath = @DocPath,
			ContentType = @ContentType,
			DocumentType = @DocumentType,
			UploadDate = @UploadDate,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID
		where	DocumentID = @DocumentID

		select @errorcode = @@error
	
		-- now update the job to working
		if (@errorcode = 0)
		begin

			exec sp__UpdateDeploymentJobToWorkingStatus @UserID, @JobID
			select @errorcode = @@error
		end
	
		if (@errorcode <> 0)
		begin
			print 'An error occurred.'
			rollback tran
			return 0
		end
		else
		begin
			print 'The update was successful.'
			commit tran
			return 1
		end
	end

end