CREATE PROCEDURE [dbo].[sp__GetSearchAttributesByBU] @BusUnitID INT = NULL
	,@LiveMode BIT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/03/2006

purpose:
	Get a list of ALL search attributes

parameters:
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Kelly Roe    (12/03/2006) - created initial procedure
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
		IF (@LiveMode = 0)
		BEGIN
			IF (
					dbo.fn__TableExists('tblSearchAttribType') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					)
			BEGIN
				SELECT l.SearchAttribTypeID
					,l.MarketID
					,m.MarketName
					,l.SearchAttributeName
					,m.MarketName + ' > ' + l.SearchAttributeName AS ListBoxDisplay
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
				INNER JOIN tblMarket m ON l.MarketID = m.MarketID
				LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobId = j.DeploymentJobID
				WHERE l.BusinessUnitID = @BusUnitID
					AND l.ActiveFlag = 1
					AND m.ActiveFlag = 1
				ORDER BY m.MarketName
					,l.SearchAttributeName ASC
			END
			ELSE
			BEGIN
				PRINT 'You are missing some tables'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			PRINT 'live sql here'
		END
	END
END