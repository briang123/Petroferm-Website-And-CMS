



CREATE    proc sp__GetFriendlyUrlByDomain
		@DomainName varchar(200) = null,
		@UrlFriendlyName varchar(500) OUTPUT
as
begin
/*
created by: Kelly Roe
created on: 12/27/2006
purpose:
	Gets the friendly url by domain (involves the tblUrlRewrite and tblDomainMapping_U tables)

history:
	Kelly Roe   (12/27/2006) - created initial procedure
*/


	select 	@UrlFriendlyName = isnull(u.UrlFriendlyName,'') 
	from 	tblUrlRewrite_LIVE u, 
		tblDomainMapping_U d
	where 	UPPER(d.DomainName) = UPPER(@DomainName)
	and	u.PageID = d.PageID
	and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(u.PublishDate) and dbo.fn__GetDateOnly(u.ExpirationDate)
	and	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(d.PublishDate) and dbo.fn__GetDateOnly(d.ExpirationDate)
	and	UPPER(u.WorkflowStatus) = 'LIVE' 
	and 	u.ActiveFlag = 1 and d.ActiveFlag = 1 


end