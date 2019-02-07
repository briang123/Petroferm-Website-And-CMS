create PROCEDURE [dbo].[sp__GetNavImagesForPetroferm] @LiveMode BIT = 1
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/24/2006
purpose: Retrieve image modules for the top nav for Petroferm

history:
	Kelly Roe    (12/24/2006) - created initial procedure (task #28)
	Kelly Roe    (12/26/2006) - added welcome image columns
*/
	IF (@LiveMode = 1)
	BEGIN
		IF (
				dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
				AND dbo.fn__TableExists('tblPage_LIVE') > 0
				AND dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0
				AND dbo.fn__TableExists('tblImageModule_LIVE') > 0
				AND dbo.fn__TableExists('tblImage_LIVE') > 0
				)
		BEGIN
			SELECT i.ImageID
				,i.ImagePath
				,i.Alt
				,i.Width
				,i.Height
				,im.ImageType
				,im.ImageOrder
				,im.RelatedImageModuleID
				,im.WelcomeImageID
				,im.WelcomeTitle
				,im.WelcomeLinkPageID
				,im.WelcomeLinkPageIDList
				,im.WelcomeLinkTextList
				,iw.ImageID AS Welcome_ImageID
				,iw.ImagePath AS Welcome_ImagePath
				,iw.Alt AS Welcome_Alt
				,iw.Width AS Welcome_Width
				,iw.Height AS Welcome_Height
				,pm.PageModuleRelnId
				,pm.ModuleOrder
				,pm.SourceName
				,pm.SourceId
				,pm.ShowTitle
				,pm.PageId
				,u.UrlFriendlyName AS WelcomeLinkUrlFriendlyName
			FROM tblBusinessUnit_LIVE b
			INNER JOIN tblPage_LIVE p ON p.BusinessUnitID = b.BusinessUnitID
			INNER JOIN tblPageModuleReln_LIVE pm ON p.PageId = pm.PageId
			INNER JOIN tblImageModule_LIVE im ON pm.SourceId = im.ImageModuleId
			INNER JOIN tblImage_LIVE i ON im.ImageId = i.ImageId
			LEFT JOIN tblImage_LIVE iw ON im.WelcomeImageId = iw.ImageId
			LEFT JOIN tblUrlRewrite_LIVE u ON im.WelcomeLinkPageID = u.PageId
			WHERE b.BusinessUnitID = 1
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(p.PublishDate)
					AND dbo.fn__GetDateOnly(p.ExpirationDate)
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(b.PublishDate)
					AND dbo.fn__GetDateOnly(b.ExpirationDate)
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pm.PublishDate)
					AND dbo.fn__GetDateOnly(pm.ExpirationDate)
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(im.PublishDate)
					AND dbo.fn__GetDateOnly(im.ExpirationDate)
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(i.PublishDate)
					AND dbo.fn__GetDateOnly(i.ExpirationDate)
				AND upper(p.WorkflowStatus) = 'LIVE'
				AND upper(b.WorkflowStatus) = 'LIVE'
				AND upper(pm.WorkflowStatus) = 'LIVE'
				AND upper(im.WorkflowStatus) = 'LIVE'
				AND upper(i.WorkflowStatus) = 'LIVE'
				AND b.ActiveFlag = 1
				AND p.ActiveFlag = 1
				AND pm.ActiveFlag = 1
				AND im.ActiveFlag = 1
				AND i.ActiveFlag = 1
				AND UPPER(pm.SourceName) IN (
					'NAV ON IMAGE'
					,'NAV OFF IMAGE'
					,'HEADER IMAGE'
					)
			ORDER BY pm.ModuleOrder

			RETURN 1
		END
		ELSE
		BEGIN
			PRINT 'Missing some live tables.'

			RETURN 0
		END
	END
	ELSE
	BEGIN
		IF (
				dbo.fn__TableExists('tblMarket') > 0
				AND dbo.fn__TableExists('tblPage') > 0
				AND dbo.fn__TableExists('tblPageModuleReln') > 0
				AND dbo.fn__TableExists('tblImageModule') > 0
				AND dbo.fn__TableExists('tblImage') > 0
				)
		BEGIN
			PRINT 'code for cms here'
		END
	END
END