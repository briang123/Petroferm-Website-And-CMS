

CREATE  proc sp__DeleteRegistrant
	@UserId uniqueidentifier
as
begin
	begin tran

	declare @errorcode int
	declare @regId int

	select @regId = RegId from tblRegistrant where UserID = @UserId
	delete from tblRegistrant where RegID = @regId
	select @errorcode = @@error

	if (@errorcode = 0)
	begin
		DELETE FROM dbo.aspnet_Membership WHERE @UserId = UserId
		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
		DELETE FROM dbo.aspnet_UsersInRoles WHERE @UserId = UserId
		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
		DELETE FROM dbo.aspnet_Profile WHERE @UserId = UserId
		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
	        DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE @UserId = UserId
		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
		DELETE FROM dbo.aspnet_Users WHERE @UserId = UserId
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