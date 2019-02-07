create PROCEDURE [dbo].[sp__GetProductsByJobId] @JobId INT
AS
BEGIN
	/*
created by: Brian Gaines
created on: 12/01/2006

purpose:
	Get a list of products (and if anything changed associated with a product) by job
	This is a union query that checks the following tables for job-related items:
	  - tblProduct
	  - tblProductAttribReln
	  - tblProductSearchAttribReln
	  - tblDocument

parameters:
	@JobId - the job

history:
	Brian Gaines (12/01/2006) - created initial procedure
	Kelly Roe    (12/16/2006) - added checks of the prod attrib, search attrib, and doc records for the job
*/
	-- DO WE NEED TO DISPLAY A *VIEW* INTO THE RELATIONSHIP OF A PAGE TO THE CONTENT 
	--(IF CONTENT IS WORKING, SHOULD WE SHOW THAT PAGE IS WORKING?) 
	-- SEE "Petroferm CMS Content Workflow Process" diagram
	-- Get list of records from tblProduct that are part of the job --
	SELECT p.ProductID
		,p.BusinessUnitID
		,b.BusinessUnitName
		,p.ProductName
		,p.ProductKeywords
		,p.ProductBlurb
		,p.ProductApprovals
		,p.PublishDate
		,p.ExpirationDate
		,upper(p.WorkflowStatus) AS 'WorkflowStatus'
		,p.LastModifiedDate
		,p.LastModifiedBy
		,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
		,p.MarkedForDeletion
		,CASE 
			WHEN p.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,p.DeploymentJobID
		,j.JobName
		,j.JobDescription
	FROM tblProduct p
	LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobId = j.DeploymentJobId
	LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserID
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitID = b.BusinessUnitID
	WHERE p.DeploymentJobId = @JobId
		AND p.ActiveFlag = 1
		AND b.ActiveFlag = 1
	
	UNION
	
	-- Get list of records from tblProductAttribReln that are part of the job --
	SELECT p.ProductID
		,p.BusinessUnitID
		,b.BusinessUnitName
		,p.ProductName
		,p.ProductKeywords
		,p.ProductBlurb
		,p.ProductApprovals
		,p.PublishDate
		,p.ExpirationDate
		,upper(p.WorkflowStatus) AS 'WorkflowStatus'
		,p.LastModifiedDate
		,p.LastModifiedBy
		,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
		,p.MarkedForDeletion
		,CASE 
			WHEN p.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,p.DeploymentJobID
		,j.JobName
		,j.JobDescription
	FROM tblProduct p
	LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobId = j.DeploymentJobId
	LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserID
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitID = b.BusinessUnitID
	INNER JOIN tblProductAttributeReln par ON par.ProductID = p.ProductID
		AND par.DeploymentJobId = @JobId
	WHERE p.ActiveFlag = 1
		AND b.ActiveFlag = 1
		AND par.ActiveFlag = 1
	
	UNION
	
	-- Get list of records from tblProductSearcAttribReln that are part of the job --
	SELECT p.ProductID
		,p.BusinessUnitID
		,b.BusinessUnitName
		,p.ProductName
		,p.ProductKeywords
		,p.ProductBlurb
		,p.ProductApprovals
		,p.PublishDate
		,p.ExpirationDate
		,upper(p.WorkflowStatus) AS 'WorkflowStatus'
		,p.LastModifiedDate
		,p.LastModifiedBy
		,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
		,p.MarkedForDeletion
		,CASE 
			WHEN p.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,p.DeploymentJobID
		,j.JobName
		,j.JobDescription
	FROM tblProduct p
	LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobId = j.DeploymentJobId
	LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserID
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitID = b.BusinessUnitID
	INNER JOIN tblProductSearchAttribReln psar ON psar.ProductID = p.ProductID
		AND psar.DeploymentJobId = @JobId
	WHERE p.ActiveFlag = 1
		AND b.ActiveFlag = 1
		AND psar.ActiveFlag = 1
	
	UNION
	
	-- Get list of records from tblDocument that are part of the job --
	SELECT p.ProductID
		,p.BusinessUnitID
		,b.BusinessUnitName
		,p.ProductName
		,p.ProductKeywords
		,p.ProductBlurb
		,p.ProductApprovals
		,p.PublishDate
		,p.ExpirationDate
		,upper(p.WorkflowStatus) AS 'WorkflowStatus'
		,p.LastModifiedDate
		,p.LastModifiedBy
		,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
		,p.MarkedForDeletion
		,CASE 
			WHEN p.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,p.DeploymentJobID
		,j.JobName
		,j.JobDescription
	FROM tblProduct p
	LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobId = j.DeploymentJobId
	LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserID
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitID = b.BusinessUnitID
	INNER JOIN tblDocument d ON d.ProductID = p.ProductID
		AND d.DeploymentJobId = @JobId
	WHERE p.ActiveFlag = 1
		AND b.ActiveFlag = 1
		AND d.ActiveFlag = 1
	ORDER BY p.ProductName ASC
END