





CREATE      proc sp__AddDeploymentJob
	@UserID int,
	@JobName varchar(100),
	@JobDescription varchar(500),
	@WorkflowStatus varchar(50) = 'WORKING',
	@DeploymentDate datetime,
	@ApprovedBy int,
	@DeployedBy int,
	@ReviewBy int,
	@JobId int OUTPUT
as
begin

begin tran

	declare @userName varchar(150),
		@errorcode int
	
	select 	@errorcode = @@error
	select 	@userName = FirstName + ' ' + LastName from tblAppUser where AppUserId = @UserID

	insert into tblDeploymentJobs (JobName, JobDescription, ReviewBy, ApprovedBy, DeploymentDate, DeployedBy, WorkflowStatus, LastModifiedBy, ActiveFlag)
	values (@JobName, @JobDescription, @ReviewBy, @ApprovedBy, @DeploymentDate, @DeployedBy, @WorkflowStatus, @UserID, 1 )

	select @JobId = @@identity
	select @errorcode = @@error

	if (@errorcode = 0)
	begin

		-- update the workflow audit table so we can track the path a deployment job takes to get to a live state
		INSERT INTO tblWorkflowAudit_U (DeploymentJobId, WorkflowStatus, StatusChangedBy, StatusChangeDate, LastModifiedBy) 
		VALUES (@JobId, @WorkflowStatus, @userName, getdate(), @UserId)

		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
		commit tran
		return 1
	end
	else
	begin	
		rollback tran
		return 0
	end
end