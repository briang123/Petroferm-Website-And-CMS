create PROCEDURE [dbo].[sp__GetPageByID] @PageId INT = 0
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/29/2006
purpose:
	Return a number of rows depending on the number of page modules defined.

	I've structured the resultset to contain all business unit info 1st, then Market info, then page
	to go with a top-down approach way of thinking. This will most likely return multiple rows; however, 
	which we will handle from the client (we want to save I/O over HTTP since it's slower)

history:
	Brian Gaines (11/29/2006) - Created initial procedure
	Kelly Roe    (12/06/2006) - Updated CMS select for page info
	Brian Gaines (12/14/2006) - Add outer join condition between page and pagemodulereln 
		- if passthrough page, it doesn't have any page module records, so no results were returned; this has been resolved
	Kelly Roe    (12/23/2006) - Added UrlFriendlyName to LIVE query
*/
	IF (@PageId = 0)
	BEGIN
		PRINT 'A page id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblPage_LIVE') > 0
					AND dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
					AND dbo.fn__TableExists('tblMarket_LIVE') > 0
					AND dbo.fn__TableExists('tblImage_LIVE') > 0
					AND dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0
					)
			BEGIN
				SELECT b.BusinessUnitID AS 'BU_Id'
					,b.BusinessUnitName AS 'BU_Name'
					,b.DocAuthorization AS 'BU_DocAuth'
					,b.LogoImageID AS 'BU_LogoID'
					,b.PublishDate AS 'BU_PublishDate'
					,b.ExpirationDate AS 'BU_ExpirationDate'
					,b.ActiveFlag AS 'BU_ActiveFlag'
					,b.WorkflowStatus AS 'BU_WorkflowStatus'
					,bi.ImagePath AS 'BI_ImagePath'
					,bi.Alt AS 'BI_Alt'
					,bi.Width AS 'BI_Width'
					,bi.Height AS 'BI_Height'
					,bi.PublishDate AS 'BI_PublishDate'
					,bi.ExpirationDate AS 'BI_ExpirationDate'
					,bi.ActiveFlag AS 'BI_ActiveFlag'
					,bi.WorkflowStatus AS 'BI_WorkflowStatus'
					,m.MarketID AS 'MKT_Id'
					,m.MarketName AS 'MKT_Name'
					,m.MarketOrder AS 'MKT_Order'
					,m.PublishDate AS 'MKT_PublishDate'
					,m.ExpirationDate AS 'MKT_ExpirationDate'
					,m.ActiveFlag AS 'MKT_ActiveFlag'
					,m.WorkflowStatus AS 'MKT_WorkflowStatus'
					,p.PageId AS 'PG_Id'
					,p.PageType AS 'PG_PageType'
					,p.PageTitle AS 'PG_Title'
					,p.MetaKeywords AS 'PG_MetaKey'
					,p.MetaDescription AS 'PG_MetaDesc'
					,p.PassthroughURL AS 'PG_Passthrough'
					,p.PublishDate AS 'PG_PublishDate'
					,p.ExpirationDate AS 'PG_ExpirationDate'
					,p.ActiveFlag AS 'PG_ActiveFlag'
					,p.WorkflowStatus AS 'PG_WorkflowStatus'
					,u.UrlFriendlyName AS 'URL_FriendlyName'
					,pm.PageModuleRelnID AS 'PM_ModuleId'
					,pm.SourceID AS 'PM_SourceId'
					,pm.SourceName AS 'PM_SourceName'
					,pm.ModuleOrder AS 'PM_ModuleOrder'
					,pm.ShowTitle AS 'PM_ShowTitle'
					,pm.PublishDate AS 'PM_PublishDate'
					,pm.ExpirationDate AS 'PM_ExpirationDate'
					,pm.ActiveFlag AS 'PM_ActiveFlag'
					,pm.WorkflowStatus AS 'PM_WorkflowStatus'
				FROM tblPage_LIVE p
				LEFT JOIN tblUrlRewrite_LIVE u ON p.PageId = u.PageId
				INNER JOIN tblBusinessUnit_LIVE b ON p.BusinessUnitId = b.BusinessUnitID
				LEFT JOIN tblMarket_LIVE m ON p.MarketId = m.MarketId
				LEFT JOIN tblImage_LIVE bi ON b.LogoImageId = bi.ImageId
				LEFT JOIN tblPageModuleReln_LIVE pm ON p.PageId = pm.PageId --, tblImageModule im
					--from	tblPage p, tblBusinessUnit b, tblMarket m, tblImage bi, tblPageModuleReln pm
				WHERE p.PageId = @PageID
					AND b.ActiveFlag = 1
					AND bi.ActiveFlag = 1
					AND m.ActiveFlag = 1
					AND p.ActiveFlag = 1
					AND pm.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(b.PublishDate)
						AND dbo.fn__GetDateOnly(b.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(bi.PublishDate)
						AND dbo.fn__GetDateOnly(bi.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(m.PublishDate)
						AND dbo.fn__GetDateOnly(m.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(p.PublishDate)
						AND dbo.fn__GetDateOnly(p.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pm.PublishDate)
						AND dbo.fn__GetDateOnly(pm.ExpirationDate)
					AND b.WorkflowStatus = 'LIVE'
					AND bi.WorkflowStatus = 'LIVE'
					AND m.WorkflowStatus = 'LIVE'
					AND p.WorkflowStatus = 'LIVE'
					AND pm.WorkflowStatus = 'LIVE'
				--				and	pm.SourceId = im.ImageModuleId 
				ORDER BY pm.ModuleOrder DESC
			END
			ELSE
			BEGIN
				PRINT 'The live tables do not exist.'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			-- CMS information
			SELECT p.PageId
				,p.BusinessUnitID
				,p.MarketID
				,p.PageType
				,p.PageTitle
				,p.MetaKeywords
				,p.MetaDescription
				,p.PassthroughURL
				,p.IsRequired
				,p.IsReadOnly
				,p.PublishDate
				,p.ExpirationDate
				,UPPER(p.WorkflowStatus) AS WorkflowStatus
				,p.LastModifiedDate
				,p.LastModifiedBy
				,u.FirstName + ' ' + u.LastName AS LastModifiedByName
				,p.MarkedForDeletion
				,CASE 
					WHEN p.MarkedForDeletion = 1
						THEN 'Yes'
					ELSE 'No'
					END AS FmtMarkedForDeletion
				,p.DeploymentJobID
				,j.JobName
				,j.JobDescription
				,url.UrlFriendlyName
			FROM tblPage p
			LEFT JOIN tblUrlRewrite url ON p.PageID = url.PageID
			LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserId
			LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobID = j.DeploymentJobId
			WHERE p.PageId = @PageID
				AND p.ActiveFlag = 1
		END
	END
END