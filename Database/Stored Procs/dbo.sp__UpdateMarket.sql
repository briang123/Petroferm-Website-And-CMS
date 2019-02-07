
CREATE  proc sp__UpdateMarket
	@MktID int = null,
	@MktName varchar(100) = null,
	@MktOrder int = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@UserID int = null,
	@ActiveFlag bit = 1,
	@JobID int = null
as
begin

	UPDATE 	tblMarket
	SET 	MarketName = @MktName,
		MarketOrder = @MktOrder,
		PublishDate = @PublishDate,
		ExpirationDate = @ExpireDate,
		WorkflowStatus = @WorkflowStatus,
		LastModifiedDate = getdate(),
		LastModifiedBy = @UserID,
		ActiveFlag = @ActiveFlag,
		DeploymentJobID = @JobID
	WHERE 	MarketID = @MktID

	if (@@error = 0)
	begin
		return 1
	end
	else
	begin
		return 0
	end
end