create PROCEDURE [dbo].[sp__GetDeploymentJobsByStatus] @WorkflowStatus VARCHAR(50) = NULL
AS
BEGIN
	SELECT d.DeploymentJobID
		,d.JobName
		,CASE 
			WHEN d.JobDescription IS NULL
				THEN '(empty)'
			ELSE d.JobDescription
			END AS 'JobDescription'
		,d.ReviewBy
		,CASE 
			WHEN d.ReviewBy = 0
				THEN '[NOT SET]'
			ELSE a1.FirstName + ' ' + a1.LastName
			END AS 'ReviewByName'
		,d.ApprovedBy
		,CASE 
			WHEN d.ApprovedBy = 0
				THEN '[NOT SET]'
			ELSE a2.FirstName + ' ' + a2.LastName
			END AS 'ApproveByName'
		,d.DeploymentDate
		,dbo.fn__GetDateOnly(d.DeploymentDate) AS 'FmtDeploymentDate'
		,d.DeployedBy
		,CASE 
			WHEN d.DeployedBy = 0
				THEN '[NOT SET]'
			ELSE a4.FirstName + ' ' + a4.LastName
			END AS 'DeployByName'
		,d.WorkflowStatus
		,d.LastModifiedDate
		,dbo.fn__FormatDate(d.LastModifiedDate, 'mm/dd/yyyy h:nn') AS 'FmtLastModDate'
		,d.LastModifiedBy
		,a3.FirstName + ' ' + a3.LastName AS 'LastModByName'
		,d.ActiveFlag
	FROM tblDeploymentJobs d
	LEFT JOIN tblAppUser a1 ON d.ReviewBy = a1.AppUserId
	LEFT JOIN tblAppUser a2 ON d.ApprovedBy = a2.AppUserId
	LEFT JOIN tblAppUser a3 ON d.LastModifiedBy = a3.AppUserId
	LEFT JOIN tblAppUser a4 ON d.DeployedBy = a4.AppUserId
	WHERE d.WorkflowStatus = @WorkflowStatus
	ORDER BY d.DeploymentDate DESC
END