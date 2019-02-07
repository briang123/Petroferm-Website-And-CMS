create PROCEDURE [dbo].[sp__GetImageModuleByModId] @ModId INT = 0
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 1x/xx/2006
purpose:
	Get information about an image module
history:
	Brian Gaines (1x/xx/2006) - Created initial procedure
	Kelly Roe    (12/31/2006) - Add columns to CMS query to handle petroferm home page (task #56)
	Kelly Roe    (01/06/2007) - added related image mod id
*/
	IF (@ModId = 0)
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
					dbo.fn__TableExists('tblImageModule_LIVE') > 0
					AND dbo.fn__TableExists('tblImage_LIVE') > 0
					)
			BEGIN
				SELECT im.ImageModuleID AS 'IM_ModuleID'
					,im.ImageID AS 'IM_ImageID'
					,im.ImageType AS 'IM_ImageType'
					,im.ImageOrder AS 'IM_Order'
					,im.PublishDate AS 'IM_PublishDate'
					,im.ExpirationDate AS 'IM_ExpirationDate'
					,im.WorkflowStatus AS 'IM_WorkflowStatus'
					,im.LastModifiedDate AS 'IM_LastModDate'
					,im.LastModifiedBy AS 'IM_LastModBy'
					,im.ActiveFlag AS 'IM_ActiveFlag'
					,im.MarkedForDeletion AS 'IM_MarkedForDeletion'
					,CASE 
						WHEN im.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'IM_FmtMarkedForDeletion'
					,im.DeploymentJobID AS 'IM_JobId'
					,jim.JobName AS 'IM_JobName'
					,jim.JobDescription AS 'IM_JobDescription'
					,uim.FirstName + ' ' + uim.LastName AS 'IM_LastModByName'
					,i.ImagePath AS 'I_Path'
					,i.Alt AS 'I_Alt'
					,i.Width AS 'I_Width'
					,i.Height AS 'I_Height'
					,i.PublishDate AS 'I_PublishDate'
					,i.ExpirationDate AS 'I_ExpirationDate'
					,i.WorkflowStatus AS 'I_WorkflowStatus'
					,i.LastModifiedDate AS 'I_LastModDate'
					,i.LastModifiedBy AS 'I_LastModBy'
					,i.ActiveFlag AS 'I_ActiveFlag'
					,i.MarkedForDeletion AS 'I_MarkedForDeletion'
					,CASE 
						WHEN i.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'I_FmtMarkedForDeletion'
					,i.DeploymentJobID AS 'I_JobId'
					,ji.JobName AS 'I_JobName'
					,ji.JobDescription AS 'I_JobDescription'
					,ui.FirstName + ' ' + ui.LastName AS 'I_LastModByName'
				FROM tblImageModule_LIVE im
				INNER JOIN tblImage_LIVE i ON im.ImageID = i.ImageID
				LEFT JOIN tblDeploymentJobs ji ON i.DeploymentJobId = ji.DeploymentJobId
				LEFT JOIN tblDeploymentJobs jim ON im.DeploymentJobId = jim.DeploymentJobId
				LEFT JOIN tblAppUser ui ON i.LastModifiedBy = ui.AppUserId
				LEFT JOIN tblAppUser uim ON im.LastModifiedBy = uim.AppUserId
				WHERE im.ImageModuleId = @ModId
					AND im.ActiveFlag = 1
					AND i.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(im.PublishDate)
						AND dbo.fn__GetDateOnly(im.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(i.PublishDate)
						AND dbo.fn__GetDateOnly(i.ExpirationDate)
					AND UPPER(im.WorkflowStatus) = 'LIVE'
					AND UPPER(i.WorkflowStatus) = 'LIVE'
					AND UPPER(im.ImageType) IN (
						'NAVIGATION ON'
						,'NAVIGATION OFF'
						,'HEADER'
						,'HEADER IMAGE'
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
		ELSE -- cms query
		BEGIN
			IF (
					dbo.fn__TableExists('tblImageModule') > 0
					AND dbo.fn__TableExists('tblImage') > 0
					)
			BEGIN
				SELECT im.ImageModuleID AS 'IM_ModuleID'
					,im.ImageID AS 'IM_ImageID'
					,im.ImageType AS 'IM_ImageType'
					,im.ImageOrder AS 'IM_Order'
					,im.PublishDate AS 'IM_PublishDate'
					,im.ExpirationDate AS 'IM_ExpirationDate'
					,im.WorkflowStatus AS 'IM_WorkflowStatus'
					,im.LastModifiedDate AS 'IM_LastModDate'
					,im.LastModifiedBy AS 'IM_LastModBy'
					,im.ActiveFlag AS 'IM_ActiveFlag'
					,im.MarkedForDeletion AS 'IM_MarkedForDeletion'
					,CASE 
						WHEN im.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'IM_FmtMarkedForDeletion'
					,im.DeploymentJobID AS 'IM_JobId'
					,jim.JobName AS 'IM_JobName'
					,jim.JobDescription AS 'IM_JobDescription'
					,uim.FirstName + ' ' + uim.LastName AS 'IM_LastModByName'
					,i.ImagePath AS 'I_Path'
					,i.Alt AS 'I_Alt'
					,i.Width AS 'I_Width'
					,i.Height AS 'I_Height'
					,i.PublishDate AS 'I_PublishDate'
					,i.ExpirationDate AS 'I_ExpirationDate'
					,i.WorkflowStatus AS 'I_WorkflowStatus'
					,i.LastModifiedDate AS 'I_LastModDate'
					,i.LastModifiedBy AS 'I_LastModBy'
					,i.ActiveFlag AS 'I_ActiveFlag'
					,i.MarkedForDeletion AS 'I_MarkedForDeletion'
					,CASE 
						WHEN i.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'I_FmtMarkedForDeletion'
					,i.DeploymentJobID AS 'I_JobId'
					,ji.JobName AS 'I_JobName'
					,ji.JobDescription AS 'I_JobDescription'
					,ui.FirstName + ' ' + ui.LastName AS 'I_LastModByName'
					,pm.PageModuleRelnID
					,pm.ModuleOrder
					,pm.ShowTitle
					,im.RelatedImageModuleID
					,-- added 1/6/07 kr
					-- added 12/31/2006 kr
					im.WelcomeImageID
					,im.WelcomeTitle
					,im.WelcomeLinkPageID
					,im.WelcomeLinkPageIDList
					,im.WelcomeLinkTextList
					,iw.ImageID AS Welcome_ImageID
					,iw.ImagePath AS Welcome_ImagePath
					,iw.Alt AS Welcome_Alt
					,iw.Width AS Welcome_Width
					,iw.Height AS Welcome_Height
				FROM tblImageModule im
				INNER JOIN tblImage i ON im.ImageID = i.ImageID
				LEFT JOIN tblImage iw ON im.WelcomeImageID = iw.ImageID
				LEFT JOIN tblDeploymentJobs ji ON i.DeploymentJobId = ji.DeploymentJobId
				LEFT JOIN tblDeploymentJobs jim ON im.DeploymentJobId = jim.DeploymentJobId
				LEFT JOIN tblAppUser ui ON i.LastModifiedBy = ui.AppUserId
				LEFT JOIN tblAppUser uim ON im.LastModifiedBy = uim.AppUserId
				INNER JOIN tblPageModuleReln pm ON pm.SourceId = im.ImageModuleId
				WHERE im.ImageModuleId = @ModId
					AND UPPER(pm.SourceName) IN (
						'NAVIGATION ON'
						,'NAVIGATION OFF'
						,'HEADER'
						,'HEADER IMAGE'
						,'NAV ON IMAGE'
						,'NAV OFF IMAGE'
						,'HEADER SIDE CONTENT IMAGE'
						)
					AND pm.ActiveFlag = 1
					AND im.ActiveFlag = 1
					AND i.ActiveFlag = 1

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