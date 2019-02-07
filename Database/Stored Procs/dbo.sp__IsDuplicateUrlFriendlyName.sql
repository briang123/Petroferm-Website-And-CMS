





CREATE      PROC sp__IsDuplicateUrlFriendlyName
		@FriendlyURL varchar(500) = null,
		@PageID int = null,
		@IsDuplicate bit = 0 OUTPUT
as
begin
declare @rec_count as int
/*
created by: Kelly Roe
created on: 12/21/2006
purpose:
	Checks to see if the url friendly name is a duplicate

history:
	Kelly Roe   (12/21/2006) - created initial stored procedure

*/

	begin
		select @rec_count = count(*) 
		from	tblUrlRewrite
		where	lower(UrlFriendlyName) = lower(@FriendlyURL)
		and	PageID <> @PageID
		and	ActiveFlag = 1
		
		if (@rec_count > 0)
		begin
			select @IsDuplicate = 1
		end
		else
		begin
			select @IsDuplicate = 0
		end
	END
END