create PROCEDURE [dbo].[sp__GetSideNavProdCategoryByID] @ProdCatID INT = NULL
	,@BusUnitID INT OUTPUT
	,@MarketID INT OUTPUT
	,@CategoryName VARCHAR(50) OUTPUT
	,@CategoryOrder INT OUTPUT
	,@PublishDate DATETIME OUTPUT
	,@ExpireDate DATETIME OUTPUT
	,@WorkflowStatus VARCHAR(50) OUTPUT
	,@LastModifiedDate DATETIME OUTPUT
	,@LastModifiedBy INT OUTPUT
	,@LastModifiedByName VARCHAR(150) OUTPUT
	,@MarkedForDeletion BIT OUTPUT
	,@FmtMarkedForDeletion VARCHAR(3) OUTPUT
	,@JobID INT OUTPUT
	,@JobName VARCHAR(100) OUTPUT
	,@JobDescription VARCHAR(500) OUTPUT
AS
BEGIN
	/*
created by: Brian Gaines
created on: 12/14/2006

purpose:
	Get a product category for side nav by its ID. We use output parameters because
	it is more efficient usage of returning a single row of data from SQL Server

history:
	Kelly Roe    (12/14/2006) - created initial procedure
*/
	IF (
			@ProdCatID IS NULL
			OR @ProdCatID = 0
			)
	BEGIN
		PRINT 'A prod cat id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		SELECT @BusUnitID = l.BusinessUnitID
			,@MarketID = l.MarketID
			,@CategoryName = l.CategoryName
			,@CategoryOrder = l.CategoryOrder
			,@PublishDate = l.PublishDate
			,@ExpireDate = l.ExpirationDate
			,@WorkflowStatus = UPPER(l.WorkflowStatus)
			,@LastModifiedDate = l.LastModifiedDate
			,@LastModifiedBy = l.LastModifiedBy
			,@LastModifiedByName = u.FirstName + ' ' + u.LastName
			,@MarkedForDeletion = l.MarkedForDeletion
			,@FmtMarkedForDeletion = CASE 
				WHEN l.MarkedForDeletion = 1
					THEN 'Yes'
				ELSE 'No'
				END
			,@JobID = l.DeploymentJobID
			,@JobName = j.JobName
			,@JobDescription = j.JobDescription
		FROM tblSideNavProdCategory l
		LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobID = j.DeploymentJobId
		WHERE l.ActiveFlag = 1
			AND l.ProdCatID = @ProdCatID
	END
END