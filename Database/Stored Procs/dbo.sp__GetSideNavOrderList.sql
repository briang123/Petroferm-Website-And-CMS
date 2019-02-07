




--sp__GetSideNavOrderList 1, 0, 3, 0, 0

CREATE      PROC sp__GetSideNavOrderList(
	@BusId int = 0,
	@MktId int = 0,
	@SectionId int = 0,
	@ProdCatId int = 0,
	@AddPlusOne bit = 0
)
AS
BEGIN

/*
created by: Kelly Roe
created on: 03/13/2007

purpose: Gets the list of order numbers for a given bu/section/product category (if appl) and appends the max+1

parameters:
	@BusId - The business unit id 
	@MktId - The market id (if at a business unit level, then pass in 0)
	@SectionId - The section which we'd like to reorder our navigation elements
	@ProdCatId - The product category id (in case for product pages -- if we're not dealing with a product, then pass in 0)
	@AddPlusOne - Determine whether to add max+1 to the list

history:
	Kelly Roe    (03/13/2007) - Created initial stored procedure
	Kelly Roe    (03/18/2007) - Added new parm to determine whether to add max+1 to list
*/


BEGIN

	if (@AddPlusOne = 1) 
	begin
		SELECT 	ItemOrder
		FROM	tblSideNav
		where 	BusinessUnitId = @BusId
		and	MarketId in (@MktId, 0)
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId
		union
		SELECT 	MAX(ItemOrder) + 1 As ItemOrder
		FROM	tblSideNav
		where 	BusinessUnitId = @BusId
		and	MarketId in (@MktId, 0)
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId
		order by ItemOrder
	end
	else
		SELECT 	ItemOrder
		FROM	tblSideNav
		where 	BusinessUnitId = @BusId
		and	MarketId in (@MktId, 0)
		and	SectionId = @SectionId
		and 	ProdCatId = @ProdCatId
		order by ItemOrder	
	end

END