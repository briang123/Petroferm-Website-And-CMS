CREATE   proc sp__GetUrlRewritePath
as
begin
/*
created by: Brian Gaines
created on: 12/01/2006
purpose:
	To get a list of all the URL rewrite mapping filenames for the website

history:
	Brian Gaines (12/01/2006) - created initial procedure
*/
	create table #product_category (
		ID int identity(1,1),
		PageID int null,
		ProdCatID int null,
		CategoryName varchar(50) null,
		Title varchar(100) null
	)

	insert into #product_category (PageID, ProdCatID, CategoryName, Title) 
	select 	p.PageID, pc.ProdCatID, pc.CategoryName, n.Title
	from 	tblSideNav_LIVE n 
	left outer join tblSideNavProdCategory_LIVE pc 
		on n.ProdCatID = pc.ProdCatID
	inner join tblPage_LIVE p 
		on n.PageID = p.PageID
	where dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(pc.PublishDate) and dbo.fn__GetDateOnly(pc.ExpirationDate)
	and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(p.PublishDate) and dbo.fn__GetDateOnly(p.ExpirationDate)
	and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(n.PublishDate) and dbo.fn__GetDateOnly(n.ExpirationDate)
	and	UPPER(pc.WorkflowStatus) = 'LIVE' and UPPER(n.WorkflowStatus) = 'LIVE' and UPPER(p.WorkflowStatus) = 'LIVE' 
	and 	pc.ActiveFlag = 1 and p.ActiveFlag = 1 and n.ActiveFlag = 1 
	and 	n.ProdCatID <> 0

	select 	p.PageID, 
		isnull(p.PageTitle,'') as 'PageTitle',
		p.BusinessUnitID, 
		b.BusinessUnitName,
		isnull(m.MarketID,0) as 'MarketID', 
		isnull(m.MarketName,'') as 'MarketName',
		isnull(t.ProdCatID,0) as 'PC_ProdCatID', 
		isnull(t.CategoryName,'') as 'PC_CategoryName', 
		isnull(t.Title,'') as 'PC_Title',
		isnull(u.UrlFriendlyName,'') as 'UrlFriendlyName',
		isnull(p.PassthroughURL,'') as 'PAGE_PassthroughURL',
		p.PageType,
		isnull(s.SectionID,0) as 'SectionID'
	from 	tblPage_LIVE p 
		left outer join tblUrlRewrite_LIVE u on p.PageID = u.PageID
		left outer join tblBusinessUnit_LIVE b on p.BusinessUnitID = b.BusinessUnitID
		left outer join tblMarket_LIVE m on p.MarketID = m.MarketID
		left outer join tblSideNav_LIVE s on p.PageID = s.PageID
		left outer join #product_category t on p.PageID = t.PageID
	where dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(u.PublishDate) and dbo.fn__GetDateOnly(u.ExpirationDate)
	and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(b.PublishDate) and dbo.fn__GetDateOnly(b.ExpirationDate)
	and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(m.PublishDate) and dbo.fn__GetDateOnly(m.ExpirationDate)
	and	UPPER(u.WorkflowStatus) = 'LIVE' and UPPER(b.WorkflowStatus) = 'LIVE' and UPPER(m.WorkflowStatus) = 'LIVE'
	and 	u.ActiveFlag = 1 and p.ActiveFlag = 1 and b.ActiveFlag = 1 and m.ActiveFlag = 1

	drop table #product_category

end