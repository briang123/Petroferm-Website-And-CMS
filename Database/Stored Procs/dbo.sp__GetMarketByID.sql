create PROCEDURE [dbo].[sp__GetMarketByID] @MarketID INT = NULL
	,@LiveMode BIT = 1
	,@BusUnitID INT OUTPUT
	,@MarketName VARCHAR(100) OUTPUT
	,@MarketOrder INT OUTPUT
	,@WorkflowStatus VARCHAR(50) OUTPUT
	,@MarkedForDeletion BIT OUTPUT
	,@FmtMarkedForDeletion VARCHAR(3) OUTPUT
	,@PublishDate DATETIME OUTPUT
	,@ExpireDate DATETIME OUTPUT
	,@LastModifiedDate DATETIME OUTPUT
	,@LastModifiedBy INT OUTPUT
	,@LastModifiedByName VARCHAR(150) OUTPUT
	,@JobID INT OUTPUT
	,@JobName VARCHAR(100) OUTPUT
	,@JobDescription VARCHAR(500) OUTPUT
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/30/2006
purpose:

usage syntax:
declare @buid int,
	@mktName varchar(100),
	@mktOrder int,
	@wfStatus varchar(50),
	@markDel bit,
	@f_markDel varchar(3),
	@pubDate datetime,
	@expDate datetime,
	@lmodDate datetime,
	@lmodby int,
	@lmodbyName varchar(150),
	@jid int,
	@jobName varchar(100),
	@jobDesc varchar(500)

exec sp__GetMarketByID
	@MarketID = 1,
	@LiveMode = 0,
	@BusUnitID = @buid OUTPUT,
	@MarketName = @mktName OUTPUT,
	@MarketOrder = @mktOrder OUTPUT,
	@WorkflowStatus = @wfStatus OUTPUT,
	@MarkedForDeletion = @markDel OUTPUT,
	@FmtMarkedForDeletion = @f_markDel OUTPUT,
	@PublishDate = @pubDate OUTPUT,
	@ExpireDate = @expDate OUTPUT,
	@LastModifiedDate = @lmodDate OUTPUT,
	@LastModifiedBy = @lmodby OUTPUT,
	@LastModifiedByName = @lmodbyName OUTPUT,
	@JobID = @jid OUTPUT,
	@JobName = @jobName OUTPUT,
	@JobDescription = @jobDesc OUTPUT

select 	@buid, @mktName, @mktOrder, @wfStatus, @markDel, @f_markDel, @pubDate, 
	@expDate, @lmodDate, @lmodby, @lmodbyName, @jid, @jobName, @jobDesc

history:
	Brian Gaines (11/30/2006) - created initial procedure
*/
	IF (
			@MarketID IS NULL
			OR @MarketID = 0
			)
	BEGIN
		PRINT 'A market is required.'
	END
	ELSE
	BEGIN
		IF (@LiveMode = 1)
		BEGIN
			IF (dbo.fn__TableExists('tblMarket_LIVE') > 0)
			BEGIN
				SELECT @BusUnitID = BusinessUnitID
					,@MarketName = MarketName
					,@MarketOrder = MarketOrder
				FROM tblMarket_LIVE
				WHERE MarketID = @MarketID
					AND dbo.fn__GetDateOnly(getdate()) BETWEEN dbo.fn__GetDateOnly(PublishDate)
						AND dbo.fn__GetDateOnly(ExpirationDate)
					AND upper(WorkflowStatus) = 'LIVE'
					AND ActiveFlag = 1

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'The LIVE tables must exist.'

				RETURN 0
			END
		END
		ELSE
		BEGIN
			IF (
					dbo.fn__TableExists('tblMarket') > 0
					AND dbo.fn__TableExists('tblAppUser') > 0
					AND dbo.fn__TableExists('tblDeploymentJobs') > 0
					)
			BEGIN
				SELECT @BusUnitID = m.BusinessUnitID
					,@MarketName = m.MarketName
					,@MarketOrder = m.MarketOrder
					,@WorkflowStatus = m.WorkflowStatus
					,@MarkedForDeletion = m.MarkedForDeletion
					,@FmtMarkedForDeletion = CASE 
						WHEN m.MarkedForDeletion = 1
							THEN 'Yes'
						ELSE 'No'
						END
					,@PublishDate = m.PublishDate
					,@ExpireDate = m.ExpirationDate
					,@LastModifiedDate = m.LastModifiedDate
					,@LastModifiedBy = m.LastModifiedBy
					,@LastModifiedByName = u.FirstName + ' ' + u.LastName
					,@JobId = m.DeploymentJobId
					,@JobName = j.JobName
					,@JobDescription = j.JobDescription
				FROM tblMarket m
				LEFT JOIN tblDeploymentJobs j ON m.DeploymentJobID = j.DeploymentJobID
				LEFT JOIN tblAppUser u ON m.LastModifiedBy = u.AppUserId
				WHERE m.MarketID = @MarketID
					AND m.ActiveFlag = 1

				RETURN 1
			END
			ELSE
			BEGIN
				PRINT 'The CMS tables must exist.'

				RETURN 0
			END
		END
	END
END