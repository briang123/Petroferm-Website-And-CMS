create PROCEDURE [dbo].[sp__GetImageModule] @PageId INT = 0
	,@LiveMode BIT = 1
AS
BEGIN
	IF (@PageId = 0)
	BEGIN
		PRINT 'A page id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			-- we do not check the business unit's status in the context of the live website because 
			-- we would not be calling this procedure if we weren't ALREADY in an active business unit
			IF (
					dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0
					AND dbo.fn__TableExists('tblImageModule_LIVE') > 0
					AND dbo.fn__TableExists('tblImage_LIVE') > 0
					)
			BEGIN
				SELECT im.ImageModuleID AS 'IM_ModuleID'
					,im.ImageID AS 'IM_ImageID'
					,im.ImageType AS 'IM_ImageType'
					,im.ImageOrder AS 'IM_Order'
					,i.ImagePath AS 'I_Path'
					,i.Alt AS 'I_Alt'
					,i.Width AS 'I_Width'
					,i.Height AS 'I_Height'
				FROM tblPageModuleReln_LIVE pm
				INNER JOIN tblImageModule_LIVE im ON pm.SourceId = im.ImageModuleId
				LEFT JOIN tblImage_LIVE i ON im.ImageID = i.ImageID
				WHERE pm.PageId = @PageID
					AND im.ActiveFlag = 1
					AND i.ActiveFlag = 1
					AND pm.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(im.PublishDate)
						AND dbo.fn__GetDateOnly(im.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(i.PublishDate)
						AND dbo.fn__GetDateOnly(i.ExpirationDate)
					AND UPPER(im.WorkflowStatus) = 'LIVE'
					AND UPPER(i.WorkflowStatus) = 'LIVE'
					AND UPPER(pm.SourceName) IN (
						'HEADER IMAGE'
						,'NAV ON IMAGE'
						,'NAV OFF IMAGE'
						,'HEADER SIDE CONTENT IMAGE'
						)

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'Not all live tables exist'

				RETURN 0
			END
		END
	END
END