create PROCEDURE [dbo].[sp__GetProductSearchAttributeRelnsByProduct] @ProductID INT = NULL
	,@BusUnitID INT = NULL
	,@MarketID INT = NULL
	,@Selected BIT = 0
	,-- this is for getting selected/unselected for product
	@LiveMode BIT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/03/2006

purpose:
	Get a list of search attributes by product

parameters:
	@ProductID - Product ID
	@MarketID - Market ID of the Search Attrib
	@Selected - 0/1 - whether to get selected or "unselected" search attributes for the product
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Kelly Roe    (12/03/2006) - created initial procedure
	Kelly Roe    (12/20/2006) - added BusUnitID parm
*/
	IF (
			@ProductID IS NULL
			OR @ProductID = 0
			)
	BEGIN
		PRINT 'A product is required.'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 0)
		BEGIN
			IF (@Selected = 1) -- get list of selected attribs and include workflow info
			BEGIN
				IF (
						dbo.fn__TableExists('tblSearchAttribType') > 0
						AND dbo.fn__TableExists('tblProductSearchAttribReln') > 0
						)
				BEGIN
					IF (@MarketID = 0) -- get ALL markets
					BEGIN
						SELECT r.ProdSearchAttribRelnID
							,a.SearchAttribTypeID
							,a.MarketID
							,m.MarketName
							,a.SearchAttributeName
							,m.MarketName + ' > ' + a.SearchAttributeName AS ListBoxDisplay
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
						FROM tblSearchAttribType a
						INNER JOIN tblProductSearchAttribReln r ON a.SearchAttribTypeID = r.SearchAttribTypeID
							AND r.ProductID = @ProductID
						INNER JOIN tblMarket m ON a.MarketID = m.MarketID
						LEFT JOIN tblAppUser u ON r.LastModifiedBy = u.AppUserId
						LEFT JOIN tblDeploymentJobs j ON r.DeploymentJobId = j.DeploymentJobID
						WHERE a.BusinessUnitID = @BusUnitID
							AND a.ActiveFlag = 1
							AND m.ActiveFlag = 1
							AND r.ActiveFlag = 1
						ORDER BY m.MarketName
							,a.SearchAttributeName ASC
					END
					ELSE -- get by market
					BEGIN
						SELECT r.ProdSearchAttribRelnID
							,a.SearchAttribTypeID
							,a.MarketID
							,m.MarketName
							,a.SearchAttributeName
							,a.SearchAttributeName AS ListBoxDisplay
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
						FROM tblSearchAttribType a
						INNER JOIN tblProductSearchAttribReln r ON a.SearchAttribTypeID = r.SearchAttribTypeID
							AND r.ProductID = @ProductID
						INNER JOIN tblMarket m ON a.MarketID = m.MarketID
						LEFT JOIN tblAppUser u ON r.LastModifiedBy = u.AppUserId
						LEFT JOIN tblDeploymentJobs j ON r.DeploymentJobId = j.DeploymentJobID
						WHERE a.BusinessUnitID = @BusUnitID
							AND r.ActiveFlag = 1
							AND m.ActiveFlag = 1
							AND a.ActiveFlag = 1
							AND a.MarketID = @MarketID
						ORDER BY m.MarketName
							,a.SearchAttributeName ASC
					END
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
					IF (@MarketID = 0) -- get all markets
					BEGIN
						SELECT l.SearchAttribTypeID
							,l.MarketID
							,m.MarketName
							,l.SearchAttributeName
							,m.MarketName + ' > ' + l.SearchAttributeName AS ListBoxDisplay
						FROM tblSearchAttribType l
						LEFT JOIN tblMarket m ON l.MarketID = m.MarketID
						WHERE l.BusinessUnitID = @BusUnitID
							AND l.SearchAttribTypeID NOT IN (
								SELECT SearchAttribTypeID
								FROM tblProductSearchAttribReln
								WHERE ProductID = @ProductID
								)
							AND l.ActiveFlag = 1
							AND m.ActiveFlag = 1
						ORDER BY m.MarketName
							,l.SearchAttributeName ASC
					END
					ELSE
					BEGIN -- get by market
						SELECT l.SearchAttribTypeID
							,l.MarketID
							,m.MarketName
							,l.SearchAttributeName
							,l.SearchAttributeName AS ListBoxDisplay
						FROM tblSearchAttribType l
						INNER JOIN tblMarket m ON l.MarketID = m.MarketID
						WHERE l.BusinessUnitID = @BusUnitID
							AND l.SearchAttribTypeID NOT IN (
								SELECT SearchAttribTypeID
								FROM tblProductSearchAttribReln
								WHERE ProductID = @ProductID
								)
							AND l.ActiveFlag = 1
							AND m.ActiveFlag = 1
							AND l.MarketID = @MarketID
						ORDER BY m.MarketName
							,l.SearchAttributeName ASC
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