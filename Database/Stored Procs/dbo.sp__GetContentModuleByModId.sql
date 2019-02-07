create PROCEDURE [dbo].[sp__GetContentModuleByModId] --12, 1
	@ContentId INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 12/03/2006
purpose:
	Return content for a page	

history:
	Brian Gaines (12/03/2006) - created initial procedure
	Kelly Roe    (12/09/2006) - added SIDE CONTENT to source name in where clauses
*/
	IF (
			@ContentId IS NULL
			OR @ContentId = 0
			)
	BEGIN
		PRINT 'A content id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0
					AND dbo.fn__TableExists('tblContentModule_LIVE') > 0
					)
			BEGIN
				SELECT c.ContentId
					,c.Title
					,c.Content
					,pm.SourceName
					,c.PublishDate
					,c.ExpirationDate
					,c.WorkflowStatus
					,c.LastModifiedDate
					,c.LastModifiedBy
					,c.MarkedForDeletion
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,CASE 
						WHEN c.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,pm.PageModuleRelnID
					,pm.ModuleOrder
					,pm.ShowTitle
					,j.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblContentModule_LIVE c
				INNER JOIN tblPageModuleReln_LIVE pm ON pm.SourceId = c.ContentId
				LEFT JOIN tblAppUser u ON c.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON c.DeploymentJobId = j.DeploymentJobId
				WHERE c.ContentId = @ContentId
					AND c.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(c.PublishDate)
						AND dbo.fn__GetDateOnly(c.ExpirationDate)
					AND UPPER(c.WorkflowStatus) = 'LIVE'
					AND UPPER(pm.SourceName) IN (
						'CONTENT'
						,'SIDE CONTENT'
						)
				ORDER BY pm.ModuleOrder ASC
			END
		END
		ELSE
		BEGIN
			IF (
					dbo.fn__TableExists('tblPageModuleReln') > 0
					AND dbo.fn__TableExists('tblContentModule') > 0
					)
			BEGIN
				SELECT c.ContentID
					,c.Title
					,c.Content
					,pm.SourceName
					,c.PublishDate
					,c.ExpirationDate
					,c.WorkflowStatus
					,c.LastModifiedDate
					,c.LastModifiedBy
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,c.MarkedForDeletion
					,CASE 
						WHEN c.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,pm.PageModuleRelnID
					,pm.ModuleOrder
					,pm.ShowTitle
					,j.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblContentModule c
				INNER JOIN tblPageModuleReln pm ON pm.SourceId = c.ContentId
				LEFT JOIN tblAppUser u ON c.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON c.DeploymentJobID = j.DeploymentJobId
				WHERE c.ContentId = @ContentId
					AND c.ActiveFlag = 1
					AND UPPER(pm.SourceName) IN (
						'CONTENT'
						,'SIDE CONTENT'
						)
				ORDER BY pm.ModuleOrder ASC

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'You are missing CMS tables'

				RETURN 0
			END
		END
	END
END