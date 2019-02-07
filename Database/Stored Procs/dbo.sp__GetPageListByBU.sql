CREATE PROCEDURE [dbo].[sp__GetPageListByBU] @BusUnitID INT
AS
BEGIN
	SELECT p.PageID
		,m.MarketName
		,b.BusinessUnitName
		,p.PageType
		,p.PageTitle
		,p.IsRequired
		,p.IsReadOnly
		,dbo.fn__GetDateOnly(p.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(p.ExpirationDate) AS 'ExpirationDate'
		,p.WorkflowStatus
		,p.LastModifiedDate
		,p.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,p.MarkedForDeletion
		,CASE 
			WHEN p.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
		,p.DeploymentJobID
	FROM tblPage p
	LEFT JOIN tblAppUser a1 ON p.LastModifiedBy = a1.AppUserId
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitId = b.BusinessUnitId
	LEFT JOIN tblMarket m ON p.MarketId = m.MarketId
	LEFT JOIN tblDeploymentJobs j ON p.DeploymentJobID = j.DeploymentJobID
	WHERE p.ActiveFlag = 1
		AND p.BusinessUnitID = @BusUnitID
	ORDER BY PageType ASC
END