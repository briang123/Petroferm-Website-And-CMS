CREATE PROCEDURE [dbo].[sp__GetProductsByBU] @BusUnitID INT = NULL
	,@LiveMode INT = 0
AS
BEGIN
	/*
created by: Brian Gaines
created on: 12/01/2006

purpose:
	Get a list of products by business unit

parameters:
	@BusUnitID - Business Unit Id 
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Brian Gaines (12/01/2006) - created initial procedure
	Kelly Roe    (12/02/2006) - named WorkflowStatus column in select
*/
	IF (
			@BusUnitId IS NULL
			OR @BusUnitID = 0
			)
	BEGIN
		PRINT 'A business unit is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 0)
		BEGIN
			IF (
					dbo.fn__TableExists('tblProduct') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
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
				WHERE p.ActiveFlag = 1
					AND b.ActiveFlag = 1
					AND p.BusinessUnitId = @BusUnitID
				ORDER BY p.ProductName ASC

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'You are missing some tables'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			IF (
					dbo.fn__TableExists('tblProduct_LIVE') > 0
					AND dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				SELECT p.ProductID
					,p.BusinessUnitID
					,b.BusinessUnitName
					,p.ProductName
					,p.ProductKeywords
					,p.ProductBlurb
					,p.ProductApprovals
					,p.PublishDate
					,p.ExpirationDate
					,upper(p.WorkflowStatus)
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
				WHERE p.ActiveFlag = 1
					AND b.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(p.PublishDate)
						AND dbo.fn__GetDateOnly(p.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(b.PublishDate)
						AND dbo.fn__GetDateOnly(b.ExpirationDate)
					AND UPPER(p.WorkflowStatus) = 'LIVE'
					AND UPPER(b.WorkflowStatus) = 'LIVE'
					AND p.BusinessUnitId = @BusUnitID
				ORDER BY b.BusinessUnitName

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'You are missing some tables'

				RETURN 0
			END
		END
	END
END