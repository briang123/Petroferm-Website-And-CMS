

CREATE proc sp__GetAppUserBUDefault
	@UserID uniqueidentifier,
	@BusUnitID int output
as
begin
	if exists (select BusinessUnitID from tblBusinessAppUser u, tblAppUser au
			where u.AppUserID = au.AppUserId and au.UserID = @UserID and u.IsDefault = 1)
	begin
		select @BusUnitID = BusinessUnitID
		from tblBusinessAppUser u, tblAppUser au
		where u.AppUserID = au.AppUserId
		and au.UserID = @UserID
		and u.IsDefault = 1
	end
	else
	begin
		select @BusUnitID = 0
	end
end