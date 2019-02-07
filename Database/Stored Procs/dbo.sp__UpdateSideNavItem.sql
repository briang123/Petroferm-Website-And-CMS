





CREATE     PROC sp__UpdateSideNavItem
	@ID int = null,
	@ProdCatID int = 0, 
	@Title varchar(100) = null, 
	@Description varchar(500) = null, 
	@URL varchar(500) = null, 
	@BusUnitID int = null, 
	@MarketID int = 0, 
	@PageID int = 0, 
	@ItemOrder int = null, 
	@Parent int = 0, 
	@SectionID int = 0, 
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
	Update a side nav item

history:
	Kelly Roe    (12/14/2006) - created initial procedure
*/

if (@ID is null or @ID = 0)
begin
	print 'A side nav id is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else
begin
	declare @errorcode int
	select @errorcode = @@error

	exec sp_UTIL_UpdateSideNavOrder 
			@BusId = @BusUnitID, 
			@MktId = @MarketID, 
			@ProdCatId = @ProdCatID, 
			@SectionId = @SectionID, 
			@ID = @ID, 
			@ItemOrder = @ItemOrder
	select @errorcode = @@error
	
	if (@errorcode = 0)
	begin
		UPDATE 	tblSideNav
		SET 	ProdCatID = @ProdCatID,
			Title = @Title, 
			Description = @Description,
			URL = @URL,
			BusinessUnitID = @BusUnitID,
			MarketID = @MarketID,
			PageID = @PageID,
			ItemOrder = @ItemOrder, 
			Parent = @Parent, 
			SectionID = @SectionID,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID
		where	ID = @ID
	end
end

END