create PROCEDURE [dbo].[sp__GetProductGridsByBU] @BusUnitID INT = NULL
	,@LiveMode INT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/12/2006

purpose:
	Get a list of product grids by business unit

parameters:
	@BusUnitID - Business Unit Id 
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Kelly Roe   (12/12/2006) - created initial procedure

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
					dbo.fn__TableExists('tblProductGrid') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				SELECT p.ProductGridID
					,p.BusinessUnitID
					,b.BusinessUnitName
					,p.ProductGridName
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
				FROM tblProductGrid p
				LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobId = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON p.LastModifiedBy = u.AppUserID
				INNER JOIN tblBusinessUnit b ON p.BusinessUnitID = b.BusinessUnitID
				WHERE p.ActiveFlag = 1
					AND b.ActiveFlag = 1
					AND p.BusinessUnitId = @BusUnitID
				ORDER BY p.ProductGridName ASC

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
			-- live query here
			--print 'live query here'
			RETURN 1
		END
	END
END