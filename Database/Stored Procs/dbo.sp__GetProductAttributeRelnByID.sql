create PROCEDURE [dbo].[sp__GetProductAttributeRelnByID] @ProdAttribRelnID INT = NULL
	,@AttribValue VARCHAR(500) OUTPUT
	,@AttribID INT OUTPUT
	,@AttribName VARCHAR(100) OUTPUT
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
created on: 12/02/2006

purpose:
	Get a single product attribute value by its ID. We use output parameters because
	it is more efficient usage of returning a single row of data from SQL Server

example script usage:
	declare @buid int,
		@attribName varchar(100),
		@allowMult bit,
		@f_allowMult varchar(3),
		...
	
	exec sp__GetProductAttributeRelnByID 
		@AttribTypeID = << attribute id here >>, 
		@BusUnitID = @buid OUTPUT,
		@AttribName = @attribName OUTPUT, 
		...
	
	select 	@buid as 'BusinessUnitID',
		@attribName as 'AttributeName',
		@allowMult as 'AllowMultiple',
		...

history:
	Kelly Roe    (12/02/2006) - created initial procedure
*/
	IF (
			@ProdAttribRelnID IS NULL
			OR @ProdAttribRelnID = 0
			)
	BEGIN
		PRINT 'An attribute value id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		SELECT @AttribValue = l.AttribValue
			,@AttribID = l.AttribTypeID
			,@AttribName = a.AttribName
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
		FROM tblProductAttributeReln l
		INNER JOIN tblProductAttributeType a ON l.AttribTypeID = a.AttribTypeID
		LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobID = j.DeploymentJobId
		WHERE l.ActiveFlag = 1
			AND l.ProdAttribRelnID = @ProdAttribRelnID
	END
END