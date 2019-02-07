create PROCEDURE [dbo].[sp__GetSearchAttributesByJobID] @JobID INT = NULL
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/17/2006

purpose:
	Get a list of ALL search attributes by Job ID

parameters:
	@JobID - job id 

history:
	Kelly Roe    (12/17/2006) - created initial procedure
*/
	IF (
			@JobID IS NULL
			OR @JobID = 0
			)
	BEGIN
		PRINT 'A job id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		SELECT l.SearchAttribTypeID
			,l.MarketID
			,b.BusinessUnitName
			,m.MarketName
			,l.SearchAttributeName
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
		FROM tblSearchAttribType l
		INNER JOIN tblBusinessUnit b ON l.BusinessUnitID = b.BusinessUnitID
		INNER JOIN tblMarket m ON l.MarketID = m.MarketID
		LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobId = j.DeploymentJobID
		WHERE l.DeploymentJobID = @JobID
			AND l.ActiveFlag = 1
			AND b.ActiveFlag = 1
			AND m.ActiveFlag = 1
		ORDER BY l.SearchAttributeName ASC
	END
END