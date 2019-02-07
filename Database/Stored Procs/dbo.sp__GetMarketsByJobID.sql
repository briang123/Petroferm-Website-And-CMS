create PROCEDURE [dbo].[sp__GetMarketsByJobID] @JobID INT = NULL
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/17/2006
purpose:
	Returns a list of markets for a particular job

history:
	Kelly Roe    (12/17/2006) - created initial stored procedure
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
		SELECT m.MarketID
			,b.BusinessUnitID
			,b.BusinessUnitName
			,m.MarketName
			,m.MarketOrder
			,m.PublishDate
			,m.ExpirationDate
			,upper(m.WorkflowStatus) AS 'WorkflowStatus'
			,m.LastModifiedDate
			,m.LastModifiedBy
			,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
			,m.MarkedForDeletion
			,CASE 
				WHEN b.MarkedForDeletion = 1
					THEN 'Yes'
				ELSE 'No'
				END AS 'FmtMarkedForDeletion'
			,j.JobName
			,m.DeploymentJobId
		FROM tblMarket m
		INNER JOIN tblBusinessUnit b ON m.BusinessUnitID = b.BusinessUnitId
		LEFT JOIN tblAppUser u ON m.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON m.DeploymentJobID = j.DeploymentJobID
		WHERE m.DeploymentJobId = @JobID
			AND m.ActiveFlag = 1
			AND b.ActiveFlag = 1
		ORDER BY m.MarketName ASC
	END
END