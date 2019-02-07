

--sp__GetProductGridAttributes 0, 4, 0
CREATE	PROC sp__GetProductGridAttributes
	@ProductGridID int = 0,
	@BusUnitID int = null,
	@Selected bit = 0 -- this is for getting selected/unselected for product
AS
BEGIN

/*
created by: Kelly Roe
created on: 12/12/2006

purpose:
	Get list of product grid attributes (columns)

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
	    dbo.fn__TableExists('tblProductGridColDef') > 0)
	begin

		if (@Selected = 1) -- get list of selected attribs and include workflow info
		begin


			select 	a.AttribTypeID,
				a.AttribName
			from	tblProductGridColDef pgc,
				tblProductAttributeType a
			where	pgc.ProductGridID = @ProductGridID
			and	pgc.AttribTypeID = a.AttribTypeID
			and	pgc.ActiveFlag = 1 and a.ActiveFlag = 1
			and	pgc.MarkedForDeletion = 0 
			and	a.MarkedForDeletion = 0
			order by pgc.ColumnNumber asc

		end
		else -- get "unselected" products (from bus unit)
		begin
		
			select 	AttribTypeID,
				AttribName
			from 	tblProductAttributeType
			where 	BusinessUnitID = @BusUnitID
			and	AttribTypeID not in 
					(select AttribTypeID from tblProductGridColDef 
						where ProductGridID = @ProductGridID
						and   MarkedForDeletion = 0) 
			and	MarkedForDeletion = 0
			and 	ActiveFlag = 1
			order by AttribName asc

		end

	end
	else
	begin
		print 'You are missing some tables'
		return 0
	end
end


END