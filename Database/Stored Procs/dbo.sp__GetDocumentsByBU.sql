create PROCEDURE [dbo].[sp__GetDocumentsByBU] @BusUnitID INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	IF (
			@BusUnitID IS NULL
			OR @BusUnitID = 0
			)
	BEGIN
		PRINT 'A business unit id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblDocument_LIVE') > 0
					OR dbo.fn__TableExists('tblProduct_LIVE') > 0
					OR dbo.fn__TableExists('tblRegion_LIVE') > 0
					OR dbo.fn__TableExists('tblImage_LIVE') > 0
					)
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
				LEFT JOIN tblProduct_LIVE p ON d.ProductID = p.ProductID
					AND p.BusinessUnitID = @BusUnitID
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
				ORDER BY d.ProductId ASC
			END
			ELSE
			BEGIN
				PRINT 'Missing live tables'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			IF (
					dbo.fn__TableExists('tblDocument') > 0
					OR dbo.fn__TableExists('tblProduct') > 0
					OR dbo.fn__TableExists('tblRegion') > 0
					OR dbo.fn__TableExists('tblImage') > 0
					OR dbo.fn__TableExists('tblAppUser') > 0
					)
			BEGIN
				SELECT d.DocumentID
					,d.ProductID
					,p.ProductName
					,d.RegionID
					,r.RegionName
					,d.DocTitle
					,d.DocPath
					,d.ContentType
					,d.DocumentType
					,d.ActiveFlag
					,UPPER(d.WorkflowStatus) AS 'WorkflowStatus'
					,d.MarkedForDeletion
					,CASE 
						WHEN d.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,d.DeploymentJobID
					,i.ImagePath
					,dbo.fn__GetDateOnly(d.UploadDate) AS 'UploadDate'
					,d.PublishDate
					,d.ExpirationDate
					,d.LastModifiedDate
					,d.LastModifiedBy
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
				FROM tblDocument d
				LEFT JOIN tblProduct p ON d.ProductID = p.ProductID
					AND p.BusinessUnitID = @BusUnitID
				INNER JOIN tblRegion r ON d.RegionID = r.RegionID
				LEFT JOIN tblImage i ON r.ImageID = i.ImageId
				LEFT JOIN tblAppUser u ON d.LastModifiedBy = u.AppUserId
				ORDER BY d.ProductId ASC
			END
			ELSE
			BEGIN
				PRINT 'Missing cms tables'

				RETURN 0
			END
		END
	END
END