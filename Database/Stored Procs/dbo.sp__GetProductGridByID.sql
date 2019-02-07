create PROCEDURE [dbo].[sp__GetProductGridByID] @ProductGridID INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/13/2006
purpose:
	gets just the information from the tblProductGrid

history:
	Kelly Roe   (12/13/2006) - created initial stored procedure

*/
	IF (
			@ProductGridID IS NULL
			OR @ProductGridID = 0
			)
	BEGIN
		PRINT 'A product grid id is required.'
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblProductGrid_LIVE') > 0
					AND dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				PRINT 'live sql here'
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
					dbo.fn__TableExists('tblProductGrid') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				SELECT p.ProductGridName
					,p.BusinessUnitID
					,UPPER(p.WorkflowStatus) AS 'WorkflowStatus'
					,p.MarkedForDeletion
					,CASE 
						WHEN p.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,p.PublishDate
					,p.ExpirationDate
					,p.WorkflowStatus
					,p.LastModifiedBy
					,p.LastModifiedDate
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,p.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblProductGrid p
				LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobId = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserId
				WHERE p.ActiveFlag = 1
					AND p.ProductGridID = @ProductGridID
			END
		END
	END
END