create PROCEDURE [dbo].[sp__GetSideNavByPageID] @PageID INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/14/2006
purpose:
	Gets info about a side nav item by page ID

history:
	Kelly Roe    (12/14/2006) - created initial stored procedure
*/
	IF (
			@PageID IS NULL
			OR @PageID = 0
			)
	BEGIN
		PRINT 'A page id is required.'
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblSideNav_LIVE') > 0
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
					dbo.fn__TableExists('tblSideNav') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				SELECT s.ID
					,s.ProdCatID
					,s.Title
					,s.Description
					,s.URL
					,s.BusinessUnitID
					,s.MarketID
					,s.PageID
					,s.ItemOrder
					,s.Parent
					,s.SectionID
					,UPPER(s.WorkflowStatus) AS 'WorkflowStatus'
					,s.MarkedForDeletion
					,CASE 
						WHEN s.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,s.PublishDate
					,s.ExpirationDate
					,s.WorkflowStatus
					,s.LastModifiedBy
					,s.LastModifiedDate
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,s.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblSideNav s
				LEFT JOIN tblDeploymentJobs j ON s.DeploymentJobId = j.DeploymentJobId
				LEFT JOIN tblAppUser u ON s.LastModifiedBy = u.AppUserId
				WHERE s.ActiveFlag = 1
					AND s.MarkedForDeletion = 0
					AND s.PageID = @PageID
			END
		END
	END
END