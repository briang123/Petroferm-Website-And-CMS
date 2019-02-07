
CREATE proc sp__GetActiveBusinessUnitsByUserID
	@UserID int = 0
as
begin
	select 	b.BusinessUnitID, b.BusinessUnitName
	from 	tblBusinessUnit b,
		tblBusinessAppUser r,
		tblAppUser u
	where	b.BusinessUnitId = r.BusinessUnitId
	and	u.AppUserId = r.AppUserId
	and	r.ActiveFlag = 1
	and	u.AppUserId = @UserID
	order by b.BusinessUnitName asc
end