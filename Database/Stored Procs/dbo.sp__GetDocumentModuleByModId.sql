create PROCEDURE [dbo].[sp__GetDocumentModuleByModId] @ModId INT = 0
	,@LiveMode BIT = 1
AS
/*
created by: Kelly Roe
created on: 12/24/2006
purpose:
	Get a document module

history:
	Kelly Roe    (12/24/2006) - created initial procedure
*/
BEGIN
	IF (@ModId = 0)
	BEGIN
		PRINT 'A module id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			-- we do not check the business unit's status in the context of the live website because 
			-- we would not be calling this procedure if we weren't ALREADY in an active business unit
			IF (
					dbo.fn__TableExists('tblDocumentModule_LIVE') > 0
					AND dbo.fn__TableExists('tblDocumentModuleReln_LIVE') > 0
					AND dbo.fn__TableExists('tblDocument_LIVE') > 0
					)
			BEGIN
				SELECT dmr.DocumentModuleRelnID AS 'DM_DocumentModuleRelnID'
					,dmr.DocumentID AS 'DM_DocumentID'
					,dmr.LinkText AS 'DM_LinkText'
					,dmr.SectionID AS 'DM_SectionID'
					,dmr.PublishDate AS 'DM_PublishDate'
					,dmr.ExpirationDate AS 'DM_ExpirationDate'
					,dmr.WorkflowStatus AS 'DM_WorkflowStatus'
					,dmr.LastModifiedDate AS 'DM_LastModDate'
					,dmr.LastModifiedBy AS 'DM_LastModBy'
					,dmr.ActiveFlag AS 'DM_ActiveFlag'
					,dmr.MarkedForDeletion AS 'DM_MarkedForDeletion'
					,CASE 
						WHEN dmr.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'DM_FmtMarkedForDeletion'
					,dmr.DeploymentJobID AS 'DM_JobId'
					,djdmr.JobName AS 'DM_JobName'
					,djdmr.JobDescription AS 'DM_JobDescription'
					,udmr.FirstName + ' ' + udmr.LastName AS 'DM_LastModByName'
					,d.ProductID AS 'D_ProductID'
					,d.RegionID AS 'D_RegionID'
					,d.DocTitle AS 'D_DocTitle'
					,d.DocPath AS 'D_DocPath'
					,d.ContentType AS 'D_ContentType'
					,d.DocumentType AS 'D_DocumentType'
					,d.UploadDate AS 'D_UploadDate'
					,d.PublishDate AS 'D_PublishDate'
					,d.ExpirationDate AS 'D_ExpirationDate'
					,d.WorkflowStatus AS 'D_WorkflowStatus'
					,d.LastModifiedDate AS 'D_LastModDate'
					,d.LastModifiedBy AS 'D_LastModBy'
					,d.ActiveFlag AS 'D_ActiveFlag'
					,d.MarkedForDeletion AS 'D_MarkedForDeletion'
					,CASE 
						WHEN d.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'D_FmtMarkedForDeletion'
					,d.DeploymentJobID AS 'D_JobId'
					,djd.JobName AS 'D_JobName'
					,djd.JobDescription AS 'D_JobDescription'
					,ud.FirstName + ' ' + ud.LastName AS 'D_LastModByName'
				FROM tblDocumentModuleReln_LIVE dmr
				INNER JOIN tblDocument_LIVE d ON dmr.DocumentID = d.DocumentID
				LEFT JOIN tblDeploymentJobs djd ON d.DeploymentJobId = djd.DeploymentJobId
				LEFT JOIN tblDeploymentJobs djdmr ON dmr.DeploymentJobId = djdmr.DeploymentJobId
				LEFT JOIN tblAppUser ud ON d.LastModifiedBy = ud.AppUserId
				LEFT JOIN tblAppUser udmr ON dmr.LastModifiedBy = udmr.AppUserId
				INNER JOIN tblPageModuleReln pm ON pm.SourceId = dmr.DocumentModuleRelnID
				WHERE dmr.DocumentModuleRelnID = @ModId
					AND UPPER(pm.SourceName) = 'DOCUMENT'
					AND pm.ActiveFlag = 1
					AND dmr.ActiveFlag = 1
					AND d.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pm.PublishDate)
						AND dbo.fn__GetDateOnly(pm.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(dmr.PublishDate)
						AND dbo.fn__GetDateOnly(dmr.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(d.PublishDate)
						AND dbo.fn__GetDateOnly(d.ExpirationDate)
					AND UPPER(dmr.WorkflowStatus) = 'LIVE'
					AND UPPER(d.WorkflowStatus) = 'LIVE'

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
					dbo.fn__TableExists('tblDocumentModule') > 0
					AND dbo.fn__TableExists('tblDocument') > 0
					)
			BEGIN
				SELECT dmr.DocumentModuleRelnID AS 'DM_DocumentModuleRelnID'
					,dmr.DocumentID AS 'DM_DocumentID'
					,dmr.LinkText AS 'DM_LinkText'
					,dmr.SectionID AS 'DM_SectionID'
					,dmr.PublishDate AS 'DM_PublishDate'
					,dmr.ExpirationDate AS 'DM_ExpirationDate'
					,dmr.WorkflowStatus AS 'DM_WorkflowStatus'
					,dmr.LastModifiedDate AS 'DM_LastModDate'
					,dmr.LastModifiedBy AS 'DM_LastModBy'
					,dmr.ActiveFlag AS 'DM_ActiveFlag'
					,dmr.MarkedForDeletion AS 'DM_MarkedForDeletion'
					,CASE 
						WHEN dmr.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'DM_FmtMarkedForDeletion'
					,dmr.DeploymentJobID AS 'DM_JobId'
					,djdmr.JobName AS 'DM_JobName'
					,djdmr.JobDescription AS 'DM_JobDescription'
					,udmr.FirstName + ' ' + udmr.LastName AS 'DM_LastModByName'
					,d.ProductID AS 'D_ProductID'
					,d.RegionID AS 'D_RegionID'
					,d.DocTitle AS 'D_DocTitle'
					,d.DocPath AS 'D_DocPath'
					,d.ContentType AS 'D_ContentType'
					,d.DocumentType AS 'D_DocumentType'
					,d.UploadDate AS 'D_UploadDate'
					,d.PublishDate AS 'D_PublishDate'
					,d.ExpirationDate AS 'D_ExpirationDate'
					,d.WorkflowStatus AS 'D_WorkflowStatus'
					,d.LastModifiedDate AS 'D_LastModDate'
					,d.LastModifiedBy AS 'D_LastModBy'
					,d.ActiveFlag AS 'D_ActiveFlag'
					,d.MarkedForDeletion AS 'D_MarkedForDeletion'
					,CASE 
						WHEN d.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'D_FmtMarkedForDeletion'
					,d.DeploymentJobID AS 'D_JobId'
					,djd.JobName AS 'D_JobName'
					,djd.JobDescription AS 'D_JobDescription'
					,ud.FirstName + ' ' + ud.LastName AS 'D_LastModByName'
					,pm.PageModuleRelnID
					,pm.ModuleOrder
					,pm.ShowTitle
				FROM tblDocumentModuleReln dmr
				INNER JOIN tblDocument d ON dmr.DocumentID = d.DocumentID
				LEFT JOIN tblDeploymentJobs djd ON d.DeploymentJobId = djd.DeploymentJobId
				LEFT JOIN tblDeploymentJobs djdmr ON dmr.DeploymentJobId = djdmr.DeploymentJobId
				LEFT JOIN tblAppUser ud ON d.LastModifiedBy = ud.AppUserId
				LEFT JOIN tblAppUser udmr ON dmr.LastModifiedBy = udmr.AppUserId
				INNER JOIN tblPageModuleReln pm ON pm.SourceId = dmr.DocumentModuleRelnID
				WHERE dmr.DocumentModuleRelnID = @ModId
					AND UPPER(pm.SourceName) IN ('DOCUMENT')
					AND pm.ActiveFlag = 1
					AND dmr.ActiveFlag = 1
					AND d.ActiveFlag = 1

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