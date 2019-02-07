





CREATE      PROC sp__AddMarket
	@UserID int = null,
	@JobID int = null,
	@BusID int = null,
	@MktName varchar(300) = null,
	@MktOrder int = 1,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@ActiveFlag bit = 1,
	@MarkedForDeletion bit = 0,
	@MktID int OUTPUT
as
begin

/*
created by: Brian Gaines
created on: 11/25/2006
purpose:
	To create a new market and define the default navigational elements.

parameters:
	@UserID - User creating the business unit (REQUIRED) 
	@JobID - Deployment job this process is associated with (REQUIRED) 
	@BusID - Business Unit ID (REQUIRED) 
	@MktName - Market Name being created (REQUIRED)
	@MktOrder - Order in which the Market appears from Left-to-Right on the top navigation menu (REQUIRED / DEFAULT = 1)
	@PublishDate - The date the content should be viewable on the website (REQUIRED) (not the deployment date)
	@ExpireDate - The date the content should not be viewable on the website (if left NULL, then default = 30 years from publish date)
	@WorkflowStatus - The status of the content in the authoring process (Default = 'WORKING')
	@ActiveFlag - Flag indicating whether the content is visible (Default = True/1) 
	@MarkedForDeletion - Flag indicating that the record is to be deleted from the live website when it's deployed (Default = False/0)
	@MktID - The Market ID that was generated should be returned to the calling app

script usage syntax:
	declare @retval int,
		@mktId int
	
	exec @retval = sp__CreateMarket
			@userId = << CMS User Id >>, 
			@jobId = << Deployment Job Id >>, 
			@BusID = << Business Unit ID >>,
			@MktName = '<< Market Name >>',
			@MktOrder = << Market placement order (L-to-R) >>,
			@PublishDate = << date to publish -- specify today for a default >>,
			@ExpireDate = << date to expire -- specify null for default (will be equal to never expire) >>,
			@WorkflowStatus = << status of content in deployment process -- default is 'WORKING' >>,
			@ActiveFlag = << flag indicating whether content should be displayed regardless of workflow status, publish or expire dates -- default is 1 >>,
			@MarkedForDeletion << flag indicating that this record was deleted in the CMS -- default is 0 >>,
			@MktId = @mktId OUTPUT
	
	print cast(@retval as varchar(5))

script test data:
	declare @retval int,
		@mktId int
	
	exec @retval = sp__CreateMarket
			@userId = 1, 
			@jobId = 1, 
			@BusID = 2,
			@MktName = 'TEST MARKET A',
			@MktOrder = 1,
			@MktId = @mktId OUTPUT
	
	print cast(@retval as varchar(5))

history:
	Brian Gaines 	(11/25/2006) - Created initial procedure
			(11/26/2006) - Updated procedure to allow for more parameter inputs
			(12/03/2006) - Increment the module order for Nav Off image
*/

-- validate the input parameters
if (@UserID is null)
  begin
	print 'A user id is required.'
  end
else if (@JobID is null)
  begin
	print 'A deployment job id is required.'
  end	
else if (@BusID is null)
  begin
	print 'A business unit id is required.'
  end
else if (@MktName is null or @MktName = '')
  begin
	print 'A business unit name is required.'
  end
else
  begin

	-- evaluate input parameters, manipulate values if a null value is passed into proc, or format dates
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

	declare @errorcode int,
		@sql varchar(1000),
		@imageId int,
		@imageModId int,
		@pageId int,
		@contentModId int,
		@imagePlaceholder varchar(50),
		@urlPage varchar(50),
		@pageType varchar(50)

	-- intialize some default values
	select 	@errorcode = @@error,
		@sql = '',
		@imageId = 0,
		@pageId = 0,
		@contentModId = 0,
		@imagePlaceholder = 'images/spacer.gif',
		@urlPage = 'Market.aspx'

	-- batch all changes into a single transaction so if anything fails, the entire process will be rolled back; otherwise committed.
	begin tran

	-- STEP 1: create a market record
	insert into tblMarket (BusinessUnitID, MarketName, MarketOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
	values (@BusID, @MktName, @MktOrder, @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobId)
		
	select 	@MktId = @@identity,
		@errorcode = @@error

	-- STEP 2: create a page record and update it with the market id we just created
	if (@errorcode = 0)
	begin
		insert into tblPage (MarketID, BusinessUnitID, PageType, PageTitle, MetaKeywords, MetaDescription, PassthroughURL, IsRequired, IsReadOnly, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@MktId,@busId,'MARKET HOME','[REPLACE MARKET HOME PAGE TITLE]','[REPLACE KEYWORD TEXT]','[REPLACE DESCRIPTION TEXT]',NULL,1,0,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@jobId)

		select 	@pageId = @@identity,
			@errorcode = @@error		
	end	

	-- STEP 3: create an image record for the navigation ON image
	if (@errorcode = 0)
	begin	
		insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@imagePlaceholder,@MktName,1,1,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@JobID)
		
		select 	@imageId = @@identity,
			@errorcode = @@error
	end
	
	-- STEP 4: create a relationship record for the navigation ON image
	if (@errorcode = 0)
	begin	
		insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@imageId,'NAVIGATION ON',1,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@JobID)
		
		select 	@imageModId = @@identity,
			@errorcode = @@error
	end

	-- STEP 5: create a relationship record between the market landing page and the navigation ON image
	if (@errorcode = 0)
	begin	
		insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@pageId,@imageModId,'NAV ON IMAGE',1,1,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@JobID)
		
		select 	@imageModId = @@identity,
			@errorcode = @@error
	end

	-- STEP 6: create an image record for the navigation OFF image
	if (@errorcode = 0)
	begin	
		insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@imagePlaceholder,@MktName,1,1,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@JobID)
		
		select 	@imageId = @@identity,
			@errorcode = @@error
	end
	
	-- STEP 7: create a relationship record for the navigation OFF image	
	if (@errorcode = 0)
	begin	
		insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@imageId,'NAVIGATION OFF',2,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@JobID)
		
		select 	@imageModId = @@identity,
			@errorcode = @@error
	end

	-- STEP 8: create a relationship record between the market landing page and the navigation OFF image
	if (@errorcode = 0)
	begin	
		insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@pageId,@imageModId,'NAV OFF IMAGE',2,1,@publishDate,@expireDate,@WorkflowStatus,@UserID, @ActiveFlag, @MarkedForDeletion,@JobID)
		
		select 	@imageModId = @@identity,
			@errorcode = @@error
	end

	-- STEP 9: create an image record for the market landing page header image
	if (@errorcode = 0)
	begin	
		insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@imagePlaceholder,@MktName, 1, 1, @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobID)
		
		select 	@imageId = @@identity, 
			@errorcode = @@error
	end
	
	-- STEP 10: create a relationship record for the market landing page header image
	if (@errorcode = 0)
	begin	
		insert into tblImageModule (ImageID, ImageType, ImageOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@imageId,'HEADER', 1, @publishDate, @expireDate,@WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobID)
		
		select 	@imageModId = @@identity,
			@errorcode = @@error
	end

	-- STEP 11: create a relationship record between the market landing page and the navigation ON image
	if (@errorcode = 0)
	begin	
		insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@pageId, @imageModId, 'HEADER IMAGE', 1, 1, @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobID)
		
		select 	@imageModId = @@identity,
			@errorcode = @@error
	end

	-- STEP 12: create a content module for the default market landing page content
	if (@errorcode = 0)
	begin
		insert into tblContentModule (Title, Content, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values ('[HOME PAGE CONTENT TITLE HERE]', '[HOME PAGE CONTENT HERE]', @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @jobId)

		select 	@contentModId = @@identity,
			@errorcode = @@error		
	end	

	-- STEP 13: create a page module relationship to link the page content from the content module to the page
	if (@errorcode = 0)
	begin
		insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@pageId, @contentModId, 'CONTENT', 1, 1, @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @jobId)

		select 	@errorcode = @@error
	end	

	-- STEP 14: create a header side content module for the default page content
	if (@errorcode = 0)
	begin
		
		insert into tblHeaderSideContentModule (Title, LineText1, InternalLink1, InternalLink1Type, ExternalLink1, LineText2, InternalLink2, InternalLink2Type, ExternalLink2, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
			values ('Market Landing Page Header Side Content', 'To visit the Petroferm home page click here.', 1, 'PAGE', NULL, 'To visit the Petroferm home page click here.', 1, 'PAGE', NULL, @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @jobId)

		select 	@contentModId = @@identity,
			@errorcode = @@error		
	end	

	-- STEP 15: create a page module relationship to link the page content from the header side content module to the page
	if (@errorcode = 0)
	begin
		insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@pageId, @contentModId, 'HEADER SIDE CONTENT', 1, 0, @publishDate, @expireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @jobId)

		select 	@errorcode = @@error
	end	

	--if (@errorcode = 0)
	--begin
	--	declare @urlId int
	--	exec sp__AddURLRewritePath 
	--		@PageID = @pageID,
	--		@ProdCatID = 0,
	--		@UrlPathOverride = '',
	--		@PublishDate = @PublishDate,
	--		@ExpireDate = @ExpireDate,
	--		@WorkflowStatus = @WorkflowStatus,
	--		@UserID = @UserID,
	--		@MarkedForDeletion = @MarkedForDeletion,
	--		@JobID = @JobID,
	--		@IsPetro = 0, -- hard code because petroferm does not have markets
	--		@UrlRewriteID = @urlId output
		
	--	select @errorcode = @@error
	--end

	-- determine if there were any errors during our processing and rollback if there were, thus not creating any records in any tables; however,
	-- if all sql statement executions were successful then commit the batch of inserts to the database.
	if (@errorcode <> 0)
	begin
		print 'An error occurred while creating a new market. The creation process will be rolled back to its original state.'
		rollback tran
		return 0
	end
	else
	begin
		print 'The market was create successfully.'
		commit tran
		return 1
	end

  end
end