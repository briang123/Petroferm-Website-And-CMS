create PROCEDURE [dbo].[sp__GetProductAttributeRelnsByProduct] @ProductID INT = NULL
	,@LiveMode BIT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/02/2006

purpose:
	Get a list of product attribute name/values by product

parameters:
	@ProductID - Product ID
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Kelly Roe    (12/02/2006) - created initial procedure
*/
	IF (
			@ProductID IS NULL
			OR @ProductID = 0
			)
	BEGIN
		PRINT 'A product id is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 0)
		BEGIN
			IF (
					dbo.fn__TableExists('tblProductAttributeType') > 0
					AND dbo.fn__TableExists('tblProductAttributeReln') > 0
					AND dbo.fn__TableExists('tblBusinessUnit') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					)
			BEGIN
				SELECT l.ProdAttribRelnID
					,l.ProductID
					,l.AttribTypeID
					,a.AttribName
					,l.AttribValue
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
				FROM tblProductAttributeReln l
				INNER JOIN tblProductAttributeType a ON l.AttribTypeID = a.AttribTypeID
				LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobId = j.DeploymentJobID
				WHERE l.ActiveFlag = 1
					AND l.ProductID = @ProductID
				ORDER BY a.AttribName
					,l.AttribValue ASC
			END
			ELSE
			BEGIN
				PRINT 'You are missing some tables'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			PRINT 'sql here'
				/* LIVE SQL HERE */
		END
	END
END