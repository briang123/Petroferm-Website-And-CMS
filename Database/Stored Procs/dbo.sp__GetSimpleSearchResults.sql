create PROCEDURE [dbo].[sp__GetSimpleSearchResults] @Keywords VARCHAR(100) = ''
	,@BusUnitID INT = NULL
AS
BEGIN
	/*
update tblbusinessunit set deploymentjobid = 1 where businessunitid = 1
select * from tblbusinessunit
select * from tblmarket
select * from tblproduct
select * from tblpage
select * from tblurlrewrite
select * from tblsidenav

select pg.PageId, p.ProductId, p.ProductName, p.ProductBlurb
from tblPage pg, tblPageModuleReln pm, tblProductGridModule pgm, tblProductGridRowDef pgrd, tblProduct p
where pg.PageId = pm.PageId
and pm.SourceId = pgm.ProductGridModuleId
and pgm.ProductGridID = pgrd.ProductGridID
and pgrd.ProductID = p.ProductID

	select pg.PageId, p.ProductId, p.ProductName, p.ProductBlurb
	from tblPage pg, tblPageModuleReln pm, tblProductBlurbModule pbm, tblProduct p
	where pg.PageId = pm.PageId
	and pm.SourceId = pbm.ProductBlurbModuleId
	and pbm.SourceId = p.ProductId
	and UPPER(pm.SourceName) = 'PRODUCT BLURB'
	and p.ProductId in (select ProductId from tblproduct where lower(ProductKeywords) like '%hydrex%')

select * from tblProductSearchAttribReln
select * from tblproduct
select * from tblpagemodulereln
select * from tblproductblurbmodule
sp__GetProductsBySearchAttributes 5, 'hydrex', ''
*/
	/*
	get product blurbs (individual) on a page
	get product blurbs (multiple) on a page
	get page based on if product is in product grid
	*/
	--create table #product_pages (PageId int, ProductId int, ProductName varchar(200), ProductBlurb varchar(2000) null)
	--insert into #product_pages 
	-- get product blurbs (individual) on a page
	SELECT pg.PageId
		,pg.PageTitle
		,p.ProductId
		,p.ProductName
		,p.ProductBlurb
		,isnull(url.UrlFriendlyName, '') AS 'UrlFriendlyName'
	FROM tblPage pg
	INNER JOIN tblPageModuleReln pm ON pg.PageId = pm.PageId
	INNER JOIN tblProductBlurbModule pbm ON pm.SourceId = pbm.ProductBlurbModuleId
	INNER JOIN tblProduct p ON pbm.SourceId = p.ProductId
	LEFT JOIN tblUrlRewrite url ON pg.PageId = url.PageId
	WHERE pg.BusinessUnitId = @BusUnitID
		AND UPPER(pm.SourceName) = 'PRODUCT BLURB'
		AND (
			lower(p.ProductKeywords) LIKE '%' + lower(@Keywords) + '%'
			OR lower(p.ProductName) LIKE '%' + lower(@Keywords) + '%'
			OR lower(p.ProductBlurb) LIKE '%' + lower(@Keywords) + '%'
			)
	
	UNION
	
	-- get product blurbs (multiple) on a page
	SELECT pg.PageId
		,pg.PageTitle
		,p.ProductId
		,p.ProductName
		,p.ProductBlurb
		,isnull(url.UrlFriendlyName, '') AS 'UrlFriendlyName'
	FROM tblPage pg
	INNER JOIN tblPageModuleReln pm ON pg.PageId = pm.Pageid
	INNER JOIN tblProductBlurbModule pbm ON pm.SourceId = pbm.ProductBlurbModuleId
	INNER JOIN tblProductBlurbModuleReln pbmr ON pbm.SourceId = pbmr.ProductBlurbModuleId
	INNER JOIN tblProduct p ON pbmr.ProductId = p.ProductId
	LEFT JOIN tblUrlRewrite url ON pg.PageId = url.PageId
	WHERE pg.BusinessUnitId = @BusUnitID
		AND UPPER(pm.SourceName) = 'PRODUCT BLURB'
		AND (
			lower(p.ProductKeywords) LIKE '%' + lower(@Keywords) + '%'
			OR lower(p.ProductName) LIKE '%' + lower(@Keywords) + '%'
			OR lower(p.ProductBlurb) LIKE '%' + lower(@Keywords) + '%'
			)
	
	UNION
	
	-- associate product id with page based on whether it's in a product grid
	SELECT pg.PageId
		,pg.PageTitle
		,p.ProductId
		,p.ProductName
		,p.ProductBlurb
		,isnull(url.UrlFriendlyName, '') AS 'UrlFriendlyName'
	FROM tblPage pg
	INNER JOIN tblPageModuleReln pm ON pg.PageId = pm.PageId
	INNER JOIN tblProductGridModule pgm ON pm.SourceId = pgm.ProductGridModuleId
	INNER JOIN tblProductGridRowDef pgrd ON pgm.ProductGridID = pgrd.ProductGridID
	INNER JOIN tblProduct p ON pgrd.ProductID = p.ProductID
	LEFT JOIN tblUrlRewrite url ON pg.PageId = url.PageId
	WHERE pg.BusinessUnitId = @BusUnitID
		AND UPPER(pm.SourceName) = 'PRODUCT GRID'
		AND (
			lower(p.ProductKeywords) LIKE '%' + lower(@Keywords) + '%'
			OR lower(p.ProductName) LIKE '%' + lower(@Keywords) + '%'
			)
	
	UNION
	
	-- query against the content table since this is where most of our web page contet is located
	--	select pg.PageId, pg.PageTitle, 0, '', substring(c.Content,1,500), isnull(url.UrlFriendlyName,'')
	SELECT pg.PageId
		,pg.PageTitle
		,0
		,''
		,substring(c.Content, 1, 8000)
		,isnull(url.UrlFriendlyName, '')
	FROM tblPage pg
	INNER JOIN tblPageModuleReln pm ON pg.PageId = pm.PageId
	INNER JOIN tblContentModule c ON pm.SourceId = c.ContentID
	LEFT JOIN tblUrlRewrite url ON pg.PageId = url.PageId
	WHERE UPPER(pm.SourceName) = 'CONTENT'
		AND pg.BusinessUnitId = @BusUnitID
		AND lower(substring(c.Content, 1, 8000)) LIKE '%' + lower(@Keywords) + '%'
	ORDER BY p.ProductName ASC
		--select * from #product_pages 
		--drop table #product_pages
END