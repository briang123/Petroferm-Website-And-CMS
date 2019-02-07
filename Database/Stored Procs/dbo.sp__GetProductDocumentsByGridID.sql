







--sp__GetProductDocumentsByGridID 1, 0
CREATE        PROC sp__GetProductDocumentsByGridID
	@GridID int = null,
	@LiveMode bit = 1
as
begin

/*
created by: Brian Gaines
created on: 11/23/2006
purpose:
	Returns the list of documents that get linked to from the product grid
	
history:
	Brian Gaines (11/23/2006) - created initial procedure
	Brian Gaines (12/15/2006) - corrected the fact that we were setting the productid = @gridid
	Kelly Roe    (12/28/2006) - took out the attrib type/value constraint -- if the attrib is
				    defined as a col in the grid, grab docs for all products defined
				    as rows

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
		if (dbo.fn__TableExists('tblProduct_LIVE') > 0 AND
			dbo.fn__TableExists('tblRegion_LIVE') > 0 AND
			dbo.fn__TableExists('tblDocument') > 0)

		begin
			select 	p.ProductID,
				p.ProductName,
				d.DocumentID,
				d.DocTitle,
				d.DocPath,
				d.ContentType,
				d.DocumentType,
				d.RegionID,
				r.RegionName
			from	tblProduct_LIVE p,
				tblDocument d,
				tblRegion_LIVE r,
				tblProductGridRowDef_LIVE rd
			where	d.ProductID = p.ProductID
			and	d.RegionID = r.RegionID
			and	p.ProductID = rd.ProductID
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(p.PublishDate) and 	dbo.fn__GetDateOnly(p.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(d.PublishDate) and dbo.fn__GetDateOnly(d.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(r.PublishDate) and dbo.fn__GetDateOnly(r.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(rd.PublishDate) and dbo.fn__GetDateOnly(rd.ExpirationDate)
			and 	upper(p.WorkflowStatus) = 'LIVE' 
			and 	upper(d.WorkflowStatus) = 'LIVE' and upper(r.WorkflowStatus) = 'LIVE' 
			and upper(rd.WorkflowStatus) = 'LIVE'
			and	p.ActiveFlag = 1 and d.ActiveFlag = 1 
			and 	r.ActiveFlag = 1 and rd.ActiveFlag = 1
			and	rd.ProductGridID = @GridID
		end
		else
		begin
			print 'The LIVE tables must exist.'
			return 0
		end
	end
	else
	begin
		if (dbo.fn__TableExists('tblProduct') > 0 AND
			dbo.fn__TableExists('tblRegion') > 0 AND
			dbo.fn__TableExists('tblDocument') > 0)

		begin

			select 	p.ProductID,
				p.ProductName,
				d.DocumentID,
				d.DocTitle,
				d.DocPath,
				d.ContentType,
				d.DocumentType,
				d.RegionID,
				r.RegionName
			from 	tblRegion r,
				tblDocument d,
				tblProduct p,
				tblProductGridRowDef rd
			where	d.ProductID = p.ProductID
			and	d.RegionID = r.RegionID
			and	p.ProductID = rd.ProductID
			and	rd.ProductGridID = @GridID

/*
			select 	p.ProductID,
				p.ProductName,
				a.AttribTypeID,
				a.AttribName,
				d.DocumentID,
				d.DocTitle,
				d.DocPath,
				d.ContentType,
				d.DocumentType,
				d.RegionID,
				r.RegionName
			from	tblProductAttributeType a,
				tblProductAttributeReln ar,
				tblProduct p,
				tblDocument d,
				tblRegion r
			where	ar.AttribTypeID = a.AttribTypeID
			and	ar.ProductID = p.ProductID
			and	d.ProductID = p.ProductID
			and	d.RegionID = r.RegionID
			and	p.ProductID = @GridID
			and	upper(a.AttribName) = 'DATASHEETS'
*/
		end
	end
  end

end