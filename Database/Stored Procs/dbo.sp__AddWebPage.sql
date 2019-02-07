



CREATE  proc sp__AddWebPage
	@BusUnitID int = null, 
	@MarketID int = 0, 
	@PageType varchar(50) = 'GENERAL CONTENT', 
	@PageTitle varchar(100) = null, 
	@MetaKeywords varchar(1500) = null, 
	@MetaDescription varchar(500) = null, 
	@PassthroughURL varchar(300) = null, 
	@IsRequired bit = 0, 
	@IsReadOnly bit = 1, 
	@PublishDate datetime = null, 
	@ExpireDate datetime = null, 
	@WorkflowStatus varchar(50) = 'WORKING', 
	@UserID int = null, 
	@ActiveFlag bit = 1, 
	@MarkedForDeletion bit = 0, 
	@JobID int = null,
	@PageID int OUTPUT
as
begin

-- history:	Kelly Roe    12/13/2006   - added friendly url record add

	if(@PageTitle = null or len(ltrim(rtrim(@PageTitle))) = 0)
	begin
		print 'A page title is required'
		return 0
	end
	else if(@BusUnitID = null or @BusUnitID = 0)
	begin
		print 'A business unit is required'
		return 0
	end
	else if(@JobID is null or @JobId = 0)
	begin
		print 'A deployment job is required'
		return 0
	end
	
	if(@MetaKeywords is null or len(ltrim(rtrim(@MetaKeywords))) = 0)
	begin
		if (@BusUnitID > 0 and @MarketId = 0)
		begin	
			-- get keywords from the business home page and pull them over as a snapshot
			select 	@MetaKeywords = MetaKeywords
			from 	tblPage
			where 	BusinessUnitID = @BusUnitID
			and	UPPER(PageType) = 'BUSINESS HOME'
		end
		else if (@BusUnitID > 0 and @MarketId > 0)
		begin
			-- get keywords from the market home page and pull them over as a snapshot
			select 	@MetaKeywords = MetaKeywords
			from 	tblPage
			where 	BusinessUnitID = @BusUnitID
			and	MarketID = @MarketID
			and	UPPER(PageType) = 'MARKET HOME'
		end
	end
	
	if(@MetaDescription is null or len(ltrim(rtrim(@MetaDescription))) = 0)
	begin
		if (@BusUnitID > 0 and @MarketId = 0)
		begin	
			-- get description from business home page and pull them over as a snapshot
			select 	@MetaDescription = MetaDescription
			from 	tblPage
			where 	BusinessUnitID = @BusUnitID
			and	UPPER(PageType) = 'BUSINESS HOME'
		end
		else if (@BusUnitID > 0 and @MarketId > 0)
		begin
			-- get description from market home page and pull them over as a snapshot
			select 	@MetaDescription = MetaDescription
			from 	tblPage
			where 	BusinessUnitID = @BusUnitID
			and	MarketID = @MarketID
			and	UPPER(PageType) = 'MARKET HOME'
		end
	end
	
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
	
	declare @errorcode int
	select @errorcode = @@error
	
	if (@errorcode = 0)
	begin
		insert into tblPage (MarketID, BusinessUnitID, PageType, PageTitle, MetaKeywords, MetaDescription, PassthroughURL, IsRequired, IsReadOnly, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@MarketID, @BusUnitID, @PageType, @PageTitle, @MetaKeywords, @MetaDescription, @PassthroughURL, @IsRequired, @IsReadOnly, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobID)
	
		select @PageID = @@identity
	end

	declare @IsPetro int
	declare @urlId varchar(500)

	if (@BusUnitID = 0)
	begin
		select @IsPetro = 1
	end
	else
		select @IsPetro = 0
	end

	--if (@errorcode = 0)
	--begin
	--	exec sp__AddURLRewritePath 
	--		@PageID = @PageID,
	--		@ProdCatID = 0,
	--		@UrlPathOverride = '',
	--		@PublishDate = @PublishDate,
	--		@ExpireDate = @ExpireDate,
	--		@WorkflowStatus = @WorkflowStatus,
	--		@UserID = @UserID,
	--		@MarkedForDeletion = @MarkedForDeletion,
	--		@JobID = @JobID,
	--		@IsPetro = @IsPetro,
	--		@UrlRewriteID = @urlId output
		
	--	select @errorcode = @@error
	--end