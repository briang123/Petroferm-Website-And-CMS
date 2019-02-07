create PROCEDURE [dbo].[sp__GetBusinessUnitsByJobID] @JobID INT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/17/2006
purpose:
	Returns a list of business units by job

history:
	Kelly Roe    (12/17/2006) - created initial procedure

*/
	SELECT b.BusinessUnitID
		,b.BusinessUnitName
		,b.DocAuthorization
		,CASE 
			WHEN b.DocAuthorization = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtDocAuthorization'
		,b.LogoImageID
		,UPPER(b.WorkflowStatus) AS 'WorkflowStatus'
		,b.MarkedForDeletion
		,CASE 
			WHEN b.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,b.PublishDate
		,b.ExpirationDate
		,b.LastModifiedDate
		,b.DeploymentJobId
		,ISNULL(j.JobName, '') AS 'JobName'
		,ISNULL(i.ImagePath, '(no image defined)') AS 'ImagePath'
		,i.Alt
		,i.Width
		,i.Height
	FROM tblBusinessUnit b
	LEFT JOIN tblImage i ON b.LogoImageID = i.ImageID
	LEFT JOIN tblDeploymentJobs j ON b.DeploymentJobID = j.DeploymentJobID
	WHERE b.DeploymentJobID = @JobID
		AND b.ActiveFlag = 1
		AND i.ActiveFlag = 1
	ORDER BY b.BusinessUnitName
END