






CREATE     PROC sp__UpdateProduct
	@BusUnitID int = null,
	@ProductID int = null,
	@ProductName varchar(200) = null,
	@ProductKeywords varchar(200) = null,
	@ProductBlurb varchar(2000) = null,
	@ProductApprovals varchar(2000) = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null

AS
BEGIN

/*
created by: Kelly Roe
created on: 12/02/2006

purpose:
	Update a single product 

example script usage:
	exec sp__UpdateProduct
		@ProductID = 1,
		@BusUnitID int = 1,
		@ProductName varchar(200) = 'Product Name',
		@ProductKeywords varchar(200) = 'Product Keywords',
		@ProductBlurb varchar(2000) = 'Product Blurb',
		@ProductApprovals varchar(2000) = 'Product Approvals',
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = 1,
		@UserID int = 1

history:
	Kelly Roe	(12/02/2006) - created initial procedure

*/
declare @errorcode int
if (@BusUnitID is null or @BusUnitID = 0)
begin
	print 'A business unit id is required'
	return 0
end
else if (@ProductID is null or @ProductID = 0)
begin
	print 'An product id is required'
	return 0
end
else if (@ProductName is null or len(ltrim(rtrim(@ProductName))) = 0)
begin
	print 'An product name is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblProduct') > 0)
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

		update 	tblProduct
		set	BusinessUnitID = @BusUnitID,
			ProductName = @ProductName,
			ProductKeywords = @ProductKeywords,
			ProductBlurb = @ProductBlurb,
			ProductApprovals = @ProductApprovals,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID,
			DeploymentJobID = @JobID
		where	ProductID = @ProductID
	
		select @errorcode = @@error

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


		if (@@error = 0)
		begin
			print 'successfully updated the product '
			return 1
		end
		else
		begin
			print 'an error occurred while attempting to add a product'
			return 0
		end
	end
	else
	begin
		print 'The tblProduct table is missing'
		return 0
	end
end

END