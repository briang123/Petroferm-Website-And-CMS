







CREATE      PROC sp__UpdateWebPage
		@PageID int = null,
		@BusUnitID int = null, 
		@MarketID int = 0, 
		@PageType varchar(50) = 'GENERAL CONTENT', 
		@PageTitle varchar(100) = null, 
		@MetaKeywords varchar(1500) = null, 
		@MetaDescription varchar(500) = null, 
		@PassthroughURL varchar(300) = null, 
		@IsRequired bit = 0, 
		@IsReadOnly bit = 1,
		@URLRewritePath varchar(500) = null, 
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
	Update a webpage, also update job 

history:
	Kelly Roe    (12/07/2006) - created initial procedure
	Kelly Roe    (12/21/2006) - added update to urlrewrite table
*/

if(@PageTitle = null or len(ltrim(rtrim(@PageTitle))) = 0)
begin
	print 'A page title is required'
	return 0
end
else if(@BusUnitID = null or @BusUnitID = 0)
begin
	print 'A business unit is required'
	return 0
end
else if(@JobID is null or @JobId = 0)
begin
	print 'A deployment job is required'
	return 0
end
else if (@PageID is null or @PageID = 0)
begin
	print 'A page id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblPage') > 0)
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


		-- check to make sure that this doc wasn't added as part of another job
		declare @part_of_other_job int
	
		select @part_of_other_job = 0
		if (@part_of_other_job = 0)
		begin
			select @part_of_other_job = count(*)
			from  tblPage 
			where PageID = @PageID
			and upper(WorkflowStatus) <> 'LIVE' and DeploymentJobId <> @JobId
		end

		if (@part_of_other_job = 0)
		begin
			begin tran
			update 	tblPage
			set	BusinessUnitID = @BusUnitID,
				MarketID = @MarketID,
				PageType = @PageType,
				PageTitle = @PageTitle,
				MetaKeywords = @MetaKeywords,
				MetaDescription = @MetaDescription,
				PassthroughURL = @PassthroughURL,
				IsRequired = @IsRequired,
				IsReadOnly = @IsReadOnly, 
				PublishDate = @PublishDate,
				ExpirationDate = @ExpireDate,
				WorkflowStatus = @WorkflowStatus,
				LastModifiedDate = getdate(),
				LastModifiedBy = @UserID,
				DeploymentJobID = @JobID
			where	PageID = @PageID
	
			select @errorcode = @@error
		

			-- now update the url rewrite stuff, too 
			-- a check has already been made to make sure that it's not a duplicate
		
			update 	tblUrlRewrite
			set	UrlFriendlyName = @URLRewritePath,
				PublishDate = @PublishDate,
				ExpirationDate = @ExpireDate,
				WorkflowStatus = @WorkflowStatus,
				LastModifiedDate = getdate(),
				LastModifiedBy = @UserID,
				DeploymentJobID = @JobID
			where	PageID = @PageID
	
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
		else
			print 'There is content for this item that is part of another deployment job process. You must deploy this content first before updating anything in order to maintain data integrity.'
			return 0
		end
	else
	begin
		print 'One or more tables is missing'
		return 0
	end
end


END