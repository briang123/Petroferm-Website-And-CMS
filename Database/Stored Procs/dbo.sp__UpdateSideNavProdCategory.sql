



CREATE   PROC sp__UpdateSideNavProdCategory
	@BusUnitID int = null,
	@MarketID int = null,
	@ProdCatID int = null,
	@CategoryName varchar(50) = null,
	@CategoryOrder int = 0,
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
created on: 12/14/2006

purpose:
	Update a product category for side nav

history:
	Kelly Roe    (12/14/2006) - created initial procedure
*/

if (@BusUnitID is null or @BusUnitID = 0)
begin
	print 'A business unit id is required'
	return 0
end
else if (@ProdCatID is null or @ProdCatID = 0)
begin
	print 'An category id is required'
	return 0
end
else if (@CategoryName is null or len(ltrim(rtrim(@CategoryName))) = 0)
begin
	print 'An category name is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblSideNavProdCategory') > 0)
	begin

		update 	tblSideNavProdCategory
		set	BusinessUnitID = @BusUnitID,
			MarketID = @MarketID,
			CategoryName = @CategoryName,
			CategoryOrder = @CategoryOrder,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID
		where	BusinessUnitId = @BusUnitID
		and	ProdCatID = @ProdCatID
	
		if (@@error = 0)
		begin
			print 'successfully updated the product category'
			return 1
		end
		else
		begin
			print 'an error occurred while attempting to add a product category'
			return 0
		end
	end
	else
	begin
		print 'The tblSideNavProdCategory table is missing'
		return 0
	end
end

END