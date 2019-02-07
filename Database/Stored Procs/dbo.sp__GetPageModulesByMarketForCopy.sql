create PROCEDURE [dbo].[sp__GetPageModulesByMarketForCopy] @MarketID INT
AS
BEGIN
	/*
created by: Kelly Roe
created on: 01/09/2006
purpose:
	Returns a list of page modules that can be copied (by market) --
	only the Content, Side Content, Header Side Content, Product Blurb types

history:
	Kelly Roe   (01/09/2006) - created initial procedure
*/
	-- get Content module info
	SELECT pmr.SourceID
		,pmr.SourceName
		,cm.Title AS ModuleTitle
		,pmr.SourceName + '|' + CAST(pmr.SourceID AS VARCHAR(10)) AS DropdownValue
		,pmr.SourceName + ' > ' + cm.Title AS 'DropdownText'
	FROM tblPageModuleReln pmr
	INNER JOIN tblContentModule cm ON pmr.SourceID = cm.ContentID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
		AND p.MarketID = @MarketID
	LEFT JOIN tblMarket m ON p.MarketID = m.MarketID
	WHERE pmr.ActiveFlag = 1
		AND pmr.SourceName IN (
			'SIDE CONTENT'
			,'CONTENT'
			)
	-- get Header Side Content info 
	
	UNION
	
	SELECT pmr.SourceID
		,pmr.SourceName
		,hscm.Title AS ModuleTitle
		,pmr.SourceName + '|' + CAST(pmr.SourceID AS VARCHAR(10)) AS DropdownValue
		,pmr.SourceName + ' > ' + hscm.Title AS 'DropdownText'
	FROM tblPageModuleReln pmr
	INNER JOIN tblHeaderSideContentModule hscm ON pmr.SourceID = hscm.HeaderSideContentModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
		AND p.MarketID = @MarketID
	LEFT JOIN tblMarket m ON p.MarketID = m.MarketID
	WHERE pmr.ActiveFlag = 1
		AND pmr.SourceName = 'HEADER SIDE CONTENT'
	-- get Product Blurb info
	
	UNION
	
	SELECT pmr.SourceID
		,pmr.SourceName
		,pbm.Title AS ModuleTitle
		,pmr.SourceName + '|' + CAST(pmr.SourceID AS VARCHAR(10)) AS DropdownValue
		,pmr.SourceName + ' > ' + pbm.Title AS DropdownText
	FROM tblPageModuleReln pmr
	INNER JOIN tblProductBlurbModule pbm ON pmr.SourceID = pbm.ProductBlurbModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
		AND p.MarketID = @MarketID
	LEFT JOIN tblMarket m ON p.MarketID = m.MarketID
	WHERE pmr.ActiveFlag = 1
		AND pmr.SourceName = 'PRODUCT BLURB'
	ORDER BY SourceName ASC
		,ModuleTitle ASC
END