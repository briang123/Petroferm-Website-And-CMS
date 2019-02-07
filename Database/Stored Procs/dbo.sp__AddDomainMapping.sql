
CREATE  proc sp__AddDomainMapping
	@DomainName varchar(200), 
	@Website varchar(100), 
	@PageID int, 
	@PublishDate datetime = null, 
	@ExpirationDate datetime = null, 
	@ActiveFlag bit = 1, 
	@LastModifiedBy int,
	@ID int output
as
begin

	if (@PublishDate is null)
	begin
		select @PublishDate = dbo.fn__GetDateOnly(getdate())
	end
	else
	begin
		select @Publishdate = dbo.fn__GetDateOnly(@PublishDate)
	end

	if (@ExpirationDate is null)
	begin
		select @ExpirationDate = dbo.fn__GetDateOnly(dateadd(year,30,@PublishDate))
	end
	else
	begin
		select @ExpirationDate = dbo.fn__GetDateOnly(@ExpirationDate)
	end

	insert into tblDomainMapping_U (DomainName, Website, PageID, PublishDate, ExpirationDate, ActiveFlag, LastModifiedDate, LastModifiedBy)
	values (@DomainName, @Website, @PageID, @PublishDate, @ExpirationDate, @ActiveFlag, getdate(), @LastModifiedBy)

	select @ID = @@identity
end