



CREATE   proc sp__GetProductGridModule
	@PageId int = 0,
	@LiveMode bit = 1
as
begin
	if (@PageId = 0)
	begin
		print 'A page id is required'
		return 0
	end
	else
	begin
		if (@LiveMode = 1)
		begin

			-- we do not check the business unit's status in the context of the live website because 
			-- we would not be calling this procedure if we weren't ALREADY in an active business unit
			if (dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0 and 
				dbo.fn__TableExists('tblProductGridModule_LIVE') > 0 and
				dbo.fn__TableExists('tblProductGrid_LIVE') > 0 and 
				dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0)
			begin
				select 	pgm.ProductGridModuleID 	as 'PGM_ProductGridModuleID', 
--					pgm.ModuleTypeID		as 'PGM_ModuleTypeID', 
					pgm.ProductGridTitle		as 'PGM_GridTitle', 
					pgm.ProductGridBlurb		as 'PGM_GridBlurb', 
					pgm.ProductGridID		as 'PGM_GridID',
					pg.ProductGridName		as 'PG_GridName'
				from tblPageModuleReln pm, tblProductGridModule pgm, tblProductGrid pg, tblBusinessUnit b
				where pm.PageId = @PageID
				and pm.ActiveFlag = 1 and pgm.ActiveFlag = 1 and pg.ActiveFlag = 1 and b.ActiveFlag = 1
				and dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(pgm.PublishDate) and dbo.fn__GetDateOnly(pgm.ExpirationDate)
				and dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(pg.PublishDate) and dbo.fn__GetDateOnly(pg.ExpirationDate)
				and UPPER(pgm.WorkflowStatus) = 'LIVE' and UPPER(pg.WorkflowStatus) = 'LIVE' and UPPER(b.WorkflowStatus) = 'LIVE'
				and pgm.ProductGridID = pg.ProductGridID
				and pm.SourceId = pgm.ProductGridModuleID
				and b.BusinessUnitID = pg.BusinessUnitID
				and UPPER(pm.SourceName) = 'PRODUCT GRID'
				order by pgm.ModuleOrder asc

				return 1
			end
			else
			begin
				print 'Not all live tables exist'
				return 0
			end
		end
	end
end