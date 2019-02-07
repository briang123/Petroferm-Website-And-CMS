create PROCEDURE [dbo].[sp__GetProductGridModuleByModId] @ProductGridModuleId INT = NULL
	,@LiveMode BIT = 1
AS
/*
created by: Brian Gaines
created on: 12/xx/2006
purpose:
	Return product grid module (and grid info) for a page	

history:
	Brian Gaines (12/xx/2006) - created initial procedure
	Kelly Roe    (12/12/2006) - updated the cms select and fixed bugs
*/
BEGIN
	IF (
			@ProductGridModuleId IS NULL
			OR @ProductGridModuleId = 0
			)
	BEGIN
		PRINT 'A module id is required'

		RETURN 0
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			-- we do not check the business unit's status in the context of the live website because 
			-- we would not be calling this procedure if we weren't ALREADY in an active business unit
			IF (
					dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0
					AND dbo.fn__TableExists('tblProductGridModule_LIVE') > 0
					AND dbo.fn__TableExists('tblProductGrid_LIVE') > 0
					)
			BEGIN
				SELECT pgm.ProductGridModuleID AS 'PGM_ProductGridModuleID'
					,
					--					pgm.ModuleTypeID		as 'PGM_ModuleTypeID', 
					pgm.ProductGridTitle AS 'PGM_GridTitle'
					,pgm.ProductGridBlurb AS 'PGM_GridBlurb'
					,pgm.ProductGridID AS 'PGM_GridID'
					,pgm.ModuleOrder AS 'PGM_ModuleOrder'
					,pg.ProductGridName AS 'PG_GridName'
				FROM tblPageModuleReln_LIVE pm
				INNER JOIN tblProductGridModule_LIVE pgm ON pm.SourceId = pgm.ProductGridModuleID
					AND pgm.ProductGridModuleID = @ProductGridModuleId
				INNER JOIN tblProductGrid_LIVE pg ON pgm.ProductGridID = pg.ProductGridID
				WHERE pm.ActiveFlag = 1
					AND pgm.ActiveFlag = 1
					AND pg.ActiveFlag = 1
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pgm.PublishDate)
						AND dbo.fn__GetDateOnly(pgm.ExpirationDate)
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(pg.PublishDate)
						AND dbo.fn__GetDateOnly(pg.ExpirationDate)
					AND UPPER(pgm.WorkflowStatus) = 'LIVE'
					AND UPPER(pg.WorkflowStatus) = 'LIVE'
					AND UPPER(pm.SourceName) = 'PRODUCT GRID'
				ORDER BY pgm.ModuleOrder ASC

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'Not all live tables exist'

				RETURN 0
			END
		END
		ELSE -- get info for cms
		BEGIN
			IF (
					dbo.fn__TableExists('tblPageModuleReln') > 0
					AND dbo.fn__TableExists('tblProductGridModule') > 0
					AND dbo.fn__TableExists('tblProductGrid') > 0
					)
			BEGIN
				SELECT pgm.ProductGridModuleID AS 'PGM_ProductGridModuleID'
					,pgm.ProductGridTitle AS 'PGM_GridTitle'
					,pgm.ProductGridBlurb AS 'PGM_GridBlurb'
					,pgm.ProductGridID AS 'PGM_GridID'
					,pgm.ModuleOrder AS 'PGM_ModuleOrder'
					,pg.ProductGridName AS 'PG_GridName'
					,pgm.PublishDate
					,pgm.ExpirationDate
					,pgm.WorkflowStatus
					,pgm.LastModifiedDate
					,pgm.LastModifiedBy
					,pgm.MarkedForDeletion
					,u.FirstName + ' ' + u.LastName AS 'LastModifiedByName'
					,CASE 
						WHEN pgm.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END AS 'FmtMarkedForDeletion'
					,pm.PageModuleRelnID
					,pm.ModuleOrder
					,pm.ShowTitle
					,j.DeploymentJobID
					,j.JobName
					,j.JobDescription
				FROM tblPageModuleReln pm
				INNER JOIN tblProductGridModule pgm ON pm.SourceId = pgm.ProductGridModuleID
					AND pgm.ProductGridModuleID = @ProductGridModuleId
				INNER JOIN tblProductGrid pg ON pgm.ProductGridID = pg.ProductGridID
				LEFT JOIN tblAppUser u ON pgm.LastModifiedBy = u.AppUserId
				LEFT JOIN tblDeploymentJobs j ON pgm.DeploymentJobId = j.DeploymentJobId
				WHERE pm.ActiveFlag = 1
					AND pgm.ActiveFlag = 1
					AND pg.ActiveFlag = 1
					AND UPPER(pm.SourceName) = 'PRODUCT GRID'
				ORDER BY pgm.ModuleOrder ASC

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'Not all tables exist'

				RETURN 0
			END
		END
	END
END