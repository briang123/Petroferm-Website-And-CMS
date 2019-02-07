create PROCEDURE [dbo].[sp__GetProductBlurbModuleByID] @ProductBlurbModuleId INT = NULL
	,@LiveMode BIT = 1
AS
BEGIN
	/*
created by: Brian Gaines
created on: 12/10/2006
purpose:
	Return product blurb for a page	

history:
	Brian Gaines (12/10/2006) - created initial procedure
	Kelly Roe    (12/10/2006) - updated the cms select
*/
	IF (
			@ProductBlurbModuleId IS NULL
			OR @ProductBlurbModuleId = 0
			)
	BEGIN
		PRINT 'A product blurb id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (
					dbo.fn__TableExists('tblProductBlurbModule_LIVE') > 0
					AND dbo.fn__TableExists('tblProductBlurbModuleReln_LIVE') > 0
					)
			BEGIN
				DECLARE @prodSelection VARCHAR(15)

				SELECT @prodSelection = UPPER(ProductSelection)
				FROM tblProductBlurbModule_LIVE
				WHERE ProductBlurbModuleId = @ProductBlurbModuleId

				IF (@prodSelection = 'INDIVIDUAL')
				BEGIN
					SELECT pbm.ProductBlurbModuleId
						,pbm.ProductSelection
						,p.ProductId
						,p.ProductName
						,p.ProductBlurb
						,pbm.Title
						,pbm.PublishDate
						,pbm.ExpirationDate
						,pbm.WorkflowStatus
						,pbm.LastModifiedDate
						,pbm.LastModifiedBy
						,pbm.MarkedForDeletion
						,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
						,CASE 
							WHEN pbm.MarkedForDeletion = 1
								THEN 'Yes'
							ELSE 'No'
							END AS 'FmtMarkedForDeletion'
						,pm.PageModuleRelnID
						,pm.ModuleOrder
						,pm.ShowTitle
						,j.DeploymentJobID
						,j.JobName
						,j.JobDescription
					FROM tblProductBlurbModule_LIVE pbm
					INNER JOIN tblProduct_LIVE p ON pbm.SourceId = p.ProductId
					INNER JOIN tblPageModuleReln_LIVE pm ON pm.SourceId = pbm.ProductBlurbModuleId
					LEFT JOIN tblAppUser u ON pbm.LastModifiedBy = u.AppUserId
					LEFT JOIN tblDeploymentJobs j ON pbm.DeploymentJobId = j.DeploymentJobId
					WHERE pbm.ProductBlurbModuleId = @ProductBlurbModuleId
						AND pbm.ActiveFlag = 1
						AND pm.ActiveFlag = 1
						AND p.ActiveFlag = 1
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pbm.PublishDate)
							AND dbo.fn__GetDateOnly(pbm.ExpirationDate)
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pm.PublishDate)
							AND dbo.fn__GetDateOnly(pm.ExpirationDate)
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(p.PublishDate)
							AND dbo.fn__GetDateOnly(p.ExpirationDate)
						AND UPPER(pbm.WorkflowStatus) = 'LIVE'
						AND UPPER(pm.WorkflowStatus) = 'LIVE'
						AND UPPER(p.WorkflowStatus) = 'LIVE'
						AND UPPER(pbm.ProductSelection) = 'INDIVIDUAL'
						AND UPPER(pm.SourceName) = 'PRODUCT BLURB'
					ORDER BY pm.ModuleOrder
						,p.ProductName ASC
				END
				ELSE
				BEGIN
					SELECT pbm.ProductBlurbModuleId
						,pbm.ProductSelection
						,pbm.ProductBlurb
						,p.ProductId
						,p.ProductName
						,pbm.Title
						,pbm.PublishDate
						,pbm.ExpirationDate
						,pbm.WorkflowStatus
						,pbm.LastModifiedDate
						,pbm.LastModifiedBy
						,pbm.MarkedForDeletion
						,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
						,CASE 
							WHEN pbm.MarkedForDeletion = 1
								THEN 'Yes'
							ELSE 'No'
							END AS 'FmtMarkedForDeletion'
						,pm.PageModuleRelnID
						,pm.ModuleOrder
						,pm.ShowTitle
						,j.DeploymentJobID
						,j.JobName
						,j.JobDescription
					FROM tblProductBlurbModule_LIVE pbm
					INNER JOIN tblProductBlurbModuleReln_LIVE pbmr ON pbm.SourceId = pbmr.ProductBlurbModuleId
					INNER JOIN tblProduct_LIVE p ON pbmr.ProductId = p.ProductId
					INNER JOIN tblPageModuleReln_LIVE pm ON pm.SourceId = pbm.ProductBlurbModuleId
					LEFT JOIN tblAppUser u ON pbm.LastModifiedBy = u.AppUserId
					LEFT JOIN tblDeploymentJobs j ON pbm.DeploymentJobId = j.DeploymentJobId
					WHERE pbm.ProductBlurbModuleId = @ProductBlurbModuleId
						AND pbm.ActiveFlag = 1
						AND pm.ActiveFlag = 1
						AND p.ActiveFlag = 1
						AND pbmr.ActiveFlag = 1
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pbm.PublishDate)
							AND dbo.fn__GetDateOnly(pbm.ExpirationDate)
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pbmr.PublishDate)
							AND dbo.fn__GetDateOnly(pbmr.ExpirationDate)
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pm.PublishDate)
							AND dbo.fn__GetDateOnly(pm.ExpirationDate)
						AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(p.PublishDate)
							AND dbo.fn__GetDateOnly(p.ExpirationDate)
						AND UPPER(pbm.WorkflowStatus) = 'LIVE'
						AND UPPER(pm.WorkflowStatus) = 'LIVE'
						AND UPPER(p.WorkflowStatus) = 'LIVE'
						AND UPPER(pbmr.WorkflowStatus) = 'LIVE'
						AND UPPER(pbm.ProductSelection) = 'MULTIPLE'
						AND UPPER(pm.SourceName) = 'PRODUCT BLURB'
					ORDER BY pm.ModuleOrder
						,p.ProductName ASC
				END
			END
		END
		ELSE
		BEGIN
			IF (
					dbo.fn__TableExists('tblPageModuleReln') > 0
					AND dbo.fn__TableExists('tblProductBlurbModule') > 0
					)
			BEGIN
				SELECT pm.PageModuleRelnId
					,pm.PageId
					,pm.ModuleOrder
					,pm.ShowTitle
					,pbm.ProductBlurbModuleId
					,pbm.SourceID
					,pbm.ProductSelection
					,pbm.Title
					,pbm.ProductBlurb
					,pbm.PublishDate
					,pbm.ExpirationDate
					,pbm.WorkflowStatus
					,pbm.LastModifiedDate
					,pbm.LastModifiedBy
					,pbm.MarkedForDeletion
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,CASE 
						WHEN pbm.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,j.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblProductBlurbModule pbm
				INNER JOIN tblPageModuleReln pm ON pm.SourceId = pbm.ProductBlurbModuleId
				LEFT JOIN tblAppUser u ON pbm.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON pbm.DeploymentJobId = j.DeploymentJobId
				WHERE pbm.ProductBlurbModuleId = @ProductBlurbModuleId
					AND pbm.ActiveFlag = 1
					AND pm.ActiveFlag = 1
					AND UPPER(pm.SourceName) = 'PRODUCT BLURB'

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'You are missing CMS tables'

				RETURN 0
			END
		END
	END
END