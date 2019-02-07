create PROCEDURE [dbo].[sp__GetDocumentsByProduct] @ProductID INT = NULL
	,@LiveMode BIT = 0
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/07/2006

purpose:
	Get a list of documents by product

parameters:
	@ProductID - Product ID
	@LiveMode - 0/1 - whether we want to get information from CMS/LIVE tables

history:
	Kelly Roe    (12/07/2006) - created initial procedure
	Brian Gaines (1/1/2007) - updated with live sql
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
					dbo.fn__TableExists('tblProduct') > 0
					AND dbo.fn__TableExists('tblDocument') > 0
					AND dbo.fn__TableExists('tblRegion') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					)
			BEGIN
				SELECT l.DocumentID
					,l.ProductID
					,l.RegionID
					,r.RegionName
					,l.DocTitle
					,l.DocPath
					,l.ContentType
					,l.DocumentType
					,l.UploadDate
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
				FROM tblDocument l
				INNER JOIN tblRegion r ON l.RegionID = r.RegionID
				LEFT JOIN tblAppUser u ON l.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON l.DeploymentJobId = j.DeploymentJobID
				WHERE l.ActiveFlag = 1
					AND l.ProductID = @ProductID
				ORDER BY l.ContentType
					,l.DocTitle
			END
			ELSE
			BEGIN
				PRINT 'You are missing some tables'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			SELECT d.DocumentID
				,d.ProductID
				,p.ProductName
				,r.RegionName
				,i.ImagePath
				,d.DocTitle
				,d.DocPath
				,d.ContentType
				,dbo.fn__GetDateOnly(d.UploadDate) AS 'UploadDate'
			FROM tblDocument_LIVE d
			INNER JOIN tblProduct_LIVE p ON d.ProductID = p.ProductID
				AND p.ProductID = @ProductID
			INNER JOIN tblRegion_LIVE r ON d.RegionID = r.RegionID
			LEFT JOIN tblImage_LIVE i ON r.ImageID = i.ImageId
			WHERE d.ActiveFlag = 1
				AND p.ActiveFlag = 1
				AND r.ActiveFlag = 1
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(d.PublishDate)
					AND dbo.fn__GetDateOnly(d.ExpirationDate)
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(p.PublishDate)
					AND dbo.fn__GetDateOnly(p.ExpirationDate)
				AND upper(d.WorkflowStatus) = 'LIVE'
				AND upper(p.WorkflowStatus) = 'LIVE'
				AND upper(r.WorkflowStatus) = 'LIVE'
			ORDER BY d.ContentType ASC
		END
	END
END