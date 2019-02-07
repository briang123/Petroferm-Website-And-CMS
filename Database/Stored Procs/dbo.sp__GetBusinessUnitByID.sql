create proc [dbo].[sp__GetBusinessUnitByID] @BusUnitID INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/30/2006
purpose:
	Returns a single business unit by its business unit id

	NOTE: we should change this procedure to return output parameters to make it more efficient.
	If we have time at the end of the project, then we can make this adjustment

usage syntax:
	exec sp__GetBusinessUnitByID 
		@BusUnitID = 1, 
		@LiveMode = 0

history:
	Brian Gaines (11/30/2006) - created initial stored procedure
	Kelly Roe    (12/01/2006) - added LastModifiedDate to CMS select
*/
	IF (
			@BusUnitID IS NULL
			OR @BusUnitID = 0
			)
	BEGIN
		PRINT 'A business unit is required.'
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblImage_LIVE') > 0
					AND dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				SELECT b.BusinessUnitID
					,b.BusinessUnitName
					,b.DocAuthorization
					,b.LogoImageID
					,b.WorkflowStatus
					,b.DeploymentJobID
					,j.JobName
					,j.JobDescription
					,i.ImagePath
					,i.Alt
					,i.Width
					,i.Height
				FROM tblBusinessUnit_LIVE b
				LEFT JOIN tblImage_LIVE i ON b.LogoImageID = i.ImageID
				LEFT JOIN tblDeploymentJobs j ON b.DeploymentJobID = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON b.LastModifiedBy = u.AppUserID
				WHERE dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(b.PublishDate)
						AND dbo.fn__GetDateOnly(b.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(i.PublishDate)
						AND dbo.fn__GetDateOnly(i.ExpirationDate)
					AND upper(b.WorkflowStatus) = 'LIVE'
					AND upper(i.WorkflowStatus) = 'LIVE'
					AND b.ActiveFlag = 1
					AND i.ActiveFlag = 1
					AND b.BusinessUnitID = @BusUnitID
			END
			ELSE
			BEGIN
				PRINT 'The LIVE tables must exist.'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			IF (
					dbo.fn__TableExists('tblImage') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
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
					,b.WorkflowStatus
					,b.LastModifiedBy
					,b.LastModifiedDate
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,b.DeploymentJobID
					,j.JobName
					,j.JobDescription
					,i.ImagePath
					,i.Alt
					,i.Width
					,i.Height
				FROM tblBusinessUnit b
				LEFT JOIN tblImage i ON b.LogoImageID = i.ImageID
				LEFT JOIN tblDeploymentJobs j ON b.DeploymentJobId = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON b.LastModifiedBy = u.AppUserId
				WHERE b.ActiveFlag = 1
					AND i.ActiveFlag = 1
					AND b.BusinessUnitID = @BusUnitID
			END
		END
	END
END