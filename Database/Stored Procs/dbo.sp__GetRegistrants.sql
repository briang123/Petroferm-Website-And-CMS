

create proc sp__GetRegistrants
as
begin
	select 	m.UserId,
		mu.UserName,
		r.RegID as 'AppUserID',
		r.FullName,
		isnull(r.Company,'') as 'Company',
		m.Email,
		r.Phone,
		isnull(rgn.RegionName,'') as 'Region',
		m.IsApproved,
		m.IsLockedOut,
		m.CreateDate,
		m.LastLoginDate,
		m.LastPasswordChangedDate,
		m.LastLockoutDate,
		m.FailedPasswordAttemptCount,
		m.FailedPasswordAnswerAttemptCount,
		m.Comment
	from tblRegistrant r inner join dbo.aspnet_Users mu on r.UserId = mu.UserId
	inner join dbo.aspnet_Membership m on mu.UserId = m.UserId
	left outer join tblRegion rgn on r.RegionId = rgn.RegionId 
	where	r.ActiveFlag = 1
	order by mu.UserName asc
end