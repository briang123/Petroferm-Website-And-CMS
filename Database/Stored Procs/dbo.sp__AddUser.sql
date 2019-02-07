
CREATE proc sp__AddUser
	@LastModBy int,
	@UserId uniqueidentifier,
	@FirstName varchar(50),
	@LastName varchar(100),
	@AppUserID int OUTPUT
as
begin
	declare @errorcode int

	insert into tblAppUser (UserID, FirstName, LastName, LastModifiedBy)
	values (@UserID, @FirstName, @LastName, @LastModBy)

	select @errorcode = @@error

	if (@errorcode = 0)
	begin
		select @AppUserID = @@identity
		return 1
	end	
	else
	begin
		select @AppUserID = 0
		return 0
	end
end