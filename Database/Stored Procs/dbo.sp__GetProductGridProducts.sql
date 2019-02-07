



--sp__GetProductBlurbModuleRelnsByProduct 16, 4, 1
CREATE	PROC sp__GetProductGridProducts
	@ProductGridID int = 0,
	@BusUnitID int = null,
	@Selected bit = 0 -- this is for getting selected/unselected for product
AS
BEGIN

/*
created by: Kelly Roe
created on: 12/12/2006

purpose:
	Get list of product grid products

history:
	Kelly Roe    (12/12/2006) - created initial procedure
*/

if (@BusUnitID is null or @BusUnitID = 0)
begin
	print 'A business unit id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblProductGrid') > 0 and 
	    dbo.fn__TableExists('tblProductGridRowDef') > 0)
	begin

		if (@Selected = 1) -- get list of selected attribs and include workflow info
		begin


			select 	p.ProductId,
				p.ProductName
			from	tblProductGridRowDef pgr,
				tblProduct p
			where	pgr.ProductGridID = @ProductGridID
			and	pgr.ProductID = p.ProductID
			and	pgr.ActiveFlag = 1 and p.ActiveFlag = 1
			and	pgr.MarkedForDeletion = 0 
			and	p.MarkedForDeletion = 0
			order by pgr.RowNumber asc

		end
		else -- get "unselected" products (from bus unit)
		begin
		
			select 	ProductId, 
				ProductName 
			from 	tblProduct
			where 	BusinessUnitID = @BusUnitID
			and	ProductID not in 
					(select ProductId from tblProductGridRowDef 
						where ProductGridID = @ProductGridID
						and   MarkedForDeletion = 0) 
			and	MarkedForDeletion = 0
			and 	ActiveFlag = 1
			order by ProductName asc

		end

	end
	else
	begin
		print 'You are missing some tables'
		return 0
	end
end


END