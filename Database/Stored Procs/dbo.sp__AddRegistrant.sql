
CREATE proc sp__AddRegistrant
	@UserID uniqueidentifier,
	@FullName varchar(150) = null,
	@RegionId int = null,
	@CompanyName varchar(300) = null,
	@ActiveFlag bit = 0,
	@LastModBy int = 0,
	@RegId int output
as
begin
	declare @errorcode int

	insert into tblRegistrant (UserId, FullName, RegionId, Company, LastModifiedBy, ActiveFlag)
	values (@UserId, @FullName, @RegionId, @CompanyName, @LastModBy, @ActiveFlag)

	select @errorcode = @@error

	if (@errorcode = 0)
	begin
		select @RegId = @@identity
	end	
	else
	begin
		select @RegId = 0
	end
end