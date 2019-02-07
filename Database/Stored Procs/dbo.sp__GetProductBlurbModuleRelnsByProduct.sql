


--sp__GetProductBlurbModuleRelnsByProduct 3, 4, 1
CREATE  PROC sp__GetProductBlurbModuleRelnsByProduct
	@ProductBlurbModuleID int = 0,
	@BusUnitID int = null,
	@Selected bit = 0, -- this is for getting selected/unselected for product
	@LiveMode bit = 0
AS	
BEGIN

/*
created by: Brian Gaines
created on: 12/10/2006

purpose:
	Get list of product blurb module products

history:
	Brian Gaines (12/10/2006) - created initial procedure
	Kelly Roe    (12/10/2006) - took out requirement of prod blurb mod id --
				    we'll want a list of "unselected" products for a new prod blurb
	Brian Gaines (1/1/2007) - added sql for live tables and extra livemode parm
*/

if (@BusUnitID is null or @BusUnitID = 0)
begin
	print 'A business unit id is required'
	return 0
end
else
begin

	if (@LiveMode = 0)
	begin
		if (dbo.fn__TableExists('tblProductBlurbModule') > 0 and 
		    dbo.fn__TableExists('tblProductBlurbModuleReln') > 0)
		begin
	
			if (@Selected = 1) -- get list of selected attribs and include workflow info
			begin
	
	
				select 	p.ProductId,
					p.ProductName
				from	tblProductBlurbModule pbm,
					tblProductBlurbModuleReln pbmr,
					tblProduct p
				where	pbm.ProductBlurbModuleId = @ProductBlurbModuleID
				and 	pbm.SourceId = pbmr.ProductBlurbModuleId
				and	pbmr.MarkedForDeletion = 0
				and	UPPER(pbm.ProductSelection) = 'MULTIPLE'
				and	pbmr.ProductId = p.ProductID
				and	pbm.ActiveFlag = 1 and pbmr.ActiveFlag = 1 and p.ActiveFlag = 1
				order by p.ProductName asc
	
			end
			else
			begin
			
				select 	ProductId, 
					ProductName 
				from 	tblProduct
				where 	BusinessUnitID = @BusUnitID
				and	ProductID not in 
						(select ProductId from tblProductBlurbModuleReln 
							where ProductBlurbModuleId = @ProductBlurbModuleId
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
	else
	begin

		if (dbo.fn__TableExists('tblProductBlurbModule_LIVE') > 0 and 
		    dbo.fn__TableExists('tblProductBlurbModuleReln_LIVE') > 0)
		begin
	
			if (@Selected = 1) -- get list of selected attribs and include workflow info
			begin
	
	
				select 	p.ProductId,
					p.ProductName
				from	tblProductBlurbModule_LIVE pbm,
					tblProductBlurbModuleReln_LIVE pbmr,
					tblProduct_LIVE p
				where	pbm.ProductBlurbModuleId = @ProductBlurbModuleID
				and 	pbm.SourceId = pbmr.ProductBlurbModuleId
				and	pbmr.MarkedForDeletion = 0
				and	UPPER(pbm.ProductSelection) = 'MULTIPLE'
				and	pbmr.ProductId = p.ProductID
				and	pbm.ActiveFlag = 1 and pbmr.ActiveFlag = 1 and p.ActiveFlag = 1
				and	upper(pbm.WorkflowStatus) = 'LIVE' and upper(pbmr.WorkflowStatus) = 'LIVE' and upper(p.WorkflowStatus) = 'LIVE'
				and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(pbm.PublishDate) and dbo.fn__GetDateOnly(pbm.ExpirationDate)
				and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(pbmr.PublishDate) and dbo.fn__GetDateOnly(pbmr.ExpirationDate)
				and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(p.PublishDate) and dbo.fn__GetDateOnly(p.ExpirationDate)
				order by p.ProductName asc
	
			end
			else
			begin
			
				select 	ProductId, 
					ProductName 
				from 	tblProduct_LIVE
				where 	BusinessUnitID = @BusUnitID
				and	upper(WorkflowStatus) = 'LIVE'
				and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(PublishDate) and dbo.fn__GetDateOnly(ExpirationDate)
				and	ProductID not in (	
						select ProductId from tblProductBlurbModuleReln_LIVE 
						where ProductBlurbModuleId = @ProductBlurbModuleId
						and ActiveFlag = 1
						and upper(WorkflowStatus) = 'LIVE' 
						and dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(PublishDate) and dbo.fn__GetDateOnly(ExpirationDate)
						and MarkedForDeletion = 0) 
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

end


END