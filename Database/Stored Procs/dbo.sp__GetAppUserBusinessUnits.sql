

CREATE proc sp__GetAppUserBusinessUnits
	@UserID uniqueidentifier
as
begin
	select b.BusinessUnitID, b.BusinessUnitName
	from tblBusinessUnit b, tblBusinessAppUser u, tblAppUser au
	where u.BusinessUnitID = b.BusinessUnitID
	and u.AppUserID = au.AppUserId
	and au.UserID = @UserID
	order by b.BusinessUnitName asc
end