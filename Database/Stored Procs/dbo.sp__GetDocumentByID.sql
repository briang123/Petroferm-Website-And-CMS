create PROCEDURE [dbo].[sp__GetDocumentByID] @DocID INT = NULL
	,@UserID INT = 0
	,@URL VARCHAR(500) = 'UNKNOWN'
	,@LiveMode BIT = 1
AS
BEGIN
	IF (@DocID IS NULL)
	BEGIN
		PRINT 'You must supply a document Id in order to get the document.'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			-- track who and when a document is being downloaded
			INSERT INTO tblDocumentStats (
				DocumentID
				,DownloadedBy
				,ReferringURL
				)
			VALUES (
				@DocID
				,@UserID
				,@URL
				)

			-- get the document based on whether it's supposed to be active on the live website
			SELECT d.DocumentID
				,d.DocTitle
				,d.DocPath
				,d.ContentType
				,d.DocumentType
				,d.RegionID
			FROM tblDocument_LIVE d
			WHERE d.DocumentID = @DocID
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(d.PublishDate)
					AND dbo.fn__GetDateOnly(d.ExpirationDate)
				AND upper(d.WorkflowStatus) = 'LIVE'
				AND d.ActiveFlag = 1
		END
		ELSE
		BEGIN
			-- CMS Mode, which we don't care about tracking stats, nor whether the file is supposed to be active or not
			SELECT d.DocumentID
				,d.DocTitle
				,d.DocPath
				,d.ContentType
				,d.DocumentType
				,d.RegionID
				,d.UploadDate
				,d.WorkflowStatus
				,d.MarkedForDeletion
				,CASE 
					WHEN d.MarkedForDeletion = 1
						THEN 'Yes'
					ELSE 'No'
					END AS FmtMarkedForDeletion
				,d.PublishDate
				,d.ExpirationDate
				,d.LastModifiedDate
				,d.LastModifiedBy
				,u.FirstName + ' ' + u.LastName AS LastModifiedByName
				,d.DeploymentJobId
				,j.JobName
				,j.JobDescription
			FROM tblDocument d
			LEFT JOIN tblDeploymentJobs j ON d.DeploymentJobID = j.DeploymentJobID
			LEFT JOIN tblAppUser u ON d.LastModifiedBy = u.AppUserId
			WHERE d.DocumentID = @DocID
				AND d.ActiveFlag = 1
		END
	END
END