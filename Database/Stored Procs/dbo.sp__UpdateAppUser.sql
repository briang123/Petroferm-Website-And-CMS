
CREATE proc sp__UpdateAppUser
	@UserId uniqueidentifier,
	@FirstName varchar(50),
	@LastName varchar(100),
	@LastModBy int
as
begin

	update 	tblAppUser
	set	FirstName = @FirstName,
		LastName = @LastName,
		LastModifiedDate = getdate(),
		LastModifiedBy = @LastModBy
	where 	UserId = @UserId
end