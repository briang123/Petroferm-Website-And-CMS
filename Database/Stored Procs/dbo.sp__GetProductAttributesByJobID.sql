create PROCEDURE [dbo].[sp__GetProductAttributesByJobID] @JobID INT = NULL
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/17/2006

purpose:
	Get a list of product attributes by job id

parameters:
	@JobID - Job Id 

history:
	Kelly Roe    (12/17/2006) - created initial procedure
*/
	IF (
			@JobID IS NULL
			OR @JobID = 0
			)
	BEGIN
		PRINT 'A Job ID is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		SELECT l.AttribTypeID
			,l.BusinessUnitID
			,b.BusinessUnitName
			,l.AttribName
			,l.AllowMultiple
			,CASE 
				WHEN l.AllowMultiple = 1
					THEN 'Yes'
				ELSE 'No'
				END AS 'FmtAllowMultiple'
			,l.IsReadOnly
			,CASE 
				WHEN l.IsReadOnly = 1
					THEN 'Yes'
				ELSE 'No'
				END AS 'FmtIsReadOnly'
			,l.PublishDate
			,l.ExpirationDate
			,UPPER(l.WorkflowStatus) AS WorkflowStatus
			,l.LastModifiedDate
			,l.LastModifiedBy
			,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
			,l.MarkedForDeletion
			,CASE 
				WHEN l.MarkedForDeletion = 1
					THEN 'Yes'
				ELSE 'No'
				END AS 'FmtMarkedForDeletion'
			,l.DeploymentJobID
			,j.JobName
			,j.JobDescription
		FROM tblProductAttributeType l
		INNER JOIN tblBusinessUnit b ON l.BusinessUnitId = b.BusinessUnitId
		LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobId = j.DeploymentJobID
		WHERE l.ActiveFlag = 1
			AND b.ActiveFlag = 1
			AND l.DeploymentJobId = @JobID
		ORDER BY l.AttribName ASC
	END
END