create PROCEDURE [dbo].[sp__GetSideNavProdCategories] @BusUnitID INT = 0
	,@MarketID INT = 0
	,@LiveMode INT = 0
AS
/*
created by: Kelly Roe
created on: 12/13/2006
purpose:
	Return a list of side nav sections from the lookup table

history:
	Kelly Roe    (12/13/2006) - created initial procedure
*/
BEGIN
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
			IF (dbo.fn__TableExists('tblSideNavProdCategory') > 0)
			BEGIN
				IF (
						@MarketID = NULL
						OR @MarketID = 0
						)
				BEGIN
					SELECT c.ProdCatID
						,c.CategoryName
						,c.BusinessUnitID
						,c.MarketID
						,c.CategoryOrder
						,UPPER(c.WorkflowStatus) AS 'WorkflowStatus'
						,c.MarkedForDeletion
						,CASE 
							WHEN c.MarkedForDeletion = 1
								THEN 'Yes'
							ELSE 'No'
							END AS 'FmtMarkedForDeletion'
						,c.PublishDate
						,c.ExpirationDate
						,c.WorkflowStatus
						,c.LastModifiedBy
						,c.LastModifiedDate
						,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
						,c.DeploymentJobID
						,j.JobName
						,j.JobDescription
					FROM tblSideNavProdCategory c
					LEFT JOIN tblDeploymentJobs j ON c.DeploymentJobId = j.DeploymentJobId
					LEFT JOIN tblAppUser u ON c.LastModifiedBy = u.AppUserId
					WHERE c.BusinessUnitID = @BusUnitID
						AND c.ActiveFlag = 1
					ORDER BY c.CategoryOrder
						,c.CategoryName
				END
				ELSE
				BEGIN
					SELECT c.ProdCatID
						,c.CategoryName
						,c.BusinessUnitID
						,c.MarketID
						,c.CategoryOrder
						,UPPER(c.WorkflowStatus) AS 'WorkflowStatus'
						,c.MarkedForDeletion
						,CASE 
							WHEN c.MarkedForDeletion = 1
								THEN 'Yes'
							ELSE 'No'
							END AS 'FmtMarkedForDeletion'
						,c.PublishDate
						,c.ExpirationDate
						,c.WorkflowStatus
						,c.LastModifiedBy
						,c.LastModifiedDate
						,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
						,c.DeploymentJobID
						,j.JobName
						,j.JobDescription
					FROM tblSideNavProdCategory c
					LEFT JOIN tblDeploymentJobs j ON c.DeploymentJobId = j.DeploymentJobId
					LEFT JOIN tblAppUser u ON c.LastModifiedBy = u.AppUserId
					WHERE c.BusinessUnitID = @BusUnitID
						AND c.MarketID = @MarketID
						AND c.ActiveFlag = 1
					ORDER BY c.CategoryOrder
						,c.CategoryName
				END

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
				PRINT 'live query here'

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