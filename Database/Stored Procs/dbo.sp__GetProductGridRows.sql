




CREATE      proc sp__GetProductGridRows
	@GridID int = null,
	@LiveMode bit = 1
as
begin

/*
created by: Brian Gaines
created on: 11/23/2006
purpose:
	Returns a list of product grid rows to build a product grid
	
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
			dbo.fn__TableExists('tblProduct_LIVE') > 0 AND
			dbo.fn__TableExists('tblProductGridRowDef_LIVE') > 0 AND
			dbo.fn__TableExists('tblProductAttributeReln_LIVE') > 0 AND
			dbo.fn__TableExists('tblProductAttributeType_LIVE') > 0)
		begin

			select 	p.ProductID,
				p.ProductName,
				p.ProductApprovals,
				a.AttribTypeID,
				a.AttribName,
				ar.AttribValue,
				r.RowNumber
			from 	tblProductGridRowDef_LIVE r,
				tblProductGrid_LIVE pg,
				tblProductAttributeReln_LIVE ar,
				tblProductAttributeType_LIVE a,
				tblProduct_LIVE p
			where	pg.ProductGridID = r.ProductGridID
			and	ar.AttribTypeID = a.AttribTypeID
			and	ar.ProductID = r.ProductID
			and	r.ProductID = p.ProductID
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(r.PublishDate) and dbo.fn__GetDateOnly(r.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(pg.PublishDate) and dbo.fn__GetDateOnly(pg.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(ar.PublishDate) and dbo.fn__GetDateOnly(ar.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(p.PublishDate) and dbo.fn__GetDateOnly(p.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(a.PublishDate) and dbo.fn__GetDateOnly(a.ExpirationDate)
			and 	upper(r.WorkflowStatus) = 'LIVE' and upper(pg.WorkflowStatus) = 'LIVE' 
			and 	upper(ar.WorkflowStatus) = 'LIVE' and upper(p.WorkflowStatus) = 'LIVE'
			and 	upper(a.WorkflowStatus) = 'LIVE' 
			and	r.ActiveFlag = 1 and pg.ActiveFlag = 1 and ar.ActiveFlag = 1 
			and 	p.ActiveFlag = 1 and a.ActiveFlag = 1 
			and	pg.ProductGridID = @GridID
			order by r.RowNumber asc

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
			dbo.fn__TableExists('tblProduct') > 0 AND
			dbo.fn__TableExists('tblProductGridRowDef') > 0 AND
			dbo.fn__TableExists('tblProductAttributeReln') > 0 AND
			dbo.fn__TableExists('tblProductAttributeType') > 0)
		begin
			select 	p.ProductID,
				p.ProductName,
				p.ProductApprovals,
				a.AttribTypeID,
				a.AttribName,
				ar.AttribValue,
				r.RowNumber
			from 	tblProductGridRowDef r,
				tblProductGrid pg,
				tblProductAttributeReln ar,
				tblProductAttributeType a,
				tblProduct p
			where	pg.ProductGridID = r.ProductGridID
			and	ar.AttribTypeID = a.AttribTypeID
			and	ar.ProductID = r.ProductID
			and	r.ProductID = p.ProductID
			and	pg.ProductGridID = @GridID
			and	r.MarkedForDeletion = 0
			order by r.RowNumber asc

			return 1
		end
		else
		begin
			print 'The CMS tables are missing'
			return 0
		end
	end
end

end