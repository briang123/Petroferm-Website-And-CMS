



CREATE  PROC sp__UpdateSearchAttribute
	@SearchAttribTypeID int = null,
	@BusUnitID int = null,
	@MarketID int = null,
	@SearchAttribName varchar(100) = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null
AS

BEGIN
declare @errorcode int

/*
created by: Kelly Roe
created on: 12/04/2006

purpose:
	Update a search attribute

history:
	Kelly Roe    (12/04/2006) - created initial procedure
*/

if (@MarketID is null or @MarketID = 0)
begin
	print 'A market id is required'
	return 0
end
if (@BusUnitID is null or @BusUnitID = 0)
begin
	print 'A business unit id is required'
	return 0
end
else if (@SearchAttribTypeID is null or @SearchAttribTypeID = 0)
begin
	print 'An attribute id is required'
	return 0
end
else if (@SearchAttribName is null or len(ltrim(rtrim(@SearchAttribName))) = 0)
begin
	print 'An attribute name is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblSearchAttribType') > 0)
	begin 
		begin tran
		update 	tblSearchAttribType
		set	BusinessUnitID = @BusUnitID,
			MarketID = @MarketID,
			SearchAttributeName = @SearchAttribName,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID
		where	SearchAttribTypeID = @SearchAttribTypeID


		select @errorcode = @@error
	
		-- now update the job to working
		if (@errorcode = 0)
		begin
	
			update 	tblDeploymentJobs
			set 	WorkflowStatus = 'WORKING',
				LastModifiedDate = getdate(),
				LastModifiedBy = @UserID
			where 	DeploymentJobID = @JobID
	
			select @errorcode = @@error
		end
	
		if (@errorcode <> 0)
		begin
			print 'An error occurred while updating the search attribute.'
			rollback tran
			return 0
		end
		else
		begin
			print 'The search attribute was updated successfully.'
			commit tran
			return 1
		end



	end
	else
	begin
		print 'The tblSearchAttribType table is missing'
		return 0
	end
end

END