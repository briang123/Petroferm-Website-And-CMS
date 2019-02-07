
CREATE proc sp__AddDocumentModuleForPage
	@PageId int = 0,
	@DocumentId int = 0,
	@SectionId int = 0	
as
begin

begin tran

	declare @errorcode int
	select @errorcode = @@error

	if (@errorcode = 0)
	begin
		print 'pending sp__AddWebPage proc to be completed'
		
	end

	if (@errorcode = 0)
	begin

		print 'exec the sp__AddSideNavItem'

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