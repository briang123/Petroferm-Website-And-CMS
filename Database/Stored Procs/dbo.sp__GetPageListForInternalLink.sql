create PROCEDURE [dbo].[sp__GetPageListForInternalLink]
AS
/*
created by: Kelly Roe
created on: 12/10/2006
purpose:
	Return a list of pages for internal link (header side content module)

history:
	Kelly Roe    (12/10/2006) - created initial procedure
	Kelly Roe    (12/13/2006) - added bu name to page title display
	Kelly Roe    (01/01/2007) - added ref= querystring values for passthrough pages
*/
BEGIN
	SELECT p.PageID
		,p.PageTitle
		,CASE 
			WHEN pl.PageID IS NULL
				THEN 'NEW - ' + b.BusinessUnitName + ' - ' + p.PageTitle
			ELSE b.BusinessUnitName + ' - ' + p.PageTitle
			END AS 'PageTitleDisplay'
		,replace(p.PageTitle, '''', '\''') AS 'LinkTitle'
		,
		--		case when p.PageType = 'PASSTHROUGH'
		--		then u.UrlFriendlyName + '?ref=' + cast(p.BusinessUnitID as varchar(4)) + ',' + cast(p.MarketID as varchar(4)) + ',' + cast(p.PageID as varchar(4))
		--		else u.UrlFriendlyName end as 'UrlFriendlyName'
		u.UrlFriendlyName
	FROM tblPage p
	LEFT JOIN tblUrlRewrite u ON p.PageID = u.PageID
	LEFT JOIN tblPage_LIVE pl ON p.PageID = pl.PageID
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitId = b.BusinessUnitId
	WHERE p.ActiveFlag = 1
		AND b.ActiveFlag = 1
	ORDER BY b.BusinessUnitName
		,p.PageTitle ASC
END