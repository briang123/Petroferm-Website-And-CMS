

CREATE  proc sp__UpdateDeploymentJob
	@UserID int,
	@JobId int,
	@JobName varchar(100),
	@JobDescription varchar(500),
	@WorkflowStatus varchar(50),
	@DeploymentDate datetime,
	@ApprovedBy int,
	@DeployedBy int,
	@ReviewBy int,
	@ActiveFlag bit = 1
as
begin
	update 	tblDeploymentJobs
	set	JobDescription = @JobDescription, 
		JobName = @JobName,
		ReviewBy = @ReviewBy, 
		ApprovedBy = @ApprovedBy, 
		DeploymentDate = dbo.fn__GetDateOnly(@DeploymentDate), 
		DeployedBy = @DeployedBy, 
		WorkflowStatus = @WorkflowStatus,
		LastModifiedDate = getdate(),
		LastModifiedBy = @UserID, 
		ActiveFlag = @ActiveFlag
	where	DeploymentJobID = @JobId

	if (@@error = 0)
	begin
		return 1
	end
	else
	begin
		return 0
	end
end