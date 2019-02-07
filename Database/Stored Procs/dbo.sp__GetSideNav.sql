create PROCEDURE [dbo].[sp__GetSideNav] @BusId INT = 0
	,@MktId INT = 0
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/25/2006

purpose: To return the navigational elements for a particular business unit. The information listed in this resultset is 
	somewhat denormalized so we can work better with it from the web application.		

parameters:
	@BusID int - Business Unit Id to get side navigation for
	@LiveMode bit - 0/1 to indicate whether we need to pull render the side navigation for the LIVE website or via the CMS

script syntax usage:
	exec sp__GetSideNav 1,0 (gets the side navigation for the Petroferm Homepage in the CMS instance.
	exec sp__GetSideNav 1,1 (gets the same Petroferm Homepage side navigation in the LIVE instance.

history:
	Brian Gaines (11/25/2006) - Created initial stored procedure
*/
	IF (@LiveMode = 1)
	BEGIN
		IF (
				dbo.fn__TableExists('tblSideNav_LIVE') > 0
				AND dbo.fn__TableExists('tblSideNavProdCategory_LIVE') > 0
				AND dbo.fn__TableExists('tblSideNavSection_LKP') > 0
				AND dbo.fn__TableExists('tblUrlRewrite_LIVE') > 0
				)
		BEGIN
			IF (@MktId = 0)
			BEGIN
				SELECT n.ID
					,n.ProdCatID
					,n.Title
					,n.[Description]
					,n.BusinessUnitID
					,n.MarketID
					,n.URL
					,n.ItemOrder
					,n.SectionID
					,s.SectionName
					,s.SectionOrder
					,pc.CategoryName
					,pc.CategoryOrder
					,n.PageID
					,url.UrlFriendlyName
				FROM tblSideNav_LIVE n
				LEFT JOIN tblSideNavSection_LKP s ON n.SectionID = s.SectionID
				LEFT JOIN tblSideNavProdCategory_LIVE pc ON n.ProdCatID = pc.ProdCatID
				LEFT JOIN tblUrlRewrite_LIVE url ON n.PageId = url.PageId
				WHERE n.BusinessUnitID = @BusId
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(n.PublishDate)
						AND dbo.fn__GetDateOnly(n.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pc.PublishDate)
						AND dbo.fn__GetDateOnly(pc.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(url.PublishDate)
						AND dbo.fn__GetDateOnly(url.ExpirationDate)
					AND upper(n.WorkflowStatus) = 'LIVE'
					AND upper(pc.WorkflowStatus) = 'LIVE'
					AND upper(url.WorkflowStatus) = 'LIVE'
					AND pc.ActiveFlag = 1
					AND n.ActiveFlag = 1
					AND s.ActiveFlag = 1
					AND url.ActiveFlag = 1
				ORDER BY s.SectionOrder
					,pc.CategoryOrder
					,n.ItemOrder
			END
			ELSE
			BEGIN
				SELECT n.ID
					,n.ProdCatID
					,n.Title
					,n.[Description]
					,n.BusinessUnitID
					,n.MarketID
					,n.URL
					,n.ItemOrder
					,n.SectionID
					,s.SectionName
					,s.SectionOrder
					,pc.CategoryName
					,pc.CategoryOrder
					,n.PageID
					,url.UrlFriendlyName
				FROM tblSideNav_LIVE n
				LEFT JOIN tblSideNavSection_LKP s ON n.SectionID = s.SectionID
				LEFT JOIN tblSideNavProdCategory_LIVE pc ON n.ProdCatID = pc.ProdCatID
				LEFT JOIN tblUrlRewrite_LIVE url ON n.PageId = url.PageId
				WHERE n.BusinessUnitID = @BusId
					AND n.MarketId IN (
						0
						,@MktId
						)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(n.PublishDate)
						AND dbo.fn__GetDateOnly(n.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pc.PublishDate)
						AND dbo.fn__GetDateOnly(pc.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(url.PublishDate)
						AND dbo.fn__GetDateOnly(url.ExpirationDate)
					AND upper(n.WorkflowStatus) = 'LIVE'
					AND upper(pc.WorkflowStatus) = 'LIVE'
					AND upper(url.WorkflowStatus) = 'LIVE'
					AND pc.ActiveFlag = 1
					AND n.ActiveFlag = 1
					AND s.ActiveFlag = 1
					AND url.ActiveFlag = 1
				ORDER BY s.SectionOrder
					,pc.CategoryOrder
					,n.ItemOrder
			END
		END
		ELSE
		BEGIN
			PRINT 'You indicated that you wanted to render the side navigation for the LIVE website; however, the LIVE website tables do not exist.'

			RETURN 0
		END
	END
	ELSE
	BEGIN
		IF (
				dbo.fn__TableExists('tblSideNav') > 0
				AND dbo.fn__TableExists('tblSideNavProdCategory') > 0
				AND dbo.fn__TableExists('tblSideNavSection_LKP') > 0
				AND dbo.fn__TableExists('tblUrlRewrite') > 0
				)
		BEGIN
			SELECT n.ID
				,n.ProdCatID
				,n.Title
				,n.[Description]
				,n.BusinessUnitID
				,n.MarketID
				,n.URL
				,n.ItemOrder
				,n.SectionID
				,s.SectionName
				,s.SectionOrder
				,pc.CategoryName
				,pc.CategoryOrder
				,n.PageId
				,url.UrlFriendlyName
				,n.PublishDate AS 'NAV_PublishDate'
				,n.ExpirationDate AS 'NAV_ExpirationDate'
				,pc.PublishDate AS 'PC_PublishDate'
				,pc.ExpirationDate AS 'PC_ExpirationDate'
				,n.WorkflowStatus AS 'NAV_WorkflowStatus'
				,pc.WorkflowStatus AS 'PC_WorkflowStatus'
			FROM tblSideNav n
			LEFT JOIN tblSideNavSection_LKP s ON n.SectionID = s.SectionID
			LEFT JOIN tblSideNavProdCategory pc ON n.ProdCatID = pc.ProdCatID
			LEFT JOIN tblUrlRewrite url ON n.PageId = url.PageId
			WHERE n.BusinessUnitID = @BusId
				AND pc.ActiveFlag = 1
				AND n.ActiveFlag = 1
				AND s.ActiveFlag = 1
				AND url.ActiveFlag = 1
			ORDER BY s.SectionOrder
				,pc.CategoryOrder
				,n.ItemOrder

			RETURN 1
		END
		ELSE
		BEGIN
			PRINT 'You indicated that you wanted to render the side navigation from the CMS tables; however, the CMS tables do not exist.'

			RETURN 0
		END
	END
END