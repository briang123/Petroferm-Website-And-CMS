










CREATE	PROC sp__AddDocument
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
		@JobID int = null,
		@DocumentID int OUTPUT
as
begin

/*
created by: Kelly Roe
created on: 12/07/2006
purpose: 
	Adds a document to tblDocument
	  

history:
	Kelly Roe 	(12/07/2006) - Created initial procedure
*/

-- validate the input parameters
if (@UserID is null)
  begin
	print 'A user id is required.'
  end
else if (@JobID is null)
  begin
	print 'A deployment job id is required.'
  end	
else if (@DocTitle is null or @DocTitle = '')
  begin
	print 'A document title is required.'
  end
else 
  begin

	-- evaluate input parameters, manipulate values if a null value is passed into proc, or format dates
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
	

	-- add document to doc table
	begin	
		insert into tblDocument 
			       (ProductID, 
				RegionID, 
				DocTitle, 
				DocPath,
				ContentType,
				DocumentType,
				UploadDate, 
				PublishDate, 
				ExpirationDate, 
				WorkflowStatus, 
				LastModifiedBy, 
				ActiveFlag, 
				MarkedForDeletion, 
				DeploymentJobID)
		values         (@ProductID,
				@RegionID,	
				@DocTitle,
				@DocPath,
				@ContentType,
				@DocumentType,
				@UploadDate,
				@PublishDate,
				@ExpireDate,
				@WorkflowStatus,
				@UserID, 
				@ActiveFlag, 
				@MarkedForDeletion,
				@JobID)

	end


	if (@@error = 0)
	begin
		select @DocumentID = @@identity
		return 1
	end
	begin
		select @DocumentID = 0
		return 0
	end

  end
end