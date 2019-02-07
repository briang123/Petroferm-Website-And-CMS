

CREATE  proc sp_NLT_RemoveDefaultFacility
	@UserId int = 0
as
begin

	begin tran

	declare @errorcode int
	select 	@errorcode = @@error
	
	if (@errorcode = 0)
	begin
		update tblUsers
		set DefaultFacility = 0
		where UserId = @UserId

		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
		update tblFacilityUsers 
		set DefaultFacility = 0
		where UserId = @UserId

		select @errorcode = @@error
	end

	if (@errorcode = 0)
	begin
		commit tran
		print 'the default facility was successfully removed'
		print ''
		print 'do not forget to refresh the web cache -- re-save the web.config file'
	end
	else
	begin
		rollback tran
		print 'an error occurred while trying to remove the default facility'
	end
end