
create proc sp__UpdateDeploymentJobToWorkingStatus
	@UserId int = null,
	@JobId int = null
as
begin

	if (@UserId is null or @UserId = 0)
	begin
		print 'A user id is required'
		return 0
	end
	else if(@JobId is null or @JobId = 0)
	begin
		print 'A job id is required'
		return 0
	end

	update 	tblDeploymentJobs
	set 	WorkflowStatus = 'WORKING', LastModifiedDate = getdate(), LastModifiedBy = @UserID 
	where 	DeploymentJobID = @JobID

end