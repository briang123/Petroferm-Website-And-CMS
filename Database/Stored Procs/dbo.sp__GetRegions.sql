create PROCEDURE [dbo].[sp__GetRegions] @LiveMode INT = 1
AS
BEGIN
	/*
created by: Kelly Roe
created on: 12/07/2006
purpose:
	Returns a list of regions

history:
	Kelly Roe   (12/07/2006) - created initial procedure
	Brian Gaines (12/16/2006) - updated livemode = 1 select -- created it
*/
	IF (@LiveMode = 1)
	BEGIN
		IF (
				dbo.fn__TableExists('tblRegion_LIVE') > 0
				AND dbo.fn__TableExists('tblDeploymentJobs') > 0
				)
		BEGIN
			SELECT r.RegionID
				,r.RegionName
				,i.imagepath
			FROM tblRegion_live r
			LEFT JOIN tblimage_live i ON r.imageid = i.imageid
			WHERE dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(r.PublishDate)
					AND dbo.fn__GetDateOnly(r.ExpirationDate)
				AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(i.PublishDate)
					AND dbo.fn__GetDateOnly(i.ExpirationDate)
				AND upper(r.WorkflowStatus) = 'LIVE'
				AND upper(i.WorkflowStatus) = 'LIVE'
				AND r.ActiveFlag = 1
				AND i.activeflag = 1
			ORDER BY r.RegionName
		END
	END
	ELSE
	BEGIN
		IF (dbo.fn__TableExists('tblRegion') > 0)
		BEGIN
			-- just bring back id and name where active=1 
			-- it's only needed for a dropdown list on product doc page for now
			SELECT r.RegionID
				,r.RegionName
			FROM tblRegion r
			WHERE r.ActiveFlag = 1
			ORDER BY r.RegionName
		END
	END
END