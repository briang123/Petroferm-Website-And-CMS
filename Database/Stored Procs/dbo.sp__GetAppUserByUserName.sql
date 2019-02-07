



--sp__GetAppUserByUserName 'kelly'

CREATE     PROC sp__GetAppUserByUserName
		@UserName varchar(256) = null
as
begin

/*
created by: Kelly Roe
created on: 12/16/2006
purpose:
	Returns a single deployment job by its id

history:
	Kelly Roe   (12/16/2006) - created initial stored procedure

*/

	if (@UserName is null or @UserName = '')
	begin
		print 'A user name is required.'
	end
	else 
	begin

		select  au.AppUserID,
			au.FirstName,
			au.LastName,
			au.Phone,
			au.Fax,
			u.UserName,
			u.UserId
		from 	aspnet_Users u,
			tblAppUser au
		where   LOWER(u.UserName) = LOWER(@UserName)
		and	u.UserId = au.UserID

	END
END