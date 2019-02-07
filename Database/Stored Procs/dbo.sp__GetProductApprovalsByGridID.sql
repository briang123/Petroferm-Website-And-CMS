








CREATE        PROC sp__GetProductApprovalsByGridID
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
	Kelly Roe    (12/28/2006) - created initial procedure
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
		if (dbo.fn__TableExists('tblProduct_LIVE') > 0)

		begin
			select 	p.ProductID,
				p.ProductName,
				p.ProductApprovals
			from	tblProduct_LIVE p,
				tblProductGridRowDef_LIVE rd
			where	p.ProductID = rd.ProductID
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(p.PublishDate) and 	dbo.fn__GetDateOnly(p.ExpirationDate)
			and	dbo.fn__GetDateOnly(getdate()) 
				between dbo.fn__GetDateOnly(rd.PublishDate) and dbo.fn__GetDateOnly(rd.ExpirationDate)
			and 	upper(p.WorkflowStatus) = 'LIVE' 
			and 	upper(rd.WorkflowStatus) = 'LIVE'
			and	p.ActiveFlag = 1 and rd.ActiveFlag = 1
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

		if (dbo.fn__TableExists('tblProduct') > 0)

		begin
			select 	p.ProductID,
				p.ProductName,
				p.ProductApprovals
			from	tblProduct p,
				tblProductGridRowDef rd
			where	p.ProductID = rd.ProductID
			and	p.ActiveFlag = 1 and rd.ActiveFlag = 1
			and	rd.ProductGridID = @GridID
		end
		else
		begin
			print 'The CMS tables must exist.'
			return 0
		end

		
	end
  end

end