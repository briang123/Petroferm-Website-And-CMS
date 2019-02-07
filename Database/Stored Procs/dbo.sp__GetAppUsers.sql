

CREATE proc sp__GetAppUsers
as
begin
	select 	m.UserId,
		mu.UserName,
		u.AppUserId,
		u.FirstName,
		u.LastName,
		m.Email,
		m.PasswordQuestion,
		m.PasswordAnswer,
		m.IsApproved,
		m.IsLockedOut,
		m.CreateDate,
		m.LastLoginDate,
		m.LastPasswordChangedDate,
		m.LastLockoutDate,
		m.FailedPasswordAttemptCount,
		m.FailedPasswordAnswerAttemptCount,
		m.Comment
	from 	dbo.aspnet_Membership m,
		dbo.aspnet_Users mu,
		tblAppUser u
	where	u.UserId = mu.UserId
	and	mu.UserId = m.UserId
	order by mu.UserName asc
end