create PROCEDURE [dbo].[sp__GetPageModulesByJobId] @JobID INT
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/30/2006
purpose:
	Returns a summary list of all modules for a job
	used for the deployment job detail page

history:
	Kelly Roe   (12/30/2006) - created initial procedure
*/
	-- get Content module info
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,cm.Title AS ModuleTitle
		,NULL AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblContentModule cm ON pmr.SourceID = cm.ContentID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName IN (
			'CONTENT'
			,'SIDE CONTENT'
			)
	-- get Header Side Content info 
	
	UNION
	
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,hscm.Title AS ModuleTitle
		,NULL AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblHeaderSideContentModule hscm ON pmr.SourceID = hscm.HeaderSideContentModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName = 'HEADER SIDE CONTENT'
	-- get Product Grid info
	
	UNION
	
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,pgm.ProductGridTitle AS ModuleTitle
		,NULL AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblProductGridModule pgm ON pmr.SourceID = pgm.ProductGridModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName = 'PRODUCT GRID'
	-- get Product Blurb info
	
	UNION
	
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,pbm.Title AS ModuleTitle
		,NULL AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblProductBlurbModule pbm ON pmr.SourceID = pbm.ProductBlurbModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName = 'PRODUCT BLURB'
	-- get Questionnaire info
	
	UNION
	
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,qm.Title AS ModuleTitle
		,NULL AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblQuestionnaireModule qm ON pmr.SourceID = qm.QuestionnaireModuleID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName = 'QUESTIONNAIRE'
	-- get Document module info
	-- we'll also include the doc path of the tblDocument record
	
	UNION
	
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,dmr.LinkText AS ModuleTitle
		,d.DocPath AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblDocumentModuleReln dmr ON pmr.SourceID = dmr.DocumentModuleRelnID
	INNER JOIN tblDocument d ON dmr.DocumentID = d.DocumentID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName = 'DOCUMENT'
	-- get Image module info
	
	UNION
	
	SELECT p.PageTitle
		,pmr.PageModuleRelnID
		,pmr.PageID
		,pmr.SourceID
		,pmr.SourceName
		,pmr.ModuleOrder
		,i.Alt AS ModuleTitle
		,i.ImagePath AS ExtraModuleInfo
		,dbo.fn__GetDateOnly(pmr.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(pmr.ExpirationDate) AS 'ExpirationDate'
		,pmr.WorkflowStatus
		,pmr.LastModifiedDate
		,pmr.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,pmr.MarkedForDeletion
		,CASE 
			WHEN pmr.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,pmr.DeploymentJobID
	FROM tblPageModuleReln pmr
	LEFT JOIN tblAppUser a1 ON pmr.LastModifiedBy = a1.AppUserId
	LEFT JOIN tblDeploymentJobs j ON pmr.DeploymentJobID = j.DeploymentJobID
	INNER JOIN tblImageModule im ON pmr.SourceID = im.ImageModuleID
	INNER JOIN tblImage i ON im.ImageID = i.ImageID
	INNER JOIN tblPage p ON pmr.PageID = p.PageID
	WHERE pmr.DeploymentJobID = @JobID
		AND pmr.ActiveFlag = 1
		AND pmr.SourceName IN (
			'NAV ON IMAGE'
			,'NAV OFF IMAGE'
			,'HEADER IMAGE'
			,'HEADER SIDE CONTENT IMAGE'
			)
	ORDER BY PageTitle ASC
		,ModuleOrder ASC
		,SourceName ASC
		,ModuleTitle ASC
END