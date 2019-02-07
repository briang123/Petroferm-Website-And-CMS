





--sp__GetPageModuleCloneListByBU 4
CREATE       proc sp__GetPageModuleCloneListByBU
	@BusUnitID int
as
begin
/*
created by: Kelly Roe
created on: 12/10/2006
purpose:
	Returns a list of modules to select from to clone, by business unit
	Only Content/Side Content, Header Side Content, and Product Blurbs are cloneable

history:
	Kelly Roe   (12/10/2006) - created initial procedure
*/


	-- get Content module list
	select	pmr.SourceID,
		pmr.SourceName,
		pmr.ModuleOrder,
		cm.Title As ModuleTitle,
		pmr.SourceName + ' > ' + cm.Title As DropdownText 
	from	tblPage p,
		tblPageModuleReln pmr,
		tblContentModule cm
	where	p.BusinessUnitID = @BusUnitID
	and	pmr.PageID = p.PageID
	and	p.ActiveFlag = 1
	and	pmr.SourceID = cm.ContentID
	and	pmr.SourceName in ('SIDE CONTENT', 'CONTENT')

	-- get Header Side Content info 
	union
	select	pmr.SourceID,
		pmr.SourceName,
		pmr.ModuleOrder,
		hscm.Title As ModuleTitle, 
		pmr.SourceName + ' > ' + hscm.Title As DropdownText 
	from	tblPage p,
		tblPageModuleReln pmr,
		tblHeaderSideContentModule hscm
	where	p.BusinessUnitID = @BusUnitID
	and	pmr.PageID = p.PageID
	and	p.ActiveFlag = 1
	and	pmr.SourceID = hscm.HeaderSideContentModuleID
	and	pmr.SourceName = 'HEADER SIDE CONTENT'


	-- get Product Blurb info
	union
	select	pmr.SourceID,
		pmr.SourceName,
		pmr.ModuleOrder,
		pbm.Title As ModuleTitle, 
		pmr.SourceName + ' > ' + pbm.Title As DropdownText
	from	tblPage p,
		tblPageModuleReln pmr,
		tblProductBlurbModule pbm
	where	p.BusinessUnitID = @BusUnitID
	and	pmr.PageID = p.PageID
	and	p.ActiveFlag = 1
	and	pmr.SourceID = pbm.ProductBlurbModuleID
	and	pmr.SourceName = 'PRODUCT BLURB'


	order by SourceName ASC, ModuleTitle ASC
	
end