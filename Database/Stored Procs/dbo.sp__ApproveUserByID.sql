

CREATE proc sp__ApproveUserByID
	@UserId uniqueidentifier,
	@IsApproved bit = 0
as
begin
	update dbo.aspnet_Membership
	set IsApproved = @IsApproved
	where UserId = @UserId
end