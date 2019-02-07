create PROCEDURE [dbo].[sp__GetProductSearchAttributeRelnsByAttrib] @SearchAttribTypeID INT = NULL
	,@BusUnitID INT = NULL
	,@Selected BIT = 0
	,-- this is for getting selected/unselected products for attrib
	@LiveMode BIT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/05/2006

purpose:
	Get a list of product search attribute relns by search attrib

parameters:
	@SearchAttribTypeID - Product ID
	@Selected - 0/1 - whether to get selected or "unselected" products for the search attribute
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Kelly Roe    (12/05/2006) - created initial procedure
	Kelly Roe    (12/06/2006) - added bus unit (to get list of prods by bus unit)
*/
	BEGIN
		IF (@LiveMode = 0)
		BEGIN
			IF (@Selected = 1) -- get list of selected attribs and include workflow info
			BEGIN
				IF (
						dbo.fn__TableExists('tblProduct') > 0
						AND dbo.fn__TableExists('tblProductSearchAttribReln') > 0
						)
				BEGIN
					SELECT r.ProdSearchAttribRelnID
						,r.SearchAttribTypeID
						,p.ProductID
						,p.ProductName
						,r.PublishDate
						,r.ExpirationDate
						,UPPER(r.WorkflowStatus) AS WorkflowStatus
						,r.LastModifiedDate
						,r.LastModifiedBy
						,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
						,r.MarkedForDeletion
						,CASE 
							WHEN r.MarkedForDeletion = 1
								THEN 'Yes'
							ELSE 'No'
							END AS 'FmtMarkedForDeletion'
						,r.DeploymentJobID
						,j.JobName
						,j.JobDescription
					FROM tblProduct p
					INNER JOIN tblProductSearchAttribReln r ON p.ProductID = r.ProductID
						AND r.SearchAttribTypeID = @SearchAttribTypeID
					LEFT JOIN tblAppUser u ON r.LastModifiedBy = u.AppUserId
					LEFT JOIN tblDeploymentJobs j ON r.DeploymentJobId = j.DeploymentJobID
					WHERE p.ActiveFlag = 1
						AND r.ActiveFlag = 1
					ORDER BY p.ProductName ASC
				END
				ELSE
				BEGIN
					PRINT 'You are missing some tables'

					RETURN 0
				END
			END
			ELSE -- get list of unselected attribs
			BEGIN
				IF (
						dbo.fn__TableExists('tblSearchAttribType') > 0
						AND dbo.fn__TableExists('tblProductSearchAttribReln') > 0
						)
				BEGIN
					IF (@SearchAttribTypeID = 0)
					BEGIN -- get back all products (the attrib is new)
						SELECT l.ProductID
							,l.ProductName
						FROM tblProduct l
						WHERE l.BusinessUnitID = @BusUnitID
							AND l.ActiveFlag = 1
						ORDER BY l.ProductName ASC
					END
					ELSE -- get back unrelated products by attrib
					BEGIN
						SELECT l.ProductID
							,l.ProductName
						FROM tblProduct l
						WHERE l.BusinessUnitID = @BusUnitID
							AND l.ProductID NOT IN (
								SELECT ProductID
								FROM tblProductSearchAttribReln
								WHERE SearchAttribTypeID = @SearchAttribTypeID
								)
							AND l.ActiveFlag = 1
						ORDER BY l.ProductName ASC
					END
				END
				ELSE
				BEGIN
					PRINT 'You are missing some tables'

					RETURN 0
				END
			END
		END
		ELSE
		BEGIN
			PRINT 'live sql here'
		END
	END
END