






CREATE       proc sp__GetProductGridColumns
	@gridID int = null,
	@LiveMode bit = 1
as
begin

/*
created by: Brian Gaines
created on: 11/23/2006
purpose:
	Returns the list of columns that get help build the product grid
	
history:
	Brian Gaines (11/23/2006) - created initial procedure
	Kelly Roe    (02/26/2007) - added marked for deletion where clause (task #94)
*/

if (@GridID is null or @GridID = 0)
begin
	print 'A Grid ID is required.'
	return 0
end
else 
begin

	if (@LiveMode = 1)
	begin
		if (dbo.fn__TableExists('tblProductGrid_LIVE') > 0 AND
			dbo.fn__TableExists('tblProductGridModule_LIVE') > 0 AND
			dbo.fn__TableExists('tblProductGridColDef_LIVE') > 0 AND
			dbo.fn__TableExists('tblProductAttributeType_LIVE') > 0)
		begin

			select 	pg.ProductGridID,
				pgm.ProductGridTitle, 
				pg.ProductGridName,
				a.AttribTypeID,
				a.AttribName,
				c.ColumnNumber
			from 	tblProductGridModule_LIVE pgm,
				tblProductGrid_LIVE pg,
				tblProductGridColDef_LIVE c,
				tblProductAttributeType_LIVE a
			where	pgm.ProductGridID = pg.ProductGridID
			and	pg.ProductGridID = c.ProductGridID
			and	a.AttribTypeID = c.AttribTypeID
			and	pg.ProductGridID = @gridID
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(pgm.PublishDate) and dbo.fn__GetDateOnly(pgm.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(pg.PublishDate) and dbo.fn__GetDateOnly(pg.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(c.PublishDate) and dbo.fn__GetDateOnly(c.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(a.PublishDate) and dbo.fn__GetDateOnly(a.ExpirationDate)
			and 	upper(pgm.WorkflowStatus) = 'LIVE' and upper(pg.WorkflowStatus) = 'LIVE' 
			and 	upper(c.WorkflowStatus) = 'LIVE' and upper(a.WorkflowStatus) = 'LIVE'
			and	pgm.ActiveFlag = 1 and pg.ActiveFlag = 1 and c.ActiveFlag = 1 and  a.ActiveFlag = 1
			order by c.ColumnNumber asc

			return 1
		end
		else
		begin
			print 'The LIVE tables must exist.'
			return 0
		end
	end
	else
	begin

		if (dbo.fn__TableExists('tblProductGrid') > 0 AND
			dbo.fn__TableExists('tblProductGridModule') > 0 AND
			dbo.fn__TableExists('tblProductGridColDef') > 0 AND
			dbo.fn__TableExists('tblProductAttributeType') > 0)

		begin
			select 	pg.ProductGridID,
				pgm.ProductGridTitle, 
				pg.ProductGridName,
				a.AttribTypeID,
				a.AttribName,
				c.ColumnNumber
			from 	tblProductGridModule pgm,
				tblProductGrid pg,
				tblProductGridColDef c,
				tblProductAttributeType a
			where	pgm.ProductGridID = pg.ProductGridID
			and	pg.ProductGridID = c.ProductGridID
			and	a.AttribTypeID = c.AttribTypeID
			and	pg.ProductGridID = @gridID
			and	c.MarkedForDeletion = 0
			order by c.ColumnNumber	asc

		end
	end
end

end