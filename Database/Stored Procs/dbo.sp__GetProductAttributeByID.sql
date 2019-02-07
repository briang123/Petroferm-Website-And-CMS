create PROCEDURE [dbo].[sp__GetProductAttributeByID] @AttribTypeID INT = NULL
	,@BusUnitID INT OUTPUT
	,@AttribName VARCHAR(100) OUTPUT
	,@AllowMultiple BIT OUTPUT
	,@FmtAllowMultiple VARCHAR(3) OUTPUT
	,@IsReadOnly BIT OUTPUT
	,@FmtIsReadOnly VARCHAR(3) OUTPUT
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
created on: 11/30/2006

purpose:
	Get a single product attribute by its ID. We use output parameters because
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
	Brian Gaines (11/30/2006) - created initial procedure
	Kelly Roe    (12/01/2006) - added MarkedForDeletion OUTPUT parm
				  - removed tblBusinessUnit reference to CMS select
				  - fixed a join in the where of CMS select
*/
	IF (
			@AttribTypeID IS NULL
			OR @AttribTypeID = 0
			)
	BEGIN
		PRINT 'An attribute id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		SELECT @BusUnitID = l.BusinessUnitID
			,@AttribName = l.AttribName
			,@AllowMultiple = l.AllowMultiple
			,@FmtAllowMultiple = CASE 
				WHEN l.AllowMultiple = 1
					THEN 'Yes'
				ELSE 'No'
				END
			,@IsReadOnly = l.IsReadOnly
			,@FmtIsReadOnly = CASE 
				WHEN l.IsReadOnly = 1
					THEN 'Yes'
				ELSE 'No'
				END
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
		FROM tblProductAttributeType l
		LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
		LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobID = j.DeploymentJobId
		WHERE l.ActiveFlag = 1
			AND l.AttribTypeID = @AttribTypeID
	END
END