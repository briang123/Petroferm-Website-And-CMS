create PROCEDURE [dbo].[sp__GetSearchAttributeByID] @SearchAttribTypeID INT = NULL
	,@BusUnitID INT OUTPUT
	,@MarketID INT OUTPUT
	,@SearchAttribName VARCHAR(100) OUTPUT
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
created by: Kelly Roe
created on: 12/04/2006

purpose:
	Get a single search attribute by its ID. We use output parameters because
	it is more efficient usage of returning a single row of data from SQL Server

example script usage:
	declare @buid int,
		@attribName varchar(100),
		@allowMult bit,
		@f_allowMult varchar(3),
		...
	
	exec sp__GetProductAttribByID 
		@AttribTypeID = << attribute id here >>, 
		@BusUnitID = @buid OUTPUT,
		@AttribName = @attribName OUTPUT, 
		...
	
	select 	@buid as 'BusinessUnitID',
		@attribName as 'AttributeName',
		@allowMult as 'AllowMultiple',
		...

history:
	Kelly Roe    (12/04/2006) - created initial procedure
*/
	IF (
			@SearchAttribTypeID IS NULL
			OR @SearchAttribTypeID = 0
			)
	BEGIN
		PRINT 'A search attribute id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		SELECT @BusUnitID = l.BusinessUnitID
			,@MarketID = l.MarketID
			,@SearchAttribName = l.SearchAttributeName
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
		FROM tblSearchAttribType l
		LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobID = j.DeploymentJobId
		WHERE l.ActiveFlag = 1
			AND l.SearchAttribTypeID = @SearchAttribTypeID
	END
END