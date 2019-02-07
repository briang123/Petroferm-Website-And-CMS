
CREATE proc sp__UpdateAppUserDefaultBU
	@UserID uniqueidentifier,
	@BusUnitID int = 0,
	@IsDefault bit = 0,
	@LastModBy int = 0
as
begin
	begin tran

	declare @errorcode int
	declare @appUserId int

	select @appUserId = AppUserId from tblAppUser where UserId = @UserId

	update 	tblBusinessAppUser 
	set 	IsDefault = 0,
		LastModifiedDate = getdate(),
		LastModifiedBy = @LastModBy
	where 	AppUserId = @AppUserID

	select @errorcode = @@error

	if (@errorcode = 0)
	begin

		update 	tblBusinessAppUser 
		set 	IsDefault = @IsDefault,
			LastModifiedDate = getdate(),
			LastModifiedBy = @LastModBy
		where 	AppUserId = @AppUserID
		and	BusinessUnitID = @BusUnitID
	
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