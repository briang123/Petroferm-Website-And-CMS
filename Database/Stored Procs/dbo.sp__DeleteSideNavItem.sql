
create proc sp__DeleteSideNavItem
	@ID int = 0,
	@JobID int = 0,
	@UserID int = 0
as
begin

if (@ID = 0 or @ID is null)
begin
	print 'An ID is required'
	return 0
end
else if (@JobId = 0 or @JobId is null)
begin
	print 'A job id is required'
	return 0
end
else if (@UserID = 0 or @UserID is null)
begin
	print 'A user id is required'
	return 0
end
else
  begin

	declare @mark_for_deletion bit

	if (dbo.fn__TableExists('tblSideNav_LIVE') > 0)
	begin
		if exists(select 1 from tblSideNav_LIVE where ID = @ID)
		begin
			select @mark_for_deletion = 1
		end
		else
		begin
			select @mark_for_deletion = 0
		end
	end
	else
	begin
		select @mark_for_deletion = 1
	end

	if (@mark_for_deletion = 1)
	begin
		update 	tblSideNav 
		set 	MarkedForDeletion = 1,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID,
			WorkflowStatus = 'WORKING'
		where	ID = @ID
		and	DeploymentJobID = @JobID
	end
	else
	begin
		delete from tblSideNav where ID = @ID
	end

	if (@@error = 0)
	begin
		return 1
	end
	else
	begin
		return 0
	end
  end
end