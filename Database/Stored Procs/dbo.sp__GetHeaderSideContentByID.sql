create PROCEDURE [dbo].[sp__GetHeaderSideContentByID] @HeaderSideContentModuleID INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 12/03/2006

purpose:


history:
	Brian Gaines (12/03/2006) - created initial procedure
	Kelly Roe    (12/23/2006) - changed it to just send record back, not output parms
				    thought that values were not being returned properly, but 
			            it was not the case and i'm going to defer changing it back
*/
	IF (
			@HeaderSideContentModuleID IS NULL
			OR @HeaderSideContentModuleID = 0
			)
	BEGIN
		PRINT 'An module id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (
				dbo.fn__TableExists('tblHeaderSideContentModule_LIVE') > 0
				AND dbo.fn__TableExists('tblDeploymentJobs') > 0
				AND dbo.fn__TableExists('tblAppUser') > 0
				)
		BEGIN
			IF (@LiveMode = 1)
			BEGIN
				SELECT m.Title
					,m.LineText1
					,m.InternalLink1
					,m.InternalLink1Type
					,m.ExternalLink1
					,m.LineText2
					,m.InternalLink2
					,m.InternalLink2Type
					,m.ExternalLink2
					,m.PublishDate
					,m.ExpirationDate
					,m.WorkflowStatus
					,m.LastModifiedDate
					,m.LastModifiedBy
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,m.ActiveFlag
					,m.MarkedForDeletion
					,CASE 
						WHEN m.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS FmtMarkedForDeletion
					,m.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblHeaderSideContentModule_LIVE m
				LEFT JOIN tblDeploymentJobs j ON m.DeploymentJobId = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON m.LastModifiedBy = u.AppUserId
				WHERE m.ActiveFlag = 1
					AND m.WorkflowStatus = 'LIVE'
					AND m.HeaderSideContentModuleID = @HeaderSideContentModuleID

				RETURN 1
			END
			ELSE -- live mode = 0 (CMS)
			BEGIN
				SELECT m.Title
					,m.LineText1
					,m.InternalLink1
					,m.InternalLink1Type
					,m.ExternalLink1
					,m.LineText2
					,m.InternalLink2
					,m.InternalLink2Type
					,m.ExternalLink2
					,m.PublishDate
					,m.ExpirationDate
					,m.WorkflowStatus
					,m.LastModifiedDate
					,m.LastModifiedBy
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,m.ActiveFlag
					,m.MarkedForDeletion
					,CASE 
						WHEN m.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS FmtMarkedForDeletion
					,m.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblHeaderSideContentModule m
				LEFT JOIN tblDeploymentJobs j ON m.DeploymentJobId = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON m.LastModifiedBy = u.AppUserId
				WHERE m.ActiveFlag = 1
					AND m.HeaderSideContentModuleID = @HeaderSideContentModuleID
			END
		END
		ELSE
		BEGIN
			PRINT 'Missing some tables'

			RETURN 0
		END
	END
END