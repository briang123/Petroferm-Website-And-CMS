

--sp__GetAdvanceSearchResults 5, 'en-rs', 'HY', '1'
CREATE   proc sp__GetAdvanceSearchResults
	@MarketId int = null,
--	@RegionName varchar(200) = 'en-us',
	@Keywords varchar(100) = null,
	@SearchAttribIdList varchar(300) = ''
as
begin
if (@SearchAttribIdList is null)
	select @SearchAttribIdList = ''
	/*
	get product blurbs (individual) on a page
	get product blurbs (multiple) on a page
	get page based on if product is in product grid
	*/
/*
--create table #product_pages (PageId int, ProductId int, ProductName varchar(200), ProductBlurb varchar(2000) null)

--insert into #product_pages 

	-- get product blurbs (individual) on a page
	select pg.PageId, p.ProductId, p.ProductName, p.ProductBlurb
	from tblPage pg, tblPageModuleReln pm, tblProductBlurbModule pbm, tblProduct p
	where pg.PageId = pm.PageId
	and pm.SourceId = pbm.ProductBlurbModuleId
	and pbm.SourceId = p.ProductId
	and UPPER(pm.SourceName) = 'PRODUCT BLURB'
--	and p.ProductId = @ProductId
	
	union
	
	-- get product blurbs (multiple) on a page
	select pg.PageId, p.ProductId, p.ProductName, p.ProductBlurb
	from tblPage pg, tblPageModuleReln pm, tblProductBlurbModule pbm, tblProductBlurbModuleReln pbmr, tblProduct p
	where pg.PageId = pm.Pageid
	and pm.SourceId = pbm.ProductBlurbModuleId
	and pbm.SourceId = pbmr.ProductBlurbModuleId
	and pbmr.ProductId = p.ProductId
	and UPPER(pm.SourceName) = 'PRODUCT BLURB'
--	and p.ProductId = @ProductId

	union
	
	-- associate product id with page based on whether it's in a product grid
	select pg.PageId, p.ProductId, p.ProductName, p.ProductBlurb
	from tblPage pg, tblPageModuleReln pm, tblProductGridModule pgm, tblProductGridRowDef pgrd, tblProduct p
	where pg.PageId = pm.PageId
	and pm.SourceId = pgm.ProductGridModuleId
	and pgm.ProductGridID = pgrd.ProductGridID
	and pgrd.ProductID = p.ProductID
	and UPPER(pm.SourceName) = 'PRODUCT GRID'
--	and p.ProductId = @ProductId

--select * from #product_pages 
--drop table #product_pages
*/


	-- we will build the document links as part of our search criteria in the web app
	-- by wrapping our product id in a function call to the document in-memory datasource
	select 	distinct(p.ProductId), 
		p.ProductName, 
		p.ProductBlurb, 
		b.DocAuthorization
	from 	tblSearchAttribType s, 
		tblProductSearchAttribReln r, 
		tblProduct p, 
		tblMarket m,
		tblBusinessUnit b/*,
		tblRegion g,
		tblDocument d*/
	where 	s.MarketId = m.MarketId
	and	m.BusinessUnitId = b.BusinessUnitId
	and 	r.SearchAttribTypeID = s.SearchAttribTypeId
	and 	p.ProductId = r.ProductId 
--	and	g.RegionId = d.RegionId
--	and	g.RegionName = @RegionName
	and 	s.MarketId = @MarketId
	and 	s.SearchAttribTypeId in (
			select str 
				from dbo.fn__CharListToTable(@SearchAttribIdList,',')
		)
	and 	(lower(p.ProductKeywords) like '%' + lower(isnull(@Keywords,'')) + '%' 
			or lower(p.ProductName) like '%' + lower(isnull(@Keywords,'')) + '%')
	order by p.ProductName asc

/*
	union
	
	select p.ProductId, p.ProductName, p.ProductBlurb, p.ProductKeywords, 2 as 'Rank', 0 as PageId, '', '' as PageTitle, '' as SearchAttributeName
	from tblproduct p, tblBusinessUnit b, tblMarket
--	where lower(p.ProductKeywords) like '%' + lower(@Keywords) + '%'
	where (lower(p.ProductKeywords) like '%' + lower(@Keywords) + '%' 
		or lower(p.ProductName) like '%' + lower(@Keywords) + '%')
	order by Rank asc, productName asc
*/
end