create PROCEDURE [dbo].[sp__GetPageModulesByBUForCopy] @BusUnitID INT
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/10/2006
purpose:
	Returns a list of page modules that can be copied --
	only the Content, Side Content, Header Side Content, Product Blurb types

history:
	Kelly Roe   (12/10/2006) - created initial procedure
	Kelly Roe   (01/09/2007) - added market to dropdown text 
*/
	-- get Content module info
	SELECT pmr.SourceID
		,pmr.SourceName
		,cm.Title AS ModuleTitle
		,pmr.SourceName + '|' + CAST(pmr.SourceID AS VARCHAR(10)) AS DropdownValue
		,CASE 
			WHEN m.MarketName IS NULL
				THEN pmr.SourceName + ' > ' + cm.Title
			ELSE pmr.SourceName + ' > ' + cm.Title + ' (' + m.MarketName + ')'
			END AS 'DropdownText'
	FROM tblPageModuleReln pmr
	INNER JOIN tblContentModule cm ON pmr.SourceID = cm.ContentID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
		AND p.BusinessUnitID = @BusUnitID
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
		,CASE 
			WHEN m.MarketName IS NULL
				THEN pmr.SourceName + ' > ' + hscm.Title
			ELSE pmr.SourceName + ' > ' + hscm.Title + ' (' + m.MarketName + ')'
			END AS 'DropdownText'
	FROM tblPageModuleReln pmr
	INNER JOIN tblHeaderSideContentModule hscm ON pmr.SourceID = hscm.HeaderSideContentModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
		AND p.BusinessUnitID = @BusUnitID
	LEFT JOIN tblMarket m ON p.MarketID = m.MarketID
	WHERE pmr.ActiveFlag = 1
		AND pmr.SourceName = 'HEADER SIDE CONTENT'
	-- get Product Blurb info
	
	UNION
	
	SELECT pmr.SourceID
		,pmr.SourceName
		,pbm.Title AS ModuleTitle
		,pmr.SourceName + '|' + CAST(pmr.SourceID AS VARCHAR(10)) AS DropdownValue
		,CASE 
			WHEN m.MarketName IS NULL
				THEN pmr.SourceName + ' > ' + pbm.Title
			ELSE pmr.SourceName + ' > ' + pbm.Title + ' (' + m.MarketName + ')'
			END AS DropdownText
	FROM tblPageModuleReln pmr
	INNER JOIN tblProductBlurbModule pbm ON pmr.SourceID = pbm.ProductBlurbModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
		AND p.BusinessUnitID = @BusUnitID
	LEFT JOIN tblMarket m ON p.MarketID = m.MarketID
	WHERE pmr.ActiveFlag = 1
		AND pmr.SourceName = 'PRODUCT BLURB'
	ORDER BY SourceName ASC
		,ModuleTitle ASC
END