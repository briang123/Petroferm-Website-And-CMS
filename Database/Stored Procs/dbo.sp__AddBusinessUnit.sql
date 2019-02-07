

CREATE PROCEDURE sp__AddBusinessUnit @BusName VARCHAR(300) = NULL
	,@DocAuth BIT = 0
	,@PublishDate DATETIME = NULL
	,@ExpireDate DATETIME = NULL
	,@WorkflowStatus VARCHAR(50) = 'WORKING'
	,@UserID INT = NULL
	,@ActiveFlag BIT = 1
	,@MarkedForDeletion BIT = 0
	,@JobID INT = NULL
	,@IsPetro BIT = 0
	,@LogoImagePath VARCHAR(500) = NULL
	,@ExistingLogoID INT = 0
	,-- this is if the new bus unit is using an existing image record
	@LogoAltText VARCHAR(200) = NULL
	,@LogoHeight INT = 1
	,@LogoWidth INT = 1
	,@LogoID INT OUTPUT
	,@BusUnitID INT OUTPUT
AS
BEGIN
	/*
created by: Brian Gaines
created on: 11/25/2006
purpose:
	We have the ability to create Petroferm default content pages AND each business unit's 
	content pages that fall under the umbrella of Petroferm. We MUST create the Petroferm 
	default content prior to creating any business units; otherwise, there's no website.
 
	To create a new business unit and all pages required by the business unit there 
	are some pages we default to Petroferm content so that information is brought over 
	from the corporate website. Other assumptions we make in the creation process of this 
	script is the fact that we don't know what graphics will be used for the business unit 
	logo, so we supply placeholder images that will need to be replaced when the user gets 
	into those particular pages to make modifications.

	Note about Petroferm content:
	We will allow a Petroferm user modify certain Petroferm pages, but not create or delete them; 
	therefore, we will have some petroferm data pre-created when the database is migrated to 
	the internal Petroferm server. Also, the terms and conditions page is one that is only 
	controlled (modified) by the Petroferm "business unit". All business divisions of Petroferm 
	will share this same page.
parameters:
	@BusName - Business Unit name (REQUIRED) 
	@PublishDate - The date the content should be viewable on the website (REQUIRED) (not the deployment date)
	@ExpireDate - The date the content should not be viewable on the website (if left NULL, then default = 30 years from publish date)
	@WorkflowStatus - The status of the content in the authoring process (Default = 'WORKING')
	@UserID - User creating the business unit (REQUIRED) 
	@ActiveFlag - Flag indicating whether the content is visible (Default = True/1) 
	@MarkedForDeletion - Flag indicating that the record is to be deleted from the live website when it's deployed (Default = False/0)
	@JobID - Deployment job this process is associated with (REQUIRED) 
	@IsPetro - Flag indicating that we are creating the main Petroferm content (only ran once and from script)
	@LogoImagePath - The path of the logo image to be uploaded
	@LogoAltText - The alternate text of the logo image
	@LogoHeight - The height of the logo image
	@LogoWidth - The width of the logo image
	@LogoID - The business unit ID that was generated should be returned to the calling app
	@BusUnitID - The business unit ID that was generated should be returned to the calling app

script usage syntax:
	declare @retval int,
		@busId int,
		@logoId int
	
	exec @retval = sp__AddBusinessUnit 
			@BusName = '<< Business Unit Name >>', 
			@DocAuth = << Document Authorization Required Flag >>,
			@PublishDate = << date to publish -- specify today for a default >>,
			@ExpireDate = << date to expire -- specify null for default (will be equal to never expire) >>,
			@WorkflowStatus = << status of content in deployment process -- default is 'WORKING' >>,
			@UserId = << CMS User Id >>, 
			@ActiveFlag = << flag indicating whether content should be displayed regardless of workflow status, publish or expire dates -- default is 1 >>,
			@MarkedForDeletion << flag indicating that this record was deleted in the CMS -- default is 0 >>,
			@JobId = << Deployment Job Id >>, 
			@IsPetro = << flag indicating whether to create the Petroferm corporate-level pages -- default is 0 >>, 
			@LogoImagePath = << File Path >>,
			@LogoAltText = << Alt Text >>,
			@LogoHeight = << Logo Height in Pixels >>,
			@LogoWidth = << Logo Width in Pixels >>,
			@LogoID = @logoId OUTPUT
			@BusUnitID = @busId OUTPUT
	
	print cast(@retval as varchar(5))

history:
	Brian Gaines 	(11/25/2006) - Created initial procedure
			(11/26/2006) - Updated procedure to return correct BusID value in @BusUnitID output param. Also, 
					I added the ability to take additional input parameters to allow for more customization.
			(11/28/2006) - Add ability to add the terms and conditions page for Petroferm main site creation only.
			(12/03/2006) - Add relationship between header image for business home page by adding entry into tblPageModuleReln table
	Kelly Roe	(12/15/2006) - Added new parm to handle using an existing logo image for the business unit (it's unlikely but I wanted to handle it anyway)
	Brian Gaines	(1/5/2007) - Updated webform.aspx names and querystring parameters/values
*/
	-- validate the input parameters
	IF (@UserID IS NULL)
	BEGIN
		PRINT 'A user id is required.'
	END
	ELSE IF (@JobID IS NULL)
	BEGIN
		PRINT 'A deployment job id is required.'
	END
	ELSE IF (
			@BusName IS NULL
			OR @BusName = ''
			)
	BEGIN
		PRINT 'A business unit name is required.'
	END
	ELSE
	BEGIN
		-- evaluate input parameters, manipulate values if a null value is passed into proc, or format dates
		IF (@PublishDate IS NULL)
		BEGIN
			SELECT @PublishDate = dbo.fn__GetDateOnly(getdate())
		END
		ELSE
		BEGIN
			SELECT @Publishdate = dbo.fn__GetDateOnly(@PublishDate)
		END

		IF (@ExpireDate IS NULL)
		BEGIN
			SELECT @ExpireDate = dbo.fn__GetDateOnly(dateadd(year, 30, @PublishDate))
		END
		ELSE
		BEGIN
			SELECT @ExpireDate = dbo.fn__GetDateOnly(@ExpireDate)
		END

		DECLARE @errorcode INT
			,@sql VARCHAR(1000)
			,@imageId INT
			,@pageId INT
			,@contentModId INT
			,@imagePlaceholder VARCHAR(50)
			,@petroGeneralInfoPage INT
			,@petroCapabilitiesPage INT
			,@petroHistoryPage INT
			,@petroTitle VARCHAR(50)
			,-- defined just above each sql statement
			@petroContent VARCHAR(8000)
			,-- defined just above each sql statement (grab the first 8000 chars since text data type is not allowed as a local variable)
			@urlPage VARCHAR(50)
			,@pageType VARCHAR(50)
			,@urlId INT -- Rewrite Url Id

		-- intialize some default values
		SELECT @errorcode = @@error
			,@sql = ''
			,@imageId = 0
			,@pageId = 0
			,@contentModId = 0
			,@imagePlaceholder = 'images/spacer.gif'
			,@urlPage = 'Business.aspx?bu=1&pageID=1' -- default to petroferm homepage

		SELECT @petroGeneralInfoPage = CASE p.PageId
				WHEN NULL
					THEN 0
				ELSE p.PageId
				END
		FROM tblPage p
			,tblBusinessUnit b
		WHERE p.BusinessUnitID = b.BusinessUnitID
			AND UPPER(b.BusinessUnitName) = 'PETROFERM INC.'
			AND UPPER(p.PageType) = 'GENERAL CONTENT > ABOUT'

		SELECT @petroCapabilitiesPage = CASE p.PageId
				WHEN NULL
					THEN 0
				ELSE p.PageId
				END
		FROM tblPage p
			,tblBusinessUnit b
		WHERE p.BusinessUnitID = b.BusinessUnitID
			AND UPPER(b.BusinessUnitName) = 'PETROFERM INC.'
			AND UPPER(p.PageType) = 'GENERAL CONTENT > CAPABILITIES'

		SELECT @petroHistoryPage = CASE p.PageId
				WHEN NULL
					THEN 0
				ELSE p.PageId
				END
		FROM tblPage p
			,tblBusinessUnit b
		WHERE p.BusinessUnitID = b.BusinessUnitID
			AND UPPER(b.BusinessUnitName) = 'PETROFERM INC.'
			AND UPPER(p.PageType) = 'GENERAL CONTENT > HISTORY'

		DECLARE @startingTranCount int
		SET @startingTranCount = @@TRANCOUNT

		-- batch all changes into a single transaction so if anything fails, the entire process will be rolled back; otherwise committed.
		IF @startingTranCount > 0
				SAVE TRANSACTION AddBusinessUnitTransPoint
		ELSE
				BEGIN TRANSACTION


		IF (@IsPetro = 1) -- determine if the user wants to create the Petroferm default content
		BEGIN
			-- override any business unit name that was previously specified; we expect certain things to be named the way we have them for this top level content
			SELECT @BusName = 'Petroferm Inc.'

			-- check to see if Petroferm records were already created.
			IF EXISTS (
					SELECT 1
					FROM tblBusinessUnit
					WHERE UPPER(BusinessUnitName) = UPPER(@BusName)
					)
			BEGIN
				PRINT 'The Petroferm Inc. primary business record was already created from an earlier process. You may continue by associating business units to the main Petroferm website.'

				IF @startingTranCount > 0
					ROLLBACK TRANSACTION AddBusinessUnitTransPoint
				ELSE
					ROLLBACK TRANSACTION

				RETURN 0
			END
		END

		-- STEP 1: load logo image into the image table
		IF (@errorcode = 0)
		BEGIN
			-- only insert an image record if an existing one is not being used
			-- AND the image path is not null
			IF (
					@ExistingLogoID = 0
					AND @LogoImagePath IS NOT NULL
					)
			BEGIN
				INSERT INTO tblImage (
					ImagePath
					,Alt
					,Width
					,Height
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					@LogoImagePath
					,@LogoAltText
					,@LogoWidth
					,@LogoHeight
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@JobID
					)

				SELECT @LogoID = @@identity
					,@errorcode = @@error
			END
			ELSE -- set the LogoID to the ExistingLogoID for insert into tblBusinessUnit (which may be 0)
			BEGIN
				SELECT @LogoID = @ExistingLogoID
			END
		END

		-- STEP 2: create a business unit and use the logo image id we just added
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblBusinessUnit (
				BusinessUnitName
				,DocAuthorization
				,LogoImageID
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@BusName
				,@DocAuth
				,@LogoID
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @BusUnitID = @@identity
				,@errorcode = @@error
		END

		-- STEP 3: create a page record and update it with the business unit id we just created
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPage (
				MarketID
				,BusinessUnitID
				,PageType
				,PageTitle
				,MetaKeywords
				,MetaDescription
				,PassthroughURL
				,IsRequired
				,IsReadOnly
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				0
				,@BusUnitID
				,'BUSINESS HOME'
				,'[REPLACE HOME PAGE TITLE]'
				,'[REPLACE KEYWORD TEXT]'
				,'[REPLACE DESCRIPTION TEXT]'
				,NULL
				,1
				,0
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @pageId = @@identity
				,@errorcode = @@error
		END

		--if (@errorcode = 0)
		--begin
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
		--		@IsPetro = @IsPetro,
		--		@UrlRewriteID = @urlId output
		--	select @errorcode = @@error
		--end
		-- STEP 4: create a content module for the default page content
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblContentModule (
				Title
				,Content
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				'[HOME PAGE CONTENT TITLE HERE]'
				,'[HOME PAGE CONTENT HERE]'
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @contentModId = @@identity
				,@errorcode = @@error
		END

		-- STEP 5: create a page module relationship to link the page content from the content module to the page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPageModuleReln (
				PageID
				,SourceID
				,SourceName
				,ModuleOrder
				,ShowTitle
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@pageId
				,@contentModId
				,'CONTENT'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @errorcode = @@error
		END

		-- STEP 6: load a temporary placeholder header image
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblImage (
				ImagePath
				,Alt
				,Width
				,Height
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@imagePlaceholder
				,'[REPLACE ALT TEXT]'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@JobID
				)

			SELECT @imageId = @@identity
				,@errorcode = @@error
		END

		-- STEP 7: load a temporary place holder image into the image table
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblImageModule (
				ImageId
				,ImageType
				,ImageOrder
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@imageId
				,'HEADER IMAGE'
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@JobID
				)

			SELECT @imageId = @@identity
				,@errorcode = @@error
		END

		-- STEP 7.5: associate the header graphic to the page via the tblPageModuleReln table
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPageModuleReln (
				PageID
				,SourceID
				,SourceName
				,ModuleOrder
				,ShowTitle
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@pageId
				,@imageId
				,'HEADER IMAGE'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @errorcode = @@error
		END

		-- STEP 8: create "general info" page
		IF (@errorcode = 0)
		BEGIN
			SELECT @pageType = 'GENERAL CONTENT > ABOUT'

			IF (@IsPetro = 1)
			BEGIN
				SELECT @petroTitle = 'About Petroferm Inc.'
					,@petroContent = '[PAGE CONTENT HERE]'
			END
			ELSE
			BEGIN
				SELECT @petroTitle = cm.Title
					,@petroContent = SUBSTRING(cm.Content, 1, 8000)
				FROM tblContentModule cm
					,tblPageModuleReln r
					,tblPage p
				WHERE p.PageId = r.PageId
					AND r.SourceID = cm.ContentID
					AND UPPER(r.SourceName) = 'CONTENT'
					AND p.PageId = @petroGeneralInfoPage
			END

			INSERT INTO tblPage (
				MarketID
				,BusinessUnitID
				,PageType
				,PageTitle
				,MetaKeywords
				,MetaDescription
				,PassthroughURL
				,IsRequired
				,IsReadOnly
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				0
				,@BusUnitID
				,@pageType
				,@petroTitle
				,'[REPLACE KEYWORD TEXT]'
				,'[REPLACE DESCRIPTION TEXT]'
				,NULL
				,1
				,0
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @pageId = @@identity
				,@errorcode = @@error

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'General.aspx?pageID=' + cast(@pageId AS VARCHAR(10))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'General Info'
					,'General Info Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,1
					,0
					,3
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
					--if (@errorcode = 0)
					--begin
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
					--		@IsPetro = @IsPetro,
					--		@UrlRewriteID = @urlId output
					--	select @errorcode = @@error
					--end
		END

		-- STEP 9: create a content record for the "general info" page (we want to get the petroferm content at this time -- user can override with business unit specific content)
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblContentModule (
				Title
				,Content
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@petroTitle
				,@petroContent
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @contentModId = @@identity
				,@errorcode = @@error
		END

		-- STEP 10: create a relationship between the "general info" content and the page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPageModuleReln (
				PageID
				,SourceID
				,SourceName
				,ModuleOrder
				,ShowTitle
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@pageId
				,@contentModId
				,'CONTENT'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @errorcode = @@error
		END

		-- STEP 11: create "capabilities" page
		IF (@errorcode = 0)
		BEGIN
			SELECT @pageType = 'GENERAL CONTENT > CAPABILITIES'

			IF (@IsPetro = 1)
			BEGIN
				SELECT @petroTitle = 'Manufacturing Capabilities'
					,@petroContent = '[PAGE CONTENT HERE]'
			END
			ELSE
			BEGIN
				SELECT @petroTitle = cm.Title
					,@petroContent = SUBSTRING(cm.Content, 1, 8000)
				FROM tblContentModule cm
					,tblPageModuleReln r
					,tblPage p
				WHERE p.PageId = r.PageId
					AND r.SourceID = cm.ContentID
					AND UPPER(r.SourceName) = 'CONTENT'
					AND p.PageId = @petroCapabilitiesPage
			END

			INSERT INTO tblPage (
				MarketID
				,BusinessUnitID
				,PageType
				,PageTitle
				,MetaKeywords
				,MetaDescription
				,PassthroughURL
				,IsRequired
				,IsReadOnly
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				0
				,@BusUnitID
				,@pageType
				,@petroTitle
				,'[REPLACE KEYWORD TEXT]'
				,'[REPLACE DESCRIPTION TEXT]'
				,NULL
				,1
				,0
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @pageId = @@identity
				,@errorcode = @@error

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'General.aspx?pageID=' + cast(@pageId AS VARCHAR(10))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'Capabilities'
					,'Capabilities Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,2
					,0
					,3
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
					--if (@errorcode = 0)
					--begin
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
					--		@IsPetro = @IsPetro,
					--		@UrlRewriteID = @urlId output
					--	select @errorcode = @@error
					--end
		END

		-- STEP 12: create a content record for the "capabilities" page (we want to get the petroferm content at this time -- user can override with business unit specific content)
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblContentModule (
				Title
				,Content
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@petroTitle
				,@petroContent
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @contentModId = @@identity
				,@errorcode = @@error
		END

		-- STEP 13: create a relationship between the "capabilities" content and the page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPageModuleReln (
				PageID
				,SourceID
				,SourceName
				,ModuleOrder
				,ShowTitle
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@pageId
				,@contentModId
				,'CONTENT'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @errorcode = @@error
		END

		-- STEP 14: create "company history" page
		IF (@errorcode = 0)
		BEGIN
			SELECT @pageType = 'GENERAL CONTENT > HISTORY'

			IF (@IsPetro = 1)
			BEGIN
				SELECT @petroTitle = 'Company History'
					,@petroContent = '[PAGE CONTENT HERE]'
			END
			ELSE
			BEGIN
				SELECT @petroTitle = cm.Title
					,@petroContent = SUBSTRING(cm.Content, 1, 8000)
				FROM tblContentModule cm
					,tblPageModuleReln r
					,tblPage p
				WHERE p.PageId = r.PageId
					AND r.SourceID = cm.ContentID
					AND UPPER(r.SourceName) = 'CONTENT'
					AND p.PageId = @petroHistoryPage
			END

			INSERT INTO tblPage (
				MarketID
				,BusinessUnitID
				,PageType
				,PageTitle
				,MetaKeywords
				,MetaDescription
				,PassthroughURL
				,IsRequired
				,IsReadOnly
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				0
				,@BusUnitID
				,@pageType
				,@petroTitle
				,'[REPLACE KEYWORD TEXT]'
				,'[REPLACE DESCRIPTION TEXT]'
				,NULL
				,1
				,0
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @pageId = @@identity
				,@errorcode = @@error

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'General.aspx?pageID=' + cast(@pageId AS VARCHAR(10))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'Company History'
					,'Company History Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,3
					,0
					,3
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
					--if (@errorcode = 0)
					--begin
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
					--		@IsPetro = @IsPetro,
					--		@UrlRewriteID = @urlId output
					--	select @errorcode = @@error
					--end
		END

		-- STEP 15: create a content record for the "company history" page (we want to get the petroferm content at this time -- user can override with business unit specific content)
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblContentModule (
				Title
				,Content
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@petroTitle
				,@petroContent
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @contentModId = @@identity
				,@errorcode = @@error
		END

		-- STEP 16: create a relationship between the "company history" content and the page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPageModuleReln (
				PageID
				,SourceID
				,SourceName
				,ModuleOrder
				,ShowTitle
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@pageId
				,@contentModId
				,'CONTENT'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @errorcode = @@error
		END

		-- STEP 17: create "our location" page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPage (
				MarketID
				,BusinessUnitID
				,PageType
				,PageTitle
				,MetaKeywords
				,MetaDescription
				,PassthroughURL
				,IsRequired
				,IsReadOnly
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				0
				,@BusUnitID
				,'GENERAL CONTENT'
				,'Contact Us'
				,'[REPLACE KEYWORD TEXT]'
				,'[REPLACE DESCRIPTION TEXT]'
				,NULL
				,1
				,0
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @pageId = @@identity
				,@errorcode = @@error

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'Contact.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + '&type=location&ref=' + cast(@BusUnitID AS VARCHAR(5)) + ',0,' + cast(@pageId AS VARCHAR(5))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'Our Location'
					,'Our Location Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,1
					,0
					,4
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
					--if (@errorcode = 0)
					--begin
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
					--		@IsPetro = @IsPetro,
					--		@UrlRewriteID = @urlId output
					--	select @errorcode = @@error
					--end
		END

		-- STEP 18: create a content record for the "our location" page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblContentModule (
				Title
				,Content
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				'Contact Us'
				,'[PAGE CONTENT HERE]'
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @contentModId = @@identity
				,@errorcode = @@error
		END

		-- STEP 19: create a relationship between the "our location" content and the page
		IF (@errorcode = 0)
		BEGIN
			INSERT INTO tblPageModuleReln (
				PageID
				,SourceID
				,SourceName
				,ModuleOrder
				,ShowTitle
				,PublishDate
				,ExpirationDate
				,WorkflowStatus
				,LastModifiedBy
				,ActiveFlag
				,MarkedForDeletion
				,DeploymentJobID
				)
			VALUES (
				@pageId
				,@contentModId
				,'CONTENT'
				,1
				,1
				,@PublishDate
				,@ExpireDate
				,@WorkflowStatus
				,@UserID
				,@ActiveFlag
				,@MarkedForDeletion
				,@jobId
				)

			SELECT @errorcode = @@error
		END

		-- STEP 20: create "request information" page
		IF (@errorcode = 0)
		BEGIN
			SELECT @sql = 'insert into tblPage (MarketID, BusinessUnitID, PageType, PageTitle, MetaKeywords, MetaDescription, PassthroughURL, IsRequired, IsReadOnly, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID) '

			SELECT @sql = @sql + 'values (0,' + cast(@BusUnitID AS VARCHAR(5)) + ',''PASSTHROUGH'',''Request Information'',NULL,NULL,''Contact.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + '&type=request'',1,1,''' + convert(VARCHAR(25), @PublishDate, 101) + ''',''' + convert(VARCHAR(25), @ExpireDate, 101) + ''',''' + @WorkflowStatus + ''',' + cast(@userId AS VARCHAR(5)) + ',1,0,' + cast(@jobId AS VARCHAR(5)) + ')'

			EXEC (@sql)

			SELECT @pageId = @@identity
				,@errorcode = @@error
				,@sql = ''

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'Contact.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + '&type=request&ref=' + cast(@BusUnitID AS VARCHAR(5)) + ',0,' + cast(@pageId AS VARCHAR(5))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'Request Information'
					,'Request Information Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,2
					,0
					,4
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
		END

		--if (@errorcode = 0)
		--begin
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
		--		@IsPetro = @IsPetro,
		--		@UrlRewriteID = @urlId output
		--	select @errorcode = @@error
		--end
		-- STEP 21: create "provide feedback" page
		IF (@errorcode = 0)
		BEGIN
			SELECT @sql = 'insert into tblPage (MarketID, BusinessUnitID, PageType, PageTitle, MetaKeywords, MetaDescription, PassthroughURL, IsRequired, IsReadOnly, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID) '

			SELECT @sql = @sql + 'values (0,' + cast(@BusUnitID AS VARCHAR(5)) + ',''PASSTHROUGH'',''Provide Feedback'',NULL,NULL,''Contact.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + '&type=feedback'',1,1,''' + convert(VARCHAR(25), @PublishDate, 101) + ''',''' + convert(VARCHAR(25), @ExpireDate, 101) + ''',''' + @WorkflowStatus + ''',' + cast(@userId AS VARCHAR(5)) + ',1,0,' + cast(@jobId AS VARCHAR(5)) + ')'

			EXEC (@sql)

			SELECT @pageId = @@identity
				,@errorcode = @@error
				,@sql = ''

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'Contact.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + '&type=feedback&ref=' + cast(@BusUnitID AS VARCHAR(5)) + ',0,' + cast(@pageId AS VARCHAR(5))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'Provide Feedback'
					,'Provide Feedback Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,3
					,0
					,4
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
		END

		--if (@errorcode = 0)
		--begin
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
		--		@IsPetro = @IsPetro,
		--		@UrlRewriteID = @urlId output
		--	select @errorcode = @@error
		--end
		-- STEP 22: create "information/sample requests" page
		IF (@errorcode = 0)
		BEGIN
			SELECT @sql = 'insert into tblPage (MarketID, BusinessUnitID, PageType, PageTitle, MetaKeywords, MetaDescription, PassthroughURL, IsRequired, IsReadOnly, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID) '

			SELECT @sql = @sql + 'values (0,' + cast(@BusUnitID AS VARCHAR(5)) + ',''PASSTHROUGH'',''Information/Sample Requests'',NULL,NULL,''Register.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + ''',0,1,''' + convert(VARCHAR(25), @PublishDate, 101) + ''',''' + convert(VARCHAR(25), @ExpireDate, 101) + ''',''' + @WorkflowStatus + ''',' + cast(@userId AS VARCHAR(5)) + ',1,0,' + cast(@jobId AS VARCHAR(5)) + ')'

			EXEC (@sql)

			SELECT @pageId = @@identity
				,@errorcode = @@error
				,@sql = ''

			IF (@errorcode = 0)
			BEGIN
				SELECT @urlPage = 'Register.aspx?bu=' + cast(@BusUnitID AS VARCHAR(5)) + '&ref=' + cast(@BusUnitID AS VARCHAR(5)) + ',0,' + cast(@pageId AS VARCHAR(5))

				-- add an entry into the side navigation table
				INSERT INTO tblSideNav (
					ProdCatID
					,Title
					,[Description]
					,URL
					,BusinessUnitID
					,MarketID
					,PageID
					,ItemOrder
					,Parent
					,SectionID
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,'Information/Sample Request'
					,'Information/Sample Request Side Nav LinkText'
					,@urlPage
					,@BusUnitID
					,0
					,@pageId
					,1
					,0
					,5
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @errorcode = @@error
			END
		END

		--if (@errorcode = 0)
		--begin
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
		--		@IsPetro = @IsPetro,
		--		@UrlRewriteID = @urlId output
		--	select @errorcode = @@error
		--end
		IF (@IsPetro = 1)
		BEGIN
			IF (@errorcode = 0)
			BEGIN
				SELECT @pageType = 'GENERAL CONTENT > TERMS'
					,@petroTitle = 'Terms and Conditions'
					,@petroContent = '[PAGE CONTENT HERE]'

				-- STEP 23: create "terms & conditions" page (PETROFERM LEVEL PAGE ONLY) -- NO SIDE NAV RECORD FOR THIS PAGE
				INSERT INTO tblPage (
					MarketID
					,BusinessUnitID
					,PageType
					,PageTitle
					,MetaKeywords
					,MetaDescription
					,PassthroughURL
					,IsRequired
					,IsReadOnly
					,PublishDate
					,ExpirationDate
					,WorkflowStatus
					,LastModifiedBy
					,ActiveFlag
					,MarkedForDeletion
					,DeploymentJobID
					)
				VALUES (
					0
					,@BusUnitID
					,@pageType
					,@petroTitle
					,'[REPLACE KEYWORD TEXT]'
					,'[REPLACE DESCRIPTION TEXT]'
					,NULL
					,1
					,0
					,@PublishDate
					,@ExpireDate
					,@WorkflowStatus
					,@UserID
					,@ActiveFlag
					,@MarkedForDeletion
					,@jobId
					)

				SELECT @pageId = @@identity
					,@errorcode = @@error

				-- STEP 24: create a content record for the "terms and conditions" page
				IF (@errorcode = 0)
				BEGIN
					INSERT INTO tblContentModule (
						Title
						,Content
						,PublishDate
						,ExpirationDate
						,WorkflowStatus
						,LastModifiedBy
						,ActiveFlag
						,MarkedForDeletion
						,DeploymentJobID
						)
					VALUES (
						@petroTitle
						,@petroContent
						,@PublishDate
						,@ExpireDate
						,@WorkflowStatus
						,@UserID
						,@ActiveFlag
						,@MarkedForDeletion
						,@jobId
						)

					SELECT @contentModId = @@identity
						,@errorcode = @@error
				END

				-- STEP 25: create a relationship between the "terms and condition" content and the page
				IF (@errorcode = 0)
				BEGIN
					INSERT INTO tblPageModuleReln (
						PageID
						,SourceID
						,SourceName
						,ModuleOrder
						,ShowTitle
						,PublishDate
						,ExpirationDate
						,WorkflowStatus
						,LastModifiedBy
						,ActiveFlag
						,MarkedForDeletion
						,DeploymentJobID
						)
					VALUES (
						@pageId
						,@contentModId
						,'CONTENT'
						,1
						,1
						,@PublishDate
						,@ExpireDate
						,@WorkflowStatus
						,@UserID
						,@ActiveFlag
						,@MarkedForDeletion
						,@jobId
						)

					SELECT @errorcode = @@error
				END
						--if (@errorcode = 0)
						--begin
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
						--		@IsPetro = @IsPetro,
						--		@UrlRewriteID = @urlId output
						--	select @errorcode = @@error
						--end
			END
		END

		-- determine if there were any errors during our processing and rollback if there were, thus not creating any records in any tables; however,
		-- if all sql statement executions were successful then commit the batch of inserts to the database.
		IF (@errorcode <> 0)
		BEGIN
			PRINT 'An error occurred while creating a new business unit. The creation process will be rolled back to its original state.'

			IF @startingTranCount > 0
				ROLLBACK TRANSACTION AddBusinessUnitTransPoint
			ELSE
				ROLLBACK TRANSACTION

			RETURN 0
		END

		PRINT 'The business unit was create successfully.'

		IF @startingTranCount = 0
			COMMIT TRANSACTION
			RETURN 1

	END
END