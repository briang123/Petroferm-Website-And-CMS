CREATE PROCEDURE [dbo].[sp__GetMarketsByBU] @BusUnitID INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/30/2006
purpose:
	Returns a list of markets for a particular business unit

usage syntax:
	exec sp__GetMarketsByBU
		@BusUnitID = 1, 
		@LiveMode = 0

history:
	Brian Gaines (11/30/2006) - created initial stored procedure
	Kelly Roe    (12/01/2006) - added JobName and MarkedForDeletion to CMS select
	Kelly Roe    (12/07/2006) - added DeploymentJobId to CMS select
*/
	IF (
			@BusUnitID IS NULL
			OR @BusUnitID = 0
			)
	BEGIN
		PRINT 'A business unit is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblMarket_LIVE') > 0
					AND dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
					)
			BEGIN
				SELECT m.MarketID
					,b.BusinessUnitID
					,b.BusinessUnitName
					,m.MarketName
					,m.MarketOrder
				FROM tblMarket_LIVE m
					,tblBusinessUnit_LIVE b
				WHERE b.BusinessUnitId = m.BusinessUnitID
					AND b.BusinessUnitID = @BusUnitID
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(m.PublishDate)
						AND dbo.fn__GetDateOnly(m.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(b.PublishDate)
						AND dbo.fn__GetDateOnly(b.ExpirationDate)
					AND upper(m.WorkflowStatus) = 'LIVE'
					AND upper(b.WorkflowStatus) = 'LIVE'
					AND m.ActiveFlag = 1
					AND b.ActiveFlag = 1
				ORDER BY m.MarketOrder ASC
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
					dbo.fn__TableExists('tblMarket') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					)
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
				WHERE m.BusinessUnitID = @BusUnitID
					AND m.ActiveFlag = 1
					AND b.ActiveFlag = 1
				ORDER BY m.MarketOrder ASC
			END
		END
	END
END