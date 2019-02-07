CREATE PROCEDURE [dbo].[sp__GetDeploymentJobByID] @DeploymentJobID INT = NULL
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/16/2006
purpose:
	Returns a single deployment job by its id

history:
	Kelly Roe   (12/16/2006) - created initial stored procedure

*/
	IF (
			@DeploymentJobID IS NULL
			OR @DeploymentJobID = 0
			)
	BEGIN
		PRINT 'A deployment job id is required.'
	END
	ELSE
	BEGIN
		SELECT j.DeploymentJobID
			,j.JobName
			,j.JobDescription
			,j.ReviewBy
			,a1.FirstName + ' ' + a1.LastName AS 'ReviewByName'
			,j.ApprovedBy
			,a2.FirstName + ' ' + a2.LastName AS 'ApprovedByName'
			,j.DeploymentDate
			,j.DeployedBy
			,a3.FirstName + ' ' + a3.LastName AS 'DeployedByName'
			,j.WorkflowStatus
			,j.LastModifiedDate
			,j.LastModifiedBy
			,a4.FirstName + ' ' + a4.LastName AS 'LastModifiedByName'
		FROM tblDeploymentJobs j
		LEFT JOIN tblAppUser a1 ON j.ReviewBy = a1.AppUserId
		LEFT JOIN tblAppUser a2 ON j.ApprovedBy = a2.AppUserId
		LEFT JOIN tblAppUser a3 ON j.DeployedBy = a3.AppUserId
		LEFT JOIN tblAppUser a4 ON j.LastModifiedBy = a4.AppUserId
		WHERE j.DeploymentJobID = @DeploymentJobID
			AND j.ActiveFlag = 1
	END
END