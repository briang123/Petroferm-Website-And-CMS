create           proc [dbo].[sp__AddURLRewritePath]
	@PageID int = null,
	@ProdCatID int = 0,
	@UrlPathOverride varchar(500) = '',
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@UserID int = null,
	@MarkedForDeletion bit = 0,
	@JobID int = null,
	@IsPetro bit = 0,
	@UrlRewriteID int output
as
begin
/*
created by: Brian Gaines
created on: 12/01/2006
purpose:
	To insert a user friendly web URL so visitors (including search engines) have a more
	logical way of navigating the website:

	typing the following may map to the following page (example)
	http://www.petroferm.com/cleaning.aerospace.application.defluxing.aspx ==>
	http://www.petroferm.com/default.aspx?bus=1&mkt=3&type=3&pageID=72

parameters:
	@PageId - PageID for which we need to build our friendly URL
	@UrlPathOverride - User has the ability to enter their own friendly URL opposed to the one 
		that is auto-generated based on the hiearchy of the page to the site.
	@UrlRewriteID - An output parameter to return the primary key of the URL just inserted

usage example:
	declare @urlid int

	exec sp__AddURLRewritePath 2, null, null, null, 'WORKING', 1, 0, 1, 0, @UrlRewriteID = @urlId output

	select @urlId

history:
	Brian Gaines (12/01/2006) - created initial procedure
	Kelly Roe    (12/19/2006) - added code for handling null publish/expire dates
*/
	
if (@PageID is null or @PageID = 0)
begin
	print 'A page id is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else if (@JobId is null or @JobId = 0)
begin
	print 'A job id is required'
	return 0
end
else
begin

	if (dbo.fn__TableExists('tblUrlRewrite') > 0)
	begin




		if (@PublishDate is null)
		begin
			select @PublishDate = dbo.fn__GetDateOnly(getdate())
		end
		else
		begin
			select @Publishdate = dbo.fn__GetDateOnly(@PublishDate)
		end
		
		if (@ExpireDate is null)
		begin
			select @ExpireDate = dbo.fn__GetDateOnly(dateadd(year,30,@PublishDate))
		end
		else
		begin
			select @ExpireDate = dbo.fn__GetDateOnly(@ExpireDate)
		end




			
		declare @bus varchar(100),
			@mkt varchar(100),
			@prodType varchar(50),
			@pageTitle varchar(100),
			@linkToTitle varchar(50),
			@prodCatType varchar(50),
			@rewritePath varchar(500)

		select	@rewritePath = ''

		if (@UrlPathOverride <> '')
		begin
			select @rewritePath = replace(replace(replace(replace(replace(replace(lower(isnull(@UrlPathOverride,'')),' ','-'),'/','-'),'.aspx',''),',',''),'&','-and-'),'!','') + '.aspx'
		end
		else
		begin
			select 	@bus = replace(replace(replace(replace(replace(replace(b.BusinessUnitName,'.',''),' ','-'),'/','-'),',',''),'&','-and-'),'!',''),
				@mkt = replace(replace(replace(replace(replace(replace(isnull(m.MarketName,''),'.',''),' ','-'),'/','-'),',',''),'&','-and-'),'!',''),
				@pageTitle = replace(replace(replace(replace(replace(replace(isnull(p.PageTitle,''),'.',''),' ','-'),'/','-'),',',''),'&','-and-'),'!','')
			from 	tblPage p
inner join tblBusinessUnit b on p.BusinessUnitID = b.BusinessUnitID
left outer join tblMarket m on p.MarketID = m.MarketID
			where	p.PageID = @PageID


			if (@bus <> '')
			begin
				if (@IsPetro = 1)
				begin	-- special case
					select @bus = 'petroferm'
				end

				select @rewritePath = @bus + '.'
			end
			
			if (@mkt <> '')
			begin
				select @rewritePath = @rewritePath + @mkt + '.'
			end		

			if (@prodCatId > 0)
			begin
				select @prodCatType = replace(replace(replace(replace(replace(replace(lower(isnull(pc.CategoryName,'')),'.',''),' ','-'),'/','-'),',',''),'&','-and-'),'!','')
				from tblSideNavProdCategory pc inner join tblSideNav n on pc.ProdCatId = n.ProdCatId
				where pc.ProdCatId = @prodCatId

				if (@prodCatType <> '')
				begin
					select @rewritePath = @rewritePath + @prodCatType + '.'
				end
			end

			if (@pageTitle <> '')
			begin
				select @rewritePath = @rewritePath + @pageTitle + '.'
			end

			if (@rewritePath <> '')
			begin			
				select @rewritePath = lower(@rewritePath) + 'aspx'
			end
		end

		-- check to see if the friendly url name exists already
		if exists(select 1 from tblUrlRewrite where lower(UrlFriendlyName) = lower(@rewritePath))
		begin

			select @rewritePath = replace(@rewritePath, '.aspx', '-' + cast(@PageId as varchar(5)) + '.aspx')
		end


		insert into tblURLRewrite (PageID, UrlFriendlyName, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, MarkedForDeletion, DeploymentJobId)
		values (@PageID, @rewritePath, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, @MarkedForDeletion, @JobId)

		select @UrlRewriteID = @@identity
		return 1	




	end
	else
	begin
		print 'The table does not exist.'
		return 0
	end	
	
end

end