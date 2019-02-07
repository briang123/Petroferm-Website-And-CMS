
CREATE proc sp__AddBusinessAppUser
	@UserID uniqueidentifier,
	@BusUnitIDList varchar(100) = '',
	@ActiveFlag bit = 1,
	@LastModBy int = 0
as
begin

	begin tran

	declare @errorcode int,
		@appUserId int

	select @appUserId = AppUserID from tblAppUser where UserId = @UserID

	delete from tblBusinessAppUser 
	where AppUserId = @appUserId

	select @errorcode = @@error

	if (@errorcode = 0)
	begin
		insert into tblBusinessAppUser (AppUserID, BusinessUnitID, IsDefault, ActiveFlag, LastModifiedBy)
		select @appUserId, str, 0, @ActiveFlag, @LastModBy
		from dbo.fn__CharListToTable(@BusUnitIDList,',')
	
		select @errorcode = @@error
	end	

	if (@errorcode = 0)
	begin
		commit tran
		return 1
	end	
	else
	begin
		rollback tran
		return 0
	end
end