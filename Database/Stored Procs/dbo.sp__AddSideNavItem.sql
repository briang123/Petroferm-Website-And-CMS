

CREATE proc sp__AddSideNavItem
	@UserID int = null,
	@ProdCatID int = 0, 
	@Title varchar(100) = null, 
	@Description varchar(500) = null, 
	@URL varchar(500) = null, 
	@BusUnitID int = null, 
	@MarketID int = 0, 
	@PageID int = 0, 
	@ItemOrder int = null, 
	@Parent int = 0, 
	@SectionID int = 6, 
	@PublishDate datetime = null, 
	@ExpireDate datetime = null, 
	@WorkflowStatus varchar(50) = 'WORKING', 
	@ActiveFlag bit = 1, 
	@MarkedForDeletion bit = 0, 
	@JobID int = null,
	@ID int OUTPUT
as
begin

if (@Title = null or len(ltrim(rtrim(@Title))) = 0)
begin
	print 'A title is required'
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

if(@ItemOrder is null or @ItemOrder = 0)
begin
	select 	@ItemOrder = max(ItemOrder) + 1 
	from 	tblSideNav
	where 	BusinessUnitID = @BusUnitID
	and	MarketID = @MarketID
	and 	SectionID = 1
	and	ProdCatID = @ProdCatID
end

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

	declare @errorcode int,
		@retval int
	select 	@errorcode = @@error

	if (@errorcode = 0)
	begin
		insert into tblSideNav (ProdCatID, Title, [Description], URL, BusinessUnitID, MarketID, PageID, ItemOrder, Parent, SectionID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@ProdCatID, @Title, @Description, @URL, @BusUnitID, @MarketID, @PageID, @ItemOrder, @Parent, @SectionID, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobID)
	
		select @ID = @@identity
	end

	if (@errorcode = 0)
	begin
		exec @retval = sp_UTIL_UpdateSideNavOrder @BusUnitID, @MarketID, @ProdCatID, @SectionID, @ID, @ItemOrder

		if (@retval = 1)
		begin
		  select @errorcode = 0
		end
	end	

	if (@errorcode = 0)
	begin
		print 'You successfully added a new navigational element'
		commit tran
		return 1
	end
	else
	begin
		print 'An error occurred while attempting to insert a new navigational element. The process was rolled back to the original state.'
		rollback tran
		return 0
	end
end