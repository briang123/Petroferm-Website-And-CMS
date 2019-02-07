create PROCEDURE [dbo].[sp__GetPageListByJobId] @JobId INT
AS
BEGIN
	-- DO WE NEED TO DISPLAY A *VIEW* INTO THE RELATIONSHIP OF A PAGE TO THE CONTENT 
	--(IF CONTENT IS WORKING, SHOULD WE SHOW THAT PAGE IS WORKING?) 
	-- SEE "Petroferm CMS Content Workflow Process" diagram
	SELECT p.PageID
		,m.MarketName
		,b.BusinessUnitName
		,p.PageType
		,p.PageTitle
		,dbo.fn__GetDateOnly(p.PublishDate) AS 'PublishDate'
		,dbo.fn__GetDateOnly(p.ExpirationDate) AS 'ExpirationDate'
		,p.WorkflowStatus
		,dbo.fn__FormatDate(p.LastModifiedDate, 'mm/dd/yyyy h:nn') AS 'LastModifiedDate'
		,p.LastModifiedBy
		,a1.FirstName + ' ' + a1.LastName AS 'LastModifiedByName'
		,p.MarkedForDeletion
		,CASE 
			WHEN p.MarkedForDeletion = 1
				THEN 'Yes'
			ELSE 'No'
			END AS 'FmtMarkedForDeletion'
		,j.JobName
	FROM tblPage p
	INNER JOIN tblAppUser a1 ON p.LastModifiedBy = a1.AppUserId
	INNER JOIN tblBusinessUnit b ON p.BusinessUnitId = b.BusinessUnitId
	LEFT JOIN tblMarket m ON p.MarketId = m.MarketId
	INNER JOIN tblDeploymentJobs j ON p.DeploymentJobID = j.DeploymentJobID
	WHERE p.ActiveFlag = 1
		AND p.DeploymentJobID = @JobID
	ORDER BY PageID ASC
END