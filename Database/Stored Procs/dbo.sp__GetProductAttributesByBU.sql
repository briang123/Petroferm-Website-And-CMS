create PROCEDURE [dbo].[sp__GetProductAttributesByBU] @BusUnitID INT = NULL
	,@LiveMode BIT = 0
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/30/2006

purpose:
	Get a list of product attributes by business unit

parameters:
	@BusUnitID - Business Unit Id 
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Brian Gaines (11/30/2006) - created initial procedure
	Kelly Roe    (12/01/2006) - add more columns to select for cms mode
*/
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
			IF (
					dbo.fn__TableExists('tblProductAttributeType') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					)
			BEGIN
				SELECT l.AttribTypeID
					,l.BusinessUnitID
					,b.BusinessUnitName
					,l.AttribName
					,l.AllowMultiple
					,CASE 
						WHEN l.AllowMultiple = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtAllowMultiple'
					,l.IsReadOnly
					,CASE 
						WHEN l.IsReadOnly = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtIsReadOnly'
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
				FROM tblProductAttributeType l
				INNER JOIN tblBusinessUnit b ON l.BusinessUnitId = b.BusinessUnitId
				LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobId = j.DeploymentJobID
				WHERE l.ActiveFlag = 1
					AND b.ActiveFlag = 1
					AND l.BusinessUnitId = @BusUnitID
				ORDER BY b.BusinessUnitName
					,l.AttribName ASC
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
					dbo.fn__TableExists('tblProductAttributeType_LIVE') > 0
					AND dbo.fn__TableExists('tblBusinessUnit_LIVE') > 0
					)
			BEGIN
				SELECT l.AttribTypeID
					,l.AttribName
					,l.AllowMultiple
				FROM tblProductAttributeType_LIVE l
				INNER JOIN tblBusinessUnit_LIVE b ON l.BusinessUnitId = b.BusinessUnitId
				WHERE l.ActiveFlag = 1
					AND b.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(l.PublishDate)
						AND dbo.fn__GetDateOnly(l.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(b.PublishDate)
						AND dbo.fn__GetDateOnly(b.ExpirationDate)
					AND UPPER(l.WorkflowStatus) = 'LIVE'
					AND UPPER(b.WorkflowStatus) = 'LIVE'
					AND l.BusinessUnitId = @BusUnitID
				ORDER BY b.BusinessUnitName
					,l.AttribName ASC
			END
			ELSE
			BEGIN
				PRINT 'You are missing some tables'

				RETURN 0
			END
		END
	END
END